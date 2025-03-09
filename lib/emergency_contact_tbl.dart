import 'package:flutter/material.dart';

class EmergencyContactTbl extends StatelessWidget {
  const EmergencyContactTbl({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Container(
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
                  0: FixedColumnWidth(100),
                  1: FixedColumnWidth(130),
                  2: FixedColumnWidth(150),
                },
                border: TableBorder.all(),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[600]),
                    children: [
                      tableCell('Name', isHeader: true),
                      tableCell('Phone Number', isHeader: true),
                      tableCell('Contact Method', isHeader: true),
                    ],
                  ),
                ],
              ),
            ),
            // Scrollable table body
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(100),
                    1: FixedColumnWidth(130),
                    2: FixedColumnWidth(150),
                  },
                  border: TableBorder.all(),
                  children: List.generate(50, (index) {
                    return TableRow(
                      children: [
                        tableCell('John Smith'),
                        tableCell('XXX-XXX-XXXX'),
                        tableCell('Text Method'),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
