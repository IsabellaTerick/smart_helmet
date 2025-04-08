import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/device_id_service.dart';
import '../notifications/notification_manager.dart'; // Import NotificationManager

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
    DocumentSnapshot doc =
        await firestore.collection(deviceId).doc('settings').get();
    if (doc.exists) {
      setState(() {
        crashMsgCtrl.text = doc['message'] ?? '';
      });
    }
  }

  void updateCrashMsg(String newMsg) async {
    // Trim the message to remove leading/trailing spaces and empty lines
    String trimmedMsg = newMsg.trim();

    // Update Firestore with the trimmed message
    await firestore
        .collection(widget.deviceId)
        .doc('settings')
        .set({'message': trimmedMsg});
    print("New crash message: $trimmedMsg");

    // Trigger "Crash message updated!" notification
    final notificationManager =
        Provider.of<NotificationManager>(context, listen: false);
    notificationManager.showNotification(
      message: "Crash message updated!",
      backgroundColor: Colors.grey,
      icon: Icons.edit_note,
    );
    // Update the text field with the trimmed message
    setState(() {
      crashMsgCtrl.text = trimmedMsg;
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
        padding: EdgeInsets.all(15.0),
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Text('Default Crash Message:',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              TextField(
                  controller: crashMsgCtrl,
                  focusNode: _focusNode,
                  onEditingComplete: () {
                    updateCrashMsg(crashMsgCtrl.text);
                    _focusNode.unfocus();
                  },
                  onSubmitted: (value) {
                    updateCrashMsg(value);
                    _focusNode.unfocus();
                  },
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 15),
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.indigo.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          BorderSide(color: Colors.indigo.shade200, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          BorderSide(color: Colors.indigo.shade400, width: 2.0),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    hintText: 'Enter custom crash message...',
                    hintStyle:
                        TextStyle(fontFamily: 'Nunito', color: Colors.black38),
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
