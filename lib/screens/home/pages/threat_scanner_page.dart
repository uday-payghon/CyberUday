import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';

class ThreatScannerPage extends StatelessWidget {
  const ThreatScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        HeroBanner(
          title: 'Threat scanner for suspicious links, apps, and screenshots.',
          subtitle:
              'Users can submit a website, APK/app link, or image evidence. Your virtual team can analyze and respond.',
        ),
        SizedBox(height: 18),
        SectionCard(
          title: 'Submit a suspicious asset',
          subtitle:
              'Paste a phishing URL, app package link, or upload screenshots so the virtual team can inspect patterns and risk.',
          child: Column(
            children: [
              FieldPlaceholder(label: 'Website or phishing link'),
              SizedBox(height: 12),
              FieldPlaceholder(label: 'App name or APK source link'),
              SizedBox(height: 12),
              FieldPlaceholder(label: 'Image or evidence note'),
              SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActionChipWidget(
                    label: 'Upload Image',
                    icon: Icons.image_outlined,
                  ),
                  ActionChipWidget(
                    label: 'Submit to Virtual Team',
                    icon: Icons.verified_user_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
