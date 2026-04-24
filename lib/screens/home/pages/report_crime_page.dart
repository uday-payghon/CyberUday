import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';

class ReportCrimePage extends StatelessWidget {
  const ReportCrimePage({super.key});

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
        const SectionCard(
          title: 'AI bot workflow',
          subtitle:
              'Speak or type what happened. The AI bot helps organize facts, suspects, payment data, screenshots, and time of incident into a formal report.',
          child: Column(
            children: [
              FieldPlaceholder(label: 'Describe the attack or fraud'),
              SizedBox(height: 12),
              FieldPlaceholder(label: 'Victim details and timeline'),
              SizedBox(height: 12),
              FieldPlaceholder(label: 'Evidence links, screenshots, UPI IDs'),
              SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActionChipWidget(label: 'Speak with AI', icon: Icons.mic_rounded),
                  ActionChipWidget(
                    label: 'Generate Report',
                    icon: Icons.description_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionCard(
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
              ),
              ActionChipWidget(
                label: 'Submit to Cyber Cell',
                icon: Icons.local_police_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
