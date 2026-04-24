import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 1120;

    return ListView(
      children: [
        const HeroBanner(
          title: 'Meet professionals one-to-one and pay for their time.',
          subtitle:
              'Book sessions with ethical hackers, stress support professionals, and developers for direct issue resolution.',
        ),
        const SizedBox(height: 18),
        mobile
            ? const Column(
                children: [
                  ExpertCard(
                    title: 'Ethical Hackers',
                    description:
                        'Incident tracing, phishing analysis, account risk mapping, and digital hygiene guidance.',
                    icon: Icons.shield_rounded,
                  ),
                  SizedBox(height: 14),
                  ExpertCard(
                    title: 'Doctors for Mental Stress',
                    description:
                        'Support for victims under stress after scams, blackmail, harassment, or identity threats.',
                    icon: Icons.favorite_rounded,
                  ),
                  SizedBox(height: 14),
                  ExpertCard(
                    title: 'Developers',
                    description:
                        'Website, app, and technical repair guidance for digital recovery and prevention.',
                    icon: Icons.code_rounded,
                  ),
                ],
              )
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ExpertCard(
                      title: 'Ethical Hackers',
                      description:
                          'Incident tracing, phishing analysis, account risk mapping, and digital hygiene guidance.',
                      icon: Icons.shield_rounded,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: ExpertCard(
                      title: 'Doctors for Mental Stress',
                      description:
                          'Support for victims under stress after scams, blackmail, harassment, or identity threats.',
                      icon: Icons.favorite_rounded,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: ExpertCard(
                      title: 'Developers',
                      description:
                          'Website, app, and technical repair guidance for digital recovery and prevention.',
                      icon: Icons.code_rounded,
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

class ExpertCard extends StatelessWidget {
  const ExpertCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      subtitle: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF3FFFD7)),
          const SizedBox(height: 14),
          const ActionChipWidget(
            label: 'Book and Pay for Time',
            icon: Icons.schedule_rounded,
          ),
        ],
      ),
    );
  }
}
