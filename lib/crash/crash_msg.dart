import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/device_id_service.dart';
import '../notifications/notification_manager.dart';

class CrashMsg extends StatefulWidget {
  final String deviceId;
  const CrashMsg({super.key, required this.deviceId});

  @override
  CrashMsgState createState() => CrashMsgState();
}

class CrashMsgState extends State<CrashMsg> {
  final TextEditingController crashMsgCtrl = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    initCrashMsg();
  }

  @override
  void dispose() {
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
    String trimmedMsg = newMsg.trim();

    if (crashMsgCtrl.text != trimmedMsg) {
      await firestore.collection(widget.deviceId).doc('settings').set({'message': trimmedMsg});
      print("New crash message: $trimmedMsg");

      final notificationManager = Provider.of<NotificationManager>(context, listen: false);
      notificationManager.showNotification(
        message: "Crash message updated!",
        backgroundColor: Colors.grey,
        icon: Icons.edit_note,
      );
    }
    setState(() {
      crashMsgCtrl.text = trimmedMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.indigo[100],
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                children: [
                  // Centered title
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                          'Default Crash Message',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ),
                  // Text field
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
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        hintText: 'Enter custom crash message...',
                        hintStyle: TextStyle(fontFamily: 'Nunito', color: Colors.black38),
                      )
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }
}