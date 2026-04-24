import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        HeroBanner(
          title:
              'Connect with the Cyber Uday team, collaborators, and support lines.',
          subtitle:
              'Use this page for help calls, team assistance, collaboration, investment, or company tie-ups.',
        ),
        SizedBox(height: 18),
        SectionCard(
          title: 'Contact options',
          subtitle:
              'Speak to the team, start collaboration, or ask for direct assistance depending on your problem.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ActionChipWidget(label: 'Call Our Team', icon: Icons.call_rounded),
              ActionChipWidget(
                label: 'Collab With Us',
                icon: Icons.handshake_rounded,
              ),
              ActionChipWidget(
                label: 'Get Investment',
                icon: Icons.trending_up_rounded,
              ),
              ActionChipWidget(label: 'Help Me', icon: Icons.support_agent_rounded),
              ActionChipWidget(
                label: 'Company Tie Up',
                icon: Icons.apartment_rounded,
              ),
            ],
          ),
        ),
        SizedBox(height: 14),
        SectionCard(
          title: 'Helpline 24/7',
          subtitle:
              'Future integrations can route to ambulance, cyber cell, police station, fire vehicle, or the Cyber Uday team based on emergency context.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ActionChipWidget(label: 'Ambulance', icon: Icons.emergency),
              ActionChipWidget(label: 'Cyber Cell', icon: Icons.local_police),
              ActionChipWidget(
                label: 'Fire Vehicle',
                icon: Icons.local_fire_department,
              ),
              ActionChipWidget(label: 'CYBER UDAY Team', icon: Icons.support_agent),
            ],
          ),
        ),
      ],
    );
  }
}
