import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './add_contact_btn.dart';

class EmergencyContactTbl extends StatelessWidget {
  EmergencyContactTbl({super.key});

  //Firebase instance to get real time updates to table
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Code for deleting the selected contact row from the database
  void deleteSelectedContact(String contId) async {
    try {
      await firestore.collection('contacts').doc(contId).delete();
      print("Deleted contact");
    } catch(e) {
      print("Could not delete contact");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Text(
              'Emergency Contacts:',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 20)
            ),
          ),
        Container(
          height: 300,
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  )
                ),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(139),
                    1: FixedColumnWidth(139),
                    2: FixedColumnWidth(100),
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.black, width: 1),
                    verticalInside: BorderSide(color: Colors.black, width: 1),
                    top: BorderSide(color: Colors.black, width: 1),
                    bottom: BorderSide(color: Colors.black, width: 1),
                    left: BorderSide(color: Colors.black, width: 1),
                    right: BorderSide(color: Colors.black, width: 1)),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[600]),
                      children: [
                        tableCell(Text('Name'), isHeader: true),
                        tableCell(Text('Phone Number'), isHeader: true),
                        tableCell(Text('Actions'), isHeader: true)
                      ],
                    ),
                  ],
                ),
              ),
              // Scrollable table body
              Expanded(
                  //Pulling realtime information from database about contacts
                  child: StreamBuilder(
                    stream: firestore.collection('contacts').snapshots(),
                    builder: (context, snapshot) {

                      //If contacts currently in list
                      var contacts = snapshot.data!.docs;

                      return SingleChildScrollView(
                        child: Table(
                          border: TableBorder.all(),
                          columnWidths: {
                            0: FixedColumnWidth(139),
                            1: FixedColumnWidth(139),
                            2: FixedColumnWidth(100),
                          },
                          children: contacts.isEmpty
                            ?[
                              //No current contacts -- show example row
                              TableRow(
                                children: [
                                  tableCell(Text('Example Name')),
                                  tableCell(Text('123-456-7890')),
                                  tableCell(Icon(
                                      Icons.delete,
                                      color: Colors.transparent))
                                ],
                              )
                            ]
                          : contacts.map((contact) {
                            //Variables related to each contact in table
                            var contId = contact.id;
                            var contName = contact['name'];
                            var contNum = contact['phoneNumber'];

                            return TableRow(
                              children: [
                                tableCell(Text(contName)),
                                tableCell(Text(contNum)),
                                tableCell(IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    deleteSelectedContact(contId);
                                  },
                                ),
                              ),
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
      )
    );
  }


  //Code for a table cell
  Widget tableCell(Widget child, {bool isHeader = false}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.0),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black,
        ),
        child: Center(child: child is Text
          ? Text (
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