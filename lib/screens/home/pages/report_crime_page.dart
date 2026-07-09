import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';
import '../../../services/firebase_service.dart';
import '../../../services/pdf_service.dart';
import '../../../widgets/ai_chatbot.dart';

class ReportCrimePage extends StatefulWidget {
  const ReportCrimePage({super.key});

  @override
  State<ReportCrimePage> createState() => _ReportCrimePageState();
}

class _ReportCrimePageState extends State<ReportCrimePage> {
  final _descController = TextEditingController();
  final _timelineController = TextEditingController();
  final _evidenceController = TextEditingController();
  bool _isSubmitting = false;
  Map<String, dynamic>? _lastGeneratedData;

  @override
  void dispose() {
    _descController.dispose();
    _timelineController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _submitReport(String destination) async {
    if (_descController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please describe the attack.')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final reportData = {
      'type': 'Cybercrime Report',
      'description': _descController.text,
      'timeline': _timelineController.text,
      'evidence': _evidenceController.text,
      'destination': destination,
    };

    try {
      final id = await FirebaseService.instance.submitReport(reportData);
      
      if (mounted) {
        setState(() {
          _lastGeneratedData = {'id': id, ...reportData};
          _descController.clear();
          _timelineController.clear();
          _evidenceController.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted to $destination successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _generatePdf() {
    if (_lastGeneratedData == null) {
      if (_descController.text.isNotEmpty) {
        _lastGeneratedData = {
          'id': 'Draft',
          'type': 'Cybercrime Draft',
          'description': _descController.text,
          'timeline': _timelineController.text,
          'evidence': _evidenceController.text,
        };
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill the details first or submit a report.')),
        );
        return;
      }
    }
    PdfService.generateReportPdf(_lastGeneratedData!);
  }

  void _openAiAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiChatbot(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const HeroBanner(
          title: 'AI report generation for cybercrime victims.',
          subtitle:
              'Language-free reporting, voice-assisted intake, and guided report creation for Marathi, Hindi, Urdu, Nepali, Ahirani, and more.',
        ),
        const SizedBox(height: 18),
        SectionCard(
          title: 'AI bot workflow',
          subtitle:
              'Speak or type what happened. The AI bot helps organize facts, suspects, payment data, screenshots, and time of incident into a formal report.',
          child: Column(
            children: [
              FieldPlaceholder(label: 'Describe the attack or fraud', controller: _descController),
              const SizedBox(height: 12),
              FieldPlaceholder(label: 'Victim details and timeline', controller: _timelineController),
              const SizedBox(height: 12),
              FieldPlaceholder(label: 'Evidence links, screenshots, UPI IDs', controller: _evidenceController),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActionChipWidget(
                    label: 'Chat with AI', 
                    icon: Icons.auto_awesome,
                    onTap: _openAiAssistant,
                  ),
                  ActionChipWidget(
                    label: 'Generate PDF Report',
                    icon: Icons.description_rounded,
                    onTap: _generatePdf,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Submit destination',
          subtitle:
              'Choose whether the generated report goes to the Cyber Uday team first or directly toward cyber cell submission.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ActionChipWidget(
                label: 'Submit to Our Team',
                icon: Icons.support_agent_rounded,
                isLoading: _isSubmitting,
                onTap: () => _submitReport('Cyber Uday Team'),
              ),
              ActionChipWidget(
                label: 'Submit to Cyber Cell',
                icon: Icons.local_police_rounded,
                isLoading: _isSubmitting,
                onTap: () => _submitReport('Cyber Cell'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
