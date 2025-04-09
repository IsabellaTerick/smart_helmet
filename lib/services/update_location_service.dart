import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import './device_id_service.dart';
import './location_service.dart';

class UpdateLocationService {
  static final UpdateLocationService _instance = UpdateLocationService._internal();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  // Singleton pattern
  factory UpdateLocationService() {
    return _instance;
  }

  UpdateLocationService._internal();

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await saveDeviceToken(token);
      print('FCM Token: $token');
    }

    // Configure message handling
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      saveDeviceToken(newToken);
    });

    _isInitialized = true;
  }

  // Save device token to Firebase
  Future<void> saveDeviceToken(String token) async {
    try {
      String deviceId = await getOrGenDeviceId();
      await FirebaseFirestore.instance
          .collection(deviceId)
          .doc('settings')
          .set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Device token saved to Firebase');
    } catch (e) {
      print('Error saving device token: $e');
    }
  }

  // Handle incoming FCM messages
  Future<void> _handleMessage(RemoteMessage message) async {
    print('Handling a foreground message: ${message.messageId}');
    print('Message data: ${message.data}');

    if (message.data['type'] == 'location_request') {
      await _processLocationRequest();
    }
  }

  // Process location request and update Firebase
  Future<void> _processLocationRequest() async {
    try {
      // Check if in crash mode
      String deviceId = await getOrGenDeviceId();
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(deviceId)
          .doc('settings')
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String? mode = data['mode']?.toString().trim();

        if (mode == 'crash') {
          // Get current location
          await LocationService.requestLocationPermission();
          Position position = await LocationService.getCurrentPosition();

          // Update in Firebase
          await _updateCurrentLocation(position.latitude, position.longitude);
          print('Updated current location in Firebase');
        } else {
          print('Not in crash mode, location update skipped');
        }
      }
    } catch (e) {
      print('Error processing location request: $e');
    }
  }

  // Update current location in Firebase
  Future<void> _updateCurrentLocation(double latitude, double longitude) async {
    try {
      String deviceId = await getOrGenDeviceId();
      await FirebaseFirestore.instance
          .collection(deviceId)
          .doc('settings')
          .set({
        'currentPosition': GeoPoint(latitude, longitude),
        'positionUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating current location: $e');
    }
  }
}

// This static function needs to be top-level for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to ensure Firebase is initialized
  // This would typically be done in the main() function
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Handling a background message: ${message.messageId}");

  if (message.data['type'] == 'location_request') {
    await UpdateLocationService()._processLocationRequest();
  }
}