import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';

class CyberNewsPage extends StatelessWidget {
  const CyberNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 960;

    return ListView(
      children: [
        const HeroBanner(
          title: 'Stay aware with recent cybercrime news and citizen updates.',
          subtitle:
              'One block for verified recent news and one block for user-submitted awareness updates sent to the team for review.',
        ),
        const SizedBox(height: 18),
        mobile
            ? const Column(
                children: [
                  RecentNewsCard(),
                  SizedBox(height: 14),
                  CreateNewsCard(),
                ],
              )
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: RecentNewsCard()),
                  SizedBox(width: 14),
                  Expanded(child: CreateNewsCard()),
                ],
              ),
      ],
    );
  }
}

class RecentNewsCard extends StatelessWidget {
  const RecentNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Recent news',
      subtitle:
          'Daily awareness feed for cyber fraud, fake lottery cases, deepfake abuse, phishing, and dark web exposure.',
      child: Column(
        children: [
          _NewsTile(
            headline: 'UPI refund scam pattern detected',
            meta: 'Awareness update • 2h ago',
          ),
          SizedBox(height: 12),
          _NewsTile(
            headline: 'Deepfake job offer fraud increasing',
            meta: 'Threat bulletin • Today',
          ),
          SizedBox(height: 12),
          _NewsTile(
            headline: 'QR-code banking theft advisory',
            meta: 'Verified news • 5h ago',
          ),
        ],
      ),
    );
  }
}

class CreateNewsCard extends StatelessWidget {
  const CreateNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Create new news',
      subtitle:
          'Users can submit local scam alerts or suspicious patterns to the team before public posting.',
      child: Column(
        children: [
          FieldPlaceholder(label: 'Headline or fraud pattern'),
          SizedBox(height: 12),
          FieldPlaceholder(label: 'What happened and where'),
          SizedBox(height: 12),
          ActionChipWidget(label: 'Submit to Team', icon: Icons.send_rounded),
        ],
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.headline, required this.meta});

  final String headline;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E4A67)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(meta, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
