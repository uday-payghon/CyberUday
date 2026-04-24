import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'admin_login_screen.dart';
import 'home/pages/dashboard_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<_ShellDestination> _destinations = [
    _ShellDestination(
      title: 'Dashboard',
      icon: Icons.dashboard_rounded,
      builder: (context) => DashboardPage(
        user: AuthService.instance.currentUser,
        onAdminTap: _openAdmin,
      ),
    ),
  ];

  void _openAdmin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AdminLoginScreen()));
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 900;
    final bool androidPhone =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        MediaQuery.sizeOf(context).width < 720;
    final theme = Theme.of(context);
    final destination = _destinations[_selectedIndex];

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
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF93AABF),
              ),
            ),
          ],
        ),
        actions: [
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
              destinations: _destinations,
              selectedIndex: _selectedIndex,
              onSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              onAdminTap: _openAdmin,
            )
          : null,
      bottomNavigationBar: null,
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
                  destinations: _destinations,
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
        color: const Color(0xFF0B1823).withOpacity(0.88),
        border: Border.all(color: const Color(0xFF1E4A67)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandBlock(),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: destinations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final destination = destinations[index];
                final selected = selectedIndex == index;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: selected
                          ? const Color(0xFF10273A)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF3FFFD7)
                            : const Color(0xFF1E4A67),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(destination.icon),
                        const SizedBox(width: 12),
                        Expanded(child: Text(destination.title)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
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
              child: ListView(
                children: [
                  ...List.generate(destinations.length, (index) {
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
                  }),
                ],
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
    final theme = Theme.of(context);
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
        Text('CYBER UDAY', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Digital war needs a digital bodyguard.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
