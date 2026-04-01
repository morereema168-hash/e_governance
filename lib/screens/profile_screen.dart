import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.user, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  
  // Simulated profile states (You can move these to your AppUser model later)
  bool isAnonymous = false;
  bool isVerified = true; // Assuming they verified their Voter ID during setup
  bool isSaving = false;

  // ── NEW STATE VARIABLES FOR SETTINGS ──
  bool pushNotifs = true;
  bool smsNotifs = true;
  String selectedLang = 'English';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => isSaving = true);
    
    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Profile updated successfully!', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
          ]),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── INTERACTIVE SETTINGS METHODS ──

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user, size: 48, color: AppColors.green),
            ),
            const SizedBox(height: 16),
            const Text('Voter ID Verified', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
            const SizedBox(height: 8),
            Text(
              'Your identity has been securely verified against the State Electoral Database. You are fully authorized to vote in ${widget.user.ward}.', 
              textAlign: TextAlign.center, 
              style: const TextStyle(color: AppColors.greyDark, fontFamily: 'Nunito', height: 1.5, fontSize: 13)
            ),
            const SizedBox(height: 24),
            AppBtn(label: 'Done', full: true, onTap: () => Navigator.pop(context)),
          ]
        )
      )
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
              const SizedBox(height: 8),
              const Text('Control how Nagar Panchayat communicates with you.', style: TextStyle(fontSize: 13, color: AppColors.grey, fontFamily: 'Nunito')),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Push Notifications', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15)),
                subtitle: const Text('Real-time alerts on your device', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.grey)),
                activeColor: AppColors.orange,
                contentPadding: EdgeInsets.zero,
                value: pushNotifs,
                onChanged: (val) {
                  setModalState(() => pushNotifs = val);
                  setState(() => pushNotifs = val); // Updates parent screen too
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              SwitchListTile(
                title: const Text('SMS Alerts', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15)),
                subtitle: const Text('Important civic updates via SMS', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.grey)),
                activeColor: AppColors.orange,
                contentPadding: EdgeInsets.zero,
                value: smsNotifs,
                onChanged: (val) {
                  setModalState(() => smsNotifs = val);
                  setState(() => smsNotifs = val);
                },
              ),
            ]
          )
        )
      )
    );
  }

  void _showLanguagePicker() {
    final langs = ['English', 'मराठी (Marathi)', 'हिंदी (Hindi)'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
            const SizedBox(height: 16),
            ...langs.map((lang) => RadioListTile(
              value: lang,
              groupValue: selectedLang,
              activeColor: AppColors.orange,
              contentPadding: EdgeInsets.zero,
              title: Text(lang, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
              onChanged: (val) {
                setState(() => selectedLang = val.toString());
                Navigator.pop(context);
              }
            )),
          ]
        )
      )
    );
  }

  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
            const SizedBox(height: 16),
            _buildSupportTile(Icons.phone_outlined, 'Toll-Free Helpline', '1800-222-1234'),
            const Divider(height: 1, color: AppColors.border),
            _buildSupportTile(Icons.email_outlined, 'Email Us', 'support@rampur-np.gov.in'),
            const Divider(height: 1, color: AppColors.border),
            _buildSupportTile(Icons.menu_book_outlined, 'FAQs', 'Read frequently asked questions'),
          ]
        )
      )
    );
  }

  Widget _buildSupportTile(IconData icon, String title, String sub) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.navy, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito')),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      trailing: const Icon(Icons.open_in_new, size: 14, color: AppColors.grey),
      onTap: () => Navigator.pop(context),
    );
  }

  // ── BUILD METHOD & LAYOUTS ──

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 160),
            child: Column(
              children: [
                const SizedBox(height: 55), 
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
                  child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, 
              end: Alignment.bottomRight,
              colors: [AppColors.navy, AppColors.navyLight],
            ),
          ),
        ),
        Positioned(
          bottom: -45,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.orangeLight,
                  child: Text(
                    widget.user.avatar,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.orange, fontFamily: 'Nunito'),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
              if (isVerified)
                Positioned(
                  bottom: 0, left: 0,
                  child: Tooltip(
                    message: 'Voter ID Verified',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                      ),
                      child: const Icon(Icons.verified, size: 22, color: AppColors.green),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildMainForm()),
        const SizedBox(width: 20),
        Expanded(flex: 4, child: _buildSettingsMenu()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildMainForm(),
        const SizedBox(height: 16),
        _buildSettingsMenu(),
      ],
    );
  }

  Widget _buildMainForm() {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Identity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
              const SizedBox(height: 16),
              const Text('USERNAME / DISPLAY NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Your public name...',
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.grey),
                ),
                style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isAnonymous ? AppColors.purple.withOpacity(0.08) : AppColors.blueLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isAnonymous ? AppColors.purple.withOpacity(0.3) : AppColors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isAnonymous ? Icons.masks : Icons.public,
                        key: ValueKey(isAnonymous),
                        color: isAnonymous ? AppColors.purple : AppColors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAnonymous ? 'Anonymous Mode On' : 'Public Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: 14, 
                              color: isAnonymous ? AppColors.purple : AppColors.blue, 
                              fontFamily: 'Nunito'
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAnonymous 
                                ? 'Your real name is hidden in community posts.' 
                                : 'Your name is visible to the community.',
                            style: const TextStyle(fontSize: 11, color: AppColors.greyDark, fontFamily: 'Nunito', height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isAnonymous,
                      activeColor: AppColors.purple,
                      inactiveTrackColor: AppColors.blue.withOpacity(0.3),
                      inactiveThumbColor: AppColors.blue,
                      onChanged: (val) => setState(() => isAnonymous = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Official Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
                  if (isVerified) AppChip(label: 'Verified ✓', color: AppColors.green, small: true),
                ],
              ),
              const SizedBox(height: 16),
              _buildReadOnlyRow(Icons.email_outlined, 'EMAIL', widget.user.email),
              const Divider(height: 24, color: AppColors.border),
              _buildReadOnlyRow(Icons.location_city_outlined, 'WARD', widget.user.ward),
              const Divider(height: 24, color: AppColors.border),
              _buildReadOnlyRow(Icons.admin_panel_settings_outlined, 'ROLE', widget.user.role.toUpperCase()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Nunito')),
          ),
        ),
      ],
    );
  }

  // ── SETTINGS MENU ──
  Widget _buildSettingsMenu() {
    // Dynamic subtitles based on state
    String notifSub = (pushNotifs && smsNotifs) ? 'Push & SMS enabled' 
                    : (pushNotifs) ? 'Push enabled' 
                    : (smsNotifs) ? 'SMS enabled' 
                    : 'All notifications muted';

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
          ),
          
          // ── The Tiles now pass the new onTap functions ──
          _buildMenuTile(Icons.how_to_vote_outlined, 'Voter ID Verification', isVerified ? 'Verified via State DB' : 'Not verified', isVerified ? AppColors.green : AppColors.grey, _showVerificationDialog),
          const Divider(height: 1, color: AppColors.border),
          
          _buildMenuTile(Icons.notifications_outlined, 'Notifications', notifSub, AppColors.dark, _showNotificationSettings),
          const Divider(height: 1, color: AppColors.border),
          
          _buildMenuTile(Icons.language_outlined, 'Language', selectedLang, AppColors.dark, _showLanguagePicker),
          const Divider(height: 1, color: AppColors.border),
          
          _buildMenuTile(Icons.help_outline, 'Help & Support', 'FAQs & Contact', AppColors.dark, _showHelpSupport),
          const Divider(height: 1, color: AppColors.border),
          
          InkWell(
            onTap: widget.onLogout,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.logout, color: AppColors.red, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.red, fontFamily: 'Nunito')),
                ],
              ),
            ),
          ),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: const Text('JanaSetu v1.0.2 (Build 42)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark, fontFamily: 'Nunito')),
          ],
        ),
      ],
    );
  }

  // Notice we added the VoidCallback here!
  Widget _buildMenuTile(IconData icon, String title, String subtitle, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.grey),
      onTap: onTap, 
    );
  }
}