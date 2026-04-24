import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.user,
    required this.onAdminTap,
  });

  final User? user;
  final VoidCallback onAdminTap;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 760;

    return ListView(
      children: [
        HeroBanner(
          title: 'The digital war begins where fraud targets ordinary people.',
          subtitle:
              'Fake news, lottery traps, deepfakes, and bank fraud need a faster response layer. Cyber Uday is designed as a digital bodyguard.',
          primaryLabel: 'Connect Bank Permission',
          onPrimaryTap: () {},
          secondaryLabel: 'Admin',
          onSecondaryTap: onAdminTap,
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: mobile ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: mobile ? 1.25 : 1.1,
          children: const [
            MetricCard(
              title: 'Total Reports',
              value: '1,248',
              icon: Icons.flag_rounded,
              accent: Color(0xFF3FFFD7),
            ),
            MetricCard(
              title: 'Threats Blocked',
              value: '386',
              icon: Icons.security_rounded,
              accent: Color(0xFF5AB2FF),
            ),
            MetricCard(
              title: 'Connected Banks',
              value: '73',
              icon: Icons.account_balance_rounded,
              accent: Color(0xFFFFC857),
            ),
            MetricCard(
              title: 'Helpline Actions',
              value: '24/7',
              icon: Icons.support_agent_rounded,
              accent: Color(0xFFFF5C8A),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (mobile)
          const Column(
            children: [
              EmergencyBankPanel(),
              SizedBox(height: 14),
              DashboardGraphCard(),
              SizedBox(height: 14),
              RecentThreatFeed(),
              SizedBox(height: 14),
              PermissionPanel(),
            ],
          )
        else
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: DashboardGraphCard()),
              SizedBox(width: 14),
              Expanded(flex: 5, child: RecentThreatFeed()),
            ],
          ),
        if (!mobile) ...[
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: EmergencyBankPanel()),
              SizedBox(width: 14),
              Expanded(child: PermissionPanel()),
            ],
          ),
        ],
        const SizedBox(height: 14),
        SectionCard(
          title: 'Left-side action lane',
          subtitle:
              'Bank-system freeze, contact team, cyber cell handoff, and protection workflows can all be triggered from here in future backend integration.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              ActionChipWidget(label: 'Freeze My Bank', icon: Icons.lock_clock),
              ActionChipWidget(label: 'Contact Our Team', icon: Icons.call),
              ActionChipWidget(label: 'Cyber Cell', icon: Icons.local_police),
              ActionChipWidget(label: 'Ambulance', icon: Icons.emergency),
              ActionChipWidget(
                label: 'Fire Vehicle',
                icon: Icons.local_fire_department,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 22),
          child: Text(
            'Logged in as ${user?.email ?? 'operator'}. Real bank freeze, police routing, and case submission still require backend and partner integrations.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0C1B28),
        border: Border.all(color: const Color(0xFF1E4A67)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const Spacer(),
          Text(title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardGraphCard extends StatelessWidget {
  const DashboardGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Threat activity graph',
      subtitle:
          'A visual activity lane for rising reports, blocked threats, and active case submissions.',
      child: SizedBox(
        height: 220,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            12,
            (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  height: 40 + (index % 5) * 24 + (index * 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF3FFFD7), Color(0xFF5AB2FF)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecentThreatFeed extends StatelessWidget {
  const RecentThreatFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Recent cybercrime',
      subtitle:
          'Fresh public-facing incidents and common attack patterns users should watch right now.',
      child: const Column(
        children: [
          _NewsTile(
            headline: 'Lottery scam with screen-share control',
            meta: 'Financial fraud • Nashik',
          ),
          SizedBox(height: 12),
          _NewsTile(
            headline: 'Bank OTP theft after fake support call',
            meta: 'Account attack • Pune',
          ),
          SizedBox(height: 12),
          _NewsTile(
            headline: 'Deepfake blackmail case under review',
            meta: 'Media abuse • Mumbai',
          ),
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

class EmergencyBankPanel extends StatelessWidget {
  const EmergencyBankPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Bank-system emergency freeze',
      subtitle:
          'If a user reports an active hack, this flow can connect bank permission, trigger freeze intent, and push the case to support and cyber teams.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ActionChipWidget(
            label: 'Freeze My Bank Data',
            icon: Icons.lock_clock_rounded,
          ),
          ActionChipWidget(
            label: 'Connect Bank Permission',
            icon: Icons.link_rounded,
          ),
          ActionChipWidget(
            label: 'Submit Account Info',
            icon: Icons.assignment_turned_in_rounded,
          ),
        ],
      ),
    );
  }
}

class PermissionPanel extends StatelessWidget {
  const PermissionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'User permission and account action',
      subtitle:
          'Once the user grants permission to connect bank details, your future backend can freeze the account and submit the incident package with essential data only.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. User grants permission'),
          SizedBox(height: 8),
          Text('2. Connect bank and account context'),
          SizedBox(height: 8),
          Text('3. Freeze action request sent'),
          SizedBox(height: 8),
          Text('4. Incident data submitted to support / authority'),
        ],
      ),
    );
  }
}
