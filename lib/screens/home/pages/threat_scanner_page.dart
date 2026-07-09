import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';
import '../../../services/firebase_service.dart';

class ThreatScannerPage extends StatefulWidget {
  const ThreatScannerPage({super.key});

  @override
  State<ThreatScannerPage> createState() => _ThreatScannerPageState();
}

class _ThreatScannerPageState extends State<ThreatScannerPage> {
  final _urlController = TextEditingController();
  final _appController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitThreat() async {
    if (_urlController.text.isEmpty && _appController.text.isEmpty && _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least one field.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseService.instance.submitThreat({
        'headline': 'Threat Scan Request',
        'source': 'Scanner Page',
        'url': _urlController.text,
        'appName': _appController.text,
        'note': _noteController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Threat submitted to virtual team for analysis!')),
        );
        _urlController.clear();
        _appController.clear();
        _noteController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const HeroBanner(
          title: 'Threat scanner for suspicious links, apps, and screenshots.',
          subtitle:
              'Users can submit a website, APK/app link, or image evidence. Your virtual team can analyze and respond.',
        ),
        const SizedBox(height: 18),
        SectionCard(
          title: 'Submit a suspicious asset',
          subtitle:
              'Paste a phishing URL, app package link, or upload screenshots so the virtual team can inspect patterns and risk.',
          child: Column(
            children: [
              FieldPlaceholder(label: 'Website or phishing link', controller: _urlController),
              const SizedBox(height: 12),
              FieldPlaceholder(label: 'App name or APK source link', controller: _appController),
              const SizedBox(height: 12),
              FieldPlaceholder(label: 'Image or evidence note', controller: _noteController),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActionChipWidget(
                    label: 'Upload Image',
                    icon: Icons.image_outlined,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picker opening...'))),
                  ),
                  ActionChipWidget(
                    label: 'Submit to Virtual Team',
                    icon: Icons.verified_user_outlined,
                    isLoading: _isSubmitting,
                    onTap: _submitThreat,
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
