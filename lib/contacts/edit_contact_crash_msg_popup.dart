import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifications/notification_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/device_id_service.dart';

// Method to show the popup for editing the crash message
Future<void> editCrashMessageDialog(BuildContext context, String? deviceId, String? contactId) async {
  // Controller for the crash message text field
  TextEditingController msgCtrl = TextEditingController();

  // State for error message
  String? errorMessage;

  // Fetch the current crash message from Firestore
  String? initialCrashMessage;
  try {
    String currentDeviceId = deviceId ?? await getOrGenDeviceId();
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(currentDeviceId)
        .doc('contacts')
        .collection('list')
        .doc(contactId)
        .get();

    if (doc.exists && doc.data() != null) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      initialCrashMessage = data?['customCrashMsg']?.toString().trim();
    }
  } catch (e) {
    print("Error fetching initial crash message: $e");
  }

  // Pre-fill the text field with the current crash message
  msgCtrl.text = initialCrashMessage ?? "";

  // Show the dialog and wait for it to close
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Emergency Message",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "The message will be sent to this emergency contact."
                        "If no message is entered, the default message will be sent",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: TextField(
                      controller: msgCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter your emergency message here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: errorMessage,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: null,
                      minLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            // Get device ID if not provided
                            String currentDeviceId = deviceId ?? await getOrGenDeviceId();

                            // Reference to the contacts collection in Firestore
                            CollectionReference contacts = FirebaseFirestore.instance
                                .collection(currentDeviceId)
                                .doc('contacts')
                                .collection('list');

                            if (contactId != null) {
                              // Update the crash message in Firestore
                              await contacts.doc(contactId).update({
                                'customCrashMsg': null,
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              // Trigger notification
                              final notificationManager =
                              Provider.of<NotificationManager>(context, listen: false);
                              notificationManager.showNotification(
                                message: "Emergency message cleared",
                                backgroundColor: Colors.grey,
                                icon: Icons.message,
                              );
                            }

                            // Close the dialog
                            Navigator.pop(context);
                          } catch (e) {
                            print("Error clearing emergency message: $e");
                            setState(() {
                              errorMessage = "Failed to clear message. Please try again.";
                            });
                          }
                        },
                        child: Text("Clear"),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () async {
                          String crashMessage = msgCtrl.text.trim();
                          if (crashMessage.isEmpty) {
                            setState(() {
                              errorMessage = "Please enter a message";
                            });
                            return;
                          }

                          try {
                            // Get device ID if not provided
                            String currentDeviceId = deviceId ?? await getOrGenDeviceId();

                            // Reference to the contacts collection in Firestore
                            CollectionReference contacts = FirebaseFirestore.instance
                                .collection(currentDeviceId)
                                .doc('contacts')
                                .collection('list');

                            if (contactId != null) {
                              // Update the crash message in Firestore
                              await contacts.doc(contactId).update({
                                'customCrashMsg': crashMessage,
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              // Trigger notification
                              final notificationManager =
                              Provider.of<NotificationManager>(context, listen: false);
                              notificationManager.showNotification(
                                message: "Emergency message updated",
                                backgroundColor: Colors.green,
                                icon: Icons.check_circle,
                              );
                            }

                            // Close the dialog
                            Navigator.pop(context);
                          } catch (e) {
                            print("Error updating emergency message: $e");
                            setState(() {
                              errorMessage = "Failed to update message. Please try again.";
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}