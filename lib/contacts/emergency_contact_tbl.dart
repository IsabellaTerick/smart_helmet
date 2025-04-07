import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/device_id_service.dart';
import './contact_service.dart';
import '../crash/mode_synchronizer.dart';
import '../services/firebase_service.dart';

class EmergencyContactTbl extends StatefulWidget {
  final ModeSynchronizer modeSynchronizer;

  const EmergencyContactTbl({super.key, required this.modeSynchronizer});

  @override
  _EmergencyContactTblState createState() => _EmergencyContactTblState();
}

class _EmergencyContactTblState extends State<EmergencyContactTbl> {
  String _currentMode = "safe";

  @override
  void initState() {
    super.initState();
    widget.modeSynchronizer.modeStream.listen((newMode) {
      setState(() {
        _currentMode = newMode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getOrGenDeviceId(),
      builder: (context, deviceSnapshot) {
        if (!deviceSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        String deviceId = deviceSnapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 350),
            decoration: BoxDecoration(
              color: Colors.white,
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
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(deviceId)
                  .doc('contacts')
                  .collection('list')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyContactsList();
                }

                var contacts = snapshot.data!.docs;
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: contacts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    var contact = contacts[index];
                    var contId = contact.id;
                    var contName = contact['name'];
                    var contNum = contact['phoneNumber'];

                    return _buildContactListTile(
                        context,
                        deviceId,
                        contId,
                        contName,
                        contNum
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyContactsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contact_phone_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No emergency contacts added yet',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add contacts using the button below',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactListTile(
      BuildContext context,
      String deviceId,
      String contactId,
      String name,
      String phoneNumber) {

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        phoneNumber,
        style: TextStyle(
          fontFamily: 'Nunito',
          color: Colors.grey[600],
        ),
      ),
      trailing: _buildActions(context, deviceId, contactId, name, phoneNumber),
    );
  }

  Widget _buildActions(
      BuildContext context,
      String deviceId,
      String contactId,
      String name,
      String phoneNumber) {

    final bool isEditable = _currentMode == "safe";

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Contact Action
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: isEditable ? Colors.blue : Colors.grey,
          ),
          tooltip: 'Edit Contact',
          onPressed: isEditable
              ? () => editContact(
            context,
            deviceId,
            contactId,
            name,
            phoneNumber,
          )
              : null,
        ),

        // Edit Message Action
        IconButton(
          icon: Icon(
            Icons.message_outlined,
            color: isEditable ? Colors.green : Colors.grey,
          ),
          tooltip: 'Edit Message',
          onPressed: isEditable
              ? () async {
            try {
              await editContactCrashMsg(
                  context,
                  deviceId,
                  contactId,
                  name,
                  phoneNumber
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Crash message updated"),
                    backgroundColor: Colors.grey,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to update crash message"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
              : null,
        ),

        // Delete Contact Action
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: isEditable ? Colors.red : Colors.grey,
          ),
          tooltip: 'Delete Contact',
          onPressed: isEditable
              ? () async {
            try {
              await deleteContact(context, deviceId, contactId, name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Contact deleted")),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete contact")),
                );
              }
            }
          }
              : null,
        ),
      ],
    );
  }
}