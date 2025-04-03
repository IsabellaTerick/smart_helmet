import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifications/notification_manager.dart'; // Import NotificationManager
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/device_id_service.dart';
import './add_contact_popup.dart'; // Import the add contact popup
import './delete_confirm_popup.dart'; // Import confirmation dialog

// Function to delete a contact from Firestore
Future<void> deleteContact(BuildContext context, String deviceId, String contId, String contactName) async {
  // Show confirmation dialog
  bool? confirmDelete = await showDeleteConfirmationDialog(context, contactName);

  // If user confirms deletion, proceed
  if (confirmDelete == true) {
    try {
      // Delete the contact from Firestore
      await FirebaseFirestore.instance.collection(deviceId).doc('contacts').collection('list').doc(contId).delete();
      print("Deleted contact");

      // Trigger "Contact deleted" notification
      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
      notificationManager.showNotification(
        message: "Contact deleted",
        backgroundColor: Colors.grey,
        icon: Icons.delete,
      );
    } catch (e) {
      print("Could not delete contact: $e");

      // Trigger failure notification
      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
      notificationManager.showNotification(
        message: "Failed to delete contact",
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }
}

// Function to edit a contact by opening the add/edit contact dialog
void editContact(BuildContext context, String deviceId, String contId, String name, String phoneNumber) {
  // Open the add contact dialog with pre-filled fields
  addContactDialog(context, initialName: name, initialPhoneNumber: phoneNumber, contactId: contId, deviceId: deviceId);
}