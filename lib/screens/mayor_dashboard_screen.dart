import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MAYOR'S EXECUTIVE DASHBOARD
//
// Tabs:
//   Command Center  — KPIs, urgent escalations, budget mini-view, project pulse
//   Citizen Pulse   — trending complaints, ward-wise heat map, top posts
//   Ward Tracking   — per-ward sevak status, issue counts, compliance
//
// Actions:
//   + New Poll      — inline form to create a poll
//   Broadcast       — send notice to all wards
// ─────────────────────────────────────────────────────────────────────────────

class MayorDashboardScreen extends StatefulWidget {
  final AppUser user;
  const MayorDashboardScreen({super.key, required this.user});
  @override State<MayorDashboardScreen> createState() => _MayorDashboardScreenState();
}

class _MayorDashboardScreenState extends State<MayorDashboardScreen>
    with TickerProviderStateMixin {

  String activeTab = 'overview';
  bool _showBroadcast = false;
  bool _showPoll      = false;
  bool _showOrder     = false;
  bool _broadcastSent = false;
  bool _orderSent     = false;

  late AnimationController _tabAnim;
  late Animation<double>   _tabFade;

  // ── Mock data ──
  static const cityBudget = 300000000;
  int get spent    => TENDERS.fold(0, (a, t) => a + (t.pct * t.value ~/ 100));
  double get spentPct => spent / cityBudget * 100;

  final _broadcastCtrl  = TextEditingController();
  final _pollQCtrl      = TextEditingController();

  // Issue Order form controllers
  final _orderSubjectCtrl  = TextEditingController();
  final _orderBodyCtrl     = TextEditingController();
  final _orderDeadlineCtrl = TextEditingController();
  String _orderToDept      = 'Water Supply Dept.';
  String _orderToWard      = 'Ward 3';
  String _orderPriority    = 'Urgent';
  String _orderCategory    = 'Service Delivery';
  // Auto-generated order number
  final String _orderNo = 'RNP/MAY/${DateTime.now().year}/${(DateTime.now().millisecondsSinceEpoch % 9000 + 1000)}';

  // Ward data (mock; aligns with real NP 12-ward structure)
  final wards = const [
    {'ward':'Ward 1', 'sevak':'Vijay Shinde',   'av':'VS','issues':3,  'resolved':2,  'events':1,'status':'good',   'comp':88},
    {'ward':'Ward 2', 'sevak':'Asha Kulkarni',  'av':'AK','issues':7,  'resolved':4,  'events':0,'status':'warn',   'comp':62},
    {'ward':'Ward 3', 'sevak':'Sunita Jadhav',  'av':'SJ','issues':18, 'resolved':6,  'events':2,'status':'alert',  'comp':40},
    {'ward':'Ward 4', 'sevak':'Ravi Pawar',     'av':'RP','issues':5,  'resolved':4,  'events':1,'status':'good',   'comp':82},
    {'ward':'Ward 5', 'sevak':'Nisha Desai',    'av':'ND','issues':9,  'resolved':5,  'events':0,'status':'warn',   'comp':58},
    {'ward':'Ward 6', 'sevak':'Deepak More',    'av':'DM','issues':2,  'resolved':2,  'events':2,'status':'good',   'comp':95},
    {'ward':'Ward 7', 'sevak':'Priya Joshi',    'av':'PJ','issues':4,  'resolved':3,  'events':1,'status':'good',   'comp':76},
    {'ward':'Ward 8', 'sevak':'Amit Gadge',     'av':'AG','issues':11, 'resolved':4,  'events':0,'status':'alert',  'comp':44},
    {'ward':'Ward 9', 'sevak':'Suresh Bhosle',  'av':'SB','issues':6,  'resolved':5,  'events':1,'status':'good',   'comp':80},
    {'ward':'Ward 10','sevak':'Kavita Rane',    'av':'KR','issues':8,  'resolved':3,  'events':0,'status':'warn',   'comp':55},
    {'ward':'Ward 11','sevak':'Mohan Patil',    'av':'MP','issues':3,  'resolved':3,  'events':1,'status':'good',   'comp':91},
    {'ward':'Ward 12','sevak':'Lalita Shinde',  'av':'LS','issues':5,  'resolved':4,  'events':1,'status':'good',   'comp':78},
  ];

  int get totalIssues   => wards.fold(0, (s, w) => s + (w['issues'] as int));
  int get totalResolved => wards.fold(0, (s, w) => s + (w['resolved'] as int));
  int get alertWards    => wards.where((w) => w['status'] == 'alert').length;

  // Citizen complaints by category (mock)
  final complaints = const [
    {'cat':'Water Supply',    'count':41, 'color':AppColors.teal,   'icon':Icons.water_drop_outlined,       'trend':'↑ 18%'},
    {'cat':'Roads & Potholes','count':28, 'color':AppColors.orange, 'icon':Icons.warning_amber_outlined,    'trend':'↑ 5%'},
    {'cat':'Street Lighting', 'count':19, 'color':AppColors.gold,   'icon':Icons.lightbulb_outline,         'trend':'→ 0%'},
    {'cat':'Garbage / Waste', 'count':16, 'color':AppColors.green,  'icon':Icons.delete_outline,            'trend':'↓ 3%'},
    {'cat':'Drainage',        'count':12, 'color':AppColors.blue,   'icon':Icons.waves,                     'trend':'↑ 2%'},
    {'cat':'Health & Sanit.', 'count':8,  'color':AppColors.red,    'icon':Icons.health_and_safety_outlined,'trend':'↓ 1%'},
  ];

  // Recent activity
  final recentActivity = const [
    {'icon':Icons.warning_amber_rounded,'color':AppColors.red,   'msg':'Ward 3 water crisis — 41 complaints in 48h',     'time':'2h ago', 'tag':'Escalated'},
    {'icon':Icons.check_circle_outline, 'color':AppColors.green, 'msg':'Main Road Drainage project marked Completed',     'time':'5h ago', 'tag':'Project'},
    {'icon':Icons.how_to_vote_outlined, 'color':AppColors.purple,'msg':'Road Repair Poll: 184 votes cast so far',          'time':'1d ago', 'tag':'Poll'},
    {'icon':Icons.upload_file,          'color':AppColors.blue,  'msg':'LED Street Lights tender awarded to BrightCity',  'time':'1d ago', 'tag':'Tender'},
    {'icon':Icons.campaign_outlined,    'color':AppColors.orange,'msg':'Property tax deadline broadcast sent to all wards','time':'2d ago', 'tag':'Notice'},
  ];

  @override void initState() {
    super.initState();
    _tabAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _tabFade = CurvedAnimation(parent: _tabAnim, curve: Curves.easeOut);
    _tabAnim.forward();
  }

  @override void dispose() {
    _tabAnim.dispose();
    _broadcastCtrl.dispose(); _pollQCtrl.dispose();
    _orderSubjectCtrl.dispose(); _orderBodyCtrl.dispose(); _orderDeadlineCtrl.dispose();
    super.dispose();
  }

  void _switchTab(String tab) {
    if (tab == activeTab) return;
    setState(() => activeTab = tab);
    _tabAnim.forward(from: 0);
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Stack(children: [
      SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(children: [
          _buildHeader(isWide),
          _buildTabBar(),
          FadeTransition(
            opacity: _tabFade,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 24 : 14),
              child: isWide ? _wideLayout() : _narrowLayout(),
            ),
          ),
        ]),
      ),
      // Modals
      if (_showBroadcast) _broadcastModal(),
      if (_showPoll)      _pollModal(),
      if (_showOrder)     _issueOrderModal(),
    ]);
  }

  // ══════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════
  Widget _buildHeader(bool isWide) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.navy, Color(0xFF1E4080)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('OFFICE OF THE MAYOR',
              style: TextStyle(fontSize: 10, color: Color(0xFFFB923C),
                  fontWeight: FontWeight.w800, letterSpacing: 1, fontFamily: 'Nunito')),
            const SizedBox(height: 3),
            Text('Welcome, ${widget.user.name.split(' ').first}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                  color: Colors.white, fontFamily: 'Nunito')),
            const Text('Rampur Nagar Panchayat · Executive Dashboard',
              style: TextStyle(fontSize: 12, color: Colors.white60, fontFamily: 'Nunito')),
          ])),
          AppAvatar(initials: widget.user.avatar, color: AppColors.orange, size: 46),
        ]),
        const SizedBox(height: 16),

        // Live pulse strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _headerStat('$totalIssues',           'Open Issues',     AppColors.red),
            _vDiv(),
            _headerStat('$alertWards',            'Alert Wards',     AppColors.gold),
            _vDiv(),
            _headerStat('${spentPct.round()}%',   'Budget Used',     AppColors.teal),
            _vDiv(),
            _headerStat('${TENDERS.where((t)=>t.status=='In Progress').length}','Active Projects', AppColors.blue),
          ]),
        ),
        const SizedBox(height: 14),

        // Action buttons
        Row(children: [
          Expanded(child: AppBtn(
            label: '+ New Poll', small: true, color: AppColors.orange,
            icon: Icons.poll_outlined,
            onTap: () => setState(() { _showPoll = true; _showBroadcast = false; }),
          )),
          const SizedBox(width: 10),
          Expanded(child: AppBtn(
            label: 'Broadcast', small: true, color: Colors.white,
            outline: true, icon: Icons.campaign_outlined,
            onTap: () => setState(() { _showBroadcast = true; _showPoll = false; }),
          )),
          const SizedBox(width: 10),
          Expanded(child: AppBtn(
            label: 'Issue Order', small: true, color: Colors.white,
            outline: true, icon: Icons.edit_document,
            onTap: () => setState(() { _showOrder = true; _showBroadcast = false; _showPoll = false; }),
          )),
        ]),
      ]),
    );
  }

  Widget _headerStat(String val, String label, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
        color: color, fontFamily: 'Nunito')),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'Nunito')),
  ]);

  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white12);

  // ══════════════════════════════════════════════
  // TAB BAR
  // ══════════════════════════════════════════════
  Widget _buildTabBar() {
    const tabs = [
      ['overview', 'Command Centre'],
      ['pulse',    'Citizen Pulse'],
      ['wards',    'Ward Tracking'],
    ];
    return Container(
      color: AppColors.white,
      child: Row(children: tabs.map((t) {
        final active = activeTab == t[0];
        return Expanded(child: GestureDetector(
          onTap: () => _switchTab(t[0]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(
              color: active ? AppColors.orange : Colors.transparent, width: 3))),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w500,
                fontSize: 13, color: active ? AppColors.orange : AppColors.grey, fontFamily: 'Nunito'),
              child: Text(t[1], textAlign: TextAlign.center)),
          ),
        ));
      }).toList()),
    );
  }

  // ══════════════════════════════════════════════
  // LAYOUTS
  // ══════════════════════════════════════════════
  Widget _wideLayout() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(flex: 6, child: _activeContent()),
    const SizedBox(width: 20),
    Expanded(flex: 4, child: _sidebar()),
  ]);

  Widget _narrowLayout() => _activeContent();

  Widget _activeContent() {
    switch (activeTab) {
      case 'pulse': return _pulseContent();
      case 'wards': return _wardsContent();
      default:      return _overviewContent();
    }
  }

  // ══════════════════════════════════════════════
  // SIDEBAR (PC)
  // ══════════════════════════════════════════════
  Widget _sidebar() => Column(children: [
    // Recent Activity
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      ...recentActivity.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: (a['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(a['icon'] as IconData, size: 14, color: a['color'] as Color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['msg'] as String, style: const TextStyle(fontSize: 12, fontFamily: 'Nunito', height: 1.4)),
            const SizedBox(height: 3),
            Row(children: [
              AppChip(label: a['tag'] as String, color: a['color'] as Color, small: true),
              const SizedBox(width: 6),
              Text(a['time'] as String, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
            ]),
          ])),
        ]),
      )),
    ])),

    // Trending topics
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Trending Citizen Topics', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final t in [
        ['#WaterCrisis',   '89 posts', AppColors.teal],
        ['#MGRoad',        '42 posts', AppColors.orange],
        ['#Cleanliness',   '61 posts', AppColors.green],
        ['#Ward3',         '34 posts', AppColors.blue],
        ['#StreetLights',  '19 posts', AppColors.gold],
      ])
        Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(t[0] as String, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: t[2] as Color, fontFamily: 'Nunito')),
            Text(t[1] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
    ])),

    // Upcoming council schedule
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Council Calendar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final e in [
        {'title':'Monthly Council Meeting', 'date':'Dec 22','time':'10:00 AM','color':AppColors.navy},
        {'title':'Water Dept. Review',      'date':'Dec 24','time':'3:00 PM', 'color':AppColors.teal},
        {'title':'Budget Audit Session',    'date':'Dec 27','time':'11:00 AM','color':AppColors.orange},
      ])
        Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(width: 4, height: 36,
              decoration: BoxDecoration(color: e['color'] as Color, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito')),
              Text('${e['date']} · ${e['time']}', style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
          ])),
    ])),
  ]);

  // ══════════════════════════════════════════════
  // TAB 1 — COMMAND CENTRE
  // ══════════════════════════════════════════════
  Widget _overviewContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

    // KPI grid
    GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.85,
      children: [
        _kpiCard('Unresolved Issues',   '$totalIssues',                                     AppColors.red,    Icons.warning_amber_rounded),
        _kpiCard('Active Projects',     '${TENDERS.where((t)=>t.status=="In Progress").length}', AppColors.blue,  Icons.construction_outlined),
        _kpiCard('Budget Used',         '${spentPct.round()}%',                             AppColors.green,  Icons.account_balance_wallet_outlined),
        _kpiCard('Wards in Alert',      '$alertWards',                                      AppColors.gold,   Icons.notifications_active_outlined),
      ],
    ),
    const SizedBox(height: 18),

    // Urgent escalations
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('🚨 Urgent Escalations', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito')),
      AppChip(label: '${wards.where((w) => w['status'] == 'alert').length} active', color: AppColors.red, small: true),
    ]),
    const SizedBox(height: 8),
    ...wards.where((w) => w['status'] == 'alert').map((w) => AppCard(
      borderColor: AppColors.red.withOpacity(0.35),
      bgColor: AppColors.redLight,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.red.withOpacity(0.12), shape: BoxShape.circle),
          child: const Icon(Icons.priority_high, color: AppColors.red, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(w['ward'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Nunito')),
            const SizedBox(width: 8),
            AppChip(label: '${w['issues']} issues', color: AppColors.red, small: true),
          ]),
          const SizedBox(height: 4),
          Text('Sevak: ${w['sevak']} · ${(w['resolved'] as int)} of ${(w['issues'] as int)} resolved',
            style: const TextStyle(fontSize: 12, color: AppColors.greyDark, fontFamily: 'Nunito')),
          const SizedBox(height: 6),
          AnimatedBar(value: (w['comp'] as int).toDouble(), color: AppColors.red, height: 6),
          const SizedBox(height: 2),
          Text('${w['comp']}% compliance', style: const TextStyle(fontSize: 10, color: AppColors.red, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
          const SizedBox(height: 10),
          Row(children: [
            AppBtn(label: 'Dispatch Order', small: true, color: AppColors.red, icon: Icons.send_outlined,
              onTap: () => setState(() {
                _orderToWard = w['ward'] as String;
                _orderPriority = 'Urgent';
                _orderToDept = 'Water Supply Dept.';
                _orderSubjectCtrl.text = 'Immediate remediation required — ${w['ward']}';
                _orderBodyCtrl.clear();
                _orderSent = false;
                _showOrder = true; _showBroadcast = false; _showPoll = false;
              })),
            const SizedBox(width: 8),
            AppBtn(label: 'Call Sevak', small: true, color: AppColors.red, outline: true, icon: Icons.call_outlined, onTap: () {}),
          ]),
        ])),
      ]),
    )),

    const SizedBox(height: 6),

    // Budget overview
    const Text('Budget Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito')),
    const SizedBox(height: 10),
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOTAL ANNUAL BUDGET', style: TextStyle(fontSize: 10, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
          Text(fmtCr(cityBudget), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.navy, fontFamily: 'Nunito')),
        ]),
        AppChip(label: 'FY 2025–26', color: AppColors.orange, small: true),
      ]),
      const SizedBox(height: 12),
      AnimatedBar(value: spentPct, color: AppColors.orange, height: 10),
      const SizedBox(height: 8),
      Row(children: [
        _budgetPill('Released',  fmtCr(spent),               AppColors.orange),
        const SizedBox(width: 8),
        _budgetPill('Remaining', fmtCr(cityBudget - spent),  AppColors.green),
        const SizedBox(width: 8),
        _budgetPill('Projects',  '${TENDERS.length}',        AppColors.blue),
      ]),
      const SizedBox(height: 14),
      // Sector split
      const Text('BY SECTOR', style: TextStyle(fontSize: 10, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
      const SizedBox(height: 10),
      for (final row in [
        ['Roads & Drainage',    28, AppColors.orange],
        ['Water Supply',        22, AppColors.teal],
        ['Solid Waste & Sanit.',16, AppColors.green],
        ['Street Lighting',     12, AppColors.gold],
        ['Health & Education',  12, AppColors.red],
        ['Administration',       6, AppColors.blue],
        ['Parks & Recreation',   4, AppColors.purple],
      ])
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: row[2] as Color)),
          const SizedBox(width: 8),
          Expanded(child: Text(row[0] as String, style: const TextStyle(fontSize: 12, fontFamily: 'Nunito'))),
          Text('${row[1]}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: row[2] as Color, fontFamily: 'Nunito')),
        ])),
    ])),

    const SizedBox(height: 6),

    // Live project tracker
    const Text('Live Project Status', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito')),
    const SizedBox(height: 10),
    ...TENDERS.map((t) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito'))),
        StatusBadge(status: t.status),
      ]),
      const SizedBox(height: 4),
      Text('${t.contractor} · ${t.sector} · Due ${t.due}',
        style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 10),
      AnimatedBar(value: t.pct.toDouble(), color: statusColor(t.status), height: 7),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(fmtCr(t.value), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
        Text('${t.pct}% complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            color: statusColor(t.status), fontFamily: 'Nunito')),
      ]),
    ]))),
  ]);

  Widget _budgetPill(String label, String val, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.09), borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
    ]),
  ));

  Widget _kpiCard(String label, String value, Color color, IconData icon) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withOpacity(0.2)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 17)),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
      ]),
    ]),
  );

  // ══════════════════════════════════════════════
  // TAB 2 — CITIZEN PULSE
  // ══════════════════════════════════════════════
  Widget _pulseContent() {
    final maxCount = complaints.fold(0, (m, c) => (c['count'] as int) > m ? (c['count'] as int) : m);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Summary
      Row(children: [
        Expanded(child: _pulseKpi('$totalIssues', 'Total Open',  AppColors.red)),
        const SizedBox(width: 10),
        Expanded(child: _pulseKpi('$totalResolved', 'Resolved',  AppColors.green)),
        const SizedBox(width: 10),
        Expanded(child: _pulseKpi('${((totalResolved/totalIssues)*100).round()}%', 'Resolution Rate', AppColors.blue)),
      ]),
      const SizedBox(height: 16),

      // Complaint breakdown
      const Text('Complaints by Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito')),
      const SizedBox(height: 10),
      AppCard(child: Column(children: [
        for (final c in complaints) ...[
          Row(children: [
            Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: (c['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(c['icon'] as IconData, size: 15, color: c['color'] as Color)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(c['cat'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
                Row(children: [
                  Text('${c['count']}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13,
                      color: c['color'] as Color, fontFamily: 'Nunito')),
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: (c['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(c['trend'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: c['color'] as Color, fontFamily: 'Nunito'))),
                ]),
              ]),
              const SizedBox(height: 5),
              ClipRRect(borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (c['count'] as int) / maxCount, minHeight: 7,
                  backgroundColor: (c['color'] as Color).withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(c['color'] as Color))),
            ])),
          ]),
          if (c != complaints.last) const SizedBox(height: 14),
        ],
      ])),

      const SizedBox(height: 6),

      // Ward heat map (list style)
      const Text('Ward-wise Complaint Heat Map', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito')),
      const SizedBox(height: 10),
      AppCard(child: Column(children: [
        // Legend
        Row(children: [
          _legendDot(AppColors.red,    'Alert  (10+)'),
          const SizedBox(width: 16),
          _legendDot(AppColors.gold,   'Watch  (5–9)'),
          const SizedBox(width: 16),
          _legendDot(AppColors.green,  'Good   (<5)'),
        ]),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.7,
          children: wards.map((w) {
            final color = w['status'] == 'alert' ? AppColors.red
                : w['status'] == 'warn'  ? AppColors.gold
                : AppColors.green;
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.09),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(w['ward'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, fontFamily: 'Nunito')),
                const SizedBox(height: 2),
                Text('${w['issues']} issues', style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
              ]),
            );
          }).toList(),
        ),
      ])),

      const SizedBox(height: 6),

      // Top citizen posts needing Mayor's attention
      const Text('Posts Needing Attention', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito')),
      const SizedBox(height: 10),
      for (final post in [
        {'user':'Meera Joshi', 'av':'MJ', 'body':'Water supply irregular for 10 days. Who is accountable? #WaterCrisis #Ward3', 'likes':89, 'comments':27, 'ward':'Ward 3', 'color':AppColors.teal},
        {'user':'Priya Desai', 'av':'PD', 'body':'Footpath on MG Road broken — kids at risk. #MGRoad #Infrastructure',           'likes':34, 'comments':8,  'ward':'Ward 3', 'color':AppColors.orange},
      ])
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AppAvatar(initials: post['av'] as String, color: post['color'] as Color, size: 32),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post['user'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
              Text(post['ward'] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
            AppChip(label: '${post['likes']} ❤', color: AppColors.red, small: true),
          ]),
          const SizedBox(height: 8),
          Text(post['body'] as String, style: const TextStyle(fontSize: 13, fontFamily: 'Nunito', height: 1.5, color: AppColors.greyDark)),
          const SizedBox(height: 10),
          Row(children: [
            AppBtn(label: 'Acknowledge', small: true, color: AppColors.blue,   icon: Icons.thumb_up_outlined,     onTap: () {}),
            const SizedBox(width: 8),
            AppBtn(label: 'Escalate',   small: true, color: AppColors.red,    icon: Icons.priority_high,          onTap: () {}),
          ]),
        ])),
    ]);
  }

  Widget _pulseKpi(String val, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
    ]),
  );

  Widget _legendDot(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.greyDark, fontFamily: 'Nunito')),
  ]);

  // ══════════════════════════════════════════════
  // TAB 3 — WARD TRACKING
  // ══════════════════════════════════════════════
  Widget _wardsContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Summary row
    Row(children: [
      Expanded(child: _pulseKpi('${wards.where((w)=>w['status']=='good').length}',  'Wards Good',  AppColors.green)),
      const SizedBox(width: 8),
      Expanded(child: _pulseKpi('${wards.where((w)=>w['status']=='warn').length}',  'Wards Watch', AppColors.gold)),
      const SizedBox(width: 8),
      Expanded(child: _pulseKpi('${wards.where((w)=>w['status']=='alert').length}', 'Wards Alert', AppColors.red)),
    ]),
    const SizedBox(height: 16),

    const Text('All Ward Sevaks', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito')),
    const SizedBox(height: 4),
    const Text('Tap a ward to issue instructions or view details',
      style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
    const SizedBox(height: 12),

    ...wards.map((w) {
      final color  = w['status'] == 'alert' ? AppColors.red
          : w['status'] == 'warn' ? AppColors.gold
          : AppColors.green;
      final comp   = w['comp'] as int;

      return AppCard(
        borderColor: color.withOpacity(0.25),
        child: Column(children: [
          Row(children: [
            AppAvatar(initials: w['av'] as String, color: color, size: 36),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(w['ward'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Nunito')),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    w['status'] == 'alert' ? '🔴 Alert' : w['status'] == 'warn' ? '🟡 Watch' : '🟢 Good',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color, fontFamily: 'Nunito'))),
              ]),
              Text(w['sevak'] as String, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$comp%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
              const Text('compliance', style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
            ]),
          ]),
          const SizedBox(height: 10),
          AnimatedBar(value: comp.toDouble(), color: color, height: 7),
          const SizedBox(height: 8),
          Row(children: [
            _wardStat(Icons.warning_amber_outlined, '${w['issues']} issues',   AppColors.red),
            const SizedBox(width: 12),
            _wardStat(Icons.check_circle_outline,   '${w['resolved']} resolved', AppColors.green),
            const SizedBox(width: 12),
            _wardStat(Icons.event_outlined,         '${w['events']} events',   AppColors.blue),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() {
                _orderToWard = w['ward'] as String;
                _orderPriority = w['status'] == 'alert' ? 'Urgent' : 'Normal';
                _orderSubjectCtrl.text = '';
                _orderBodyCtrl.clear();
                _orderSent = false;
                _showOrder = true; _showBroadcast = false; _showPoll = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.send_outlined, size: 13, color: color),
                  const SizedBox(width: 4),
                  Text('Order', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'Nunito')),
                ]),
              ),
            ),
          ]),
        ]),
      );
    }),
  ]);

  Widget _wardStat(IconData icon, String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: color),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
  ]);

  // ══════════════════════════════════════════════
  // BROADCAST MODAL
  // ══════════════════════════════════════════════
  Widget _broadcastModal() {
    return Positioned.fill(child: GestureDetector(
      onTap: () => setState(() { _showBroadcast = false; _broadcastSent = false; }),
      child: Container(
        color: Colors.black54,
        child: Center(child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _broadcastSent
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('📢', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 10),
                  const Text('Notice Broadcast!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.green, fontFamily: 'Nunito')),
                  const SizedBox(height: 6),
                  const Text('Sent to all 12 wards and 1.2K registered citizens.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.grey, fontFamily: 'Nunito')),
                  const SizedBox(height: 18),
                  AppBtn(label: 'Close', full: true, color: AppColors.navy, onTap: () => setState(() { _showBroadcast = false; _broadcastSent = false; })),
                ])
              : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Send Broadcast Notice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
                    GestureDetector(onTap: () => setState(() => _showBroadcast = false),
                      child: const Icon(Icons.close, color: AppColors.grey)),
                  ]),
                  const SizedBox(height: 6),
                  const Text('Reaches all registered JanaSetu citizens and ward sevaks.',
                    style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
                  const SizedBox(height: 16),
                  const Text('NOTICE TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    for (final t in ['Alert 🚨', 'Announcement 📢', 'Event 📅', 'Service Update 🔧'])
                      AppChip(label: t, color: AppColors.orange, small: true),
                  ]),
                  const SizedBox(height: 14),
                  const Text('MESSAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
                  const SizedBox(height: 6),
                  TextField(controller: _broadcastCtrl, maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Write your official notice here…'),
                    style: const TextStyle(fontFamily: 'Nunito')),
                  const SizedBox(height: 14),
                  Container(padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(10)),
                    child: Row(children: const [
                      Icon(Icons.info_outline, size: 13, color: AppColors.blue),
                      SizedBox(width: 6),
                      Expanded(child: Text('Will be delivered via SMS + push notification to all wards.',
                        style: TextStyle(fontSize: 11, color: AppColors.blue, fontFamily: 'Nunito'))),
                    ])),
                  const SizedBox(height: 16),
                  AppBtn(label: '📢 Send to All Wards', full: true, color: AppColors.navy, icon: Icons.campaign_outlined,
                    onTap: () => setState(() => _broadcastSent = true)),
                ]),
            ),
          ),
        )),
      ),
    ));
  }

  // ══════════════════════════════════════════════
  // POLL CREATION MODAL
  // ══════════════════════════════════════════════
  Widget _pollModal() {
    return Positioned.fill(child: GestureDetector(
      onTap: () => setState(() => _showPoll = false),
      child: Container(
        color: Colors.black54,
        child: Center(child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Create Community Poll', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
                GestureDetector(onTap: () => setState(() => _showPoll = false),
                  child: const Icon(Icons.close, color: AppColors.grey)),
              ]),
              const SizedBox(height: 6),
              const Text('Poll will be visible to all registered citizens and ward sevaks.',
                style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
              const SizedBox(height: 16),
              const Text('POLL QUESTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
              const SizedBox(height: 6),
              TextField(controller: _pollQCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Which road should be repaired first?'),
                style: const TextStyle(fontFamily: 'Nunito')),
              const SizedBox(height: 14),
              const Text('OPTIONS (minimum 2)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
              const SizedBox(height: 6),
              for (final hint in ['Option 1', 'Option 2', 'Option 3 (optional)'])
                Padding(padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(decoration: InputDecoration(hintText: hint),
                    style: const TextStyle(fontFamily: 'Nunito'))),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.grey),
                const SizedBox(width: 6),
                const Text('Poll duration:', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
                const SizedBox(width: 8),
                for (final d in ['3 days', '7 days', '14 days'])
                  Padding(padding: const EdgeInsets.only(right: 6),
                    child: AppChip(label: d, color: AppColors.orange, small: true, active: d == '7 days')),
              ]),
              const SizedBox(height: 16),
              AppBtn(label: '📊 Publish Poll', full: true, color: AppColors.orange, icon: Icons.poll_outlined,
                onTap: () => setState(() => _showPoll = false)),
            ])),
          ),
        )),
      ),
    ));
  }

  // ══════════════════════════════════════════════
  // ISSUE ORDER MODAL
  // ══════════════════════════════════════════════
  Widget _issueOrderModal() {
    const depts = [
      'Water Supply Dept.', 'Engineering Dept.', 'Sanitation Dept.',
      'Street Lighting Dept.', 'Health Dept.', 'Fire & Safety Dept.',
      'Education Dept.', 'Markets Dept.', 'Ward Sevak (Direct)',
    ];
    const wardList = [
      'All Wards', 'Ward 1', 'Ward 2', 'Ward 3', 'Ward 4',
      'Ward 5', 'Ward 6', 'Ward 7', 'Ward 8', 'Ward 9',
      'Ward 10', 'Ward 11', 'Ward 12',
    ];
    const categories = [
      'Service Delivery', 'Infrastructure Repair', 'Public Health',
      'Financial / Tax', 'Law & Order', 'Development Project', 'Other',
    ];
    const priorities = ['Urgent', 'High', 'Normal', 'Routine'];
    final priorityColors = {
      'Urgent':  AppColors.red,
      'High':    AppColors.orange,
      'Normal':  AppColors.blue,
      'Routine': AppColors.grey,
    };

    return Positioned.fill(child: GestureDetector(
      onTap: () => setState(() { _showOrder = false; _orderSent = false; }),
      child: Container(
        color: Colors.black54,
        child: Center(child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            constraints: const BoxConstraints(maxWidth: 560),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2),
                  blurRadius: 40, offset: const Offset(0, 16))]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                child: _orderSent
                    ? _orderSuccessView()
                    : _orderFormView(depts, wardList, categories, priorities, priorityColors),
              ),
            ),
          ),
        )),
      ),
    ));
  }

  Widget _orderSuccessView() => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green.withOpacity(0.1),
          border: Border.all(color: AppColors.green, width: 2.5)),
        child: const Icon(Icons.verified_outlined, color: AppColors.green, size: 42)),
      const SizedBox(height: 16),
      const Text('Order Dispatched', style: TextStyle(fontSize: 22,
          fontWeight: FontWeight.w900, color: AppColors.green, fontFamily: 'Nunito')),
      const SizedBox(height: 6),
      Text(_orderNo, style: const TextStyle(fontSize: 12, color: AppColors.grey,
          fontFamily: 'Nunito', letterSpacing: 0.5)),
      const SizedBox(height: 18),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _summaryRow('To',       '$_orderToDept — $_orderToWard'),
          _summaryRow('Subject',  _orderSubjectCtrl.text.isEmpty ? '(No subject)' : _orderSubjectCtrl.text),
          _summaryRow('Category', _orderCategory),
          _summaryRow('Priority', _orderPriority),
          _summaryRow('Deadline', _orderDeadlineCtrl.text.isEmpty ? 'As soon as possible' : _orderDeadlineCtrl.text),
          _summaryRow('Issued by','Mayor · ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
        ]),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(10)),
        child: Row(children: const [
          Icon(Icons.info_outline, size: 13, color: AppColors.blue),
          SizedBox(width: 8),
          Expanded(child: Text(
            'The designated officer has been notified via SMS and in-app alert. '
            'A copy has been logged in official records.',
            style: TextStyle(fontSize: 11, color: AppColors.blue, fontFamily: 'Nunito', height: 1.5))),
        ]),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: AppBtn(
          label: 'Issue Another', outline: true, color: AppColors.navy, icon: Icons.add,
          onTap: () => setState(() { _orderSent = false; _orderSubjectCtrl.clear(); _orderBodyCtrl.clear(); _orderDeadlineCtrl.clear(); }),
        )),
        const SizedBox(width: 10),
        Expanded(child: AppBtn(
          label: 'Done', color: AppColors.navy, icon: Icons.check,
          onTap: () => setState(() { _showOrder = false; _orderSent = false; }),
        )),
      ]),
    ]),
  );

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 80, child: Text('$label:', style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.grey, fontFamily: 'Nunito'))),
      Expanded(child: Text(value, style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dark, fontFamily: 'Nunito'))),
    ]),
  );

  Widget _orderFormView(
    List<String> depts, List<String> wardList,
    List<String> categories, List<String> priorities,
    Map<String, Color> priorityColors,
  ) {
    final pColor = priorityColors[_orderPriority] ?? AppColors.grey;
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── Official header band ──
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [AppColors.navy, Color(0xFF1E4080)],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('OFFICIAL EXECUTIVE ORDER', style: TextStyle(fontSize: 9,
                  color: Color(0xFFFB923C), fontWeight: FontWeight.w800,
                  letterSpacing: 1.5, fontFamily: 'Nunito')),
              const SizedBox(height: 3),
              const Text('Rampur Nagar Panchayat', style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
              Text('Office of the Mayor  ·  $_orderNo', style: const TextStyle(
                  fontSize: 11, color: Colors.white54, fontFamily: 'Nunito')),
            ])),
            GestureDetector(
              onTap: () => setState(() { _showOrder = false; _orderSent = false; }),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.close, color: Colors.white, size: 18))),
          ]),
        ]),
      ),

      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Priority ──
          _sectionLabel('PRIORITY LEVEL'),
          const SizedBox(height: 8),
          Row(children: priorities.map((p) {
            final active = _orderPriority == p;
            final c = priorityColors[p]!;
            return Expanded(child: Padding(
              padding: EdgeInsets.only(right: p != priorities.last ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _orderPriority = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? c : c.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: active ? c : c.withOpacity(0.3), width: 1.5)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_priorityIcon(p), size: 16, color: active ? Colors.white : c),
                    const SizedBox(height: 3),
                    Text(p, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        color: active ? Colors.white : c, fontFamily: 'Nunito')),
                  ]),
                ),
              ),
            ));
          }).toList()),
          const SizedBox(height: 18),

          // ── Addressed to ──
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionLabel('ADDRESSED TO (DEPT.)'),
              const SizedBox(height: 8),
              _orderDropdown(value: _orderToDept, items: depts,
                onChanged: (v) => setState(() => _orderToDept = v ?? _orderToDept)),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionLabel('WARD / JURISDICTION'),
              const SizedBox(height: 8),
              _orderDropdown(value: _orderToWard, items: wardList,
                onChanged: (v) => setState(() => _orderToWard = v ?? _orderToWard)),
            ])),
          ]),
          const SizedBox(height: 16),

          // ── Category ──
          _sectionLabel('ORDER CATEGORY'),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: categories.map((c) {
            final active = _orderCategory == c;
            return GestureDetector(
              onTap: () => setState(() => _orderCategory = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.navy : AppColors.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? AppColors.navy : AppColors.border, width: 1.5)),
                child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.greyDark, fontFamily: 'Nunito')),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),

          // ── Subject ──
          _sectionLabel('SUBJECT OF ORDER'),
          const SizedBox(height: 8),
          TextField(
            controller: _orderSubjectCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g. Immediate restoration of water supply in Ward 3'),
            style: const TextStyle(fontFamily: 'Nunito')),
          const SizedBox(height: 16),

          // ── Body ──
          _sectionLabel('DIRECTIVES & DETAILS'),
          const SizedBox(height: 8),
          TextField(
            controller: _orderBodyCtrl, maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Describe the required action, responsible officer, '
                  'and any conditions attached to this order.',
              alignLabelWithHint: true),
            style: const TextStyle(fontFamily: 'Nunito', height: 1.5)),
          const SizedBox(height: 16),

          // ── Deadline ──
          _sectionLabel('COMPLIANCE DEADLINE'),
          const SizedBox(height: 8),
          TextField(
            controller: _orderDeadlineCtrl,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              hintText: 'e.g. 25 December 2025, 5:00 PM',
              prefixIcon: Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.grey)),
            style: const TextStyle(fontFamily: 'Nunito')),
          const SizedBox(height: 14),

          // ── Priority note banner ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pColor.withOpacity(0.25))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(_priorityIcon(_orderPriority), size: 15, color: pColor),
              const SizedBox(width: 8),
              Expanded(child: Text(
                _orderPriority == 'Urgent'
                  ? 'URGENT: This order supersedes all routine scheduling. The designated officer must respond and initiate action within 24 hours.'
                  : _orderPriority == 'High'
                  ? 'HIGH PRIORITY: Action must be initiated within 48 hours of receipt. Weekly progress reports required.'
                  : _orderPriority == 'Normal'
                  ? 'Action to be completed by the stated deadline. Submit a completion report to the Mayor\'s office upon compliance.'
                  : 'Routine directive. Comply as per standard operating timelines and procedures.',
                style: TextStyle(fontSize: 11, color: pColor, fontFamily: 'Nunito', height: 1.5))),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Legal footer ──
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Icon(Icons.gavel_outlined, size: 13, color: AppColors.grey),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Issued under the authority of the Mayor, Rampur Nagar Panchayat, '
                'under the Maharashtra Municipal Councils, Nagar Panchayats and '
                'Industrial Townships Act, 1965. Non-compliance may attract disciplinary action.',
                style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito', height: 1.5))),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Actions ──
          Row(children: [
            Expanded(child: AppBtn(
              label: 'Cancel', outline: true, color: AppColors.grey,
              onTap: () => setState(() { _showOrder = false; _orderSent = false; }),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: AppBtn(
              label: 'Issue Official Order',
              color: AppColors.navy, icon: Icons.send_outlined, full: true,
              onTap: () { if (_orderSubjectCtrl.text.trim().isNotEmpty) setState(() => _orderSent = true); },
            )),
          ]),

        ]),
      ),
    ]);
  }

  IconData _priorityIcon(String p) {
    switch (p) {
      case 'Urgent':  return Icons.priority_high;
      case 'High':    return Icons.keyboard_double_arrow_up;
      case 'Normal':  return Icons.remove;
      case 'Routine': return Icons.keyboard_double_arrow_down;
      default:        return Icons.circle_outlined;
    }
  }

  Widget _sectionLabel(String t) => Text(t, style: const TextStyle(
    fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey,
    letterSpacing: 0.6, fontFamily: 'Nunito'));

  Widget _orderDropdown({
    required String value, required List<String> items,
    required void Function(String?) onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: AppColors.bg,
      border: Border.all(color: AppColors.border, width: 1.5),
      borderRadius: BorderRadius.circular(12)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value, isExpanded: true,
      style: const TextStyle(fontFamily: 'Nunito', color: AppColors.dark, fontSize: 13),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    )),
  );
}