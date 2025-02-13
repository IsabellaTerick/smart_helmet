import 'package:flutter/material.dart';

class AddContactBtn extends StatelessWidget {
  const AddContactBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ElevatedButton(onPressed: null, child: Text('Add New Contact'))
        ],
      )
    );
  }
}
