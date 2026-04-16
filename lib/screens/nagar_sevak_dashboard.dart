import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NAGAR SEVAK DASHBOARD
//
// Role: Elected ward councillor — primary link between citizens & administration
// Scope: Single ward (Ward 3 for Sunita Jadhav)
//
// Tabs:
//   My Ward       — KPIs, amenity status, active projects, recent activity
//   Grievances    — All citizen complaints filed in ward, with action buttons
//   Ward Fund     — Budget allocation, spending log, raise new work request
//
// Modals:
//   Escalate to Mayor  — forward a grievance up the chain
//   Report to Council  — submit ward activity report for the monthly meeting
//   New Work Request   — request ward fund expenditure for a small project
// ─────────────────────────────────────────────────────────────────────────────

class NagarSevakDashboard extends StatefulWidget {
  final AppUser user;
  const NagarSevakDashboard({super.key, required this.user});
  @override State<NagarSevakDashboard> createState() => _NagarSevakDashboardState();
}

class _NagarSevakDashboardState extends State<NagarSevakDashboard>
    with TickerProviderStateMixin {

  String _tab = 'ward';

  late AnimationController _tabCtrl;
  late Animation<double>   _tabFade;

  // Modals
  bool _showEscalate  = false;
  bool _showReport    = false;
  bool _showWorkReq   = false;
  bool _escalateSent  = false;
  bool _reportSent    = false;
  bool _workReqSent   = false;

  // Controllers
  final _escalateCtrl = TextEditingController();
  final _reportCtrl   = TextEditingController();
  final _workTitleCtrl= TextEditingController();
  final _workDescCtrl = TextEditingController();
  final _workCostCtrl = TextEditingController();
  String _workCat     = 'Roads & Drainage';

  // ── Ward 3 data (mock, scoped to this ward) ──

  // Amenity health — each service the sevak is responsible for
  final amenities = const [
    {'name':'Water Supply',   'status':'Issue',   'desc':'Irregular supply 8–10 AM only',      'color':AppColors.red,    'icon':Icons.water_drop_outlined,        'since':'3 days'},
    {'name':'Street Lighting','status':'Good',    'desc':'All 42 lights functional',           'color':AppColors.green,  'icon':Icons.lightbulb_outline,          'since':'—'},
    {'name':'Garbage Pickup', 'status':'Good',    'desc':'Daily 6 AM collection running',      'color':AppColors.green,  'icon':Icons.delete_outline,             'since':'—'},
    {'name':'Drainage',       'status':'Warning', 'desc':'2 blocked drains near school gate',  'color':AppColors.gold,   'icon':Icons.waves,                      'since':'5 days'},
    {'name':'Road Condition', 'status':'Issue',   'desc':'Pothole on MG Road near bus stop',   'color':AppColors.red,    'icon':Icons.warning_amber_outlined,     'since':'7 days'},
    {'name':'Public Park',    'status':'Good',    'desc':'Gandhi Park maintained & open',      'color':AppColors.green,  'icon':Icons.park_outlined,              'since':'—'},
  ];

  // Active civic projects in the ward
  final List<Map<String, dynamic>> projects = [
    {'title':'MG Road Tarring',          'dept':'Engineering','status':'In Progress','pct':65,'color':AppColors.orange, 'due':'Jun 2025','value':12500000},
    {'title':'Ward 3 Drainage Repair',   'dept':'Engineering','status':'Pending',    'pct':0, 'color':AppColors.gold,   'due':'Mar 2025','value':3200000},
    {'title':'Community Hall Renovation','dept':'Civic',       'status':'Completed',  'pct':100,'color':AppColors.green, 'due':'Dec 2024','value':1800000},
  ];

  // Citizen grievances filed in Ward 3
  final List<Map<String, dynamic>> grievances = [
    {'id':'#8831','name':'Priya Desai',   'av':'PD','dept':'Water Supply',   'title':'No water for 3 days',                 'status':'Pending',     'time':'1d ago', 'priority':'High',   'color':AppColors.teal},
    {'id':'#8832','name':'Rahul More',    'av':'RM','dept':'Roads',          'title':'Dangerous pothole near bus stop',      'status':'In Progress', 'time':'2d ago', 'priority':'High',   'color':AppColors.orange},
    {'id':'#8833','name':'Meera Joshi',   'av':'MJ','dept':'Sanitation',     'title':'Open drain near primary school',       'status':'Resolved',    'time':'3d ago', 'priority':'Medium', 'color':AppColors.green},
    {'id':'#8834','name':'Amit Sharma',   'av':'AS','dept':'Street Lighting','title':'3 streetlights non-functional',        'status':'Pending',     'time':'4d ago', 'priority':'Medium', 'color':AppColors.gold},
    {'id':'#8835','name':'Kavita Rane',   'av':'KR','dept':'Health',         'title':'Stagnant water — mosquito breeding',   'status':'Pending',     'time':'5d ago', 'priority':'High',   'color':AppColors.red},
    {'id':'#8836','name':'Vijay Shinde',  'av':'VS','dept':'Roads',          'title':'Footpath broken outside ward office',  'status':'In Progress', 'time':'6d ago', 'priority':'Low',    'color':AppColors.orange},
  ];

  // Ward fund summary
  static const wardFundTotal    = 2500000; // ₹25 L
  static const wardFundSpent    = 1620000; // ₹16.2 L
  static const wardFundReserved = 380000;  // ₹3.8 L (approved, not yet released)
  int  get wardFundBalance => wardFundTotal - wardFundSpent - wardFundReserved;
  double get wardFundPct   => wardFundSpent / wardFundTotal * 100;

  final fundLog = const [
    {'desc':'Road patching – MG Road',    'amt':280000, 'date':'Dec 10','status':'Released', 'color':AppColors.orange},
    {'desc':'Streetlight repair – 8 lights','amt':95000, 'date':'Dec 3', 'status':'Released', 'color':AppColors.gold},
    {'desc':'Park maintenance Q3',         'amt':120000, 'date':'Nov 28','status':'Released', 'color':AppColors.green},
    {'desc':'Community clean-up drive',    'amt':45000,  'date':'Nov 20','status':'Released', 'color':AppColors.teal},
    {'desc':'Drainage unblocking – 3 pts', 'amt':180000, 'date':'Nov 15','status':'Released', 'color':AppColors.blue},
    {'desc':'Drainage repair – school zone','amt':380000,'date':'Pending','status':'Approved, pending release','color':AppColors.gold},
  ];

  // Welfare scheme awareness data
  final schemes = const [
    {'name':'Swachh Bharat Mission',    'desc':'Sanitation and waste management grants', 'icon':Icons.cleaning_services_outlined,'color':AppColors.green},
    {'name':'PM Awas Yojana (Urban)',   'desc':'Affordable housing for eligible citizens','icon':Icons.home_outlined,            'color':AppColors.blue},
    {'name':'Birth/Death Registration', 'desc':'Official certificates via ward office',   'icon':Icons.badge_outlined,           'color':AppColors.navy},
    {'name':'Marriage Registration',    'desc':'Legal registration at ward / NP office',  'icon':Icons.favorite_outline,         'color':AppColors.rose},
  ];

  // Council calendar
  final council = const [
    {'title':'Monthly Council Meeting',    'date':'Dec 22','time':'10:00 AM','type':'mandatory','color':AppColors.navy},
    {'title':'Ward Activity Report Due',   'date':'Dec 20','time':'5:00 PM', 'type':'report',   'color':AppColors.orange},
    {'title':'Budget Audit Session',       'date':'Dec 27','time':'11:00 AM','type':'mandatory','color':AppColors.red},
    {'title':'Ward Fund Utilisation Review','date':'Jan 5', 'time':'2:00 PM', 'type':'review',  'color':AppColors.gold},
  ];

  // ── Computed KPIs ──
  int get openGrievances   => grievances.where((g) => g['status'] != 'Resolved').length;
  int get resolvedGrievances => grievances.where((g) => g['status'] == 'Resolved').length;
  int get amenityIssues    => amenities.where((a) => a['status'] == 'Issue').length;

  @override void initState() {
    super.initState();
    _tabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 270));
    _tabFade = CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOut);
    _tabCtrl.forward();
  }

  @override void dispose() {
    _tabCtrl.dispose();
    _escalateCtrl.dispose(); _reportCtrl.dispose();
    _workTitleCtrl.dispose(); _workDescCtrl.dispose(); _workCostCtrl.dispose();
    super.dispose();
  }

  void _switchTab(String t) {
    if (t == _tab) return;
    setState(() => _tab = t);
    _tabCtrl.forward(from: 0);
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
      if (_showEscalate) _escalateModal(),
      if (_showReport)   _reportModal(),
      if (_showWorkReq)  _workReqModal(),
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
          colors: [Color(0xFF0D5C3A), Color(0xFF1A8A54)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('NAGAR SEVAK · WARD COUNCILLOR', style: TextStyle(
              fontSize: 9, color: Color(0xFF86EFAC), fontWeight: FontWeight.w800,
              letterSpacing: 1.5, fontFamily: 'Nunito')),
            const SizedBox(height: 3),
            Text('Namaste, ${widget.user.name.split(' ').last}', style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
            Row(children: [
              const Icon(Icons.location_on, size: 13, color: Color(0xFF86EFAC)),
              const SizedBox(width: 4),
              Text('${widget.user.ward}  ·  Rampur Nagar Panchayat', style: const TextStyle(
                fontSize: 12, color: Color(0xFF86EFAC), fontFamily: 'Nunito')),
            ]),
          ])),
          AppAvatar(initials: widget.user.avatar, color: const Color(0xFF059669), size: 46),
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
            _hStat('$openGrievances',   'Open Issues',    const Color(0xFFFCA5A5)),
            _vDiv(),
            _hStat('$amenityIssues',    'Amenity Alerts', const Color(0xFFFCD34D)),
            _vDiv(),
            _hStat('${wardFundBalance ~/ 100000}L', 'Fund Balance', const Color(0xFF86EFAC)),
            _vDiv(),
            _hStat('${projects.where((p)=>p['status']=='In Progress').length}','Active Projects', const Color(0xFF93C5FD)),
          ]),
        ),
        const SizedBox(height: 14),

        // Action row
        Row(children: [
          Expanded(child: AppBtn(
            label: '⚠ Escalate', small: true, color: Colors.white, outline: true,
            icon: Icons.priority_high,
            onTap: () => setState(() { _showEscalate = true; _escalateSent = false; }),
          )),
          const SizedBox(width: 10),
          Expanded(child: AppBtn(
            label: 'Report', small: true, color: Colors.white, outline: true,
            icon: Icons.assignment_outlined,
            onTap: () => setState(() { _showReport = true; _reportSent = false; }),
          )),
          const SizedBox(width: 10),
          Expanded(child: AppBtn(
            label: '+ Work Request', small: true,
            color: const Color(0xFF059669), icon: Icons.add_task,
            onTap: () => setState(() { _showWorkReq = true; _workReqSent = false; }),
          )),
        ]),
      ]),
    );
  }

  Widget _hStat(String val, String label, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
    Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.white54, fontFamily: 'Nunito')),
  ]);
  Widget _vDiv() => Container(width: 1, height: 32, color: Colors.white12);

  // ══════════════════════════════════════════════
  // TAB BAR
  // ══════════════════════════════════════════════
  Widget _buildTabBar() {
    const tabs = [
      ['ward',       'My Ward',   Icons.home_outlined],
      ['grievances', 'Grievances',Icons.assignment_outlined],
      ['fund',       'Ward Fund', Icons.account_balance_wallet_outlined],
    ];
    return Container(
      color: AppColors.white,
      child: Row(children: tabs.map((t) {
        final active = _tab == t[0];
        return Expanded(child: GestureDetector(
          onTap: () => _switchTab(t[0] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(
              color: active ? const Color(0xFF059669) : Colors.transparent, width: 3))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(t[2] as IconData, size: 16,
                color: active ? const Color(0xFF059669) : AppColors.grey),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 11.5, color: active ? const Color(0xFF059669) : AppColors.grey,
                  fontFamily: 'Nunito'),
                child: Text(t[1] as String, textAlign: TextAlign.center)),
            ]),
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
    switch (_tab) {
      case 'grievances': return _grievancesTab();
      case 'fund':       return _fundTab();
      default:           return _wardTab();
    }
  }

  // ══════════════════════════════════════════════
  // SIDEBAR (PC)
  // ══════════════════════════════════════════════
  Widget _sidebar() => Column(children: [

    // Council accountability calendar
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.gavel_outlined, size: 16, color: AppColors.navy),
        const SizedBox(width: 8),
        const Text('Council Accountability', style: TextStyle(
          fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      ]),
      const SizedBox(height: 4),
      const Text('Answerable to Chairperson & Council',
        style: TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 14),
      for (final e in council)
        Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          Container(width: 4, height: 40,
            decoration: BoxDecoration(color: e['color'] as Color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e['title'] as String, style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito')),
            Text('${e['date']} · ${e['time']}', style: const TextStyle(
              fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: (e['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
            child: Text(e['type'] as String, style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: e['color'] as Color, fontFamily: 'Nunito'))),
        ])),
    ])),

    // Welfare schemes
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Welfare Schemes', style: TextStyle(
        fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      const Text('Assist citizens with registrations & benefits',
        style: TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final s in schemes)
        Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          Container(padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: (s['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(s['icon'] as IconData, size: 14, color: s['color'] as Color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s['name'] as String, style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito')),
            Text(s['desc'] as String, style: const TextStyle(
              fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
        ])),
    ])),

    // Quick contacts — who to call
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quick Escalation Chain', style: TextStyle(
        fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final c in [
        ['Chief Officer',      'Routine civic issues',    AppColors.navy,   Icons.manage_accounts_outlined],
        ['Mayor (Chairperson)','Urgent ward escalations',  AppColors.red,    Icons.account_balance],
        ['Engineering Dept.',  'Roads, drainage, permits', AppColors.orange, Icons.engineering_outlined],
        ['Water Supply Dept.', 'Supply disruptions',       AppColors.teal,   Icons.water_drop_outlined],
      ])
        Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          Container(padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: (c[2] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(c[3] as IconData, size: 14, color: c[2] as Color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c[0] as String, style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito')),
            Text(c[1] as String, style: const TextStyle(
              fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
        ])),
    ])),
  ]);

  // ══════════════════════════════════════════════
  // TAB 1 — MY WARD
  // ══════════════════════════════════════════════
  Widget _wardTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

    // KPI row
    GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.9,
      children: [
        _kpi('Open Grievances',  '$openGrievances',    AppColors.red,               Icons.assignment_late_outlined),
        _kpi('Amenity Alerts',   '$amenityIssues',     const Color(0xFFD97706),     Icons.warning_amber_outlined),
        _kpi('Resolved Today',   '$resolvedGrievances',const Color(0xFF059669),     Icons.check_circle_outline),
        _kpi('Fund Balance',     '₹${wardFundBalance ~/ 100000}L',
          wardFundBalance < 300000 ? AppColors.red : const Color(0xFF059669),
          Icons.account_balance_wallet_outlined),
      ],
    ),
    const SizedBox(height: 18),

    // Amenity status
    _secHead('Amenity Status', 'Live service health for ${widget.user.ward}'),
    const SizedBox(height: 12),
    AppCard(child: Column(children: [
      for (int i = 0; i < amenities.length; i++) ...[
        _amenityRow(amenities[i]),
        if (i < amenities.length - 1) const Divider(height: 18),
      ],
    ])),

    const SizedBox(height: 6),

    // Active projects
    _secHead('Ward Projects', 'Ongoing civic works in ${widget.user.ward}'),
    const SizedBox(height: 12),
    for (final p in projects)
      AppCard(
        borderColor: (p['color'] as Color).withOpacity(0.25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(p['title'] as String, style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito'))),
            StatusBadge(status: p['status'] as String),
          ]),
          const SizedBox(height: 4),
          Text('${p['dept']} Dept  ·  Due ${p['due']}  ·  ${fmtCr(p['value'] as int)}',
            style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
          const SizedBox(height: 10),
          AnimatedBar(value: (p['pct'] as int).toDouble(),
            color: statusColor(p['status'] as String), height: 7),
          const SizedBox(height: 4),
          Text('${p['pct']}% complete',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: statusColor(p['status'] as String), fontFamily: 'Nunito')),
        ])),

    const SizedBox(height: 6),

    // Council accountability reminder
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy.withOpacity(0.2))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.gavel_outlined, color: AppColors.navy, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Next Council Meeting — Dec 22, 10:00 AM',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
              color: AppColors.navy, fontFamily: 'Nunito')),
          const SizedBox(height: 4),
          const Text('Prepare your ward activity report. Present updates on open grievances, '
            'fund utilisation, and project progress to the Chairperson.',
            style: TextStyle(fontSize: 11, color: AppColors.greyDark,
              fontFamily: 'Nunito', height: 1.5)),
          const SizedBox(height: 10),
          AppBtn(
            label: 'Prepare Activity Report', small: true,
            color: AppColors.navy, icon: Icons.assignment_outlined,
            onTap: () => setState(() { _showReport = true; _reportSent = false; }),
          ),
        ])),
      ]),
    ),
  ]);

  Widget _amenityRow(Map a) {
    final color = a['color'] as Color;
    final status = a['status'] as String;
    return Row(children: [
      Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(a['icon'] as IconData, size: 18, color: color)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a['name'] as String, style: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
        Text(a['desc'] as String, style: const TextStyle(
          fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
      ])),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3))),
          child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
              color: color, fontFamily: 'Nunito'))),
        if (status != 'Good') ...[
          const SizedBox(height: 2),
          Text('${a['since']}', style: const TextStyle(
            fontSize: 9, color: AppColors.grey, fontFamily: 'Nunito')),
        ],
      ]),
    ]);
  }

  // ══════════════════════════════════════════════
  // TAB 2 — GRIEVANCES
  // ══════════════════════════════════════════════
  Widget _grievancesTab() {
    final open     = grievances.where((g) => g['status'] != 'Resolved').toList();
    final resolved = grievances.where((g) => g['status'] == 'Resolved').toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Summary row
      Row(children: [
        Expanded(child: _miniKpi('${grievances.length}', 'Total',       AppColors.navy)),
        const SizedBox(width: 8),
        Expanded(child: _miniKpi('${open.length}',       'Open',        AppColors.red)),
        const SizedBox(width: 8),
        Expanded(child: _miniKpi('${resolved.length}',   'Resolved',    const Color(0xFF059669))),
        const SizedBox(width: 8),
        Expanded(child: _miniKpi(
          '${grievances.where((g) => g['priority'] == 'High').length}',
          'High Priority', AppColors.gold)),
      ]),
      const SizedBox(height: 18),

      // Open grievances
      if (open.isNotEmpty) ...[
        _secHead('Open Grievances', 'Awaiting action from you or the department'),
        const SizedBox(height: 10),
        for (final g in open) _grievanceCard(g),
        const SizedBox(height: 6),
      ],

      // Resolved
      if (resolved.isNotEmpty) ...[
        _secHead('Resolved', 'Closed complaints in ${widget.user.ward}'),
        const SizedBox(height: 10),
        for (final g in resolved) _grievanceCard(g),
      ],
    ]);
  }

  Widget _grievanceCard(Map g) {
    final isResolved = g['status'] == 'Resolved';
    final priColor = g['priority'] == 'High' ? AppColors.red
        : g['priority'] == 'Medium' ? AppColors.gold
        : AppColors.grey;

    return AppCard(
      borderColor: (g['color'] as Color).withOpacity(0.2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AppAvatar(initials: g['av'] as String, color: g['color'] as Color, size: 32),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(g['name'] as String, style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
            Text('${g['id']}  ·  ${g['time']}', style: const TextStyle(
              fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
          StatusBadge(status: g['status'] as String),
        ]),
        const SizedBox(height: 8),
        Text(g['title'] as String, style: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Nunito')),
        const SizedBox(height: 6),
        Row(children: [
          AppChip(label: g['dept'] as String, color: g['color'] as Color, small: true),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('${g['priority']} Priority', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: priColor, fontFamily: 'Nunito'))),
        ]),

        // Progress bar
        const SizedBox(height: 10),
        AnimatedBar(value: statusProgress(g['status'] as String).toDouble(),
          color: statusColor(g['status'] as String), height: 5),
        const SizedBox(height: 4),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Filed', style: TextStyle(fontSize: 9, color: AppColors.grey, fontFamily: 'Nunito')),
          Text('In Review', style: TextStyle(fontSize: 9, color: AppColors.grey, fontFamily: 'Nunito')),
          Text('Resolved', style: TextStyle(fontSize: 9, color: AppColors.grey, fontFamily: 'Nunito')),
        ]),

        if (!isResolved) ...[
          const SizedBox(height: 12),
          Row(children: [
            AppBtn(
              label: 'Escalate to Mayor', small: true,
              color: AppColors.red, icon: Icons.priority_high,
              onTap: () => setState(() { _showEscalate = true; _escalateSent = false; }),
            ),
            const SizedBox(width: 8),
            AppBtn(
              label: 'Mark Resolved', small: true,
              color: const Color(0xFF059669), outline: true, icon: Icons.check,
              onTap: () => setState(() => g['status'] = 'Resolved'),
            ),
          ]),
        ],
      ]),
    );
  }

  // ══════════════════════════════════════════════
  // TAB 3 — WARD FUND
  // ══════════════════════════════════════════════
  Widget _fundTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

    // Fund summary card
    Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5C3A), Color(0xFF1A8A54)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NAGAR SEVAK WARD FUND', style: TextStyle(fontSize: 9, color: Color(0xFF86EFAC),
              fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Nunito')),
            SizedBox(height: 3),
            Text('Annual Allocation · FY 2025–26', style: TextStyle(
              fontSize: 13, color: Colors.white70, fontFamily: 'Nunito')),
          ]),
          AppChip(label: '${widget.user.ward}', color: const Color(0xFF059669), small: true),
        ]),
        const SizedBox(height: 12),
        Text(fmtCr(wardFundTotal), style: const TextStyle(fontSize: 28,
          fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
        const SizedBox(height: 10),
        AnimatedBar(value: wardFundPct, color: const Color(0xFF34D399), height: 10),
        const SizedBox(height: 8),
        Row(children: [
          _fundPill('Spent',    fmtCr(wardFundSpent),    const Color(0xFF34D399)),
          const SizedBox(width: 8),
          _fundPill('Approved', fmtCr(wardFundReserved), const Color(0xFFFCD34D)),
          const SizedBox(width: 8),
          _fundPill('Balance',  fmtCr(wardFundBalance),  const Color(0xFF93C5FD)),
        ]),
      ]),
    ),

    // Accountability note
    Container(
      padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withOpacity(0.25))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Icon(Icons.info_outline, size: 14, color: AppColors.blue),
        SizedBox(width: 8),
        Expanded(child: Text(
          'All ward fund expenditure must be reported to the Nagar Panchayat council. '
          'The Nagar Sevak is accountable to the Chairperson for proper utilisation of allocated funds.',
          style: TextStyle(fontSize: 11, color: AppColors.blue, fontFamily: 'Nunito', height: 1.5))),
      ]),
    ),

    // Expenditure log
    _secHead('Expenditure Log', 'All fund transactions for ${widget.user.ward}'),
    const SizedBox(height: 12),
    for (final f in fundLog)
      AppCard(
        borderColor: (f['color'] as Color).withOpacity(0.2),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (f['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.receipt_long_outlined, size: 18, color: f['color'] as Color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f['desc'] as String, style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
            const SizedBox(height: 2),
            Text('${f['date']}  ·  ${f['status']}', style: const TextStyle(
              fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
          Text(fmtCr(f['amt'] as int), style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w900, color: f['color'] as Color, fontFamily: 'Nunito')),
        ])),

    const SizedBox(height: 8),
    AppBtn(
      label: '+ Raise New Work Request', full: true,
      color: const Color(0xFF059669), icon: Icons.add_task,
      onTap: () => setState(() { _showWorkReq = true; _workReqSent = false; }),
    ),
  ]);

  Widget _fundPill(String label, String val, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
          color: color, fontFamily: 'Nunito')),
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.white60, fontFamily: 'Nunito')),
    ]),
  ));

  // ══════════════════════════════════════════════
  // ESCALATE TO MAYOR MODAL
  // ══════════════════════════════════════════════
  Widget _escalateModal() => _modal(
    onDismiss: () => setState(() { _showEscalate = false; _escalateSent = false; }),
    child: _escalateSent
      ? _successView('Escalation Sent!',
          'The Mayor and Chief Officer have been notified. You will receive an update within 24 hours.',
          Icons.priority_high, AppColors.red,
          onClose: () => setState(() { _showEscalate = false; _escalateSent = false; }))
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _modalHeader('Escalate to Mayor / Chairperson', Icons.priority_high, AppColors.red,
            onClose: () => setState(() => _showEscalate = false)),
          const SizedBox(height: 6),
          const Text('Use this only for urgent issues that cannot be resolved at the ward or '
            'department level. The escalation will reach the Mayor and Chief Officer directly.',
            style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito', height: 1.5)),
          const SizedBox(height: 16),
          _label('GRIEVANCE / ISSUE'),
          const SizedBox(height: 6),
          TextField(controller: _escalateCtrl, maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe the issue and why it needs the Mayor\'s attention…'),
            style: const TextStyle(fontFamily: 'Nunito')),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.red.withOpacity(0.2))),
            child: Row(children: const [
              Icon(Icons.info_outline, size: 13, color: AppColors.red),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Will be routed to Mayor → Chief Officer → Department Head with a mandatory 24-hour response SLA.',
                style: TextStyle(fontSize: 11, color: AppColors.red, fontFamily: 'Nunito', height: 1.4))),
            ])),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: AppBtn(label: 'Cancel', outline: true, color: AppColors.grey,
              onTap: () => setState(() => _showEscalate = false))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: AppBtn(label: 'Escalate Now', color: AppColors.red,
              icon: Icons.send_outlined, full: true,
              onTap: () { if (_escalateCtrl.text.trim().isNotEmpty) setState(() => _escalateSent = true); })),
          ]),
        ]),
  );

  // ══════════════════════════════════════════════
  // WARD ACTIVITY REPORT MODAL
  // ══════════════════════════════════════════════
  Widget _reportModal() => _modal(
    onDismiss: () => setState(() { _showReport = false; _reportSent = false; }),
    child: _reportSent
      ? _successView('Report Submitted!',
          'Your ward activity report has been submitted to the Chairperson for the council meeting.',
          Icons.assignment_turned_in_outlined, const Color(0xFF059669),
          onClose: () => setState(() { _showReport = false; _reportSent = false; }))
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _modalHeader('Ward Activity Report', Icons.assignment_outlined, AppColors.navy,
            onClose: () => setState(() => _showReport = false)),
          const SizedBox(height: 6),
          const Text('Submit your progress report to the Chairperson before the council meeting. '
            'This is a mandatory accountability requirement.',
            style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito', height: 1.5)),
          const SizedBox(height: 14),

          // Auto-filled summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('AUTO-FILLED FROM YOUR WARD DATA', style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.grey,
                letterSpacing: 0.8, fontFamily: 'Nunito')),
              const SizedBox(height: 8),
              _reportRow('Ward',            widget.user.ward),
              _reportRow('Sevak',           widget.user.name),
              _reportRow('Open Grievances', '$openGrievances'),
              _reportRow('Resolved',        '$resolvedGrievances'),
              _reportRow('Amenity Issues',  '$amenityIssues'),
              _reportRow('Active Projects', '${projects.where((p)=>p['status']=='In Progress').length}'),
              _reportRow('Fund Utilised',   '${wardFundPct.round()}%  (${fmtCr(wardFundSpent)} of ${fmtCr(wardFundTotal)})'),
            ]),
          ),
          const SizedBox(height: 14),
          _label('ADDITIONAL NOTES / HIGHLIGHTS'),
          const SizedBox(height: 6),
          TextField(controller: _reportCtrl, maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Any specific achievements, challenges, or requests for the council…'),
            style: const TextStyle(fontFamily: 'Nunito')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: AppBtn(label: 'Cancel', outline: true, color: AppColors.grey,
              onTap: () => setState(() => _showReport = false))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: AppBtn(label: 'Submit to Chairperson',
              color: AppColors.navy, icon: Icons.send_outlined, full: true,
              onTap: () => setState(() => _reportSent = true))),
          ]),
        ]),
  );

  Widget _reportRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    SizedBox(width: 110, child: Text('$label:', style: const TextStyle(
      fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito'))),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
  ]));

  // ══════════════════════════════════════════════
  // NEW WORK REQUEST MODAL
  // ══════════════════════════════════════════════
  Widget _workReqModal() {
    const cats = ['Roads & Drainage','Street Lighting','Sanitation','Water Supply',
                  'Parks & Grounds','Community Centre','Other'];
    return _modal(
      onDismiss: () => setState(() { _showWorkReq = false; _workReqSent = false; }),
      child: _workReqSent
        ? _successView('Work Request Raised!',
            'Your ward fund request has been forwarded to the Chief Officer for approval.',
            Icons.add_task, const Color(0xFF059669),
            onClose: () => setState(() { _showWorkReq = false; _workReqSent = false; }))
        : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _modalHeader('New Ward Fund Work Request', Icons.add_task, const Color(0xFF059669),
              onClose: () => setState(() => _showWorkReq = false)),
            const SizedBox(height: 6),
            const Text('Submit a small-scale urgent development request against the Ward Fund. '
              'Approval required from the Chief Officer before works begin.',
              style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito', height: 1.5)),
            const SizedBox(height: 14),
            _label('WORK CATEGORY'),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: cats.map((c) {
              final active = _workCat == c;
              return GestureDetector(
                onTap: () => setState(() => _workCat = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF059669) : AppColors.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? const Color(0xFF059669) : AppColors.border, width: 1.5)),
                  child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.greyDark, fontFamily: 'Nunito'))),
              );
            }).toList()),
            const SizedBox(height: 14),
            _label('WORK TITLE'),
            const SizedBox(height: 6),
            TextField(controller: _workTitleCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Road patching near Ward 3 market'),
              style: const TextStyle(fontFamily: 'Nunito')),
            const SizedBox(height: 12),
            _label('DESCRIPTION & JUSTIFICATION'),
            const SizedBox(height: 6),
            TextField(controller: _workDescCtrl, maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe the work needed and why it is urgent…'),
              style: const TextStyle(fontFamily: 'Nunito')),
            const SizedBox(height: 12),
            _label('ESTIMATED COST (₹)'),
            const SizedBox(height: 6),
            TextField(controller: _workCostCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 45000',
                prefixIcon: Icon(Icons.currency_rupee, size: 16, color: AppColors.grey)),
              style: const TextStyle(fontFamily: 'Nunito')),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF059669).withOpacity(0.25))),
              child: Row(children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 13, color: Color(0xFF059669)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'Available balance: ${fmtCr(wardFundBalance)}  ·  '
                  'Requests above ₹5L require council approval.',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF059669),
                    fontFamily: 'Nunito', height: 1.4))),
              ])),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: AppBtn(label: 'Cancel', outline: true, color: AppColors.grey,
                onTap: () => setState(() => _showWorkReq = false))),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: AppBtn(label: 'Submit Request',
                color: const Color(0xFF059669), icon: Icons.send_outlined, full: true,
                onTap: () {
                  if (_workTitleCtrl.text.trim().isNotEmpty) setState(() => _workReqSent = true);
                })),
            ]),
          ]),
    );
  }

  // ══════════════════════════════════════════════
  // SHARED HELPERS
  // ══════════════════════════════════════════════

  Widget _modal({required Widget child, required VoidCallback onDismiss}) =>
    Positioned.fill(child: GestureDetector(
      onTap: onDismiss,
      child: Container(color: Colors.black54,
        child: Center(child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18),
                  blurRadius: 40, offset: const Offset(0, 16))]),
            child: ClipRRect(borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: child)),
          ),
        ))),
    ));

  Widget _successView(String title, String msg, IconData icon, Color color,
      {required VoidCallback onClose}) =>
    Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2)),
        child: Icon(icon, color: color, size: 36)),
      const SizedBox(height: 14),
      Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
          color: color, fontFamily: 'Nunito')),
      const SizedBox(height: 8),
      Text(msg, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: AppColors.grey,
            fontFamily: 'Nunito', height: 1.55)),
      const SizedBox(height: 20),
      AppBtn(label: 'Done', color: color, full: true, onTap: onClose),
    ]);

  Widget _modalHeader(String title, IconData icon, Color color,
      {required VoidCallback onClose}) =>
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Nunito')),
      ]),
      GestureDetector(onTap: onClose,
        child: const Icon(Icons.close, color: AppColors.grey, size: 20)),
    ]);

  Widget _kpi(String label, String value, Color color, IconData icon) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withOpacity(0.2)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 16)),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
            color: color, fontFamily: 'Nunito')),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
      ]),
    ]),
  );

  Widget _miniKpi(String val, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
          color: color, fontFamily: 'Nunito')),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
    ]),
  );

  Widget _secHead(String title, String sub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Nunito')),
    const SizedBox(height: 2),
    Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
  ]);

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 11,
    fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito'));
}