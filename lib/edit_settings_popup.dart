import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_helmet_v4/main.dart';

//Method to have popup to edit settings
void editUserSettings(BuildContext context) {
  //Controllers to edit dialog
  TextEditingController usernameCtrl = TextEditingController();

  //Popup
  showDialog(
      context: context,
      builder: (BuildContext context)
  {
    return AlertDialog(
      title: Text("Edit Name"),
      content: Column (
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: usernameCtrl,
            decoration: InputDecoration(labelText: "Name"),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel")
        ),
        ElevatedButton(
            onPressed: () async {
              //Getting value from text box
              String userName = usernameCtrl.text.trim();

              //Error checking
              if (userName.isNotEmpty) {
                //Getting deviceId
                String deviceId = await getOrGenDeviceId();

                //Adding username to database
                await FirebaseFirestore.instance.collection(deviceId).doc('settings').set({
                  'userName': userName,
                }, SetOptions(merge: true));
                Navigator.pop(context);
              }
            },
            child: Text("Save")
          ),
        ],
      );
    }
  );
}