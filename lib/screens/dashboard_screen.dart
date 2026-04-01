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
  String tenderFilter = 'All';
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

  // Recent activity feed
  final activity = const [
    {'icon': Icons.check_circle,    'color': AppColors.green,  'msg': 'Main Road Drainage marked Completed',    'time': '2h ago'},
    {'icon': Icons.upload_file,     'color': AppColors.blue,   'msg': 'LED Street Lights tender awarded',        'time': '5h ago'},
    {'icon': Icons.location_on,     'color': AppColors.orange, 'msg': 'MG Road Tarring GPS update logged',       'time': '1d ago'},
    {'icon': Icons.warning_amber,   'color': AppColors.gold,   'msg': 'Water Pipeline milestone delayed 2 weeks','time': '2d ago'},
  ];

  List<Tender> get filteredTenders => tenderFilter == 'All'
      ? TENDERS
      : TENDERS.where((t) => t.status == tenderFilter).toList();

  @override Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(children: [
        _buildHeader(isWide),
        _buildTabBar(),
        Padding(
          padding: EdgeInsets.all(isWide ? 24 : 14),
          child: isWide ? _wideBody() : _body(),
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
        // Budget card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TOTAL CITY BUDGET · FY 2025-26', style: TextStyle(fontSize: 10, color: Colors.white60, fontFamily: 'Nunito', letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(fmtCr(cityBudget), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
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
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(
                color: sec == t[0] ? AppColors.orange : Colors.transparent, width: 3))),
              child: Text(t[1], textAlign: TextAlign.center,
                style: TextStyle(fontWeight: sec == t[0] ? FontWeight.w900 : FontWeight.w500,
                  fontSize: 13, color: sec == t[0] ? AppColors.orange : AppColors.grey, fontFamily: 'Nunito')),
            ),
          )),
      ]),
    );
  }

  // ── WIDE LAYOUT ──
  Widget _wideBody() {
    if (sec == 'tenders' && selT != null) return _tenderDetail(selT!);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 6, child: _body()),
      const SizedBox(width: 20),
      Expanded(flex: 4, child: _rightPanel()),
    ]);
  }

  Widget _rightPanel() {
    return Column(children: [
      // Mini budget donut-style summary
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

      // Recent activity
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

      // Quick stats
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

  Widget _body() {
    if (sec == 'overview')  return _overview();
    if (sec == 'tenders')   return selT != null ? _tenderDetail(selT!) : _tenderList();
    if (sec == 'stats')     return _stats();
    return _activityFeed();
  }

  // ── OVERVIEW ──
  Widget _overview() {
    final stats = [
      ['Active',       AppColors.orange, TENDERS.where((t) => t.status == 'In Progress').length.toString(), Icons.autorenew],
      ['Done',         AppColors.green,  TENDERS.where((t) => t.status == 'Completed').length.toString(),   Icons.check_circle_outline],
      ['Spent',        AppColors.blue,   fmtCr(spent),                                                       Icons.account_balance_wallet_outlined],
      ['GPS Verified', AppColors.purple, '${TENDERS.where((t) => t.pct > 0).length}',                       Icons.location_on_outlined],
    ];

    return Column(children: [
      // Stat cards
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2,
        children: stats.map((s) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border(top: BorderSide(color: s[1] as Color, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14)],
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
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s[2] as String, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: s[1] as Color, fontFamily: 'Nunito')),
              Text(s[0] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
            ]),
          ]),
        )).toList(),
      ),
      const SizedBox(height: 14),

      // Budget by sector
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Budget by Sector', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          AppChip(label: 'FY 2025-26', color: AppColors.orange, small: true),
        ]),
        const SizedBox(height: 14),
        for (final s in sectors)
          Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(children: [
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
            const SizedBox(height: 6),
            AnimatedBar(value: (s['v'] as int).toDouble(), color: s['c'] as Color, height: 7),
          ])),
      ])),

      // Recent tenders preview
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Latest Projects', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          GestureDetector(
            onTap: () => setState(() => sec = 'tenders'),
            child: const Text('View all →', style: TextStyle(fontSize: 12, color: AppColors.orange, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
          ),
        ]),
        const SizedBox(height: 12),
        for (final t in TENDERS.take(2))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 4, height: 44,
                decoration: BoxDecoration(
                  color: t.status == 'Completed' ? AppColors.green : t.status == 'In Progress' ? AppColors.blue : AppColors.gold,
                  borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
                Text('${t.pct}% · ${fmtCr(t.value)}', style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
              ])),
              StatusBadge(status: t.status),
            ]),
          ),
      ])),
    ]);
  }

  // ── TENDER LIST ──
  Widget _tenderList() {
    final sc = {'Completed': AppColors.green, 'In Progress': AppColors.blue, 'Pending': AppColors.gold};
    final filters = ['All', 'In Progress', 'Completed', 'Pending'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Filter chips
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal,
        children: filters.map((f) => Padding(padding: const EdgeInsets.only(right: 8),
          child: AppChip(label: f, color: AppColors.orange,
            active: tenderFilter == f, onTap: () => setState(() => tenderFilter = f), small: true),
        )).toList(),
      )),
      const SizedBox(height: 12),
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
      AppCard(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MapWidget(label: t.title, height: 180),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
              ]),
            )).toList(),
          ),
        ])),
      ])),

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
      ])),
    ]);
  }

  // ── STATS ──
  Widget _stats() {
    return Column(children: [
      // Top KPI row
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
        const Text('Expenditure by Sector', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Allocation breakdown for FY 2025-26', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
        const SizedBox(height: 16),
        for (final s in sectors)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 12, height: 12,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: s['c'] as Color)),
                const SizedBox(width: 8),
                Text(s['l'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
              ]),
              Text('${fmtCr(cityBudget * (s['v'] as int) ~/ 100)}  ·  ${s['v']}%',
                style: TextStyle(color: s['c'] as Color, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
            ]),
            const SizedBox(height: 6),
            AnimatedBar(value: (s['v'] as int).toDouble(), color: s['c'] as Color, height: 10),
          ])),
      ])),

      // Tender status breakdown
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Project Status Breakdown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 14),
        for (final row in [
          ['Completed',   AppColors.green, TENDERS.where((t) => t.status == 'Completed').length,   100],
          ['In Progress', AppColors.blue,  TENDERS.where((t) => t.status == 'In Progress').length, 50],
          ['Pending',     AppColors.gold,  TENDERS.where((t) => t.status == 'Pending').length,     10],
        ])
          Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
            Container(width: 10, height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: row[1] as Color)),
            const SizedBox(width: 8),
            Expanded(child: Text(row[0] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Nunito'))),
            Text('${row[2]} project${(row[2] as int) != 1 ? 's' : ''}',
              style: TextStyle(fontWeight: FontWeight.w800, color: row[1] as Color, fontFamily: 'Nunito')),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
      ]),
    );
  }

  // ── ACTIVITY FEED ──
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
      }),
    ]);
  }
}