import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';
import '../../../services/firebase_service.dart';
import '../../../services/localization_service.dart';

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
    if (_urlController.text.isEmpty &&
        _appController.text.isEmpty &&
        _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.instance.translate('scanner_fill_one'),
          ),
        ),
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
          SnackBar(
            content: Text(
              LocalizationService.instance.translate('scanner_submitted'),
            ),
          ),
        );
        _urlController.clear();
        _appController.clear();
        _noteController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.instance.translate('dashboard_action_failed'),
            ),
          ),
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
        HeroBanner(
          title: LocalizationService.instance.translate('scanner_page_title'),
          subtitle: LocalizationService.instance.translate(
            'scanner_page_subtitle',
          ),
        ),
        const SizedBox(height: 18),
        SectionCard(
          title: LocalizationService.instance.translate('scanner_submit_title'),
          subtitle: LocalizationService.instance.translate(
            'scanner_submit_subtitle',
          ),
          child: Column(
            children: [
              FieldPlaceholder(
                label: LocalizationService.instance.translate(
                  'scanner_link_label',
                ),
                controller: _urlController,
              ),
              const SizedBox(height: 12),
              FieldPlaceholder(
                label: LocalizationService.instance.translate(
                  'scanner_app_label',
                ),
                controller: _appController,
              ),
              const SizedBox(height: 12),
              FieldPlaceholder(
                label: LocalizationService.instance.translate(
                  'scanner_note_label',
                ),
                controller: _noteController,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActionChipWidget(
                    label: LocalizationService.instance.translate(
                      'scanner_upload',
                    ),
                    icon: Icons.image_outlined,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          LocalizationService.instance.translate(
                            'scanner_picker_opening',
                          ),
                        ),
                      ),
                    ),
                  ),
                  ActionChipWidget(
                    label: LocalizationService.instance.translate(
                      'scanner_submit',
                    ),
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
