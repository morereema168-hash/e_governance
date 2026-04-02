import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENHANCED ReportScreen
// New form additions:
//   • Severity picker (Low / Medium / High / Critical)
//   • Photo / evidence upload placeholder
//   • Preferred contact method (Call / WhatsApp / Email / No preference)
//   • Best time to inspect (Morning / Afternoon / Evening / Anytime)
//   • Stepped multi-page form (Step 1 → Step 2 → Step 3 → Review)
//
// New screen features:
//   • Filter bar (All / Pending / In Progress / Resolved)
//   • Search reports
//   • Expandable report detail card
//   • Delete / withdraw a report (with undo snackbar)
//   • Upvote similar issues
//   • Summary analytics panel (wide layout)
//   • LIVE NEWS TICKER for top trending issues
// ─────────────────────────────────────────────────────────────────────────────

class ReportScreen extends StatefulWidget {
  final AppUser user;
  const ReportScreen({super.key, required this.user});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with TickerProviderStateMixin {
  // ── DATA ──────────────────────────────────────────────────────────────────
  final List<Report> myReports = [
    Report(id: '1', dept: 'Water',     title: 'No water for 3 days',    desc: 'Ward 3 dry since Monday.',          status: 'Pending',     time: '1d ago',  ticket: '#8831', ward: 'Ward 3'),
    Report(id: '2', dept: 'Roads',     title: 'Pothole near bus stop',  desc: 'Dangerous pothole on MG Road.',     status: 'In Progress', time: '2d ago',  ticket: '#8832', ward: 'Ward 3'),
    Report(id: '3', dept: 'Sanitation',title: 'Open drain near school', desc: 'Children at risk.',                 status: 'Resolved',    time: '3d ago',  ticket: '#8829', ward: 'Ward 3'),
  ];

  // upvote counts keyed by report id
  final Map<String, int>  _upvotes   = {'1': 4, '2': 11, '3': 2};
  final Map<String, bool> _upvoted   = {};
  final Set<String>       _expanded  = {};

  // ── UI STATE ──────────────────────────────────────────────────────────────
  bool   showForm   = false;
  bool   submitting = false;
  bool   submitted  = false;
  String filterStatus = 'All';
  String searchQuery  = '';
  final _searchCtrl = TextEditingController();

  // ── FORM STATE (multi-step) ───────────────────────────────────────────────
  int    _step = 0;          // 0 = category/dept, 1 = details, 2 = meta, 3 = review
  String selCat      = 'Pothole';
  String selDept     = 'Roads';
  String selSeverity = 'Medium';
  String selContact  = 'WhatsApp';
  String selTime     = 'Anytime';
  bool   hasPhoto    = false; // placeholder – real impl would use image_picker
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();

  // ── CONSTANTS ─────────────────────────────────────────────────────────────
  final deptColors = const {
    'Water':      AppColors.teal,
    'Sanitation': AppColors.green,
    'Electricity':AppColors.gold,
    'Roads':      AppColors.greyDark,
    'Other':      AppColors.purple,
  };

  final cats   = ['Streetlight','Water Leak','Pothole','Garbage','Drainage','Other'];
  final depts  = ['Water','Sanitation','Electricity','Roads','Other'];
  final filters = ['All','Pending','In Progress','Resolved'];

  static const severityMeta = {
    'Low':      {'color': Color(0xFF22C55E), 'icon': Icons.arrow_downward_rounded,  'desc': 'Minor inconvenience'},
    'Medium':   {'color': Color(0xFFF59E0B), 'icon': Icons.remove_rounded,           'desc': 'Noticeable problem'},
    'High':     {'color': Color(0xFFEF4444), 'icon': Icons.arrow_upward_rounded,     'desc': 'Urgent action needed'},
    'Critical': {'color': Color(0xFF7C3AED), 'icon': Icons.priority_high_rounded,    'desc': 'Immediate danger'},
  };

  static const contactOpts = ['Call','WhatsApp','Email','No preference'];
  static const timeOpts    = ['Morning','Afternoon','Evening','Anytime'];

  // ── HELPERS ───────────────────────────────────────────────────────────────
  List<Report> get filteredReports {
    return myReports.where((r) {
      final matchStatus = filterStatus == 'All' || r.status == filterStatus;
      final matchSearch = searchQuery.isEmpty ||
          r.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          r.dept.toLowerCase().contains(searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();
  }

  void _submitReport() async {
    if (_titleCtrl.text.isEmpty) return;
    setState(() => submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final newId = '${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      myReports.insert(0, Report(
        id:     newId,
        dept:   selDept,
        title:  _titleCtrl.text,
        desc:   _descCtrl.text,
        status: 'Pending',
        time:   'Just now',
        ticket: '#${8860 + myReports.length}',
        ward:   widget.user.ward,
      ));
      _upvotes[newId] = 0;
      submitting = false;
      submitted  = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      submitted = false;
      showForm  = false;
      _step     = 0;
      _titleCtrl.clear();
      _descCtrl.clear();
      selCat      = 'Pothole';
      selDept     = 'Roads';
      selSeverity = 'Medium';
      selContact  = 'WhatsApp';
      selTime     = 'Anytime';
      hasPhoto    = false;
    });
  }

  void _deleteReport(Report r) {
    setState(() => myReports.remove(r));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report "${r.title}" withdrawn.', style: const TextStyle(fontFamily: 'Nunito')),
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

  void _toggleUpvote(String id) {
    setState(() {
      if (_upvoted[id] == true) {
        _upvoted[id] = false;
        _upvotes[id] = (_upvotes[id] ?? 1) - 1;
      } else {
        _upvoted[id] = true;
        _upvotes[id] = (_upvotes[id] ?? 0) + 1;
      }
    });
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(children: [
        // HEADER
        PageHeader(
          tag:   'OFFICIAL REPORTS',
          title: 'Report an Issue',
          sub:   'Sent → Department · Ward Rep · Mayor',
          bottom: Row(children: [
            AppBtn(
              label: '+ New Report', small: true,
              onTap: () => setState(() { showForm = true; _step = 0; }),
            ),
            const SizedBox(width: 8),
            AppBtn(
              label: 'My Reports (${myReports.length})',
              small: true, outline: true, color: Colors.white,
              onTap: () => setState(() => showForm = false),
            ),
          ]),
        ),

        // ── LIVE NEWS TICKER ──
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
      position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
      child: child,
    ),
  );

  // ── STATS PANEL (wide, no form) ───────────────────────────────────────────
  Widget _statsPanel({Key? key}) {
    final total      = myReports.length;
    final resolved   = myReports.where((r) => r.status == 'Resolved').length;
    final pending    = myReports.where((r) => r.status == 'Pending').length;
    final inProgress = myReports.where((r) => r.status == 'In Progress').length;

    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
        children: [
          _statCard('Total',       total.toString(),      AppColors.orange,   Icons.assignment_outlined),
          _statCard('Resolved',    resolved.toString(),   AppColors.green,    Icons.check_circle_outline),
          _statCard('In Progress', inProgress.toString(), AppColors.blue,     Icons.autorenew),
          _statCard('Pending',     pending.toString(),    AppColors.gold,     Icons.hourglass_empty),
        ],
      ),
      const SizedBox(height: 16),
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
              Text('Takes less than 2 minutes', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
          ]),
          const SizedBox(height: 14),
          AppBtn(label: '+ New Report', full: true, onTap: () => setState(() { showForm = true; _step = 0; })),
        ]),
      ),
      const SizedBox(height: 10),
      AppCard(
        bgColor: AppColors.blueLight,
        borderColor: AppColors.blue.withOpacity(0.2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('How it works', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.blue, fontFamily: 'Nunito')),
          const SizedBox(height: 10),
          for (final step in [
            ['1', 'Choose category, department & severity'],
            ['2', 'Add title, details and optional photo'],
            ['3', 'Set contact preference & inspection time'],
            ['4', 'Review and submit – goes to dept, ward rep & mayor'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blue),
                  child: Center(child: Text(step[0], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(step[1], style: const TextStyle(fontSize: 12, fontFamily: 'Nunito', color: AppColors.dark))),
              ]),
            ),
        ]),
      ),
    ]);
  }

  Widget _statCard(String label, String value, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border(top: BorderSide(color: color, width: 3)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
        Text(label,  style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
      ]),
    ]),
  );

  // ── MULTI-STEP FORM ────────────────────────────────────────────────────────
  Widget _formPanel({Key? key}) {
    if (submitted) {
      return AppCard(key: key, child: Column(children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: const Text('✅', style: TextStyle(fontSize: 64)),
        ),
        const SizedBox(height: 12),
        const Text('Report Submitted!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        Text('Sent to $selDept Dept · ${widget.user.ward} Rep · Mayor',
            style: const TextStyle(fontSize: 13, color: AppColors.grey, fontFamily: 'Nunito')),
        const SizedBox(height: 8),
      ]));
    }

    return Column(key: key, children: [
      // Step indicator
      _stepIndicator(),
      const SizedBox(height: 14),
      // Step content
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: _fadeSlide,
        child: _stepContent(),
      ),
      const SizedBox(height: 14),
      // Nav buttons
      _stepNavRow(),
    ]);
  }

  Widget _stepIndicator() {
    const labels = ['Category', 'Details', 'Preferences', 'Review'];
    return Row(children: List.generate(4, (i) {
      final done    = i < _step;
      final current = i == _step;
      return Expanded(child: Row(children: [
        Expanded(child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            decoration: BoxDecoration(
              color: done || current ? AppColors.orange : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(labels[i], style: TextStyle(
            fontSize: 10, fontFamily: 'Nunito', fontWeight: FontWeight.w700,
            color: current ? AppColors.orange : done ? AppColors.green : AppColors.grey,
          )),
        ])),
        if (i < 3) const SizedBox(width: 4),
      ]));
    }));
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:  return _step0(key: const ValueKey(0));
      case 1:  return _step1(key: const ValueKey(1));
      case 2:  return _step2(key: const ValueKey(2));
      default: return _step3(key: const ValueKey(3));
    }
  }

  Widget _stepNavRow() => Row(children: [
    if (_step > 0)
      Expanded(child: AppBtn(
        label: '← Back', outline: true,
        onTap: () => setState(() => _step--),
      )),
    if (_step > 0) const SizedBox(width: 10),
    Expanded(child: _step < 3
        ? AppBtn(
            label: 'Continue →',
            onTap: () {
              if (_step == 1 && _titleCtrl.text.isEmpty) return;
              setState(() => _step++);
            },
          )
        : AppBtn(
            label: submitting ? 'Submitting…' : 'Submit Report 🚀',
            disabled: submitting,
            onTap: _submitReport,
          )),
  ]);

  // ── STEP 0: Category & Department ─────────────────────────────────────────
  Widget _step0({Key? key}) => AppCard(
    key: key,
    borderColor: AppColors.orange.withOpacity(0.4),
    borderWidth: 2,
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
            child: AnimatedScale(
              scale: sel ? 1.05 : 1.0, duration: const Duration(milliseconds: 200), curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: sel ? AppColors.orangeLight : AppColors.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? AppColors.orange : AppColors.border, width: sel ? 2 : 1),
                  boxShadow: sel ? [BoxShadow(color: AppColors.orange.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_catIcon(c), size: 24, color: sel ? AppColors.orange : AppColors.grey),
                  const SizedBox(height: 6),
                  Text(c, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sel ? AppColors.dark : AppColors.grey, fontFamily: 'Nunito'), textAlign: TextAlign.center),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      _sectionLabel('DEPARTMENT'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6, runSpacing: 6,
        children: depts.map((d) => AppChip(
          label: d, color: deptColors[d] ?? AppColors.grey,
          active: selDept == d, onTap: () => setState(() => selDept = d), small: true,
        )).toList(),
      ),
      const SizedBox(height: 20),
      _sectionLabel('SEVERITY LEVEL'),
      const SizedBox(height: 10),
      Row(children: ['Low','Medium','High','Critical'].map((s) {
        final sel  = selSeverity == s;
        final meta = severityMeta[s]!;
        final color = meta['color'] as Color;
        return Expanded(child: Padding(
          padding: EdgeInsets.only(right: s != 'Critical' ? 6 : 0),
          child: GestureDetector(
            onTap: () => setState(() => selSeverity = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? color.withOpacity(0.12) : AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? color : AppColors.border, width: sel ? 2 : 1),
              ),
              child: Column(children: [
                Icon(meta['icon'] as IconData, color: sel ? color : AppColors.grey, size: 18),
                const SizedBox(height: 4),
                Text(s, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: sel ? color : AppColors.grey, fontFamily: 'Nunito')),
              ]),
            ),
          ),
        ));
      }).toList()),
      const SizedBox(height: 4),
      Text(severityMeta[selSeverity]!['desc'] as String,
          style: TextStyle(fontSize: 11, color: (severityMeta[selSeverity]!['color'] as Color), fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
    ]),
  );

  // ── STEP 1: Title, Description, Photo ─────────────────────────────────────
  Widget _step1({Key? key}) => AppCard(
    key: key,
    borderColor: AppColors.blue.withOpacity(0.4),
    borderWidth: 2,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MapWidget(label: '${widget.user.ward}, Rampur', height: 110),
      const SizedBox(height: 16),
      _sectionLabel('ISSUE TITLE *'),
      const SizedBox(height: 6),
      TextField(
        controller: _titleCtrl,
        decoration: InputDecoration(
          hintText: 'e.g. Pothole at junction near bus stop',
          filled: true, fillColor: AppColors.bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        style: const TextStyle(fontFamily: 'Nunito'),
      ),
      const SizedBox(height: 14),
      _sectionLabel('DESCRIPTION'),
      const SizedBox(height: 6),
      TextField(
        controller: _descCtrl,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Describe the issue in detail – location landmarks, duration, affected residents…',
          filled: true, fillColor: AppColors.bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        style: const TextStyle(fontFamily: 'Nunito'),
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasPhoto ? AppColors.green : AppColors.border,
              width: hasPhoto ? 2 : 1,
              style: hasPhoto ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(hasPhoto ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                color: hasPhoto ? AppColors.green : AppColors.grey, size: 28),
            const SizedBox(height: 6),
            Text(hasPhoto ? 'Photo attached ✓' : 'Tap to attach photo or video',
                style: TextStyle(fontSize: 12, fontFamily: 'Nunito', color: hasPhoto ? AppColors.green : AppColors.grey, fontWeight: FontWeight.w600)),
          ])),
        ),
      ),
      if (_titleCtrl.text.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text('* Title is required to continue', style: TextStyle(fontSize: 11, color: AppColors.orange, fontFamily: 'Nunito')),
        ),
    ]),
  );

  // ── STEP 2: Preferences ───────────────────────────────────────────────────
  Widget _step2({Key? key}) => AppCard(
    key: key,
    borderColor: AppColors.purple.withOpacity(0.4),
    borderWidth: 2,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('PREFERRED CONTACT METHOD'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: contactOpts.map((c) {
          final sel = selContact == c;
          final icon = c == 'Call'         ? Icons.phone_outlined
                     : c == 'WhatsApp'     ? Icons.chat_bubble_outline
                     : c == 'Email'        ? Icons.email_outlined
                     :                       Icons.do_not_disturb_on_outlined;
          return GestureDetector(
            onTap: () => setState(() => selContact = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: sel ? AppColors.purple.withOpacity(0.1) : AppColors.bg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: sel ? AppColors.purple : AppColors.border, width: sel ? 2 : 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 15, color: sel ? AppColors.purple : AppColors.grey),
                const SizedBox(width: 6),
                Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? AppColors.purple : AppColors.grey, fontFamily: 'Nunito')),
              ]),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      _sectionLabel('BEST TIME TO INSPECT'),
      const SizedBox(height: 8),
      Row(children: timeOpts.map((t) {
        final sel  = selTime == t;
        final icon = t == 'Morning'   ? Icons.wb_sunny_outlined
                   : t == 'Afternoon' ? Icons.wb_cloudy_outlined
                   : t == 'Evening'   ? Icons.nights_stay_outlined
                   :                    Icons.access_time;
        return Expanded(child: Padding(
          padding: EdgeInsets.only(right: t != 'Anytime' ? 6 : 0),
          child: GestureDetector(
            onTap: () => setState(() => selTime = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? AppColors.teal.withOpacity(0.1) : AppColors.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? AppColors.teal : AppColors.border, width: sel ? 2 : 1),
              ),
              child: Column(children: [
                Icon(icon, color: sel ? AppColors.teal : AppColors.grey, size: 20),
                const SizedBox(height: 4),
                Text(t, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, fontFamily: 'Nunito', color: sel ? AppColors.teal : AppColors.grey)),
              ]),
            ),
          ),
        ));
      }).toList()),
      const SizedBox(height: 20),
      AppCard(
        bgColor: AppColors.blueLight,
        borderColor: AppColors.blue.withOpacity(0.2),
        child: Row(children: [
          const Icon(Icons.info_outline, color: AppColors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Officials will contact you via $selContact and aim to inspect during $selTime hours.',
            style: const TextStyle(fontSize: 12, color: AppColors.blue, fontFamily: 'Nunito', height: 1.4),
          )),
        ]),
      ),
    ]),
  );

  // ── STEP 3: Review & Submit ────────────────────────────────────────────────
  Widget _step3({Key? key}) => AppCard(
    key: key,
    borderColor: AppColors.green.withOpacity(0.4),
    borderWidth: 2,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Review Your Report', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
      const SizedBox(height: 14),
      _reviewRow('Category',    selCat,      Icons.category_outlined),
      _reviewRow('Department',  selDept,     Icons.business_outlined),
      _reviewRow('Severity',    selSeverity, Icons.warning_amber_outlined),
      _reviewRow('Title',       _titleCtrl.text.isEmpty ? '(no title)' : _titleCtrl.text, Icons.title),
      _reviewRow('Description', _descCtrl.text.isEmpty  ? '(no details)' : _descCtrl.text, Icons.notes),
      _reviewRow('Photo',       hasPhoto ? 'Attached' : 'None',  Icons.photo_outlined),
      _reviewRow('Contact',     selContact,  Icons.contact_phone_outlined),
      _reviewRow('Inspect time',selTime,     Icons.schedule_outlined),
      const Divider(height: 24),
      AppCard(
        bgColor: AppColors.blueLight,
        borderColor: AppColors.blue.withOpacity(0.2),
        child: Row(children: [
          const Icon(Icons.send, color: AppColors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Will be sent to: $selDept Department · ${widget.user.ward} Rep · Mayor',
            style: const TextStyle(fontSize: 12, color: AppColors.blue, fontFamily: 'Nunito', height: 1.4),
          )),
        ]),
      ),
    ]),
  );

  Widget _reviewRow(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: AppColors.grey),
      const SizedBox(width: 8),
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito'))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: AppColors.dark))),
    ]),
  );

  // ── REPORTS SECTION (list + search + filter) ───────────────────────────────
  Widget _reportsSection({Key? key}) => Column(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Title row
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('My Reports (${myReports.length})', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      Row(children: [
        _miniChip('${myReports.where((r) => r.status == "Resolved").length} Resolved', AppColors.green),
        const SizedBox(width: 6),
        _miniChip('${myReports.where((r) => r.status == "Pending").length} Pending', AppColors.gold),
      ]),
    ]),
    const SizedBox(height: 12),

    // Search bar
    TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search reports…',
        hintStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => searchQuery = ''); })
            : null,
        filled: true, fillColor: AppColors.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 13),
    ),
    const SizedBox(height: 10),

    // Filter chips
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: filters.map((f) {
        final active = filterStatus == f;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => setState(() => filterStatus = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active ? AppColors.orange : AppColors.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppColors.orange : AppColors.border),
              ),
              child: Text(f, style: TextStyle(
                fontSize: 12, fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.grey,
              )),
            ),
          ),
        );
      }).toList()),
    ),
    const SizedBox(height: 14),

    // Report cards
    if (filteredReports.isEmpty)
      AppCard(child: Center(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Icon(Icons.inbox_outlined, size: 36, color: AppColors.grey),
          const SizedBox(height: 8),
          Text('No reports match "$filterStatus"', style: const TextStyle(color: AppColors.grey, fontFamily: 'Nunito')),
        ]),
      )))
    else
      ...filteredReports.asMap().entries.map((entry) {
        final r         = entry.value;
        final isExpanded = _expanded.contains(r.id);
        final votes     = _upvotes[r.id] ?? 0;
        final voted     = _upvoted[r.id] == true;

        return TweenAnimationBuilder<double>(
          key: ValueKey(r.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - v)),
            child: Opacity(opacity: v, child: child),
          ),
          child: GestureDetector(
            onTap: () => setState(() => isExpanded ? _expanded.remove(r.id) : _expanded.add(r.id)),
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Top row: dept chip + status badge
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  AppChip(label: r.dept, color: deptColors[r.dept] ?? AppColors.grey, small: true),
                  Row(children: [
                    StatusBadge(status: r.status),
                    const SizedBox(width: 8),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 18, color: AppColors.grey),
                  ]),
                ]),
                const SizedBox(height: 8),
                Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, fontFamily: 'Nunito')),

                // Expandable detail
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: isExpanded
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (r.desc.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(r.desc, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
                          ],
                          const SizedBox(height: 10),
                          // Severity indicator (stored in report if you extend model, shown from current form for newly added)
                          Row(children: [
                            const Icon(Icons.label_outline, size: 13, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Text('${r.ticket} · ${r.ward} · ${r.time}',
                                style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
                          ]),
                        ])
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 10),
                AnimatedBar(value: statusProgress(r.status).toDouble(), color: r.status == 'Resolved' ? AppColors.green : AppColors.orange, height: 5),
                const SizedBox(height: 6),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Filed',     style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
                  Text('In Review', style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
                  Text('Resolved',  style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
                ]),
                const SizedBox(height: 12),

                // Action row: upvote + withdraw
                Row(children: [
                  // Upvote
                  GestureDetector(
                    onTap: () => _toggleUpvote(r.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: voted ? AppColors.orange.withOpacity(0.12) : AppColors.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: voted ? AppColors.orange : AppColors.border),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(voted ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 13, color: voted ? AppColors.orange : AppColors.grey),
                        const SizedBox(width: 4),
                        Text('$votes others', style: TextStyle(
                            fontSize: 11, fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                            color: voted ? AppColors.orange : AppColors.grey)),
                      ]),
                    ),
                  ),
                  const Spacer(),
                  // Withdraw (only for Pending)
                  if (r.status == 'Pending')
                    GestureDetector(
                      onTap: () => _deleteReport(r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.close_rounded, size: 13, color: AppColors.grey),
                          const SizedBox(width: 4),
                          Text('Withdraw', style: TextStyle(fontSize: 11, fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: AppColors.grey)),
                        ]),
                      ),
                    ),
                ]),
              ]),
            ),
          ),
        );
      }),
  ]);

  // ── UTILITIES ─────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito'));

  Widget _miniChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'Nunito')),
  );

  IconData _catIcon(String c) {
    switch (c) {
      case 'Streetlight': return Icons.lightbulb_outline;
      case 'Water Leak':  return Icons.water_drop_outlined;
      case 'Pothole':     return Icons.warning_amber_outlined;
      case 'Garbage':     return Icons.delete_outline;
      case 'Drainage':    return Icons.waves;
      default:            return Icons.more_horiz;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: LIVE NEWS TICKER WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _TrendingTicker extends StatefulWidget {
  const _TrendingTicker();

  @override
  State<_TrendingTicker> createState() => _TrendingTickerState();
}

class _TrendingTickerState extends State<_TrendingTicker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // The string is repeated inside the builder to create an infinite loop effect
  final String _text = "🚨 TOP ISSUES THIS WEEK:   •   🚰 Water scarcity in Ward 3 (152 reports)   •   🚧 Severe potholes on MG Road (89 reports)   •   💡 Streetlight outage in Ward 7 (45 reports)   •   🗑️ Missed garbage collection in Ward 1 (30 reports)        ";

  @override
  void initState() {
    super.initState();
    // 25 seconds for a full loop. Increase duration to slow it down.
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.navy, // Using navy for a premium news-ticker look
        border: Border(
          bottom: BorderSide(color: AppColors.orange, width: 2), // Accent strip
        ),
      ),
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(), // User shouldn't scroll it manually
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FractionalTranslation(
                // Translates exactly half the width of the row to make the duplicated text loop seamlessly
                translation: Offset(-_controller.value * 0.5, 0),
                child: child,
              );
            },
            child: Row(
              children: [
                // We double the text here so the FractionalTranslation can loop perfectly
                Text(
                  _text + _text, 
                  style: const TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.white, 
                    fontFamily: 'Nunito',
                    letterSpacing: 0.5
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}