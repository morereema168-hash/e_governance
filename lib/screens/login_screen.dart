import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- ADDED THIS FOR WEB SUPPORT
import 'package:image_picker/image_picker.dart'; 
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UI inspired by the Nagar Panchayat Seva reference design
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  final Function(AppUser) onLogin;
  const LoginScreen({super.key, required this.onLogin});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {

  String _mode = 'home';
  int    _step = 0;

  bool   _loading  = false;
  String _err      = '';
  bool   _locationAsked = false;

  late AnimationController _fadeCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _shakeAnim;

  // ── SCANNING ANIMATION STATE ──
  late AnimationController _scanCtrl;
  late Animation<double>   _scanAnim;
  bool _isScanning = false;
  XFile? _capturedImage; // <-- CHANGED from File? to XFile? for Web compatibility

  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  bool  _showPass    = false;
  String? _quickRole;

  final _otpPhoneCtrl = TextEditingController();
  final _otpCodeCtrl  = TextEditingController();

  final _firstNameCtrl   = TextEditingController();
  final _middleNameCtrl  = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _regPhoneCtrl    = TextEditingController();
  final _regOtpCtrl      = TextEditingController();
  bool  _idUploaded      = false;
  final _epicCtrl        = TextEditingController();
  final _ocrNameCtrl     = TextEditingController();
  final _ocrDobCtrl      = TextEditingController();
  final _ocrAddressCtrl  = TextEditingController();
  String _ward           = '';
  final _currentAddrCtrl = TextEditingController();
  final _taxNoCtrl       = TextEditingController();
  bool   _isTenant       = false;
  final _newPassCtrl     = TextEditingController();
  final _confPassCtrl    = TextEditingController();
  bool  _showNewPass     = false;
  bool  _showConfPass    = false;

  static const _demoOtp = '123456';

  // ── THE WIZARD OF OZ DEMO DATA ──
  int _demoCardIndex = 0;
  final List<Map<String, String>> _fakeVoterCards = [
    {
      'epic': 'MH/14/123/111111',
      'name': 'RAHUL SURESH DESAI',
      'dob': '12/04/1990',
      'address': 'Plot 45, Shivaji Nagar, Rampur - 431001'
    },
    {
      'epic': 'MH/14/123/222222',
      'name': 'PRIYA ANIL KADAM',
      'dob': '08/11/1988',
      'address': 'Flat 12, Green Park Heights, Rampur - 431002'
    },
    {
      'epic': 'MH/14/123/333333',
      'name': 'VIKRAM MANOJ MORE',
      'dob': '23/07/1995',
      'address': '8A, Main Market Road, Rampur - 431001'
    },
  ];

  static const _btnGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
    begin: Alignment.centerLeft, end: Alignment.centerRight,
  );

  @override void initState() {
    super.initState();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _shakeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    // The Laser Scan Animation (sweeps back and forth)
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOutSine));

    WidgetsBinding.instance.addPostFrameCallback((_) => _showLocationDialog());
  }

  @override void dispose() {
    _fadeCtrl.dispose(); 
    _shakeCtrl.dispose();
    _scanCtrl.dispose();
    for (final c in [_phoneCtrl, _passCtrl, _otpPhoneCtrl, _otpCodeCtrl,
                     _firstNameCtrl, _middleNameCtrl, _lastNameCtrl,
                     _regPhoneCtrl, _regOtpCtrl, _epicCtrl, _ocrNameCtrl,
                     _ocrDobCtrl, _ocrAddressCtrl, _currentAddrCtrl,
                     _taxNoCtrl, _newPassCtrl, _confPassCtrl]) c.dispose();
    super.dispose();
  }

  void _setErr(String e) {
    _shakeCtrl.forward(from: 0);
    setState(() { _err = e; _loading = false; });
  }

  void _showLocationDialog() {
    if (_locationAsked) return;
    _locationAsked = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)]),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF00BFA5).withOpacity(0.35),
                  blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.location_on, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 20),
            const Text('Allow Location Access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  fontFamily: 'Nunito', color: Color(0xFF0D1B3E))),
            const SizedBox(height: 10),
            const Text(
              'JanaSetu requires your location to identify your Nagar Panchayat ward, route civic complaints to the correct official, and display services relevant to your area.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54,
                  fontFamily: 'Nunito', height: 1.55)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10)),
              child: Row(children: const [
                Icon(Icons.shield_outlined, size: 14, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Expanded(child: Text(
                  'Your location is only used for civic services and is never shared with third parties.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontFamily: 'Nunito'))),
              ]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _btnGradient,
                  borderRadius: BorderRadius.circular(14)),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Allow Location',
                    style: TextStyle(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not Now',
                style: TextStyle(color: Colors.black45, fontSize: 13, fontFamily: 'Nunito')),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _loginWithPassword() async {
    if (_phoneCtrl.text.trim().length < 10) { _setErr('Please enter a valid 10-digit mobile number.'); return; }
    if (_passCtrl.text.isEmpty) { _setErr('Account password is required.'); return; }
    setState(() { _loading = true; _err = ''; _quickRole = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (_passCtrl.text == 'pass123') {
      widget.onLogin(USERS['amit@gmail.com']!);
    } else {
      _setErr('Incorrect password. (Demo: pass123)');
    }
  }

  void _quickLogin(String email, String role) {
    setState(() { _quickRole = role; _loading = true; _err = ''; });
    Future.delayed(const Duration(milliseconds: 700), () {
      final u = USERS[email];
      if (u != null) widget.onLogin(u);
    });
  }

  Future<void> _sendOtp() async {
    if (_otpPhoneCtrl.text.trim().length < 10) { _setErr('Please enter a valid 10-digit mobile number.'); return; }
    setState(() { _loading = true; _err = ''; });
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() { _loading = false; _step = 1; });
  }

  Future<void> _verifyOtp() async {
    if (_otpCodeCtrl.text.trim() != _demoOtp) { _setErr('The OTP entered is incorrect. (Demo: $_demoOtp)'); return; }
    setState(() { _loading = true; _err = ''; });
    await Future.delayed(const Duration(milliseconds: 700));
    widget.onLogin(USERS['amit@gmail.com']!);
  }

  Future<void> _sendRegOtp() async {
    if (_lastNameCtrl.text.trim().isEmpty) { _setErr('Surname is required.'); return; }
    if (_firstNameCtrl.text.trim().isEmpty) { _setErr('First name is required.'); return; }
    if (_regPhoneCtrl.text.trim().length < 10) { _setErr('Please enter a valid 10-digit mobile number.'); return; }
    setState(() { _loading = true; _err = ''; });
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() { _loading = false; _step = 1; });
  }

  Future<void> _verifyRegOtp() async {
    if (_regOtpCtrl.text.trim() != _demoOtp) { _setErr('The OTP entered is incorrect. (Demo: $_demoOtp)'); return; }
    setState(() { _loading = true; _err = ''; });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() { _loading = false; _step = 2; });
  }

  // ── THE REAL CAMERA & SCANNING MAGIC ──
  Future<void> _takePictureAndScan() async {
    final ImagePicker picker = ImagePicker();
    // Open the native camera
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    
    if (photo != null) {
      setState(() {
        _capturedImage = photo; // <-- Use the XFile directly
        _isScanning = true;
      });

      // Start the laser sweeping animation back and forth
      _scanCtrl.repeat(reverse: true);

      // Let it scan for 3 seconds so the judges can watch it
      await Future.delayed(const Duration(seconds: 3));

      _scanCtrl.stop();
      setState(() {
        _isScanning = false;
        _idUploaded = true;
      });
    }
  }

  Future<void> _simulateOcr() async {
    setState(() { _loading = true; _err = ''; });
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Pull the next fake card profile
    final fakeProfile = _fakeVoterCards[_demoCardIndex];
    
    _epicCtrl.text       = fakeProfile['epic']!;
    _ocrNameCtrl.text    = fakeProfile['name']!;
    _ocrDobCtrl.text     = fakeProfile['dob']!;
    _ocrAddressCtrl.text = fakeProfile['address']!;

    // Move to the next card index for the next time you demo it
    _demoCardIndex = (_demoCardIndex + 1) % _fakeVoterCards.length;

    setState(() { _loading = false; _step = 3; });
  }

  void _confirmOcr() {
    if (_epicCtrl.text.trim().isEmpty) { _setErr('Electoral ID (EPIC) number is required.'); return; }
    setState(() { _err = ''; _step = 4; });
  }

  void _submitResidency() {
    if (_ward.isEmpty) { _setErr('Ward selection is mandatory.'); return; }
    if (_currentAddrCtrl.text.trim().isEmpty) { _setErr('Current residential address is required.'); return; }
    setState(() { _err = ''; _step = 5; });
  }

  Future<void> _createAccount() async {
    if (_newPassCtrl.text.length < 6) { _setErr('Password must be a minimum of 6 characters.'); return; }
    if (_newPassCtrl.text != _confPassCtrl.text) { _setErr('The passwords entered do not match.'); return; }
    setState(() { _loading = true; _err = ''; });
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final nameToUse = _ocrNameCtrl.text.isNotEmpty 
        ? _ocrNameCtrl.text 
        : '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';

    final nameParts = nameToUse.split(' ').where((w) => w.isNotEmpty).toList();
    final initials = nameParts.length >= 2 
        ? '${nameParts[0][0]}${nameParts.last[0]}'.toUpperCase()
        : (nameParts.isNotEmpty ? nameParts[0][0].toUpperCase() : 'U');

    widget.onLogin(AppUser(
      email: _regPhoneCtrl.text.trim(), 
      name: nameToUse,
      role: 'citizen', 
      avatar: initials, 
      ward: _ward
    ));
  }

  @override Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      body: Stack(children: [
        _scenicBackground(),
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: isWide ? _wideLayout() : _narrowLayout(),
          ),
        ),
      ]),
    );
  }

  Widget _scenicBackground() {
    return Container(
      width: double.infinity, height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFB3E5FC), Color(0xFFFFCCBC), Color(0xFFDCEDC8)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(children: [
        Positioned(top: -60, right: -40,
          child: Container(width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFFFFCC02).withOpacity(0.55),
                Colors.transparent])),
          )),
        Positioned(bottom: 0, left: 0, right: 0,
          child: SizedBox(
            height: 140,
            child: CustomPaint(painter: _CitySilhouettePainter()),
          )),
      ]),
    );
  }

  Widget _wideLayout() {
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(flex: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 56),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            _logoWidget(size: 72),
            const SizedBox(height: 22),
            const Text('JanaSetu',
              style: TextStyle(color: Color(0xFF0D1B3E), fontSize: 38,
                  fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
            const Text('नागर पंचायत सेवा',
              style: TextStyle(color: Color(0xFF1A3468), fontSize: 16,
                  fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
            const SizedBox(height: 10),
            const Text('Digital Governance Platform\nfor Rampur Nagar Panchayat',
              style: TextStyle(color: Colors.black54, fontSize: 14,
                  fontFamily: 'Nunito', height: 1.6)),
            const SizedBox(height: 36),
            const Divider(color: Colors.black12),
            const SizedBox(height: 28),
            for (final f in [
              [Icons.how_to_vote_outlined,       'Ranked Choice Voting'],
              [Icons.assignment_outlined,         'Report Civic Issues'],
              [Icons.dashboard_outlined,          'Transparent Budget Tracker'],
              [Icons.volunteer_activism_outlined, 'Community Fundraising'],
            ])
              Padding(padding: const EdgeInsets.only(bottom: 18), child: Row(children: [
                Container(padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(f[0] as IconData, color: const Color(0xFF00897B), size: 18)),
                const SizedBox(width: 12),
                Text(f[1] as String, style: const TextStyle(color: Color(0xFF1A3468),
                    fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
              ])),
          ]),
        )),
      Expanded(flex: 4,
        child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: _buildCard(maxWidth: 440),
        ))),
      Expanded(flex: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Quick Access',
              style: TextStyle(color: Color(0xFF0D1B3E), fontSize: 20,
                  fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
            const SizedBox(height: 6),
            const Text('Sign in instantly with a demo account\nto explore the platform.',
              style: TextStyle(color: Colors.black54, fontSize: 13,
                  fontFamily: 'Nunito', height: 1.5)),
            const SizedBox(height: 28),
            _roleCard(role: 'Mayor',      name: 'Ramesh Patil',
              subtitle: 'Full administrative access',
              email: 'mayor@np.gov', icon: Icons.account_balance,
              color: const Color(0xFF1A3468)),
            const SizedBox(height: 12),
            _roleCard(role: 'Nagar Sevak', name: 'Sunita Jadhav',
              subtitle: 'Ward 3 Supervisor',
              email: 'sevak@np.gov', icon: Icons.supervisor_account,
              color: const Color(0xFF1565C0)),
            const SizedBox(height: 12),
            _roleCard(role: 'Citizen',    name: 'Amit Sharma',
              subtitle: 'Ward 3 Resident',
              email: 'amit@gmail.com', icon: Icons.person_outline,
              color: const Color(0xFF00897B)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12)),
              child: Row(children: const [
                Icon(Icons.info_outline, size: 14, color: Colors.black45),
                SizedBox(width: 8),
                Expanded(child: Text('Demo password: pass123',
                  style: TextStyle(color: Colors.black45, fontSize: 12, fontFamily: 'Nunito'))),
              ]),
            ),
          ]),
        )),
    ]);
  }

  Widget _narrowLayout() {
    return SingleChildScrollView(
      child: Column(children: [
        const SizedBox(height: 32),
        _buildCard(maxWidth: double.infinity, mobilePadding: 20),
        const SizedBox(height: 24),
        _mobileQuickAccess(),
        const SizedBox(height: 28),
      ]),
    );
  }

  Widget _mobileQuickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Access',
          style: TextStyle(color: Color(0xFF0D1B3E), fontSize: 14,
              fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _mobileRoleChip('Mayor',   'mayor@np.gov',   Icons.account_balance,    const Color(0xFF1A3468))),
          const SizedBox(width: 8),
          Expanded(child: _mobileRoleChip('Sevak',   'sevak@np.gov',   Icons.supervisor_account, const Color(0xFF1565C0))),
          const SizedBox(width: 8),
          Expanded(child: _mobileRoleChip('Citizen', 'amit@gmail.com', Icons.person_outline,     const Color(0xFF00897B))),
        ]),
      ]),
    );
  }

  Widget _mobileRoleChip(String label, String email, IconData icon, Color color) {
    final isActive = _quickRole == label && _loading;
    return GestureDetector(
      onTap: _loading ? null : () => _quickLogin(email, label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? color : color.withOpacity(0.3), width: 1.5)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 20, color: isActive ? Colors.white : color),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : color, fontFamily: 'Nunito')),
        ]),
      ),
    );
  }

  Widget _buildCard({required double maxWidth, double mobilePadding = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mobilePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 40, offset: const Offset(0, 16))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(children: [
                  _cardHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                    child: _shakeWrapper(_cardContent()),
                  ),
                  _cardFooter(),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardHeader() {
    if (_mode == 'register' || (_mode == 'otp' && _step > 0)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
      child: Column(children: [
        _logoWidget(size: 72),
        const SizedBox(height: 14),
        const Text('JANASETU',
          style: TextStyle(color: Color(0xFF0D1B3E), fontSize: 13,
              fontWeight: FontWeight.w900, letterSpacing: 2.5, fontFamily: 'Nunito')),
        const Text('नागर पंचायत सेवा',
          style: TextStyle(color: Color(0xFF1A3468), fontSize: 13,
              fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
        const SizedBox(height: 18),
        const Text('Welcome / स्वागत आहे',
          style: TextStyle(color: Color(0xFF0D1B3E), fontSize: 22,
              fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Log in to access your local services',
          style: TextStyle(color: Colors.black45, fontSize: 13, fontFamily: 'Nunito')),
        const SizedBox(height: 6),
      ]),
    );
  }

  Widget _cardFooter() {
    return Column(children: [
      const Divider(height: 1, color: Color(0xFFF0F0F0)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.shield_outlined, size: 13, color: Color(0xFF00897B)),
          SizedBox(width: 6),
          Text('Secure & Official App  |  Nagar Panchayat, Maharashtra',
            style: TextStyle(fontSize: 10.5, color: Colors.black38,
                fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
        ]),
      ),
    ]);
  }

  Widget _shakeWrapper(Widget child) => AnimatedBuilder(
    animation: _shakeAnim,
    builder: (context, c) {
      final dx = _err.isNotEmpty ? 8 * (0.5 - (_shakeAnim.value - 0.5).abs()) : 0.0;
      return Transform.translate(offset: Offset(dx, 0), child: c);
    },
    child: child,
  );

  Widget _cardContent() {
    if (_mode == 'otp')      return _otpLoginFlow();
    if (_mode == 'register') return _registerFlow();
    return _homeLoginForm();
  }

  Widget _homeLoginForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _phoneField(_phoneCtrl, onSubmitted: null),
      const SizedBox(height: 14),
      TextField(
        controller: _passCtrl, obscureText: !_showPass,
        decoration: InputDecoration(
          hintText: 'Password / पासवर्ड',
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14, fontFamily: 'Nunito'),
          prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.black38),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _showPass = !_showPass),
            child: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18, color: Colors.black38)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.8)),
          filled: true, fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
        onSubmitted: (_) => _loginWithPassword()),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
          child: const Text('Forgot Password?',
            style: TextStyle(color: Color(0xFF00897B), fontSize: 12,
                fontWeight: FontWeight.w700, fontFamily: 'Nunito')))),
      _errBox(),
      const SizedBox(height: 16),
      _gradientButton(
        label: _loading ? 'Authenticating…' : 'LOG IN  →',
        onTap: _loading ? null : _loginWithPassword),
      const SizedBox(height: 20),
      Row(children: const [
        Expanded(child: Divider(color: Color(0xFFDDDDDD))),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR', style: TextStyle(fontSize: 12, color: Colors.black38,
              fontWeight: FontWeight.w700, fontFamily: 'Nunito'))),
        Expanded(child: Divider(color: Color(0xFFDDDDDD))),
      ]),
      const SizedBox(height: 16),
      Center(child: GestureDetector(
        onTap: () => setState(() { _mode = 'otp'; _step = 0; _err = ''; }),
        child: RichText(text: const TextSpan(
          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
          children: [
            TextSpan(text: 'Log in with OTP\n',
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0D1B3E))),
            TextSpan(text: 'OTP सह लॉगिन करा',
              style: TextStyle(color: Colors.black45, fontSize: 12)),
          ])))),
      const SizedBox(height: 14),
      Center(child: GestureDetector(
        onTap: () => setState(() { _mode = 'register'; _step = 0; _err = ''; }),
        child: RichText(text: const TextSpan(
          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
          children: [
            TextSpan(text: 'New User? Register Now\n',
              style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF00897B))),
            TextSpan(text: 'नवीन वापरकर्ता? नोंदणी करा',
              style: TextStyle(color: Colors.black45, fontSize: 12)),
          ])))),
      const SizedBox(height: 8),
    ]);
  }

  Widget _gradientButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: onTap == null ? null : _btnGradient,
            color: onTap == null ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: onTap == null ? [] : [BoxShadow(
              color: const Color(0xFF00BFA5).withOpacity(0.4),
              blurRadius: 16, offset: const Offset(0, 6))]),
          child: Center(child: _loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Nunito'))),
        ),
      ),
    );
  }

  Widget _phoneField(TextEditingController ctrl, {void Function(String)? onSubmitted}) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      decoration: InputDecoration(
        hintText: 'Mobile Number / मोबाईल क्रमांक',
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14, fontFamily: 'Nunito'),
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            Text('🇮🇳', style: TextStyle(fontSize: 18)),
            SizedBox(width: 6),
            Text('+91', style: TextStyle(fontWeight: FontWeight.w800,
                fontSize: 14, color: Color(0xFF0D1B3E), fontFamily: 'Nunito')),
            SizedBox(width: 8),
            SizedBox(height: 20, child: VerticalDivider(width: 1, color: Color(0xFFDDDDDD))),
          ]),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.8)),
        filled: true, fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
      onSubmitted: onSubmitted,
    );
  }

  Widget _otpLoginFlow() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _backLink(onTap: () => setState(() { _mode = 'home'; _step = 0; _err = ''; })),
      const SizedBox(height: 16),
      _stepHeader(
        title:    _step == 0 ? 'Log In with OTP' : 'One-Time Password Verification',
        subtitle: _step == 0
          ? 'Enter your registered mobile number to receive an OTP.'
          : 'A 6-digit OTP has been dispatched to +91 ${_otpPhoneCtrl.text}.',
      ),
      const SizedBox(height: 20),
      if (_step == 0) ...[
        _phoneField(_otpPhoneCtrl),
        _errBox(),
        const SizedBox(height: 20),
        _gradientButton(
          label: _loading ? 'Dispatching OTP…' : 'Send One-Time Password',
          onTap: _loading ? null : _sendOtp),
      ],
      if (_step == 1) ...[
        _otpSentBadge(_otpPhoneCtrl.text),
        const SizedBox(height: 16),
        _label('ONE-TIME PASSWORD (OTP)'),
        const SizedBox(height: 8),
        TextField(
          controller: _otpCodeCtrl, keyboardType: TextInputType.number, maxLength: 6,
          textAlign: TextAlign.center,
          decoration: _otpFieldDecor(),
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 24,
              fontWeight: FontWeight.w900, letterSpacing: 12)),
        const SizedBox(height: 8),
        _demoOtpHint(),
        _errBox(),
        const SizedBox(height: 20),
        _gradientButton(
          label: _loading ? 'Verifying…' : 'Verify & Sign In',
          onTap: _loading ? null : _verifyOtp),
        const SizedBox(height: 10),
        Center(child: TextButton(
          onPressed: () => setState(() { _step = 0; _err = ''; }),
          child: const Text('← Return to Previous Step',
            style: TextStyle(color: Color(0xFF00897B), fontFamily: 'Nunito',
                fontWeight: FontWeight.w700)))),
      ],
      const SizedBox(height: 8),
    ]);
  }

  static const _regTitles = [
    'Applicant Particulars', 'Mobile Verification',
    'Identity Document Upload', 'Document Data Verification',
    'Residence & Ward Details', 'Set Account Password',
  ];
  static const _regSubtitles = [
    'Provide your legal name and registered mobile number as per official records.',
    'A 6-digit One-Time Password has been dispatched to your registered mobile number.',
    'Please submit a legible photograph of your Voter ID card (front and reverse).',
    'Review the data extracted from your identity document. Amend any inaccuracies prior to submission.',
    'Specify your ward and residential address to enable accurate routing of civic requests.',
    'Establish a secure password to finalise your JanaSetu account registration.',
  ];

  Widget _registerFlow() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _backLink(onTap: () => _step > 0
      ? setState(() { _step--; _err = ''; })
      : setState(() { _mode = 'home'; _step = 0; _err = ''; })),
    const SizedBox(height: 16),
    _regProgressBar(),
    const SizedBox(height: 16),
    _stepHeader(title: _regTitles[_step], subtitle: _regSubtitles[_step]),
    const SizedBox(height: 20),
    if (_step == 0) _regStep0(),
    if (_step == 1) _regStep1(),
    if (_step == 2) _regStep2(),
    if (_step == 3) _regStep3(),
    if (_step == 4) _regStep4(),
    if (_step == 5) _regStep5(),
    _errBox(),
    const SizedBox(height: 20),
    if (_step == 0) _gradientButton(
      label: _loading ? 'Dispatching OTP…' : 'Continue — Send Verification OTP',
      onTap: _loading ? null : _sendRegOtp),
    if (_step == 1) _gradientButton(
      label: _loading ? 'Verifying…' : 'Verify One-Time Password',
      onTap: _loading ? null : _verifyRegOtp),
    if (_step == 2 && _idUploaded) _gradientButton(
      label: _loading ? 'Processing Document…' : 'Extract Data via OCR',
      onTap: _loading ? null : _simulateOcr),
    if (_step == 3) _gradientButton(
      label: 'Confirm Details & Proceed',
      onTap: _confirmOcr),
    if (_step == 4) _gradientButton(
      label: 'Save Residence Details & Proceed',
      onTap: _submitResidency),
    if (_step == 5) _gradientButton(
      label: _loading ? 'Registering Account…' : 'Complete Registration & Sign In',
      onTap: _loading ? null : _createAccount),
    const SizedBox(height: 8),
  ]);

  Widget _regStep0() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('SURNAME (Last Name)'),
    const SizedBox(height: 8),
    _textField(_lastNameCtrl, hint: 'e.g. Sharma', icon: Icons.person_outline),
    const SizedBox(height: 14),
    _label('FIRST NAME (Given Name)'),
    const SizedBox(height: 8),
    _textField(_firstNameCtrl, hint: 'e.g. Amit', icon: Icons.person_outline),
    const SizedBox(height: 14),
    _label("MIDDLE NAME / FATHER'S NAME (Optional)"),
    const SizedBox(height: 8),
    _textField(_middleNameCtrl, hint: 'e.g. Ramesh', icon: Icons.person_outline),
    const SizedBox(height: 10),
    _infoBanner('Please enter your name exactly as it appears on your Voter ID card.',
        const Color(0xFF00897B), const Color(0xFFE0F2F1)),
    const SizedBox(height: 14),
    _label('REGISTERED MOBILE NUMBER'),
    const SizedBox(height: 8),
    _phoneField(_regPhoneCtrl),
  ]);

  Widget _regStep1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _otpSentBadge(_regPhoneCtrl.text),
    const SizedBox(height: 16),
    _label('ONE-TIME PASSWORD (OTP)'),
    const SizedBox(height: 8),
    TextField(
      controller: _regOtpCtrl, keyboardType: TextInputType.number, maxLength: 6,
      textAlign: TextAlign.center,
      decoration: _otpFieldDecor(),
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 24,
          fontWeight: FontWeight.w900, letterSpacing: 12)),
    const SizedBox(height: 8),
    _demoOtpHint(),
  ]);

  Widget _regStep2() => Column(children: [
    GestureDetector(
      onTap: () {
        if (!_idUploaded && !_isScanning) {
          _takePictureAndScan(); // Trigger the native camera!
        }
      },
      child: Container(
        width: double.infinity, height: 180,
        clipBehavior: Clip.hardEdge, // ensure the image doesn't bleed out of rounded corners
        decoration: BoxDecoration(
          color: _idUploaded ? const Color(0xFFE0F2F1) : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _idUploaded
                ? const Color(0xFF00897B).withOpacity(0.6)
                : const Color(0xFF00BFA5).withOpacity(0.4),
            width: 2)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // If we took a picture, show it as the background
            // ── ADDED WEB COMPATIBILITY HERE ──
            if (_capturedImage != null)
              Positioned.fill(
                child: kIsWeb
                  ? Image.network(_capturedImage!.path, fit: BoxFit.cover)
                  : Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
              ),

            // If we are currently scanning, show the sweeping laser
            if (_isScanning)
              AnimatedBuilder(
                animation: _scanAnim,
                builder: (context, child) {
                  return Positioned(
                    top: _scanAnim.value * 170, // Sweeps across height
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        boxShadow: [
                          BoxShadow(color: Colors.greenAccent.withOpacity(0.8), blurRadius: 12, spreadRadius: 3),
                          BoxShadow(color: Colors.white, blurRadius: 4),
                        ]
                      )
                    )
                  );
                }
              ),

            // The UI text/icons overlay
            if (!_isScanning) 
              Container(
                color: _capturedImage != null ? Colors.black54 : Colors.transparent, // Darken image behind text
                width: double.infinity,
                height: double.infinity,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _idUploaded
                          ? const Color(0xFF00897B).withOpacity(_capturedImage != null ? 0.9 : 0.12)
                          : const Color(0xFF00BFA5).withOpacity(0.1),
                      shape: BoxShape.circle),
                    child: Icon(
                      _idUploaded ? Icons.check_circle_outline : Icons.credit_card,
                      size: 32,
                      color: _idUploaded 
                        ? (_capturedImage != null ? Colors.white : const Color(0xFF00897B)) 
                        : const Color(0xFF00BFA5))),
                  const SizedBox(height: 10),
                  Text(
                    _idUploaded ? 'Document Scanned Successfully ✓' : 'Electoral Photo Identity Card',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito',
                      color: _idUploaded 
                        ? (_capturedImage != null ? Colors.white : const Color(0xFF00897B)) 
                        : const Color(0xFF0D1B3E))),
                  const SizedBox(height: 4),
                  Text(
                    _idUploaded ? 'Tap "Extract Data via OCR" below to proceed' : 'Tap to scan physical card',
                    style: TextStyle(fontSize: 11, fontFamily: 'Nunito',
                      color: _capturedImage != null ? Colors.white70 : Colors.black45)),
                  
                  if (!_idUploaded) ...[
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _uploadChip(Icons.camera_alt_outlined, 'Camera'),
                      const SizedBox(width: 10),
                      _uploadChip(Icons.photo_library_outlined, 'Gallery'),
                    ]),
                  ],
                ]),
              ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 14),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        for (final tip in [
          ['📸', 'Ensure adequate lighting with no shadows across the document'],
          ['📄', 'Include photographs of both front and reverse sides of the card'],
          ['🔍', 'The EPIC / Electoral Roll Number must be fully legible'],
        ])
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Text(tip[0], style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(child: Text(tip[1],
              style: const TextStyle(fontSize: 12, color: Color(0xFF1565C0), fontFamily: 'Nunito'))),
          ])),
      ]),
    ),
    if (_loading) Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
        SizedBox(width: 16, height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00BFA5))),
        SizedBox(width: 10),
        Text('Running Optical Character Recognition…',
          style: TextStyle(fontSize: 12, color: Colors.black45, fontFamily: 'Nunito')),
      ])),
  ]);

  Widget _uploadChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF00BFA5).withOpacity(0.09),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.4))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: const Color(0xFF00897B)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: Color(0xFF00897B), fontFamily: 'Nunito')),
    ]),
  );

  Widget _regStep3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _infoBanner('Identity document processed successfully. Review all fields and correct any discrepancies.',
        const Color(0xFF00897B), const Color(0xFFE0F2F1)),
    const SizedBox(height: 16),
    _label('EPIC / VOTER ID NUMBER'),
    const SizedBox(height: 8),
    _textField(_epicCtrl, hint: 'e.g. MH/14/123/456789', icon: Icons.badge_outlined),
    const SizedBox(height: 14),
    _label('NAME AS PER IDENTITY DOCUMENT'),
    const SizedBox(height: 8),
    _textField(_ocrNameCtrl, hint: '', icon: Icons.person_outline),
    const SizedBox(height: 14),
    _label('DATE OF BIRTH'),
    const SizedBox(height: 8),
    _textField(_ocrDobCtrl, hint: 'DD/MM/YYYY', icon: Icons.cake_outlined),
    const SizedBox(height: 14),
    _label('PERMANENT ADDRESS (AS PER VOTER ID)'),
    const SizedBox(height: 8),
    TextField(controller: _ocrAddressCtrl, maxLines: 2,
      decoration: InputDecoration(
        prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 24),
          child: Icon(Icons.home_outlined, size: 18, color: Colors.black38)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.8)),
        filled: true, fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
    const SizedBox(height: 10),
    _infoBanner('Optical character recognition may misread similar characters (e.g. "0"/"O", "1"/"I"). Verify all fields carefully.',
        const Color(0xFFE65100), const Color(0xFFFFF3E0)),
  ]);

  Widget _regStep4() {
    final wards = List.generate(12, (i) => 'Ward ${i + 1}');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('WARD NUMBER *'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFAFAFA)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: _ward.isEmpty ? null : _ward,
          isExpanded: true,
          hint: const Text('Select your ward',
            style: TextStyle(fontFamily: 'Nunito', color: Colors.black38)),
          style: const TextStyle(fontFamily: 'Nunito', color: Color(0xFF0D1B3E), fontSize: 14),
          items: wards.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
          onChanged: (v) => setState(() => _ward = v ?? ''),
        ))),
      const SizedBox(height: 16),
      Row(children: [
        Switch(value: _isTenant, onChanged: (v) => setState(() => _isTenant = v),
            activeColor: const Color(0xFF00897B)),
        const SizedBox(width: 8),
        const Expanded(child: Text('I am a tenant — current address differs from Voter ID',
          style: TextStyle(fontSize: 12, fontFamily: 'Nunito', color: Colors.black54))),
      ]),
      const SizedBox(height: 12),
      _label(_isTenant ? 'CURRENT RESIDENTIAL ADDRESS *' : 'RESIDENTIAL ADDRESS *'),
      const SizedBox(height: 8),
      TextField(controller: _currentAddrCtrl, maxLines: 2,
        decoration: InputDecoration(
          hintText: _isTenant
              ? 'Your current rental address in Rampur'
              : 'Your residential address',
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 24),
            child: Icon(Icons.location_on_outlined, size: 18, color: Colors.black38)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.8)),
          filled: true, fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
      const SizedBox(height: 14),
      _label('PROPERTY / HOUSE TAX ASSESSMENT NUMBER (Optional)'),
      const SizedBox(height: 8),
      _textField(_taxNoCtrl, hint: 'e.g. RPR/2024/00123', icon: Icons.receipt_outlined),
      const SizedBox(height: 10),
      _infoBanner('Your ward assignment ensures civic complaints are routed to the correct official.',
          const Color(0xFF00897B), const Color(0xFFE0F2F1)),
    ]);
  }

  Widget _regStep5() {
    final nameParts = _ocrNameCtrl.text.split(' ').where((w) => w.isNotEmpty).toList();
    final initials = nameParts.length >= 2 
        ? '${nameParts[0][0]}${nameParts.last[0]}'.toUpperCase()
        : (nameParts.isNotEmpty ? nameParts[0][0].toUpperCase() : 'U');
    final fullName = _ocrNameCtrl.text;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D1B3E), Color(0xFF1A3468)]),
          borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(width: 46, height: 46,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15)),
            child: Center(child: Text(initials,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16,
                  color: Colors.white, fontFamily: 'Nunito')))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14,
                color: Colors.white, fontFamily: 'Nunito')),
            Text('$_ward · Citizen',
              style: const TextStyle(fontSize: 11, color: Colors.white54, fontFamily: 'Nunito')),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF00897B), borderRadius: BorderRadius.circular(20)),
            child: const Text('Identity Verified ✓',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Nunito'))),
        ]),
      ),
      _label('SET NEW PASSWORD'),
      const SizedBox(height: 8),
      TextField(controller: _newPassCtrl, obscureText: !_showNewPass,
        decoration: InputDecoration(
          hintText: 'Minimum 6 characters',
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.black38),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _showNewPass = !_showNewPass),
            child: Icon(_showNewPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18, color: Colors.black38)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.8)),
          filled: true, fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
      const SizedBox(height: 14),
      _label('CONFIRM PASSWORD'),
      const SizedBox(height: 8),
      TextField(controller: _confPassCtrl, obscureText: !_showConfPass,
        decoration: InputDecoration(
          hintText: 'Re-enter your password',
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.black38),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _showConfPass = !_showConfPass),
            child: Icon(_showConfPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18, color: Colors.black38)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.8)),
          filled: true, fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
    ]);
  }

  Widget _logoWidget({double size = 80}) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * 0.26),
      gradient: const LinearGradient(
        colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      boxShadow: [BoxShadow(
        color: const Color(0xFF00BFA5).withOpacity(0.45),
        blurRadius: 24, offset: const Offset(0, 8))],
    ),
    child: Icon(Icons.account_balance, size: size * 0.48, color: Colors.white),
  );

  Widget _roleCard({
    required String role, required String name, required String subtitle,
    required String email, required IconData icon, required Color color,
  }) {
    final isActive = _quickRole == role && _loading;
    return GestureDetector(
      onTap: _loading ? null : () => _quickLogin(email, role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.25), width: 1.5),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: isActive ? Colors.white : color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(role, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13,
                color: isActive ? Colors.white : const Color(0xFF0D1B3E), fontFamily: 'Nunito')),
            Text(name, style: TextStyle(fontSize: 12,
                color: isActive ? Colors.white70 : Colors.black54, fontFamily: 'Nunito')),
            Text(subtitle, style: TextStyle(fontSize: 11,
                color: isActive ? Colors.white54 : Colors.black38, fontFamily: 'Nunito')),
          ])),
          if (isActive)
            const SizedBox(width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          else
            Icon(Icons.arrow_forward_ios, size: 11, color: color.withOpacity(0.5)),
        ]),
      ),
    );
  }

  Widget _stepHeader({required String title, required String subtitle}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
            fontFamily: 'Nunito', color: Color(0xFF0D1B3E))),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(fontSize: 12.5, color: Colors.black45,
            fontFamily: 'Nunito', height: 1.5)),
      ]);

  Widget _regProgressBar() {
    const total  = 6;
    const labels = ['Identity', 'OTP', 'Voter ID', 'Confirm', 'Residency', 'Password'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Step ${_step + 1} of $total',
          style: const TextStyle(fontSize: 11, color: Colors.black45, fontFamily: 'Nunito')),
        Text(labels[_step],
          style: const TextStyle(fontSize: 11, color: Color(0xFF00897B),
              fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: (_step + 1) / total, minHeight: 6,
          backgroundColor: const Color(0xFF00BFA5).withOpacity(0.12),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF00BFA5)))),
    ]);
  }

  Widget _backLink({required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: const Text('← Return to Previous Step',
      style: TextStyle(color: Color(0xFF00897B), fontSize: 12,
          fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
  );

  Widget _label(String t) => Text(t,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
        color: Colors.black45, letterSpacing: 0.5, fontFamily: 'Nunito'));

  InputDecoration _otpFieldDecor() => InputDecoration(
    hintText: '• • • • • •', counterText: '',
    hintStyle: const TextStyle(color: Colors.black26, letterSpacing: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.8)),
    filled: true, fillColor: const Color(0xFFFAFAFA),
    contentPadding: const EdgeInsets.symmetric(vertical: 16));

  Widget _textField(TextEditingController ctrl, {required String hint, required IconData icon}) =>
      TextField(
        controller: ctrl,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: Icon(icon, size: 18, color: Colors.black38),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.8)),
          filled: true, fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        style: const TextStyle(fontFamily: 'Nunito', fontSize: 14));

  Widget _otpSentBadge(String phone) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF00897B).withOpacity(0.3))),
    child: Row(children: [
      const Icon(Icons.sms_outlined, color: Color(0xFF00897B), size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text('One-Time Password dispatched to +91 $phone',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            color: Color(0xFF00897B), fontFamily: 'Nunito'))),
    ]),
  );

  Widget _demoOtpHint() => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3))),
    child: Row(children: const [
      Icon(Icons.star_outline, size: 13, color: Color(0xFFFFB300)),
      SizedBox(width: 6),
      Text('Demo OTP: 123456  (Development only)',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: Color(0xFF5D4037), fontFamily: 'Nunito')),
    ]),
  );

  Widget _infoBanner(String msg, Color color, Color bg) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.25))),
    child: Row(children: [
      Icon(Icons.info_outline, size: 13, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: TextStyle(fontSize: 11, color: color, fontFamily: 'Nunito'))),
    ]),
  );

  Widget _errBox() => AnimatedSize(
    duration: const Duration(milliseconds: 200),
    child: _err.isNotEmpty
        ? Padding(padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_err, style: const TextStyle(
                    color: Color(0xFFE53935), fontSize: 12, fontFamily: 'Nunito'))),
              ])))
        : const SizedBox.shrink(),
  );
}

class _CitySilhouettePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB2DFDB).withOpacity(0.55);
    final path  = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h);
    path.lineTo(0, h * 0.55);
    path.lineTo(w * 0.04, h * 0.55);
    path.lineTo(w * 0.04, h * 0.35);
    path.lineTo(w * 0.06, h * 0.25);
    path.lineTo(w * 0.08, h * 0.35);
    path.lineTo(w * 0.10, h * 0.35);
    path.lineTo(w * 0.10, h * 0.45);
    path.lineTo(w * 0.15, h * 0.45);
    path.lineTo(w * 0.15, h * 0.30);
    path.lineTo(w * 0.20, h * 0.30);
    path.lineTo(w * 0.20, h * 0.50);
    path.lineTo(w * 0.28, h * 0.50);
    path.lineTo(w * 0.28, h * 0.40);
    path.lineTo(w * 0.35, h * 0.40);
    path.lineTo(w * 0.35, h * 0.55);
    path.lineTo(w * 0.55, h * 0.55);
    path.lineTo(w * 0.55, h * 0.20);
    path.lineTo(w * 0.62, h * 0.20);
    path.lineTo(w * 0.62, h * 0.10);
    path.lineTo(w * 0.66, h * 0.10);
    path.lineTo(w * 0.66, h * 0.20);
    path.lineTo(w * 0.70, h * 0.20);
    path.lineTo(w * 0.70, h * 0.30);
    path.lineTo(w * 0.76, h * 0.30);
    path.lineTo(w * 0.76, h * 0.15);
    path.lineTo(w * 0.80, h * 0.15);
    path.lineTo(w * 0.80, h * 0.35);
    path.lineTo(w * 0.88, h * 0.35);
    path.lineTo(w * 0.88, h * 0.22);
    path.lineTo(w * 0.93, h * 0.22);
    path.lineTo(w * 0.93, h * 0.40);
    path.lineTo(w, h * 0.40);
    path.lineTo(w, h);
    path.close();
    canvas.drawPath(path, paint);

    final groundPaint = Paint()..color = const Color(0xFFA5D6A7).withOpacity(0.6);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.88, w, h * 0.12), groundPaint);
  }
  @override bool shouldRepaint(_) => false;
}