import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/device_id_service.dart';
import '../services/firebase_service.dart'; // Import FirebaseService

// Method to show the popup for editing user settings
void editUserSettings(BuildContext context) {
  // Controllers for text fields
  TextEditingController usernameCtrl = TextEditingController();

  // State for the "Enable SMS" checkbox
  bool enableSMS = false;

  // Flag to ensure settings are loaded only once
  bool isSettingsLoaded = false;

  // Load settings from SharedPreferences and Firestore
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    enableSMS = prefs.getBool('enableSMS') ?? false; // Default is unchecked (false)

    FirebaseService firebaseService = FirebaseService();
    String? userName = await firebaseService.getUserName();
    usernameCtrl.text = userName ?? ""; // Pre-fill with current username
  }

  // Save the "Enable SMS" setting to SharedPreferences
  Future<void> saveEnableSMS(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableSMS', value);
  }

  // Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Edit Settings"),
        content: StatefulBuilder(
          builder: (context, setState) {
            // Load settings only once when the dialog is first built
            if (!isSettingsLoaded) {
              isSettingsLoaded = true; // Set the flag to true
              loadSettings().then((_) {
                setState(() {}); // Trigger a rebuild after loading settings
              });
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: enableSMS,
                      onChanged: (value) {
                        if (value != null) {
                          saveEnableSMS(value); // Save the new value
                          setState(() {
                            enableSMS = value; // Update the local state
                          });
                        }
                      },
                    ),
                    const Text("Enable SMS"),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get the username from the text field
              String userName = usernameCtrl.text.trim();

              // Validate input
              if (userName.isEmpty) {
                // Show an error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a name")),
                );
                return;
              }

              try {
                // Get device ID
                String deviceId = await getOrGenDeviceId();

                // Save the username to Firestore
                await FirebaseFirestore.instance.collection(deviceId).doc('settings').set({
                  'userName': userName,
                }, SetOptions(merge: true));

                // Close the dialog
                Navigator.pop(context);
              } catch (e) {
                print("Error saving settings: $e");

                // Show an error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to save settings. Please try again.")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}