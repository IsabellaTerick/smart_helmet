import 'package:flutter/material.dart';

class AddContactBtn extends StatelessWidget {
  const AddContactBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Column(
        children: [
          SizedBox (
            width: double.infinity,
            child: ElevatedButton(onPressed: () {

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
