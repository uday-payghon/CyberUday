import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/localization_service.dart';
import 'admin_login_screen.dart';
import 'home/pages/dashboard_page.dart';
import 'home/pages/report_crime_page.dart';
import 'home/pages/threat_scanner_page.dart';
import 'home/pages/cyber_news_page.dart';
import 'home/pages/rewards_page.dart';
import 'home/pages/contact_us_page.dart';
import 'home/pages/sessions_page.dart';
import 'home/pages/scan_system_page.dart';
import 'home/pages/emergency_contacts_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 900;

    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.instance.currentLocale,
      builder: (context, locale, _) {
        final List<_ShellDestination> destinations = [
          _ShellDestination(
            title: LocalizationService.instance.translate('dashboard'),
            icon: Icons.dashboard_rounded,
            builder: (context) => DashboardPage(
              user: AuthService.instance.currentUser,
              onAdminTap: _openAdmin,
            ),
          ),
          _ShellDestination(
            title: LocalizationService.instance.translate('report_crime'),
            icon: Icons.campaign_rounded,
            builder: (context) => const ReportCrimePage(),
          ),
          _ShellDestination(
            title: 'Emergency',
            icon: Icons.emergency_rounded,
            builder: (context) => const EmergencyContactsPage(),
          ),
          _ShellDestination(
            title: LocalizationService.instance.translate('threat_scanner'),
            icon: Icons.travel_explore_rounded,
            builder: (context) => const ThreatScannerPage(),
          ),
          _ShellDestination(
            title: LocalizationService.instance.translate('cyber_news'),
            icon: Icons.newspaper_rounded,
            builder: (context) => const CyberNewsPage(),
          ),
          _ShellDestination(
            title: LocalizationService.instance.translate('rewards'),
            icon: Icons.workspace_premium_rounded,
            builder: (context) => const RewardsPage(),
          ),
          _ShellDestination(
            title: LocalizationService.instance.translate('contact_us'),
            icon: Icons.support_agent_rounded,
            builder: (context) => const ContactUsPage(),
          ),
          _ShellDestination(
            title: LocalizationService.instance.translate('sessions'),
            icon: Icons.groups_rounded,
            builder: (context) => const SessionsPage(),
          ),
          _ShellDestination(
            title: LocalizationService.instance.translate('scan_system'),
            icon: Icons.phonelink_lock_rounded,
            builder: (context) => const ScanSystemPage(),
          ),
        ];

        final destination = destinations[_selectedIndex];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CYBER UDAY'),
                Text(
                  destination.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF93AABF),
                  ),
                ),
              ],
            ),
            actions: [
              _LanguageSelector(),
              IconButton(
                onPressed: _openAdmin,
                tooltip: 'Admin',
                icon: const Icon(Icons.admin_panel_settings_outlined),
              ),
              IconButton(
                onPressed: _logout,
                tooltip: 'Logout',
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          drawer: mobile
              ? _ShellDrawer(
                  destinations: destinations,
                  selectedIndex: _selectedIndex,
                  onSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  onAdminTap: _openAdmin,
                )
              : null,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF040B11), Color(0xFF07111A), Color(0xFF0B2030)],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (!mobile)
                    _ShellRail(
                      destinations: destinations,
                      selectedIndex: _selectedIndex,
                      onSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        mobile ? 12 : 0,
                        12,
                        mobile ? 12 : 18,
                        18,
                      ),
                      child: destination.builder(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  void _openAdmin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AdminLoginScreen()));
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
  }
}

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Color(0xFF3FFFD7)),
      onSelected: (locale) => LocalizationService.instance.setLocale(locale),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'hi', child: Text('हिंदी (Hindi)')),
        const PopupMenuItem(value: 'mr', child: Text('मराठी (Marathi)')),
      ],
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.title,
    required this.icon,
    required this.builder,
  });

  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

class _ShellRail extends StatelessWidget {
  const _ShellRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF0B1823).withValues(alpha: 0.88),
        border: Border.all(color: const Color(0xFF1E4A67)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandBlock(),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < destinations.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _RailItem(
                      destination: destinations[i],
                      selected: selectedIndex == i,
                      onTap: () => onSelected(i),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AdminLoginScreen(),
                ),
              );
            },
            icon: const Icon(Icons.admin_panel_settings_outlined),
            label: const Text('Admin'),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? const Color(0xFF10273A) : Colors.transparent,
          border: Border.all(
            color: selected ? const Color(0xFF3FFFD7) : const Color(0xFF1E4A67),
          ),
        ),
        child: Row(
          children: [
            Icon(destination.icon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                destination.title,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellDrawer extends StatelessWidget {
  const _ShellDrawer({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdminTap,
  });

  final List<_ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdminTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(16), child: _BrandBlock()),
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return ListTile(
                    selected: selectedIndex == index,
                    leading: Icon(destination.icon),
                    title: Text(destination.title),
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelected(index);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Admin'),
              onTap: () {
                Navigator.of(context).pop();
                onAdminTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF3FFFD7), Color(0xFF5AB2FF)],
            ),
          ),
          child: const Icon(
            Icons.shield_moon_rounded,
            color: Color(0xFF07111A),
          ),
        ),
        const SizedBox(height: 14),
        const Text('CYBER UDAY', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
          'Digital war needs a digital bodyguard.',
          style: TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}
