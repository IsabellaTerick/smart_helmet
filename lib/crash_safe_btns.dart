import 'package:flutter/material.dart';

class CrashSafeBtns extends StatelessWidget {
  const CrashSafeBtns({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom:10.0, right: 20.0, left: 20.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: () {

              },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                  ),
                  child: Text('CRASH ALERT!',
                          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20))),
            )
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(onPressed: () {

            },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[700],
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  )
                ),
                child: Text('SAFE ALERT!',
                    style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20)))
          )
        ]
      )
    );
  }
}
