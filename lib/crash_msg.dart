import 'package:flutter/material.dart';

class CrashMsg extends StatelessWidget {
  const CrashMsg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            children: [
              Text('Edit Custom Crash Message:'),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Edit Custom Crash Message'
                )
              )
            ]
        )
    );
  }
}
