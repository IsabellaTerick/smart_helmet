import 'package:flutter/material.dart';

class CrashMsg extends StatelessWidget {
  const CrashMsg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child:Text('Edit Custom Crash Message:', style: TextStyle(fontFamily: 'Nunito', fontSize: 20)),
            ),
            TextFormField(
              onFieldSubmitted: (String newMsg) {

              },
              style: TextStyle(fontFamily: 'Nunito', fontSize: 15),
              minLines: 5,
              maxLines: 5,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                hintText: 'Edit Custom Crash Message'
              )
            )
          ]
        )
    );
  }
}
