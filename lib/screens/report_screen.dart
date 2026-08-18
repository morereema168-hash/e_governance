import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart'; // ADDED: Import theme to access AppColors
import '../widgets/shared_widgets.dart';

// Local Mock Report Model
class MockReport {
  final String id;
  final String category;
  final String desc;
  String status; 
  final String time;
  final String ticket;
  final String ward;

  MockReport({
    required this.id, required this.category, required this.desc,
    required this.status, required this.time, required this.ticket,
    required this.ward,
  });
}

class ReportScreen extends StatefulWidget {
  final AppUser user;
  const ReportScreen({super.key, required this.user});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with TickerProviderStateMixin {
  // ── DATA ──────────────────────────────────────────────────────────────────
  final List<MockReport> myReports = [
    MockReport(id: '1', category: 'Water leak',  desc: 'Ward 3 dry since Monday. No water for 3 days.',      status: 'Unresolved',  time: '1d ago', ticket: '#8831', ward: 'Ward 3'),
    MockReport(id: '2', category: 'Potholes',    desc: 'Dangerous pothole on MG Road near the bus stop.',    status: 'In Progress', time: '2d ago', ticket: '#8832', ward: 'Ward 3'),
    MockReport(id: '3', category: 'Drainage',    desc: 'Open drain near school. Children at risk.',          status: 'Resolved',    time: '3d ago', ticket: '#8829', ward: 'Ward 3'),
  ];

  final Set<String> _expanded = {};

  // ── UI STATE ──────────────────────────────────────────────────────────────
  bool   showForm      = false;
  bool   submitting    = false;
  bool   submitted     = false;
  String filterStatus  = 'All';
  String searchQuery   = '';
  final _searchCtrl = TextEditingController();

  // ── FORM STATE (multi-step) ───────────────────────────────────────────────
  int    _step        = 0;
  String selCat       = 'Potholes';
  String customCat    = ''; // Stores user input when "Other" is selected
  bool   hasPhoto     = false;
  final _descCtrl  = TextEditingController();
  final _customCatCtrl = TextEditingController();

  // ── CONSTANTS ─────────────────────────────────────────────────────────────
  final cats = ['Electricity', 'Water leak', 'Potholes', 'Garbage', 'Drainage', 'Other'];
  final filters = ['All', 'Unresolved', 'In Progress', 'Resolved'];

  final Map<String, String> catImages = {
    'Electricity': 'assets/images/Electricity.jpeg',
    'Water leak':  'assets/images/Water leak.jpeg',
    'Potholes':     'assets/images/Potholes.jpeg',
    'Garbage':     'assets/images/Garbage.jpeg',
    'Drainage':    'assets/images/Drainage.jpeg',
    'Other':       'assets/images/Other.jpeg', 
  };

  final catColors = const {
    'Electricity': Colors.amber,
    'Water leak':  Colors.teal,
    'Potholes':     Colors.orange,
    'Garbage':     Colors.green,
    'Drainage':    Colors.blue,
    'Other':       Colors.deepPurple,
  };

  // ── HELPERS ───────────────────────────────────────────────────────────────
  List<MockReport> get filteredReports {
    return myReports.where((r) {
      final matchStatus = filterStatus == 'All' || r.status == filterStatus;
      final matchSearch = searchQuery.isEmpty ||
          r.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
          r.desc.toLowerCase().contains(searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();
  }

  void _submitReport() async {
    if (_descCtrl.text.isEmpty) return;
    setState(() => submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final newId = '${DateTime.now().millisecondsSinceEpoch}';
    
    // If "Other" is selected, use the custom text as the category label
    final finalCategory = selCat == 'Other' && customCat.isNotEmpty ? customCat : selCat;

    setState(() {
      myReports.insert(0, MockReport(
        id:       newId,
        category: finalCategory,
        desc:     _descCtrl.text,
        status:   'Unresolved',
        time:     'Just now',
        ticket:   '#${8860 + myReports.length}',
        ward:     'Ward ${widget.user.ward}',
      ));
      submitting = false;
      submitted  = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      submitted = false;
      showForm  = false;
      _step     = 0;
      _descCtrl.clear();
      _customCatCtrl.clear();
      selCat    = 'Potholes';
      customCat = '';
      hasPhoto  = false;
    });
  }

  void _deleteReport(MockReport r) {
    setState(() => myReports.remove(r));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report withdrawn.', style: TextStyle(fontFamily: 'Nunito')),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.orange,
          onPressed: () {
            setState(() {
              myReports.add(r);
              myReports.sort((a, b) => b.time.compareTo(a.time));
            });
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _descCtrl.dispose();
    _customCatCtrl.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(children: [
        _buildHeader(),
        Padding(
          padding: EdgeInsets.all(isWide ? 24 : 14),
          child: isWide ? _wideLayout() : _narrowLayout(),
        ),
      ]),
    );
  }

  // ── HEADER MATCHING VOTE SCREEN ──
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/fist.jpeg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Container(
        color: AppColors.navy.withOpacity(0.75), 
        padding: const EdgeInsets.fromLTRB(20, 72, 20, 40),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MY REPORTS', 
              style: TextStyle(
                fontSize: 10, 
                color: Color(0xFFFB923C), 
                fontWeight: FontWeight.w800, 
                letterSpacing: 1, 
                fontFamily: 'Nunito'
              )
            ),
            const SizedBox(height: 6),
            const Text(
              'Report Tracker', 
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                color: Colors.white, 
                fontFamily: 'Nunito'
              )
            ),
            const SizedBox(height: 6),
            const Text(
              'Track, update, and manage your personal civic reports.', 
              style: TextStyle(
                fontSize: 13, 
                color: Colors.white70, 
                height: 1.4,
                fontFamily: 'Nunito'
              )
            ),
            const SizedBox(height: 16),
            Row(children: [
              ElevatedButton.icon(
                onPressed: () => setState(() { showForm = true; _step = 0; }),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('New Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => showForm = false),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white38))
                ),
                child: Text('My Reports (${myReports.length})', style: const TextStyle(color: Colors.white, fontFamily: 'Nunito')),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _wideLayout() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 5, child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: _fadeSlide,
        child: showForm
            ? _formPanel(key: const ValueKey('form'))
            : _statsPanel(key: const ValueKey('stats')),
      )),
      const SizedBox(width: 20),
      Expanded(flex: 6, child: _reportsSection()),
    ],
  );

  Widget _narrowLayout() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 400),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: _fadeSlide,
    child: showForm
        ? _formPanel(key: const ValueKey('form'))
        : Column(
            key: const ValueKey('list'),
            children: [
              _statsPanel(),
              const SizedBox(height: 20),
              _reportsSection(),
            ],
          ),
  );

  Widget _fadeSlide(Widget child, Animation<double> animation) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );

  Widget _statsPanel({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(
        bgColor: AppColors.orangeLight,
        borderColor: AppColors.orange.withOpacity(0.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.orange, AppColors.orangeDark]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('File a New Report', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
              Text('Takes less than 1 minute', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
          ]),
          const SizedBox(height: 14),
          AppBtn(
            label: 'Start Report', 
            full: true, 
            onTap: () => setState(() { showForm = true; _step = 0; })
          ),
        ]),
      ),
    ]);
  }

  Widget _formPanel({Key? key}) {
    if (submitted) {
      return Card(
        key: key,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.green.withOpacity(0.5))),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: const Icon(Icons.check_circle, color: AppColors.green, size: 64),
            ),
            const SizedBox(height: 16),
            const Text('Report Submitted!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green, fontFamily: 'Nunito')),
            const SizedBox(height: 4),
            Text('Sent to Ward ${widget.user.ward} Rep', style: const TextStyle(fontSize: 13, color: AppColors.grey, fontFamily: 'Nunito')),
          ]),
        ),
      );
    }

    return Column(key: key, children: [
      _stepIndicator(),
      const SizedBox(height: 14),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: _fadeSlide,
        child: _stepContent(),
      ),
      const SizedBox(height: 14),
      _stepNavRow(),
    ]);
  }

  Widget _stepIndicator() {
    const labels = ['Category', 'Details', 'Review'];
    return Row(children: List.generate(3, (i) {
      final done    = i < _step;
      final current = i == _step;
      return Expanded(child: Row(children: [
        Expanded(child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            decoration: BoxDecoration(
              color: done || current ? AppColors.orange : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(labels[i], style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Nunito',
            color: current ? AppColors.orange : done ? AppColors.green : Colors.grey,
          )),
        ])),
        if (i < 2) const SizedBox(width: 4),
      ]));
    }));
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:  return _step0(key: const ValueKey(0));
      case 1:  return _step1(key: const ValueKey(1));
      default: return _step2(key: const ValueKey(2)); 
    }
  }

  Widget _stepNavRow() => Row(children: [
    if (_step > 0)
      Expanded(child: TextButton(
        onPressed: () => setState(() => _step--),
        style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.withOpacity(0.3)))),
        child: const Text('← Back', style: TextStyle(color: AppColors.grey, fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      )),
    if (_step > 0) const SizedBox(width: 10),
    Expanded(child: _step < 2
        ? AppBtn(
            label: 'Continue →',
            color: AppColors.orange,
            full: true,
            onTap: () {
              if (_step == 0 && selCat == 'Other' && customCat.isEmpty) return;
              if (_step == 1 && _descCtrl.text.isEmpty) return;
              setState(() => _step++);
            },
          )
        : AppBtn(
            label: submitting ? 'Submitting…' : 'Submit Report',
            color: AppColors.green,
            full: true,
            disabled: submitting,
            onTap: _submitReport,
          )),
  ]);

  // ── STEP 0: Category with Images & "Other" Dropdown Prompt ────────────────
  Widget _step0({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Card(
      key: key, elevation: 0, color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.orange.withOpacity(0.4), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel('ISSUE CATEGORY'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3, 
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, 
            crossAxisSpacing: 10, 
            childAspectRatio: 0.95,
            children: cats.map((c) {
              final sel = selCat == c;
              final imagePath = catImages[c] ?? '';
              
              return GestureDetector(
                onTap: () => setState(() => selCat = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.orange.withOpacity(0.1) : (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.orange : Colors.grey.withOpacity(0.2), width: sel ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Container(
                            color: isDark ? Colors.black26 : Colors.grey.shade200,
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          c, 
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            fontFamily: 'Nunito',
                            color: sel ? (isDark ? Colors.white : Colors.black87) : Colors.grey
                          ), 
                          textAlign: TextAlign.center
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          if (selCat == 'Other') ...[
            const SizedBox(height: 16),
            _sectionLabel('WHAT IS IT ABOUT? *'),
            const SizedBox(height: 6),
            TextField(
              controller: _customCatCtrl,
              onChanged: (val) => setState(() => customCat = val),
              decoration: InputDecoration(
                hintText: 'Specify what this issue is about...',
                filled: true, fillColor: AppColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(fontFamily: 'Nunito')
            ),
            if (customCat.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('* Please specify what it is about', style: TextStyle(fontSize: 11, color: AppColors.orange, fontFamily: 'Nunito')),
              ),
          ],
        ]),
      ),
    );
  }

  // ── STEP 1: Description, Photo, Map ───────────────────────────────────────
  Widget _step1({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Card(
      key: key, elevation: 0, color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.navy.withOpacity(0.4), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=mahad&zoom=14&size=600x300&sensor=false'), fit: BoxFit.cover)
            ),
            child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text('Ward ${widget.user.ward}, Mahad', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Nunito')))),
          ),
          const SizedBox(height: 16),
          _sectionLabel('DESCRIPTION *'),
          const SizedBox(height: 6),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Describe the issue in detail...',
              filled: true, fillColor: AppColors.bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            style: const TextStyle(fontFamily: 'Nunito')
          ),
          const SizedBox(height: 16),
          _sectionLabel('PHOTO / EVIDENCE'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => hasPhoto = !hasPhoto),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 90,
              decoration: BoxDecoration(
                color: hasPhoto ? AppColors.green.withOpacity(0.08) : AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: hasPhoto ? AppColors.green : Colors.grey.withOpacity(0.2), width: hasPhoto ? 2 : 1),
              ),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(hasPhoto ? Icons.check_circle_rounded : Icons.add_a_photo_outlined, color: hasPhoto ? AppColors.green : AppColors.grey, size: 28),
                const SizedBox(height: 6),
                Text(hasPhoto ? 'Photo attached ✓' : 'Tap to attach photo or video', style: TextStyle(fontSize: 12, color: hasPhoto ? AppColors.green : AppColors.grey, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
              ])),
            ),
          ),
          if (_descCtrl.text.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 10), child: Text('* Description is required to continue', style: TextStyle(fontSize: 11, color: AppColors.orange, fontFamily: 'Nunito'))),
        ]),
      ),
    );
  }

  // ── STEP 2: Review ────────────────────────────────────────────────────────
  Widget _step2({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final displayedCategory = selCat == 'Other' && customCat.isNotEmpty ? 'Other: $customCat' : selCat;

    return Card(
      key: key, elevation: 0, color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.green.withOpacity(0.4), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fact_check_outlined, color: AppColors.green, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Review Your Report', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
              Text('Check details before submitting', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
            ]),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 16),

          _reviewRow('Category',   displayedCategory, Icons.category_outlined, AppColors.orange),
          _reviewRow('Description',_descCtrl.text.isEmpty ? 'No description provided' : _descCtrl.text, Icons.description_outlined, isDark ? Colors.white : Colors.black87),
          _reviewRow('Photo',      hasPhoto ? 'Attached ✓' : 'None', Icons.photo_outlined, hasPhoto ? AppColors.green : AppColors.grey),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.navy.withOpacity(0.15))),
            child: Row(children: [
              const Icon(Icons.send_rounded, size: 16, color: AppColors.navy),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Will be sent to: Ward ${widget.user.ward} Rep',
                style: const TextStyle(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _reviewRow(String label, String value, IconData icon, Color color) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w600, fontFamily: 'Nunito'))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyMedium?.color, fontFamily: 'Nunito'))),
        ]),
      );

  // ── REPORTS LIST SECTION ──────────────────────────────────────────────────
  Widget _reportsSection({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search my reports...',
            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14, fontFamily: 'Nunito'),
            prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
      ),

      SizedBox(height: 36, child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) {
          final count = f == 'All' ? myReports.length : myReports.where((r) => r.status == f).length;
          final active = filterStatus == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => filterStatus = f),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? _filterColor(f) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? _filterColor(f) : Colors.grey.withOpacity(0.3), width: 1.5)
                ),
                child: Text('$f ($count)', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Nunito',
                  color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black87)
                )),
              ),
            ),
          );
        }).toList(),
      )),
      const SizedBox(height: 16),

      if (filteredReports.isEmpty)
        _emptyState()
      else
        ...filteredReports.asMap().entries.map((entry) {
          final r = entry.value;
          final isExpanded = _expanded.contains(r.id);

          return Card(
            key: ValueKey(r.id),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.15))),
            elevation: 0,
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: InkWell(
              onTap: () => setState(() { isExpanded ? _expanded.remove(r.id) : _expanded.add(r.id); }),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: (catColors[r.category] ?? Colors.grey).withOpacity(0.2),
                      child: Icon(_catIcon(r.category), size: 16, color: catColors[r.category] ?? Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Nunito')),
                      Text('${r.ticket} • ${r.time}', style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _statusColor(r.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(r.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(r.status), fontFamily: 'Nunito')),
                    )
                  ]),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: isExpanded
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(height: 12),
                            if (r.desc.isNotEmpty) ...[
                              Text(r.desc, style: const TextStyle(fontSize: 13, height: 1.5, fontFamily: 'Nunito')),
                              const SizedBox(height: 12),
                            ],
                            Row(children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                              const SizedBox(width: 4),
                              Text(r.ward, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
                            ]),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: AppColors.border),
                            const SizedBox(height: 8),
                            
                            Row(children: [
                              const Text('Update Status: ', style: TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
                              const SizedBox(width: 8),
                              Container(
                                height: 30,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.bg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border)
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: r.status,
                                    isDense: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _statusColor(r.status), fontFamily: 'Nunito'),
                                    items: ['Unresolved', 'In Progress', 'Resolved'].map((s) {
                                      return DropdownMenuItem(value: s, child: Text(s));
                                    }).toList(),
                                    onChanged: (newStatus) {
                                      if (newStatus != null) {
                                        setState(() => r.status = newStatus);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (r.status == 'Unresolved')
                                TextButton.icon(
                                  onPressed: () => _deleteReport(r), 
                                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.red), 
                                  label: const Text('Withdraw', style: TextStyle(color: AppColors.red, fontSize: 12, fontFamily: 'Nunito', fontWeight: FontWeight.bold))
                                )
                            ]),
                          ])
                        : const SizedBox.shrink(),
                  ),
                  
                  if (!isExpanded)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Center(child: Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.grey)),
                    )
                ]),
              ),
            ),
          );
        }).toList(),
    ]);
  }

  Widget _emptyState() => Container(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(children: [
      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.withOpacity(0.4)),
      const SizedBox(height: 12),
      Text(
        searchQuery.isNotEmpty ? 'No reports match "$searchQuery"' : 'No ${filterStatus == 'All' ? '' : filterStatus.toLowerCase()} reports yet',
        style: const TextStyle(fontSize: 14, color: AppColors.grey, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
        textAlign: TextAlign.center,
      ),
    ]),
  );

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito'));

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':    return AppColors.green;
      case 'In Progress': return Colors.blue;
      default:            return Colors.amber;
    }
  }

  Color _filterColor(String f) {
    switch (f) {
      case 'Resolved':    return AppColors.green;
      case 'In Progress': return Colors.blue;
      case 'Unresolved':  return Colors.amber;
      default:            return AppColors.navy; // Changed from primaryAccent to Navy
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Electricity': return Icons.lightbulb_outline;
      case 'Water leak':  return Icons.water_drop_outlined;
      case 'Potholes':    return Icons.warning_amber_outlined;
      case 'Garbage':     return Icons.delete_outline;
      case 'Drainage':    return Icons.water_outlined;
      default:            return Icons.help_outline;
    }
  }
}