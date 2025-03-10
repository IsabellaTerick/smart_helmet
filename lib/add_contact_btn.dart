import 'package:flutter/material.dart';
import './add_contact_popup.dart';

class AddContactBtn extends StatelessWidget {
  const AddContactBtn({super.key});

  //Add contact button
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Column(
        children: [
          SizedBox (
            width: double.infinity,
            child: ElevatedButton(onPressed: () {
              //Calling add new contact popup
              addContactDialog(context);
            },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Add New Contact',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 20),
                ))
          )],
      )
    );
  }
}
