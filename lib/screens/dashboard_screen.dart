import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String sec = 'overview';
  Tender? selT;
<<<<<<< HEAD
  String tenderFilter = 'All';
=======
  
  // ── NEW FEATURES: Filter, Search, and Sort ──
  String tenderFilter = 'All';
  String searchQuery = '';
  String sortBy = 'recent';

>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
  static const cityBudget = 300000000;
  int get spent => TENDERS.fold(0, (a, t) => a + (t.pct * t.value ~/ 100));
  int get remaining => cityBudget - spent;
  double get spentPct => spent / cityBudget * 100;

  final sectors = const [
    {'l': 'Roads',       'v': 35, 'c': AppColors.orange},
    {'l': 'Water',       'v': 30, 'c': AppColors.teal},
    {'l': 'Electricity', 'v': 15, 'c': AppColors.gold},
    {'l': 'Sanitation',  'v': 12, 'c': AppColors.green},
    {'l': 'Parks',       'v': 8,  'c': AppColors.purple},
  ];

<<<<<<< HEAD
  // Recent activity feed
=======
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
  final activity = const [
    {'icon': Icons.check_circle,    'color': AppColors.green,  'msg': 'Main Road Drainage marked Completed',    'time': '2h ago'},
    {'icon': Icons.upload_file,     'color': AppColors.blue,   'msg': 'LED Street Lights tender awarded',        'time': '5h ago'},
    {'icon': Icons.location_on,     'color': AppColors.orange, 'msg': 'MG Road Tarring GPS update logged',       'time': '1d ago'},
    {'icon': Icons.warning_amber,   'color': AppColors.gold,   'msg': 'Water Pipeline milestone delayed 2 weeks','time': '2d ago'},
  ];

<<<<<<< HEAD
  List<Tender> get filteredTenders => tenderFilter == 'All'
      ? TENDERS
      : TENDERS.where((t) => t.status == tenderFilter).toList();
=======
  // ── ENHANCED LOGIC: Search & Sort added ──
  List<Tender> get filteredTenders {
    var list = [...TENDERS];
    
    if (tenderFilter != 'All') {
      list = list.where((t) => t.status == tenderFilter).toList();
    }
    
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((t) => 
        t.title.toLowerCase().contains(q) || 
        t.contractor.toLowerCase().contains(q) || 
        t.sector.toLowerCase().contains(q)
      ).toList();
    }

    if (sortBy == 'highest_value') list.sort((a, b) => b.value.compareTo(a.value));
    if (sortBy == 'completion') list.sort((a, b) => b.pct.compareTo(a.pct));

    return list;
  }
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc

  @override Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(children: [
        _buildHeader(isWide),
        _buildTabBar(),
        Padding(
          padding: EdgeInsets.all(isWide ? 24 : 14),
<<<<<<< HEAD
          child: isWide ? _wideBody() : _body(),
=======
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: isWide ? _wideBody(key: ValueKey('wide_$sec${selT?.id}')) : _body(key: ValueKey('narrow_$sec${selT?.id}')),
          ),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
        ),
      ]),
    );
  }

  // ── HEADER ──
  Widget _buildHeader(bool isWide) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PUBLIC DASHBOARD', style: TextStyle(fontSize: 10, color: Color(0xFFFB923C), fontWeight: FontWeight.w800, letterSpacing: 1, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Fund & Project Tracker', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
        const Text('Transparent governance · FY 2025-26', style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
        const SizedBox(height: 16),
<<<<<<< HEAD
        // Budget card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TOTAL CITY BUDGET · FY 2025-26', style: TextStyle(fontSize: 10, color: Colors.white60, fontFamily: 'Nunito', letterSpacing: 0.5)),
=======
        // Budget card (Glassmorphic style)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TOTAL CITY BUDGET', style: TextStyle(fontSize: 10, color: Colors.white60, fontFamily: 'Nunito', letterSpacing: 0.5)),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
                const SizedBox(height: 2),
                Text(fmtCr(cityBudget), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
<<<<<<< HEAD
                  color: spentPct > 80 ? AppColors.red.withOpacity(0.3) : AppColors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${spentPct.round()}% used',
                  style: TextStyle(color: spentPct > 80 ? AppColors.red : AppColors.green,
                    fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
              ),
            ]),
            const SizedBox(height: 12),
            AnimatedBar(value: spentPct, color: AppColors.orange, height: 10),
            const SizedBox(height: 8),
=======
                  color: spentPct > 80 ? AppColors.red.withOpacity(0.2) : AppColors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: spentPct > 80 ? AppColors.red.withOpacity(0.5) : AppColors.green.withOpacity(0.5)),
                ),
                child: Text('${spentPct.round()}% used',
                  style: TextStyle(color: spentPct > 80 ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                    fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
              ),
            ]),
            const SizedBox(height: 16),
            // Animated Header Bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: spentPct),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, val, _) => AnimatedBar(value: val, color: AppColors.orange, height: 8),
            ),
            const SizedBox(height: 12),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
            Row(children: [
              _budgetPill('Spent', fmtCr(spent), AppColors.orange),
              const SizedBox(width: 10),
              _budgetPill('Remaining', fmtCr(remaining), AppColors.green),
              const SizedBox(width: 10),
              _budgetPill('Projects', '${TENDERS.length}', AppColors.blue),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _budgetPill(String label, String value, Color color) {
    return Expanded(child: Container(
<<<<<<< HEAD
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
=======
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
        const SizedBox(height: 2),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'Nunito')),
      ]),
    ));
  }

  // ── TAB BAR ──
  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: Row(children: [
        for (final t in [['overview', 'Overview'], ['tenders', 'Projects'], ['stats', 'Stats'], ['activity', 'Activity']])
          Expanded(child: GestureDetector(
            onTap: () => setState(() { sec = t[0]; selT = null; }),
<<<<<<< HEAD
            child: Container(
=======
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(
                color: sec == t[0] ? AppColors.orange : Colors.transparent, width: 3))),
              child: Text(t[1], textAlign: TextAlign.center,
<<<<<<< HEAD
                style: TextStyle(fontWeight: sec == t[0] ? FontWeight.w900 : FontWeight.w500,
=======
                style: TextStyle(fontWeight: sec == t[0] ? FontWeight.w900 : FontWeight.w600,
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
                  fontSize: 13, color: sec == t[0] ? AppColors.orange : AppColors.grey, fontFamily: 'Nunito')),
            ),
          )),
      ]),
    );
  }

  // ── WIDE LAYOUT ──
<<<<<<< HEAD
  Widget _wideBody() {
    if (sec == 'tenders' && selT != null) return _tenderDetail(selT!);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 6, child: _body()),
=======
  Widget _wideBody({Key? key}) {
    if (sec == 'tenders' && selT != null) return _tenderDetail(selT!);
    return Row(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 6, child: _body(key: const ValueKey('body'))),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      const SizedBox(width: 20),
      Expanded(flex: 4, child: _rightPanel()),
    ]);
  }

  Widget _rightPanel() {
    return Column(children: [
<<<<<<< HEAD
      // Mini budget donut-style summary
=======
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Budget Health', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        Text('FY 2025-26 · ${spentPct.round()}% utilised',
          style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
        const SizedBox(height: 14),
        for (final s in sectors)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 10, height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: s['c'] as Color)),
              const SizedBox(width: 8),
              Expanded(child: Text(s['l'] as String,
                style: const TextStyle(fontSize: 12, fontFamily: 'Nunito'))),
              Text('${s['v']}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: s['c'] as Color, fontFamily: 'Nunito')),
            ]),
          ),
      ])),

<<<<<<< HEAD
      // Recent activity
=======
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 12),
        for (final a in activity)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (a['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(a['icon'] as IconData, size: 14, color: a['color'] as Color),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a['msg'] as String,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Nunito', height: 1.4)),
                const SizedBox(height: 2),
                Text(a['time'] as String,
                  style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
              ])),
            ]),
          ),
      ])),

<<<<<<< HEAD
      // Quick stats
=======
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      AppCard(
        bgColor: AppColors.navy,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Project Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white, fontFamily: 'Nunito')),
          const SizedBox(height: 14),
          for (final row in [
            ['Completed',   AppColors.green,  TENDERS.where((t) => t.status == 'Completed').length],
            ['In Progress', AppColors.blue,   TENDERS.where((t) => t.status == 'In Progress').length],
            ['Pending',     AppColors.gold,   TENDERS.where((t) => t.status == 'Pending').length],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(width: 8, height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: row[1] as Color)),
                  const SizedBox(width: 8),
                  Text(row[0] as String, style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
                ]),
                Text('${row[2]}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                  color: row[1] as Color, fontFamily: 'Nunito')),
              ]),
            ),
        ]),
      ),
    ]);
  }

<<<<<<< HEAD
  Widget _body() {
    if (sec == 'overview')  return _overview();
    if (sec == 'tenders')   return selT != null ? _tenderDetail(selT!) : _tenderList();
    if (sec == 'stats')     return _stats();
    return _activityFeed();
  }

  // ── OVERVIEW ──
  Widget _overview() {
=======
  Widget _body({Key? key}) {
    if (sec == 'overview')  return _overview(key: key);
    if (sec == 'tenders')   return selT != null ? _tenderDetail(selT!) : _tenderList(key: key);
    if (sec == 'stats')     return _stats(key: key);
    return _activityFeed(key: key);
  }

  // ── OVERVIEW ──
  Widget _overview({Key? key}) {
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
    final stats = [
      ['Active',       AppColors.orange, TENDERS.where((t) => t.status == 'In Progress').length.toString(), Icons.autorenew],
      ['Done',         AppColors.green,  TENDERS.where((t) => t.status == 'Completed').length.toString(),   Icons.check_circle_outline],
      ['Spent',        AppColors.blue,   fmtCr(spent),                                                       Icons.account_balance_wallet_outlined],
      ['GPS Verified', AppColors.purple, '${TENDERS.where((t) => t.pct > 0).length}',                       Icons.location_on_outlined],
    ];

<<<<<<< HEAD
    return Column(children: [
      // Stat cards
=======
    return Column(key: key, children: [
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2,
        children: stats.map((s) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
<<<<<<< HEAD
            borderRadius: BorderRadius.circular(20),
            border: Border(top: BorderSide(color: s[1] as Color, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14)],
=======
            borderRadius: BorderRadius.circular(16),
            border: Border(top: BorderSide(color: s[1] as Color, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
          ),
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (s[1] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(s[3] as IconData, color: s[1] as Color, size: 20),
            ),
            const SizedBox(width: 10),
<<<<<<< HEAD
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s[2] as String, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: s[1] as Color, fontFamily: 'Nunito')),
              Text(s[0] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
            ]),
=======
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(s[2] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: s[1] as Color, fontFamily: 'Nunito'), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(s[0] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
          ]),
        )).toList(),
      ),
      const SizedBox(height: 14),

<<<<<<< HEAD
      // Budget by sector
=======
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Budget by Sector', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          AppChip(label: 'FY 2025-26', color: AppColors.orange, small: true),
        ]),
<<<<<<< HEAD
        const SizedBox(height: 14),
        for (final s in sectors)
          Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(children: [
=======
        const SizedBox(height: 16),
        for (final s in sectors)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(children: [
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 10, height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: s['c'] as Color)),
                const SizedBox(width: 8),
                Text(s['l'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
              ]),
              Row(children: [
                Text(fmtCr(cityBudget * (s['v'] as int) ~/ 100),
                  style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
                const SizedBox(width: 8),
                Text('${s['v']}%', style: TextStyle(color: s['c'] as Color, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
              ]),
            ]),
<<<<<<< HEAD
            const SizedBox(height: 6),
            AnimatedBar(value: (s['v'] as int).toDouble(), color: s['c'] as Color, height: 7),
          ])),
      ])),

      // Recent tenders preview
=======
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: (s['v'] as int).toDouble()),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
              builder: (context, val, _) => AnimatedBar(value: val, color: s['c'] as Color, height: 7),
            ),
          ])),
      ])),

>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Latest Projects', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          GestureDetector(
            onTap: () => setState(() => sec = 'tenders'),
            child: const Text('View all →', style: TextStyle(fontSize: 12, color: AppColors.orange, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
          ),
        ]),
<<<<<<< HEAD
        const SizedBox(height: 12),
        for (final t in TENDERS.take(2))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
=======
        const SizedBox(height: 16),
        for (final t in TENDERS.take(2))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
            child: Row(children: [
              Container(width: 4, height: 44,
                decoration: BoxDecoration(
                  color: t.status == 'Completed' ? AppColors.green : t.status == 'In Progress' ? AppColors.blue : AppColors.gold,
                  borderRadius: BorderRadius.circular(4))),
<<<<<<< HEAD
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
=======
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
                const SizedBox(height: 2),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
                Text('${t.pct}% · ${fmtCr(t.value)}', style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
              ])),
              StatusBadge(status: t.status),
            ]),
          ),
      ])),
    ]);
  }

  // ── TENDER LIST ──
<<<<<<< HEAD
  Widget _tenderList() {
    final sc = {'Completed': AppColors.green, 'In Progress': AppColors.blue, 'Pending': AppColors.gold};
    final filters = ['All', 'In Progress', 'Completed', 'Pending'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Filter chips
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal,
=======
  Widget _tenderList({Key? key}) {
    final sc = {'Completed': AppColors.green, 'In Progress': AppColors.blue, 'Pending': AppColors.gold};
    final filters = ['All', 'In Progress', 'Completed', 'Pending'];

    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── NEW: Search & Sort Tools ──
      Row(children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search projects, contractors...',
                hintStyle: TextStyle(fontSize: 13, fontFamily: 'Nunito', color: AppColors.grey),
                prefixIcon: Icon(Icons.search, size: 18, color: AppColors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 13, fontFamily: 'Nunito'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: sortBy,
            icon: const Icon(Icons.sort, size: 16, color: AppColors.grey),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.dark, fontFamily: 'Nunito'),
            items: const [
              DropdownMenuItem(value: 'recent', child: Text('Recent')),
              DropdownMenuItem(value: 'highest_value', child: Text('Highest Value')),
              DropdownMenuItem(value: 'completion', child: Text('Completion %')),
            ],
            onChanged: (v) => setState(() => sortBy = v!),
          )),
        ),
      ]),
      const SizedBox(height: 14),

      SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal,
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
        children: filters.map((f) => Padding(padding: const EdgeInsets.only(right: 8),
          child: AppChip(label: f, color: AppColors.orange,
            active: tenderFilter == f, onTap: () => setState(() => tenderFilter = f), small: true),
        )).toList(),
      )),
      const SizedBox(height: 12),
<<<<<<< HEAD
      Text('${filteredTenders.length} project${filteredTenders.length != 1 ? 's' : ''}',
        style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 10),

      ...filteredTenders.map((t) => AppCard(
        onTap: () => setState(() => selT = t),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            AppChip(label: t.sector, color: AppColors.orange, small: true),
            StatusBadge(status: t.status),
          ]),
          const SizedBox(height: 8),
          Text(t.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          const SizedBox(height: 4),
          Text('${t.contractor} · GPS Verified ✓', style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
          const SizedBox(height: 10),
          AnimatedBar(value: t.pct.toDouble(), color: t.pct == 100 ? AppColors.green : (sc[t.status] ?? AppColors.orange), height: 8),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 13, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(fmtCr(t.value), style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.grey),
              const SizedBox(width: 4),
              Text('Due ${t.due}', style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
            ]),
            Text('${t.pct}%', style: TextStyle(fontWeight: FontWeight.w900,
              color: t.pct == 100 ? AppColors.green : (sc[t.status] ?? AppColors.orange), fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 6),
          const Text('Tap for details & updates →', style: TextStyle(fontSize: 11, color: AppColors.blue, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
        ]),
      )).toList(),
=======
      Text('${filteredTenders.length} project${filteredTenders.length != 1 ? 's' : ''} found',
        style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 10),

      // Staggered list
      ...filteredTenders.asMap().entries.map((entry) {
        final t = entry.value;
        return TweenAnimationBuilder<double>(
          key: ValueKey(t.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuad,
          builder: (context, val, child) => Transform.translate(
            offset: Offset(0, 15 * (1 - val)),
            child: Opacity(opacity: val, child: child),
          ),
          child: AppCard(
            onTap: () => setState(() => selT = t),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                AppChip(label: t.sector, color: AppColors.orange, small: true),
                StatusBadge(status: t.status),
              ]),
              const SizedBox(height: 10),
              Text(t.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.verified, size: 12, color: AppColors.green),
                const SizedBox(width: 4),
                Text('${t.contractor} · GPS Verified', style: const TextStyle(fontSize: 12, color: AppColors.greyDark, fontFamily: 'Nunito')),
              ]),
              const SizedBox(height: 14),
              AnimatedBar(value: t.pct.toDouble(), color: t.pct == 100 ? AppColors.green : (sc[t.status] ?? AppColors.orange), height: 8),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(fmtCr(t.value), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.dark, fontFamily: 'Nunito')),
                  const SizedBox(width: 14),
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text('Due ${t.due}', style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
                ]),
                Text('${t.pct}%', style: TextStyle(fontWeight: FontWeight.w900,
                  color: t.pct == 100 ? AppColors.green : (sc[t.status] ?? AppColors.orange), fontFamily: 'Nunito')),
              ]),
            ]),
          ),
        );
      }).toList(),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
    ]);
  }

  // ── TENDER DETAIL ──
  Widget _tenderDetail(Tender t) {
    final sc = {'Completed': AppColors.green, 'In Progress': AppColors.blue, 'Pending': AppColors.gold};
    final c = sc[t.status] ?? AppColors.orange;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextButton.icon(
        onPressed: () => setState(() => selT = null),
        icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.orange),
        label: const Text('Back to Projects', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
      ),
<<<<<<< HEAD
=======
      const SizedBox(height: 8),

      // ── NEW: Action Buttons ──
      Row(children: [
        Expanded(
          child: AppBtn(label: 'Download Report PDF', icon: Icons.download_rounded, outline: true, small: true, color: AppColors.navy, onTap: () {}),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
          child: IconButton(icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.dark), onPressed: () {}),
        ),
      ]),
      const SizedBox(height: 12),

>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      AppCard(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MapWidget(label: t.title, height: 180),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
<<<<<<< HEAD
            Expanded(child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito'))),
            StatusBadge(status: t.status),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.business, size: 14, color: AppColors.grey),
            const SizedBox(width: 6),
            Text('Contractor: ${t.contractor}', style: const TextStyle(fontSize: 13, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey),
            const SizedBox(width: 6),
            Text('GPS Verified ✓ · ${t.sector}', style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 14),
          // Completion bar
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Completion', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
            Text('${t.pct}%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: t.pct == 100 ? AppColors.green : c, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 6),
          AnimatedBar(value: t.pct.toDouble(), color: t.pct == 100 ? AppColors.green : c, height: 12),
          const SizedBox(height: 14),
          // Info grid
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.5,
            children: [
              ['Budget',  fmtCr(t.value)],
              ['Due',     t.due],
              ['Sector',  t.sector],
              ['GPS',     'Verified ✓'],
            ].map((item) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item[0], style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
                Text(item[1], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
=======
            Expanded(child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito'))),
            StatusBadge(status: t.status),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.business, size: 16, color: AppColors.grey),
            const SizedBox(width: 6),
            Text('Contractor: ${t.contractor}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.verified, size: 16, color: AppColors.green),
            const SizedBox(width: 6),
            Text('GPS Verified · ${t.sector}', style: const TextStyle(fontSize: 12, color: AppColors.greyDark, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Completion', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
            Text('${t.pct}%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: t.pct == 100 ? AppColors.green : c, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: t.pct.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) => AnimatedBar(value: val, color: t.pct == 100 ? AppColors.green : c, height: 12),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
            children: [
              ['Total Budget',  fmtCr(t.value)],
              ['Deadline',      t.due],
              ['Sector',        t.sector],
              ['GPS Tracking',  'Verified ✓'],
            ].map((item) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withOpacity(0.5))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(item[0], style: const TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
                const SizedBox(height: 2),
                Text(item[1], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: item[1] == 'Verified ✓' ? AppColors.green : AppColors.dark, fontFamily: 'Nunito')),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
              ]),
            )).toList(),
          ),
        ])),
      ])),

<<<<<<< HEAD
      // Update log with timeline style
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Work Update Log', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 14),
        ...List.generate(t.updates.length, (i) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 12, height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.orange)),
            if (i < t.updates.length - 1)
              Container(width: 2, height: 36, color: AppColors.orange.withOpacity(0.2)),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Padding(
            padding: EdgeInsets.only(bottom: i < t.updates.length - 1 ? 12 : 0),
            child: Text(t.updates[i], style: const TextStyle(fontSize: 13, fontFamily: 'Nunito', height: 1.5)),
          )),
        ])),
=======
      // Enhanced update log timeline
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Work Update Log', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
        const SizedBox(height: 16),
        ...List.generate(t.updates.length, (i) => IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Column(children: [
              Container(width: 14, height: 14, margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white, border: Border.all(color: AppColors.orange, width: 3))),
              if (i < t.updates.length - 1)
                Expanded(child: Container(width: 2, color: AppColors.orange.withOpacity(0.3))),
            ]),
            const SizedBox(width: 14),
            Expanded(child: Padding(
              padding: EdgeInsets.only(bottom: i < t.updates.length - 1 ? 16 : 0),
              child: Text(t.updates[i], style: const TextStyle(fontSize: 13, fontFamily: 'Nunito', height: 1.5)),
            )),
          ]),
        )),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      ])),
    ]);
  }

  // ── STATS ──
<<<<<<< HEAD
  Widget _stats() {
    return Column(children: [
      // Top KPI row
=======
  Widget _stats({Key? key}) {
    return Column(key: key, children: [
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      GridView.count(
        crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.8,
        children: [
          _kpiCard('Total Budget', fmtCr(cityBudget), AppColors.navy),
          _kpiCard('Spent', fmtCr(spent), AppColors.orange),
          _kpiCard('Remaining', fmtCr(remaining), AppColors.green),
        ],
      ),
      const SizedBox(height: 14),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
<<<<<<< HEAD
        const Text('Expenditure by Sector', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Allocation breakdown for FY 2025-26', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
        const SizedBox(height: 16),
        for (final s in sectors)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(children: [
=======
        const Text('Expenditure by Sector', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Allocation breakdown for FY 2025-26', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
        const SizedBox(height: 20),
        for (final s in sectors)
          Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(children: [
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 12, height: 12,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: s['c'] as Color)),
                const SizedBox(width: 8),
<<<<<<< HEAD
                Text(s['l'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
=======
                Text(s['l'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito')),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
              ]),
              Text('${fmtCr(cityBudget * (s['v'] as int) ~/ 100)}  ·  ${s['v']}%',
                style: TextStyle(color: s['c'] as Color, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
            ]),
<<<<<<< HEAD
            const SizedBox(height: 6),
            AnimatedBar(value: (s['v'] as int).toDouble(), color: s['c'] as Color, height: 10),
          ])),
      ])),

      // Tender status breakdown
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Project Status Breakdown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 14),
=======
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: (s['v'] as int).toDouble()),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
              builder: (context, val, _) => AnimatedBar(value: val, color: s['c'] as Color, height: 10),
            ),
          ])),
      ])),

      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Project Status Breakdown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
        const SizedBox(height: 16),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
        for (final row in [
          ['Completed',   AppColors.green, TENDERS.where((t) => t.status == 'Completed').length,   100],
          ['In Progress', AppColors.blue,  TENDERS.where((t) => t.status == 'In Progress').length, 50],
          ['Pending',     AppColors.gold,  TENDERS.where((t) => t.status == 'Pending').length,     10],
        ])
<<<<<<< HEAD
          Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
            Container(width: 10, height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: row[1] as Color)),
            const SizedBox(width: 8),
            Expanded(child: Text(row[0] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Nunito'))),
            Text('${row[2]} project${(row[2] as int) != 1 ? 's' : ''}',
              style: TextStyle(fontWeight: FontWeight.w800, color: row[1] as Color, fontFamily: 'Nunito')),
=======
          Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
            Container(width: 12, height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: row[1] as Color)),
            const SizedBox(width: 10),
            Expanded(child: Text(row[0] as String,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Nunito'))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: (row[1] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text('${row[2]} project${(row[2] as int) != 1 ? 's' : ''}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: row[1] as Color, fontFamily: 'Nunito')),
            ),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
          ])),
      ])),
    ]);
  }

  Widget _kpiCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
<<<<<<< HEAD
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
=======
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.greyDark, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      ]),
    );
  }

  // ── ACTIVITY FEED ──
<<<<<<< HEAD
  Widget _activityFeed() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      const Text('Latest updates across all projects', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 16),
      ...List.generate(activity.length, (i) {
        final a = activity[i];
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (a['color'] as Color).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(a['icon'] as IconData, size: 16, color: a['color'] as Color),
            ),
            if (i < activity.length - 1)
              Container(width: 2, height: 32, color: AppColors.border),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a['msg'] as String,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito', height: 1.4)),
              const SizedBox(height: 4),
              Text(a['time'] as String,
                style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
          )),
        ]);
=======
  Widget _activityFeed({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      const Text('Latest updates across all projects', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 20),
      ...List.generate(activity.length, (i) {
        final a = activity[i];
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Column(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: a['color'] as Color, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Icon(a['icon'] as IconData, size: 14, color: a['color'] as Color),
              ),
              if (i < activity.length - 1)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ]),
            const SizedBox(width: 14),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a['msg'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito', height: 1.4)),
                const SizedBox(height: 6),
                Text(a['time'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
              ])),
            )),
          ]),
        );
>>>>>>> 0bb83b382137fe82d4c3281e06b68288b7424ccc
      }),
    ]);
  }
}