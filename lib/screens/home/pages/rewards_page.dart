import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 960;

    return ListView(
      children: [
        const HeroBanner(
          title: 'Operative status, coins, premium support, and claim flow.',
          subtitle:
              'Users earn points by completing security habits like enabling 2FA, scanning devices, changing passwords, and helping others.',
        ),
        const SizedBox(height: 18),
        mobile
            ? const Column(
                children: [
                  RewardsStatusCard(),
                  SizedBox(height: 14),
                  PremiumFeaturesCard(),
                ],
              )
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: RewardsStatusCard()),
                  SizedBox(width: 14),
                  Expanded(child: PremiumFeaturesCard()),
                ],
              ),
      ],
    );
  }
}

class RewardsStatusCard extends StatelessWidget {
  const RewardsStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Operative status',
      subtitle:
          'Track balance, claim points, and complete your mobile challenge to unlock premium support.',
      child: Column(
        children: [
          _MetricStrip(label: 'Balance', value: '142 coins'),
          SizedBox(height: 10),
          _MetricStrip(label: 'Points claim', value: 'Ready'),
          SizedBox(height: 10),
          _MetricStrip(label: 'Mobile challenge', value: '2/5 done'),
        ],
      ),
    );
  }
}

class PremiumFeaturesCard extends StatelessWidget {
  const PremiumFeaturesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Premium features',
      subtitle:
          'Premium unlocks direct team support, faster case handling, and near-continuous availability.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Our team support to solve your case'),
          SizedBox(height: 10),
          Text('24/7 solution guidance'),
          SizedBox(height: 10),
          Text('Priority escalation for high-risk reports'),
          SizedBox(height: 14),
          ActionChipWidget(label: 'Claim Points', icon: Icons.redeem_rounded),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E4A67)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF3FFFD7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
