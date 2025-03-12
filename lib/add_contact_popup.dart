import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Method to have popup for new contact dialog
void addContactDialog(BuildContext context) {
  //Controllers to edit dialog
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController numCtrl = TextEditingController();

  //Popup
  showDialog(
      context: context,
      builder: (BuildContext context)
  {
    return AlertDialog(
      title: Text("Add New Contact"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: numCtrl,
            decoration: InputDecoration(labelText: "Phone Number"),
            keyboardType: TextInputType.phone, //error checking phone number
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
              //Getting values from text box
              String name = nameCtrl.text.trim();
              String num = numCtrl.text.trim();

              //Error checking before adding to database
              if (name.isNotEmpty && num.isNotEmpty) {
                //Adding new contact to database
                await FirebaseFirestore.instance.collection('contacts').add({
                  'name': name,
                  'phoneNumber': num,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            child: Text("Save")
          ),
        ],
      );
    },
  );
}