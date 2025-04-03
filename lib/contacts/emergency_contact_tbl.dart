import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/device_id_service.dart';
import './contact_service.dart'; // Import contact service

class EmergencyContactTbl extends StatelessWidget {
  EmergencyContactTbl({super.key});

  // Firebase instance to get real-time updates to the table
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  'Emergency Contacts:',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    // Fixed header
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        color: Colors.grey[600],
                      ),
                      child: Table(
                        columnWidths: {
                          0: const FixedColumnWidth(139),
                          1: const FixedColumnWidth(139),
                          2: const FixedColumnWidth(100),
                        },
                        border: TableBorder(
                          horizontalInside: BorderSide(color: Colors.black, width: 1),
                          verticalInside: BorderSide(color: Colors.black, width: 1),
                          top: BorderSide(color: Colors.black, width: 1),
                          bottom: BorderSide(color: Colors.black, width: 1),
                          left: BorderSide(color: Colors.black, width: 1),
                          right: BorderSide(color: Colors.black, width: 1),
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[600]),
                            children: [
                              tableCell(const Text('Name'), isHeader: true),
                              tableCell(const Text('Phone Number'), isHeader: true),
                              tableCell(const Text('Actions'), isHeader: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Scrollable table body
                    Expanded(
                      child: StreamBuilder(
                        stream: firestore.collection(deviceId).doc('contacts').collection('list').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            // No contacts -- show example row
                            return SingleChildScrollView(
                              child: Table(
                                border: TableBorder.all(),
                                columnWidths: {
                                  0: const FixedColumnWidth(139),
                                  1: const FixedColumnWidth(139),
                                  2: const FixedColumnWidth(100),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      tableCell(const Text('Example Name')),
                                      tableCell(const Text('123-456-7890')),
                                      tableCell(Icon(Icons.delete, color: Colors.transparent)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }

                          var contacts = snapshot.data!.docs;
                          return SingleChildScrollView(
                            child: Table(
                              border: TableBorder.all(),
                              columnWidths: {
                                0: const FixedColumnWidth(139),
                                1: const FixedColumnWidth(139),
                                2: const FixedColumnWidth(100),
                              },
                              children: contacts.map((contact) {
                                var contId = contact.id;
                                var contName = contact['name'];
                                var contNum = contact['phoneNumber'];

                                return TableRow(
                                  children: [
                                    tableCell(Text(contName)),
                                    tableCell(Text(contNum)),
                                    tableCell(Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            editContact(
                                              context,
                                              deviceId,
                                              contId,
                                              contName,
                                              contNum,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            deleteContact(context, deviceId, contId, contName);
                                          },
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Code for a table cell
  Widget tableCell(Widget child, {bool isHeader = false}) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black,
        ),
        child: Center(
          child: child is Text
              ? Text(
            child.data!,
            textAlign: TextAlign.center,
            style: child.style,
          )
              : child,
        ),
      ),
    );
  }
}