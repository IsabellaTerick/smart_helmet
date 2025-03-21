import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/device_id_service.dart';

class CrashMsg extends StatefulWidget {
  final String deviceId;
  const CrashMsg({super.key, required this.deviceId});

  @override
  CrashMsgState createState() => CrashMsgState();
}

class CrashMsgState extends State<CrashMsg> {
  final TextEditingController crashMsgCtrl = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FocusNode _focusNode = FocusNode(); // Add a FocusNode

  @override
  void initState() {
    super.initState();
    initCrashMsg();
  }

  @override
  void dispose() {
    // Dispose the focus node when the widget is disposed
    _focusNode.dispose();
    crashMsgCtrl.dispose();
    super.dispose();
  }

  void initCrashMsg() async {
    String id = await getOrGenDeviceId();
    loadCrashMsg(id);
  }

  void loadCrashMsg(String deviceId) async {
    DocumentSnapshot doc = await firestore.collection(deviceId).doc('settings').get();
    if (doc.exists) {
      setState(() {
        crashMsgCtrl.text = doc['message'] ?? '';
      });
    }
  }

  void updateCrashMsg(String newMsg) async {
    await firestore.collection(widget.deviceId).doc('settings').set({'message': newMsg});
    print("New crash message: $newMsg");
    setState(() {
      crashMsgCtrl.text = newMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Add a GestureDetector to handle taps outside the text field
      onTap: () {
        // Remove focus when tapping outside the text field
        FocusScope.of(context).unfocus();
      },
      child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Text(
                      'Custom Crash Message:',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ),
                TextField(
                    controller: crashMsgCtrl,
                    focusNode: _focusNode, // Assign the focus node
                    onEditingComplete: () {
                      updateCrashMsg(crashMsgCtrl.text);
                      // Unfocus the text field when editing is complete
                      _focusNode.unfocus();
                    },
                    onSubmitted: (value) {
                      // Also handle the onSubmitted event
                      updateCrashMsg(value);
                      _focusNode.unfocus();
                    },
                    textInputAction: TextInputAction.done,
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 15),
                    minLines: 5,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Enter custom crash message...'
                    )
                )
              ]
          )
      ),
    );
  }
}