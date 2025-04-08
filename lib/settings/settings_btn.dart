import 'package:flutter/material.dart';
import 'edit_settings_popup.dart';

class EditSettingsBtn extends StatelessWidget {
  const EditSettingsBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.settings,
          size: 30, // Match the size of the help icon
        ),
        color: Colors.black45,
        tooltip: "Settings",
        onPressed: () {
          editUserSettings(context);
        }
    );
  }
}