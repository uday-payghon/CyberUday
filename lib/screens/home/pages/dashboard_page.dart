import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/home_shared_widgets.dart';
import '../../../services/firebase_service.dart';
import '../../../services/localization_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.user,
    required this.onAdminTap,
  });

  final User? user;
  final VoidCallback onAdminTap;

  Future<void> _handleEmergencyAction(
    BuildContext context,
    String action,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${LocalizationService.instance.translate('hacked_desc')}...',
        ),
      ),
    );

    try {
      await FirebaseService.instance.logEmergencyAction(action, {
        'platform': Theme.of(context).platform.toString(),
        'context': 'Dashboard Emergency Lane',
        'isEmergency': action == 'I AM HACKED',
      });

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0B1823),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 10),
                Text(LocalizationService.instance.translate('hacked_title')),
              ],
            ),
            content: Text(
              LocalizationService.instance.translate('hacked_desc'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 760;

    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.instance.currentLocale,
      builder: (context, locale, _) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            HeroBanner(
              title: LocalizationService.instance.translate('hero_title'),
              subtitle: 'Digital war needs a digital bodyguard.',
              primaryLabel: LocalizationService.instance.translate(
                'connect_bank',
              ),
              onPrimaryTap: () =>
                  _handleEmergencyAction(context, 'Bank Connection'),
              secondaryLabel: 'Admin',
              onSecondaryTap: onAdminTap,
            ),
            const SizedBox(height: 18),

            // EMERGENCY "I AM HACKED" BUTTON
            InkWell(
              onTap: () => _handleEmergencyAction(context, 'I AM HACKED'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.security_update_warning,
                        color: Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        LocalizationService.instance.translate('hacked_btn'),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),
            StreamBuilder<int>(
              stream: FirebaseService.instance.getReportsCount(),
              builder: (context, reportsSnapshot) {
                return StreamBuilder<int>(
                  stream: FirebaseService.instance.getThreatsCount(),
                  builder: (context, threatsSnapshot) {
                    return StreamBuilder<int>(
                      stream: FirebaseService.instance.getConnectedBanksCount(),
                      builder: (context, banksSnapshot) {
                        return GridView.count(
                          crossAxisCount: mobile ? 2 : 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: mobile ? 1.1 : 1.1,
                          children: [
                            MetricCard(
                              title: LocalizationService.instance.translate(
                                'total_reports',
                              ),
                              value: reportsSnapshot.data?.toString() ?? '0',
                              icon: Icons.flag_rounded,
                              accent: const Color(0xFF3FFFD7),
                            ),
                            MetricCard(
                              title: LocalizationService.instance.translate(
                                'threats_blocked',
                              ),
                              value: threatsSnapshot.data?.toString() ?? '0',
                              icon: Icons.security_rounded,
                              accent: const Color(0xFF5AB2FF),
                            ),
                            MetricCard(
                              title: 'Connected Banks',
                              value: banksSnapshot.data?.toString() ?? '0',
                              icon: Icons.account_balance_rounded,
                              accent: const Color(0xFFFFC857),
                            ),
                            const MetricCard(
                              title: 'Helpline Actions',
                              value: '24/7',
                              icon: Icons.support_agent_rounded,
                              accent: Color(0xFFFF5C8A),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
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
            const SizedBox(height: 14),
            SectionCard(
              title: 'Left-side action lane',
              subtitle: 'Quick response triggers for multiple scenarios.',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActionChipWidget(
                    label: LocalizationService.instance.translate(
                      'freeze_bank',
                    ),
                    icon: Icons.lock_clock,
                    onTap: () => _handleEmergencyAction(context, 'Bank Freeze'),
                  ),
                  ActionChipWidget(
                    label: 'Contact Our Team',
                    icon: Icons.call,
                    onTap: () =>
                        _handleEmergencyAction(context, 'Call to Team'),
                  ),
                  ActionChipWidget(
                    label: 'Cyber Cell',
                    icon: Icons.local_police,
                    onTap: () =>
                        _handleEmergencyAction(context, 'Cyber Cell Alert'),
                  ),
                  ActionChipWidget(
                    label: 'Ambulance',
                    icon: Icons.emergency,
                    onTap: () =>
                        _handleEmergencyAction(context, 'Emergency Services'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 22),
              child: Text(
                'Logged in as ${user?.email ?? 'operator'}. All actions are encrypted and secured.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0C1B28),
        border: Border.all(color: const Color(0xFF1E4A67)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 20),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
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
    return StreamBuilder<List<int>>(
      stream: FirebaseService.instance.getMonthlyReportStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? List.filled(12, 0);
        int maxVal = stats.reduce((a, b) => a > b ? a : b);
        if (maxVal == 0) maxVal = 1;

        return SectionCard(
          title: 'Threat activity graph',
          subtitle: 'Real-time report traffic analysis across months.',
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
                      height: (stats[index] / maxVal) * 180 + 20,
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
      },
    );
  }
}

class RecentThreatFeed extends StatelessWidget {
  const RecentThreatFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService.instance.getAllThreats(),
      builder: (context, snapshot) {
        final threats = snapshot.data ?? [];
        return SectionCard(
          title: 'Recent cybercrime',
          subtitle: 'Live patterns from the field.',
          child: Column(
            children: threats
                .take(3)
                .map(
                  (threat) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _NewsTile(
                      headline: threat['headline'] ?? 'Suspicious Activity',
                      meta:
                          'Context: ${threat['url'] ?? threat['appName'] ?? 'Unknown'}',
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
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
          Text(
            headline,
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            meta,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class EmergencyBankPanel extends StatelessWidget {
  const EmergencyBankPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Emergency Handshake',
      subtitle: 'Fast-track connectivity for high-risk accounts.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ActionChipWidget(
            label: LocalizationService.instance.translate('freeze_bank'),
            icon: Icons.lock_clock_rounded,
            onTap: () => _handleAction(context, 'Bank Data Freeze'),
          ),
          ActionChipWidget(
            label: LocalizationService.instance.translate('connect_bank'),
            icon: Icons.link_rounded,
            onTap: () => _handleAction(context, 'Bank Permission'),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Simulating $action...')));
    await FirebaseService.instance.logEmergencyAction(action, {
      'source': 'Emergency Panel',
    });
  }
}
