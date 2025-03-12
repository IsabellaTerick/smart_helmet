import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrashMsg extends StatefulWidget {
  const CrashMsg({super.key});

  //Getting current state of text message to update
  @override
  CrashMsgState createState() => CrashMsgState();
}

class CrashMsgState extends State<CrashMsg> {
  final TextEditingController crashMsgCtrl = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Initiating initial state for text field
  @override
  void initState() {
    super.initState();
    loadCrashMsg();
  }

  //Getting currently database stored crashMsg
  void loadCrashMsg() async {
    DocumentSnapshot doc = await firestore.collection('settings').doc('crash_msg').get();
    if (doc.exists) {
      setState(() {
        crashMsgCtrl.text = doc['message'] ?? '';
      });
    }
  }

  //Updating with new custom message
  void updateCrashMsg(String newMsg) async {
    //Setting to default if msg is empty
    if(newMsg.isEmpty) {
      newMsg = 'Crash Detected!';
    }

    await firestore.collection('settings').doc('crash_msg').set({'message': newMsg});
    print("new msg $newMsg");

    setState(() {
      crashMsgCtrl.text = newMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child:Text('Edit Custom Crash Message:', style: TextStyle(fontFamily: 'Nunito', fontSize: 20)),
            ),
            TextField(
              controller: crashMsgCtrl,
              onEditingComplete: () { updateCrashMsg(crashMsgCtrl.text); },
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontFamily: 'Nunito'
                , fontSize: 15),
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
