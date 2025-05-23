import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/device_id_service.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Used for UPDATE polling
  Future<void> registerDevice() async {
    try {
      String deviceId = await getOrGenDeviceId();
      await firestore
          .collection('device_registry')
          .doc(deviceId)
          .set({
        'lastActive': FieldValue.serverTimestamp(),
      });

      print("Device registered in global registry");
    } catch (e) {
      print("Error registering device: $e");
    }
  }


  // Retrieves the username from Firestore
  Future<String?> getUserName() async {
    try {
      String deviceId = await getOrGenDeviceId();
      DocumentSnapshot doc = await firestore.collection(deviceId).doc('settings').get();

      // Check if the document exists and contains valid data
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        String? userName = data?['userName']?.toString().trim();

        if (userName == null || userName.isEmpty) {
          print("Username is null or empty in Firestore.");
        }

        return userName; // Return trimmed string or null
      } else {
        print("Settings document does not exist in Firestore.");
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return null; // Return null if no username is found or an error occurs
  }

  // Retrieves the crash message from Firestore
  Future<String?> getCrashMsg() async {
    try {
      String deviceId = await getOrGenDeviceId();
      DocumentSnapshot doc = await firestore.collection(deviceId).doc('settings').get();

      // Check if the document exists and contains valid data
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['message']?.toString().trim(); // Return trimmed string or null
      }
    } catch (e) {
      print("Error fetching crash message: $e");
    }
    return null; // Return null if no crash message is found or an error occurs
  }

  // Retrieves the phone numbers of emergency contacts from Firestore
  Future<List<String?>?> getEmergencyContactNumbers() async {
    try {
      String deviceId = await getOrGenDeviceId();
      QuerySnapshot snapshot = await firestore
          .collection(deviceId)
          .doc('contacts')
          .collection('list')
          .get();

      // Extract phone numbers from the documents
      List<String?> phoneNums = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('phoneNumber')) {
          phoneNums.add(data['phoneNumber']?.toString().trim()); // Add trimmed string or null
        }
      }
      return phoneNums.isNotEmpty ? phoneNums : null; // Return null if no phone numbers are found
    } catch (e) {
      print("Error fetching emergency contact numbers: $e");
    }
    return null; // Return null if no contacts are found or an error occurs
  }

  // Retrieves the custom crash message for an emergency contact from Firestore
  Future<String?> getContactCustomCrashMsg(String phoneNumber) async {
    try {
      String deviceId = await getOrGenDeviceId();
      QuerySnapshot snapshot = await firestore
          .collection(deviceId)
          .doc('contacts')
          .collection('list')
          .where('phoneNumber', isEqualTo: phoneNumber.trim())
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Extract the data from the first matching document
        Map<String, dynamic>? data =
        snapshot.docs.first.data() as Map<String, dynamic>?;

        // Return the custom crash message if it exists
        return data?['customCrashMsg']?.toString().trim();
      }
    } catch (e) {
      print("Error fetching emergency contact numbers: $e");
    }
    return null; // Return null if no contacts are found or an error occurs
  }

  // Retrieves the current mode of the helmet (safe/crash) from Firestore
  Future<String?> getMode() async {
    try {
      String deviceId = await getOrGenDeviceId();
      DocumentSnapshot doc = await firestore.collection(deviceId).doc('settings').get();

      // Check if the document exists and contains valid data
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['mode']?.toString().trim(); // Return trimmed string or null
      }
    } catch (e) {
      print("Error fetching mode: $e");
    }
    return null; // Return null if no mode is found or an error occurs
  }

  // Retrieves the crash location
  Future<GeoPoint?> getCrashLocation() async {
    try {
      final deviceId = await getOrGenDeviceId();

      DocumentSnapshot snapshot = await firestore
          .collection(deviceId)
          .doc('settings')
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['initialPosition'] as GeoPoint?;
      } else {
        return null;
      }
    } catch (e) {
      print("Failed to retrieve crash location: $e");
      return null;
    }
  }

  // Save crash location to Firestore
  Future<void> saveCrashLocation(double latitude, double longitude) async {
    try {
      String deviceId = await getOrGenDeviceId();
      await firestore
          .collection(deviceId)
          .doc('settings')
          .set({
        'initialPosition': GeoPoint(latitude, longitude),
        'crashTimestamp': FieldValue.serverTimestamp(),
      },
          SetOptions(merge: true));

      print("Saved crash location to Firestore: $latitude, $longitude");
    } catch (e) {
      print("Error saving crash location: $e");
    }
  }

  // Clear crash location from Firestore
  Future<void> clearCrashLocation() async {
    try {
      String deviceId = await getOrGenDeviceId();
      await firestore
          .collection(deviceId)
          .doc('settings')
          .update({
        'initialPosition': FieldValue.delete(),
        'crashTimestamp': FieldValue.delete(),
      });

      print("Cleared crash location from Firestore");
    } catch (e) {
      print("Error clearing crash location: $e");
    }
  }

  // Update mode in Firestore
  Future<void> updateMode(String newMode) async {
    try {
      String deviceId = await getOrGenDeviceId();
      await firestore
          .collection(deviceId)
          .doc('settings')
          .set({'mode': newMode}, SetOptions(merge: true));

      print("Updated Firestore mode to: $newMode");
    } catch (e) {
      print("Error updating Firestore mode: $e");
    }
  }

  // Retrieves a stream of the number of emergency contacts from Firestore
  Stream<int> getEmergencyContactCountStream() async* {
    try {
      // Fetch the device ID asynchronously
      String deviceId = await getOrGenDeviceId();

      // Yield the contact count as a stream
      yield* FirebaseFirestore.instance
          .collection(deviceId)
          .doc('contacts')
          .collection('list')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      print("Error fetching contact count stream: $e");
      yield 0; // Fallback value if an error occurs
    }
  }
}