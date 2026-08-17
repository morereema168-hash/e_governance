import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

const Color primaryAccent = Color(0xFF2563EB);

// Local Mock Report Model
class MockReport {
  final String id;
  final String category;
  final String desc;
  String status; // Made mutable so the user can mark it
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
    MockReport(id: '1', category: 'Water Leak',  desc: 'Ward 3 dry since Monday. No water for 3 days.',      status: 'Unresolved',  time: '1d ago', ticket: '#8831', ward: 'Ward 3'),
    MockReport(id: '2', category: 'Pothole',     desc: 'Dangerous pothole on MG Road near the bus stop.',    status: 'In Progress', time: '2d ago', ticket: '#8832', ward: 'Ward 3'),
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
  String selCat       = 'Pothole';
  bool   hasPhoto     = false;
  final _descCtrl  = TextEditingController();

  // ── CONSTANTS ─────────────────────────────────────────────────────────────
  final cats = ['Streetlight', 'Water Leak', 'Pothole', 'Garbage', 'Drainage', 'Other'];
  final filters = ['All', 'Unresolved', 'In Progress', 'Resolved'];

  final catColors = const {
    'Streetlight': Colors.amber,
    'Water Leak':  Colors.teal,
    'Pothole':     Colors.orange,
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
    setState(() {
      myReports.insert(0, MockReport(
        id:       newId,
        category: selCat,
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
      selCat    = 'Pothole';
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
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(children: [
        // HEADER
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MY REPORTS', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w800, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('Report Tracker', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 4),
              const Text('Track, update, and manage your personal civic reports.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              Row(children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() { showForm = true; _step = 0; }),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('New Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => showForm = false),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.withOpacity(0.3)))
                  ),
                  child: Text('My Reports (${myReports.length})', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                ),
              ]),
            ],
          )
        ),

        const _TrendingTicker(),

        Padding(
          padding: EdgeInsets.all(isWide ? 24 : 14),
          child: isWide ? _wideLayout() : _narrowLayout(),
        ),
      ]),
    );
  }

  // ── LAYOUTS ───────────────────────────────────────────────────────────────
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
        : _reportsSection(key: const ValueKey('list')),
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

  // ── STATS PANEL (wide, no form) ───────────────────────────────────────────
  Widget _statsPanel({Key? key}) {
    final total      = myReports.length;
    final resolved   = myReports.where((r) => r.status == 'Resolved').length;
    final pending    = myReports.where((r) => r.status == 'Unresolved').length;
    final inProgress = myReports.where((r) => r.status == 'In Progress').length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
        children: [
          _statCard('Total',       total.toString(),      Colors.orange, Icons.assignment_outlined),
          _statCard('Resolved',    resolved.toString(),   Colors.green,  Icons.check_circle_outline),
          _statCard('In Progress', inProgress.toString(), Colors.blue,   Icons.autorenew),
          _statCard('Unresolved',  pending.toString(),    Colors.amber,  Icons.hourglass_empty),
        ],
      ),
      const SizedBox(height: 16),
      Card(
        color: isDark ? primaryAccent.withOpacity(0.2) : primaryAccent.withOpacity(0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryAccent.withOpacity(0.3))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: primaryAccent, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('File a New Report', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                Text('Takes less than 1 minute', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
            ]),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => setState(() { showForm = true; _step = 0; }),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text('Start Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: color, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      ]),
    );
  }

  // ── 3-STEP FORM ────────────────────────────────────────────────────────────
  Widget _formPanel({Key? key}) {
    if (submitted) {
      return Card(
        key: key,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.withOpacity(0.5))),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 16),
            const Text('Report Submitted!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green)),
            const SizedBox(height: 4),
            Text('Sent to Ward ${widget.user.ward} Rep', style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
              color: done || current ? primaryAccent : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(labels[i], style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: current ? primaryAccent : done ? Colors.green : Colors.grey,
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
      default: return _step2(key: const ValueKey(2)); // Now Step 2 is Review
    }
  }

  Widget _stepNavRow() => Row(children: [
    if (_step > 0)
      Expanded(child: TextButton(
        onPressed: () => setState(() => _step--),
        style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.withOpacity(0.3)))),
        child: const Text('← Back', style: TextStyle(color: Colors.grey)),
      )),
    if (_step > 0) const SizedBox(width: 10),
    Expanded(child: _step < 2
        ? ElevatedButton(
            onPressed: () {
              if (_step == 1 && _descCtrl.text.isEmpty) return; // Validation requires description now
              setState(() => _step++);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Continue →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : ElevatedButton(
            onPressed: submitting ? null : _submitReport,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text(submitting ? 'Submitting…' : 'Submit Report', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )),
  ]);

  // ── STEP 0: Category ──────────────────────────────────────────────────────
  Widget _step0({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Card(
      key: key, elevation: 0, color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryAccent.withOpacity(0.4), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel('ISSUE CATEGORY'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.1,
            children: cats.map((c) {
              final sel = selCat == c;
              return GestureDetector(
                onTap: () => setState(() => selCat = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? primaryAccent.withOpacity(0.1) : (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? primaryAccent : Colors.grey.withOpacity(0.2), width: sel ? 2 : 1),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_catIcon(c), size: 24, color: sel ? primaryAccent : Colors.grey),
                    const SizedBox(height: 6),
                    Text(c, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sel ? (isDark ? Colors.white : Colors.black87) : Colors.grey), textAlign: TextAlign.center),
                  ]),
                ),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }

  // ── STEP 1: Description, Photo, Map ───────────────────────────────────────
  Widget _step1({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final fieldBg = isDark ? Colors.grey.shade900 : Colors.grey.shade50;

    return Card(
      key: key, elevation: 0, color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.withOpacity(0.4), width: 2)),
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
            child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text('Ward ${widget.user.ward}, Mahad', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
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
              filled: true, fillColor: fieldBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
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
                color: hasPhoto ? Colors.green.withOpacity(0.08) : fieldBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hasPhoto ? Colors.green : Colors.grey.withOpacity(0.2), width: hasPhoto ? 2 : 1),
              ),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(hasPhoto ? Icons.check_circle_rounded : Icons.add_a_photo_outlined, color: hasPhoto ? Colors.green : Colors.grey, size: 28),
                const SizedBox(height: 6),
                Text(hasPhoto ? 'Photo attached ✓' : 'Tap to attach photo or video', style: TextStyle(fontSize: 12, color: hasPhoto ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
              ])),
            ),
          ),
          if (_descCtrl.text.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 10), child: Text('* Description is required to continue', style: TextStyle(fontSize: 11, color: Colors.orange))),
        ]),
      ),
    );
  }

  // ── STEP 2: Review (Formerly Step 3) ──────────────────────────────────────
  Widget _step2({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Card(
      key: key, elevation: 0, color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.withOpacity(0.4), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fact_check_outlined, color: Colors.green, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Review Your Report', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              Text('Check details before submitting', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 16),

          _reviewRow('Category',   selCat,      Icons.category_outlined,    Colors.orange),
          _reviewRow('Description',_descCtrl.text.isEmpty ? 'No description provided' : _descCtrl.text, Icons.description_outlined, isDark ? Colors.white : Colors.black87),
          _reviewRow('Photo',      hasPhoto ? 'Attached ✓' : 'None', Icons.photo_outlined, hasPhoto ? Colors.green : Colors.grey),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: primaryAccent.withOpacity(0.15))),
            child: Row(children: [
              const Icon(Icons.send_rounded, size: 16, color: primaryAccent),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Will be sent to: Ward ${widget.user.ward} Rep',
                style: const TextStyle(fontSize: 12, color: primaryAccent, fontWeight: FontWeight.bold),
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
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyMedium?.color))),
        ]),
      );

  // ── REPORTS LIST SECTION ──────────────────────────────────────────────────
  Widget _reportsSection({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Search Bar
      Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search my reports...',
            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
        ),
      ),

      // Filter chips 
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
                  fontSize: 12, fontWeight: FontWeight.bold,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: InkWell(
              onTap: () => setState(() { isExpanded ? _expanded.remove(r.id) : _expanded.add(r.id); }),
              borderRadius: BorderRadius.circular(8),
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
                      Text(r.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${r.ticket} • ${r.time}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _statusColor(r.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(r.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(r.status))),
                    )
                  ]),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: isExpanded
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(height: 12),
                            if (r.desc.isNotEmpty) ...[
                              Text(r.desc, style: const TextStyle(fontSize: 13, height: 1.5)),
                              const SizedBox(height: 12),
                            ],
                            Row(children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(r.ward, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            
                            // ── STATUS UPDATER AND WITHDRAW ──
                            Row(children: [
                              const Text('Update Status: ', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                height: 30,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.withOpacity(0.3))
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: r.status,
                                    isDense: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _statusColor(r.status)),
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
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red), 
                                  label: const Text('Withdraw', style: TextStyle(color: Colors.red, fontSize: 12))
                                )
                            ]),
                          ])
                        : const SizedBox.shrink(),
                  ),
                  
                  if (!isExpanded)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Center(child: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey)),
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
        style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    ]),
  );

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5));

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':    return Colors.green;
      case 'In Progress': return Colors.blue;
      default:            return Colors.amber;
    }
  }

  Color _filterColor(String f) {
    switch (f) {
      case 'Resolved':    return Colors.green;
      case 'In Progress': return Colors.blue;
      case 'Unresolved':  return Colors.amber;
      default:            return primaryAccent;
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Streetlight': return Icons.lightbulb_outline;
      case 'Water Leak':  return Icons.water_drop_outlined;
      case 'Pothole':     return Icons.warning_amber_outlined;
      case 'Garbage':     return Icons.delete_outline;
      case 'Drainage':    return Icons.water_outlined;
      default:            return Icons.help_outline;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBTLE TRENDING TICKER
// ─────────────────────────────────────────────────────────────────────────────
class _TrendingTicker extends StatefulWidget {
  const _TrendingTicker();

  @override
  State<_TrendingTicker> createState() => _TrendingTickerState();
}

class _TrendingTickerState extends State<_TrendingTicker> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  static const _items = [
    'Ward 3: 38 open water complaints this week',
    'Sector 5 drainage marked Resolved today',
    'Streetlight maintenance scheduled for Ward 4',
  ];

  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _startLoop();
  }

  void _startLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;
      await _ctrl.reverse();
      setState(() => _current = (_current + 1) % _items.length);
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: isDark ? primaryAccent.withOpacity(0.1) : primaryAccent.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 14, color: primaryAccent),
        const SizedBox(width: 10),
        Expanded(child: ClipRect(child: SlideTransition(
          position: _slide,
          child: Text(_items[_current],
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ))),
      ]),
    );
  }
}
