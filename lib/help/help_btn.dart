import 'package:flutter/material.dart';
import './help_content.dart';

class HelpBtn extends StatelessWidget {
  const HelpBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.help_outline,
        color: Colors.black45,
        size: 30,
      ),
      tooltip: 'Help',
      onPressed: () => _showHelpGuide(context),
    );
  }

  void _showHelpGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const HelpGuideDialog(),
        );
      },
    );
  }
}

class HelpGuideDialog extends StatelessWidget {
  const HelpGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.indigo[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Smart Helmet App Help Guide',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Your Companion for a Safer Ride',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Welcome to the Smart Helmet App Help Guide! This guide is your resource for understanding how your helmet and app work together to help keep you safe and connected. Tap any section to explore more.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Help guide sections
                  HelpContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}