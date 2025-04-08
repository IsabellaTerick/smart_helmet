import 'package:flutter/material.dart';
import './help_guide.dart';

class HelpContent extends StatelessWidget {
  const HelpContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HelpGuide(
          icon: '🚨',
          title: 'How Crash Detection Works',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The Smart Helmet is designed to automatically alert your emergency contacts if you\'re in a crash. A crash can be detected in one of three ways:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Helmet Impact:', 'Sensors in the helmet detect a significant force.'),
              _buildBulletPoint('Manual Trigger:', 'Hold the helmet\'s physical button for 5 seconds.'),
              _buildBulletPoint('App Trigger:', 'Press the "Crash" button inside the app.'),
              const SizedBox(height: 8),
              const Text(
                'Once triggered, the app will:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('', 'Send a text message to your emergency contacts.'),
              _buildBulletPoint('', 'Include your name (from app settings), a crash message, and a live location link.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '📍',
          title: 'Real-Time Location Updates',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your location is automatically monitored after a crash:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('', 'If you move 0.25 miles from the original crash site, an updated location is sent to all contacts.'),
              _buildBulletPoint('', 'Contacts can also text UPDATE to the system number to get your latest location.'),
              _buildBulletPoint('', 'Once you confirm your safety, location updates stop and contacts can no longer request your location.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '✅',
          title: 'Confirming You\'re Safe',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'When you\'re okay:',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('', 'Tap the "Safe" button in the app.'),
              _buildBulletPoint('', 'Your contacts will be notified that you\'re safe.'),
              _buildBulletPoint('', 'You\'ll then be able to update or modify your emergency contacts again.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '👥',
          title: 'Emergency Contacts',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletPoint('', 'You can add up to 5 emergency contacts.'),
              _buildBulletPoint('', 'Once a crash is detected, contacts cannot be edited until you confirm your safety.'),
              _buildBulletPoint('', 'Each contact can have a custom crash message.'),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: _buildBulletPoint('', 'If no custom message is set, the default crash message will be used.'),
              ),
            ],
          ),
        ),

        HelpGuide(
          icon: '⚙️',
          title: 'App Settings',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletPoint('Your Name:', 'Displayed in crash alert messages.'),
              _buildBulletPoint('Default Crash Message:', 'This message is sent to contacts unless a custom message is set.'),
              _buildBulletPoint('Custom Messages (Optional):', 'Tailor a message for each contact—include reassurance, instructions, or a keyword to signal it\'s not a scam.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '📲',
          title: 'Crash & Safe Buttons',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletPoint('Crash Button:', 'Immediately sends a crash alert to your emergency contacts.'),
              _buildBulletPoint('Safe Button:', 'Sends a safety confirmation and stops location tracking and updates.'),
            ],
          ),
        ),

        HelpGuide(
          icon: '🛠',
          title: 'Getting Started',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNumberedPoint(1, 'Set Up Your Profile:', 'Add your name and a default crash message in Settings.'),
              _buildNumberedPoint(2, 'Add Emergency Contacts:', 'Enter up to 5 people with their names and phone numbers. Customize their messages if desired.'),
              _buildNumberedPoint(3, 'Test the System:', 'Try the Crash and Safe buttons to see how alerts are sent.'),
              _buildNumberedPoint(4, 'During a Crash:', 'Helmet triggers or app inputs will notify contacts automatically.'),
              _buildNumberedPoint(5, 'After the Crash:', 'Once safe, tap "Safe" to stop updates and regain access to edit your contacts.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontFamily: 'Nunito')),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  if (title.isNotEmpty)
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(int number, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold
              )
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  if (title.isNotEmpty)
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}