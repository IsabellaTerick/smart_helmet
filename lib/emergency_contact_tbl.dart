import 'package:flutter/material.dart';

class EmergencyContactTbl extends StatelessWidget {
  const EmergencyContactTbl({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        height: 400,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Phone Number')),
                  DataColumn(label: Text('Contact Method'))
                ],
                rows: List.generate(
                20,
                (index) => DataRow(cells: [
                DataCell(Text('John Smith')),
                DataCell(Text('XXX-XXX-XXXX')),
                DataCell(Text('Text Message')),
                ])
              )
            )
          ));
        }
      ))
    );
  }
}
