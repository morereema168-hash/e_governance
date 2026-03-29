import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class ReportScreen extends StatefulWidget {
  final AppUser user;
  const ReportScreen({super.key, required this.user});
  @override State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<Report> myReports = [
    Report(id:'1',dept:'Water',title:'No water for 3 days',desc:'Ward 3 dry since Monday.',status:'Pending',time:'1d ago',ticket:'#8831',ward:'Ward 3'),
    Report(id:'2',dept:'Roads',title:'Pothole near bus stop',desc:'Dangerous pothole on MG Road.',status:'In Progress',time:'2d ago',ticket:'#8832',ward:'Ward 3'),
    Report(id:'3',dept:'Sanitation',title:'Open drain near school',desc:'Children at risk.',status:'Resolved',time:'3d ago',ticket:'#8829',ward:'Ward 3'),
  ];
  bool showForm = false;
  String selCat = 'Pothole';
  String selDept = 'Roads';
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  bool submitting = false;
  bool submitted  = false;

  final deptColors = const {'Water':AppColors.teal,'Sanitation':AppColors.green,'Electricity':AppColors.gold,'Roads':AppColors.greyDark,'Other':AppColors.purple};
  final cats = ['Streetlight','Water Leak','Pothole','Garbage','Drainage','Other'];
  final depts = ['Water','Sanitation','Electricity','Roads','Other'];

  void _submit() async {
    if(_titleCtrl.text.isEmpty) return;
    setState(()=>submitting=true);
    await Future.delayed(const Duration(milliseconds:900));
    setState((){
      myReports.insert(0,Report(id:'${DateTime.now().millisecondsSinceEpoch}',dept:selDept,title:_titleCtrl.text,
        desc:_descCtrl.text,status:'Pending',time:'Just now',ticket:'#${8860+myReports.length}',ward:widget.user.ward));
      submitting=false; submitted=true;
    });
    await Future.delayed(const Duration(seconds:2));
    setState((){submitted=false;showForm=false;_titleCtrl.clear();_descCtrl.clear();});
  }

  @override Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(children: [
        // ── HEADER ──
        PageHeader(
          tag: 'OFFICIAL REPORTS',
          title: 'Report an Issue',
          sub: 'Sent → Department · Ward Rep · Mayor',
          bottom: Row(children: [
            AppBtn(label: '+ New Report', small: true, onTap: () => setState(() => showForm = !showForm)),
            const SizedBox(width: 8),
            AppBtn(
              label: 'My Reports (${myReports.length})',
              small: true, outline: true, color: Colors.white,
              onTap: () => setState(() => showForm = false),
            ),
          ]),
        ),

        Padding(
          padding: EdgeInsets.all(isWide ? 24 : 14),
          child: isWide
              ? _wideLayout()
              : _narrowLayout(),
        ),
      ]),
    );
  }

  // ── WIDE LAYOUT (PC): two-column side by side ──
  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: form or stats
        Expanded(
          flex: 5,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showForm) _formPanel() else _statsPanel(),
          ]),
        ),
        const SizedBox(width: 20),
        // Right column: reports list
        Expanded(
          flex: 6,
          child: _reportsList(),
        ),
      ],
    );
  }

  // ── NARROW LAYOUT (mobile): stacked ──
  Widget _narrowLayout() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (showForm) ...[_formPanel()] else ...[_reportsList()],
    ]);
  }

  // ── STATS PANEL (shown on PC when form is hidden) ──
  Widget _statsPanel() {
    final total = myReports.length;
    final resolved = myReports.where((r) => r.status == 'Resolved').length;
    final pending = myReports.where((r) => r.status == 'Pending').length;
    final inProgress = myReports.where((r) => r.status == 'In Progress').length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      const SizedBox(height: 14),

      // Stat cards grid
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: [
          _statCard('Total', total.toString(), AppColors.orange, Icons.assignment_outlined),
          _statCard('Resolved', resolved.toString(), AppColors.green, Icons.check_circle_outline),
          _statCard('In Progress', inProgress.toString(), AppColors.blue, Icons.autorenew),
          _statCard('Pending', pending.toString(), AppColors.gold, Icons.hourglass_empty),
        ],
      ),

      const SizedBox(height: 16),

      // Quick action card
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
          AppBtn(
            label: '+ New Report',
            full: true,
            onTap: () => setState(() => showForm = true),
          ),
        ]),
      ),

      const SizedBox(height: 10),

      // Info card
      AppCard(
        bgColor: AppColors.blueLight,
        borderColor: AppColors.blue.withOpacity(0.2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('How it works', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.blue, fontFamily: 'Nunito')),
          const SizedBox(height: 10),
          for (final step in [
            ['1', 'Choose category & department'],
            ['2', 'Add title and details'],
            ['3', 'Report is sent to dept, ward rep & mayor'],
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

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
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
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
        ]),
      ]),
    );
  }

  // ── FORM PANEL ──
  Widget _formPanel() {
    return Column(children: [
      if (submitted)
        AppCard(child: Column(children: [
          const Text('✅', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 8),
          const Text('Report Submitted!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.green, fontFamily: 'Nunito')),
          Text('Sent to $selDept Dept · Ward Rep · Mayor', style: const TextStyle(fontSize: 13, color: AppColors.grey, fontFamily: 'Nunito')),
        ]))
      else
        AppCard(
          borderColor: AppColors.orange.withOpacity(0.4),
          borderWidth: 2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("What's the problem?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
            const SizedBox(height: 14),
            // Category grid
            GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.1,
              children: cats.map((c) => GestureDetector(
                onTap: () => setState(() => selCat = c),
                child: Container(
                  decoration: BoxDecoration(
                    color: selCat == c ? AppColors.orangeLight : AppColors.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: selCat == c ? AppColors.orange : AppColors.border, width: selCat == c ? 2 : 1),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_catIcon(c), size: 22, color: selCat == c ? AppColors.orange : AppColors.grey),
                    const SizedBox(height: 4),
                    Text(c, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: selCat == c ? AppColors.dark : AppColors.grey, fontFamily: 'Nunito'), textAlign: TextAlign.center),
                  ]),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
            const Text('DEPARTMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: depts.map((d) => AppChip(
                label: d, color: deptColors[d] ?? AppColors.grey,
                active: selDept == d, onTap: () => setState(() => selDept = d), small: true,
              )).toList(),
            ),
            const SizedBox(height: 12),
            MapWidget(label: '${widget.user.ward}, Rampur', height: 110),
            const SizedBox(height: 12),
            const Text('ISSUE TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
            const SizedBox(height: 5),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'Brief title…'), style: const TextStyle(fontFamily: 'Nunito')),
            const SizedBox(height: 12),
            const Text('DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
            const SizedBox(height: 5),
            TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'More details…'), style: const TextStyle(fontFamily: 'Nunito')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.send, color: AppColors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'Will be sent to: $selDept Department · ${widget.user.ward} Rep · Mayor',
                  style: const TextStyle(fontSize: 12, color: AppColors.blue, fontFamily: 'Nunito'),
                )),
              ]),
            ),
            const SizedBox(height: 12),
            AppBtn(label: submitting ? 'Submitting…' : 'Submit Official Report', full: true, disabled: submitting, onTap: _submit),
          ]),
        ),
    ]);
  }

  // ── REPORTS LIST ──
  Widget _reportsList() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('My Reports (${myReports.length})', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
        // Summary chips
        Row(children: [
          _miniChip('${myReports.where((r) => r.status == "Resolved").length} Resolved', AppColors.green),
          const SizedBox(width: 6),
          _miniChip('${myReports.where((r) => r.status == "Pending").length} Pending', AppColors.gold),
        ]),
      ]),
      const SizedBox(height: 14),
      for (final r in myReports)
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              AppChip(label: r.dept, color: deptColors[r.dept] ?? AppColors.grey, small: true),
              StatusBadge(status: r.status),
            ]),
            const SizedBox(height: 8),
            Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, fontFamily: 'Nunito')),
            if (r.desc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(r.desc, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
            ],
            const SizedBox(height: 8),
            Text('${r.ticket} · ${r.ward} · ${r.time}', style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
            const SizedBox(height: 10),
            AnimatedBar(value: statusProgress(r.status).toDouble(), color: r.status == 'Resolved' ? AppColors.green : AppColors.orange, height: 5),
            const SizedBox(height: 4),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Filed', style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
              Text('In Review', style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
              Text('Resolved', style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
            ]),
          ]),
        ),
    ]);
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'Nunito')),
    );
  }

  IconData _catIcon(String c) {
    switch(c){
      case 'Streetlight': return Icons.lightbulb_outline;
      case 'Water Leak':  return Icons.water_drop_outlined;
      case 'Pothole':     return Icons.warning_amber_outlined;
      case 'Garbage':     return Icons.delete_outline;
      case 'Drainage':    return Icons.waves;
      default:            return Icons.more_horiz;
    }
  }
}