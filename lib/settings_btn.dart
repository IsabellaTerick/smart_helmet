import 'package:flutter/material.dart';
import './edit_settings_popup.dart';

class EditSettingsBtn extends StatelessWidget {
  const EditSettingsBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings),
      color: Colors.black45,
      onPressed: () {
        editUserSettings(context);
      }
    );
  }
}