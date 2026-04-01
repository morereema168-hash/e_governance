import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'models/models.dart';
import 'screens/login_screen.dart';
import 'screens/vote_screen.dart';
import 'screens/report_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/community_screen.dart';
import 'screens/fundraise_screen.dart';
import 'screens/cityinfo_screen.dart';
import 'screens/mayor_dashboard_screen.dart';
import 'widgets/shared_widgets.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NagarPanchayatApp());
}

class NagarPanchayatApp extends StatelessWidget {
  const NagarPanchayatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nagar Panchayat – Rampur',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  AppUser? user;
  String tab = 'vote';

  void _login(AppUser u) => setState(() {
    user = u;
    tab = 'vote';
  });
  void _logout() => setState(() {
    user = null;
  });
  void _setTab(String t) => setState(() => tab = t);

  @override
  Widget build(BuildContext context) {
    if (user == null) return LoginScreen(onLogin: _login);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(user: user!, onLogout: _logout, setTab: _setTab),
            Expanded(child: _page()),
          ],
        ),
      ),
      // ARCHITECTURE FIX: Bottom nav remains visible on 'cityinfo'
      // Only hide the bottom navigation bar if the user is the Mayor
      bottomNavigationBar: user!.role == 'mayor'
          ? null
          : _BottomNav(active: tab, setTab: _setTab),
    );
  }

  Widget _page() {
    // Both Citizen and Mayor can access the City Info page from the top bar
    if (tab == 'cityinfo') {
      return const CityInfoScreen();
    }

    // If the user is the Mayor, show the Mayor Dashboard instead of standard tabs!
    if (user!.role == 'mayor') {
      return MayorDashboardScreen(user: user!);
    }

    // Standard citizen routing
    switch (tab) {
      case 'feed':
        return CommunityScreen(user: user!);
      case 'report':
        return ReportScreen(user: user!);
      case 'dashboard':
        return const DashboardScreen();
      case 'fundraise':
        return const FundraiseScreen();
      default:
        return const VoteScreen();
    }
  }
}

// ── TOP BAR ──
class _TopBar extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;
  final Function(String) setTab;
  const _TopBar({
    required this.user,
    required this.onLogout,
    required this.setTab,
  });
  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  bool showN = false;
  bool showP = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: AppColors.orange.withOpacity(0.15),
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              // Logo
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.orange, AppColors.orangeDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nagar Panchayat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  Text(
                    'Rampur · Digital Gov',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.grey,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // City info
              _IconBtn(
                icon: Icons.public,
                onTap: () {
                  // Allow Mayor to toggle back to dashboard if they click the globe again
                  if (widget.user.role == 'mayor') {
                    widget.setTab('dashboard'); // Forces a rebuild to show the mayor screen again
                  } else {
                    widget.setTab('cityinfo');
                  }
                },
              ),
              const SizedBox(width: 8),
              // Notifications
              Stack(
                children: [
                  _IconBtn(
                    icon: Icons.notifications_outlined,
                    onTap: () => setState(() {
                      showN = !showN;
                      showP = false;
                    }),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Avatar / profile
              GestureDetector(
                onTap: () => setState(() {
                  showP = !showP;
                  showN = false;
                }),
                child: AppAvatar(
                  initials: widget.user.avatar,
                  color: AppColors.navy,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
        // Notification panel
        if (showN)
          Positioned(
            top: 58,
            right: 8,
            child: _NotifPanel(onClose: () => setState(() => showN = false)),
          ),
        // Profile panel
        if (showP)
          Positioned(
            top: 58,
            right: 8,
            child: _ProfilePanel(
              user: widget.user,
              onClose: () => setState(() => showP = false),
              onLogout: widget.onLogout,
            ),
          ),
        // Overlay dismiss
        if (showN || showP)
          Positioned.fill(
            top: 58,
            child: GestureDetector(
              onTap: () => setState(() {
                showN = false;
                showP = false;
              }),
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Icon(icon, size: 18, color: AppColors.navy),
      ),
    );
  }
}

class _NotifPanel extends StatelessWidget {
  final VoidCallback onClose;
  const _NotifPanel({required this.onClose});
  static const notifs = [
    {
      'title': 'Water maintenance – Dec 14',
      'body': '6 AM–2 PM. Ward 3.',
      'type': 'alert',
      'time': '2h ago',
    },
    {
      'title': 'Town Hall – Sunday 10 AM',
      'body': 'Municipal Hall.',
      'type': 'event',
      'time': '5h ago',
    },
    {
      'title': 'Road Repair #8832 resolved',
      'body': 'Ward 3 complete.',
      'type': 'success',
      'time': '1d ago',
    },
  ];
  static const cc = {
    'alert': AppColors.red,
    'event': AppColors.gold,
    'success': AppColors.green,
  };
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 290,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.navyLight],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            for (final n in notifs)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withOpacity(0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cc[n['type']],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Text(
                            '${n['body']} · ${n['time']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  final AppUser user;
  final VoidCallback onClose, onLogout;
  const _ProfilePanel({
    required this.user,
    required this.onClose,
    required this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.orangeLight, Colors.white],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    initials: user.avatar,
                    color: AppColors.navy,
                    size: 44,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppChip(
                    label: user.role.toUpperCase(),
                    color: AppColors.orange,
                    small: true,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onLogout,
              child: Container(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppColors.red, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── BOTTOM NAV ──
class _BottomNav extends StatelessWidget {
  final String active;
  final Function(String) setTab;
  const _BottomNav({required this.active, required this.setTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _NavBtn(
            id: 'report',
            icon: Icons.assignment_outlined,
            label: 'Report',
            active: active == 'report',
            onTap: setTab,
          ),
          _NavBtn(
            id: 'vote',
            icon: Icons.how_to_vote_outlined,
            label: 'Vote',
            active: active == 'vote',
            onTap: setTab,
          ),
          // Community center fab
          Expanded(
            child: GestureDetector(
              onTap: () => setTab('feed'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: active == 'feed'
                            ? [AppColors.orange, AppColors.orangeDark]
                            : [AppColors.navy, AppColors.navyLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (active == 'feed'
                                      ? AppColors.orange
                                      : AppColors.navy)
                                  .withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const Text(
                          'Community',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 7,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _NavBtn(
            id: 'dashboard',
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            active: active == 'dashboard',
            onTap: setTab,
          ),
          _NavBtn(
            id: 'fundraise',
            icon: Icons.volunteer_activism_outlined,
            label: 'Fundraise',
            active: active == 'fundraise',
            onTap: setTab,
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String id, label;
  final IconData icon;
  final bool active;
  final Function(String) onTap;
  const _NavBtn({
    required this.id,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(id),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: active ? 1.2 : 1.0,
                    child: Icon(
                      icon,
                      color: active ? AppColors.orange : AppColors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                      color: active ? AppColors.orange : AppColors.grey,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Container(
                height: 3,
                width: 22,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}