import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';

class ScanSystemPage extends StatelessWidget {
  const ScanSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 900;

    return ListView(
      children: [
        const HeroBanner(
          title: 'Scan your mobile and computer for threats.',
          subtitle:
              'Separate sections for mobile and computer checks, built as a guided security intake surface for future scanning integrations.',
        ),
        const SizedBox(height: 18),
        mobile
            ? const Column(
                children: [
                  MobileScanCard(),
                  SizedBox(height: 14),
                  ComputerScanCard(),
                ],
              )
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: MobileScanCard()),
                  SizedBox(width: 14),
                  Expanded(child: ComputerScanCard()),
                ],
              ),
      ],
    );
  }
}

class MobileScanCard extends StatelessWidget {
  const MobileScanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Scan your mobile',
      subtitle:
          'Find risky permissions, fake loan apps, hidden overlays, and notification interception patterns.',
      child: ActionChipWidget(
        label: 'Start Mobile Scan',
        icon: Icons.phone_android_rounded,
      ),
    );
  }
}

class ComputerScanCard extends StatelessWidget {
  const ComputerScanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Scan your computer',
      subtitle:
          'Check browser warnings, remote access exposure, phishing traces, and suspicious downloads.',
      child: ActionChipWidget(
        label: 'Start Computer Scan',
        icon: Icons.computer_rounded,
      ),
    );
  }
}
