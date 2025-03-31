import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/device_id_service.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Retrieves username
  Future<String?> getUserName() async {
    try {
      String deviceId = await getOrGenDeviceId();
      DocumentSnapshot doc = await firestore.collection(deviceId).doc('settings').get();

      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['userName'];
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return null; // Return null if not found
  }

  //Retrieves crash message
  Future<String?> getCrashMsg() async {
    try {
      String deviceId = await getOrGenDeviceId();
      DocumentSnapshot doc = await firestore.collection(deviceId).doc('settings').get();

      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['message'];
      }
      else {
        return ""; //Default message
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return null; // Return null if not found
  }

  //Retrieves phone numbers of emergency contacts
  Future<List<String?>?> getEmergencyContactNumbers() async {
    List<String> phoneNums = [];

    try {
      String deviceId = await getOrGenDeviceId();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(deviceId)
          .doc('contacts')
          .collection('list')
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('phoneNumber')) {
          phoneNums.add(data['phoneNumber']);
        }
      }
      return phoneNums;
    } catch (e) {
      print("Error fetching username: $e");
    }
    return null; // Return null if not found
  }

  //Retrieves current mode of helmet (safe/crash)
  Future<String?> getMode() async {
    try {
      String deviceId = await getOrGenDeviceId();
      DocumentSnapshot doc = await firestore.collection(deviceId).doc('settings').get();

      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['mode'];
      }
      else {
        return "safe"; //Default message
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return null; // Return null if not found
  }
}