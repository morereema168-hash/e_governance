import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class FundraiseScreen extends StatefulWidget {
  const FundraiseScreen({super.key});
  @override State<FundraiseScreen> createState() => _FundraiseScreenState();
}

class _FundraiseScreenState extends State<FundraiseScreen> {
  final List<Fundraiser> funds = [
    Fundraiser(id:1,type:'community',title:'Ganeshotsav 2025',goal:50000,raised:32000,desc:'Annual festival fund for decorations, sound & prasad distribution across 5 wards.',backers:142),
    Fundraiser(id:2,type:'community',title:'Swachh Ward 3 Campaign',goal:15000,raised:11200,desc:'Cleanliness drive — buying equipment, gloves & waste bags for 200 volunteers.',backers:67),
    Fundraiser(id:3,type:'private',title:'Medical Help – R. Kale',goal:20000,raised:8000,desc:'Cancer treatment support for Ramesh Kale, father of two. Chemotherapy ongoing.',backers:34),
    Fundraiser(id:4,type:'private',title:'Education Fund – M. Jadhav',goal:10000,raised:4500,desc:'School fees assistance for Meena Jadhav, Class 10 student from Ward 3.',backers:28),
  ];

  String filter    = 'all';
  bool showForm    = false;
  String formType  = 'community';
  String sortBy    = 'recent';
  final _titleCtrl = TextEditingController();
  final _goalCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  int? donatingId;
  final _amtCtrl   = TextEditingController();
  int? expandedId;

  int get totalRaised  => funds.fold(0, (a, f) => a + f.raised);
  int get totalBackers => funds.fold(0, (a, f) => a + f.backers);
  int get totalGoal    => funds.fold(0, (a, f) => a + f.goal);

  List<Fundraiser> get shown {
    var list = filter == 'all' ? [...funds] : funds.where((f) => f.type == filter).toList();
    if (sortBy == 'most_raised') list.sort((a, b) => b.raised.compareTo(a.raised));
    if (sortBy == 'ending_soon') list.sort((a, b) => (a.goal - a.raised).compareTo(b.goal - b.raised));
    if (sortBy == 'most_backed') list.sort((a, b) => b.backers.compareTo(a.backers));
    return list;
  }

  @override Widget build(BuildContext context) {
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

  // ── HEADER ──
  Widget _buildHeader() {
    final overallPct = totalGoal > 0 ? (totalRaised / totalGoal * 100) : 0.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('COMMUNITY FUNDRAISING', style: TextStyle(fontSize: 10, color: Color(0xFFFB923C), fontWeight: FontWeight.w800, letterSpacing: 1, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Raise Funds', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
        const Text('Community events · Private pleas', style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
        const SizedBox(height: 16),
        // Stats row
        Row(children: [
          _headerStat('₹${(totalRaised / 1000).toStringAsFixed(0)}K', 'Raised'),
          _vDivider(),
          _headerStat('₹${(totalGoal / 1000).toStringAsFixed(0)}K', 'Goal'),
          _vDivider(),
          _headerStat('$totalBackers', 'Backers'),
          _vDivider(),
          _headerStat('${funds.length}', 'Campaigns'),
        ]),
        const SizedBox(height: 14),
        // Overall progress
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Overall Progress', style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
              Text('${overallPct.round()}% of total goal',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Nunito')),
            ]),
            const SizedBox(height: 8),
            AnimatedBar(value: overallPct.clamp(0, 100), color: AppColors.orange, height: 8),
          ]),
        ),
      ]),
    );
  }

  Widget _headerStat(String v, String l) => Expanded(child: Column(children: [
    Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
    Text(l, style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'Nunito')),
  ]));

  Widget _vDivider() => Container(width: 1, height: 30, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 4));

  // ── LAYOUTS ──
  Widget _wideLayout() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 6, child: _mainContent()),
      const SizedBox(width: 20),
      Expanded(flex: 4, child: _sidebar()),
    ]);
  }

  Widget _narrowLayout() => _mainContent();

  // ── SIDEBAR ──
  Widget _sidebar() {
    return Column(children: [
      // Start fundraiser CTA
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
              child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Start a Campaign', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Nunito')),
              Text('For community or personal needs', style: TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
          ]),
          const SizedBox(height: 12),
          AppBtn(label: '+ Start Fundraiser', full: true, onTap: () => setState(() => showForm = !showForm)),
        ]),
      ),

      // Top campaigns
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Top Campaigns', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 12),
        for (final f in [...funds]..sort((a, b) => b.raised.compareTo(a.raised)))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: (f.type == 'community' ? AppColors.green : AppColors.purple).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(
                  f.type == 'community' ? Icons.groups_outlined : Icons.person_outline,
                  size: 18, color: f.type == 'community' ? AppColors.green : AppColors.purple,
                )),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito'),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                AnimatedBar(value: (f.raised / f.goal * 100).clamp(0, 100),
                  color: f.type == 'community' ? AppColors.green : AppColors.purple, height: 4),
              ])),
              const SizedBox(width: 8),
              Text('${(f.raised / f.goal * 100).round()}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: f.type == 'community' ? AppColors.green : AppColors.purple, fontFamily: 'Nunito')),
            ]),
          ),
      ])),

      // Impact card
      AppCard(bgColor: AppColors.navy, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Community Impact', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white, fontFamily: 'Nunito')),
        const SizedBox(height: 14),
        for (final row in [
          [Icons.check_circle_outline, '${funds.where((f) => f.raised >= f.goal).length} campaigns fully funded', AppColors.green],
          [Icons.people_outline,       '$totalBackers people contributed', AppColors.teal],
          [Icons.favorite_outline,     '${funds.length} active causes', AppColors.rose],
        ])
          Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
            Icon(row[0] as IconData, color: row[2] as Color, size: 16),
            const SizedBox(width: 8),
            Text(row[1] as String, style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
          ])),
      ])),
    ]);
  }

  // ── MAIN CONTENT ──
  Widget _mainContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Filter + Sort row
      Row(children: [
        for (final f in [['all', 'All'], ['community', 'Community'], ['private', 'Private']])
          Padding(padding: const EdgeInsets.only(right: 6),
            child: AppChip(label: f[1], color: AppColors.orange, active: filter == f[0],
              onTap: () => setState(() => filter = f[0]), small: true)),
        const Spacer(),
        // Sort dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: sortBy,
            isDense: true,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.dark, fontFamily: 'Nunito'),
            items: const [
              DropdownMenuItem(value: 'recent',      child: Text('Recent')),
              DropdownMenuItem(value: 'most_raised', child: Text('Most Raised')),
              DropdownMenuItem(value: 'ending_soon', child: Text('Ending Soon')),
              DropdownMenuItem(value: 'most_backed', child: Text('Most Backed')),
            ],
            onChanged: (v) => setState(() => sortBy = v!),
          )),
        ),
      ]),
      const SizedBox(height: 12),

      // Start fundraiser button (mobile only — wide has sidebar)
      if (MediaQuery.of(context).size.width <= 700) ...[
        AppBtn(label: '+ Start Fundraiser', full: true, onTap: () => setState(() => showForm = !showForm)),
        const SizedBox(height: 12),
      ],

      // Form
      if (showForm) ...[
        _buildForm(),
        const SizedBox(height: 12),
      ],

      // Campaign count
      Text('${shown.length} campaign${shown.length != 1 ? 's' : ''}',
        style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 10),

      // Cards
      for (final f in shown) _fundraiserCard(f),
    ]);
  }

  // ── FORM ──
  Widget _buildForm() {
    return AppCard(
      borderColor: AppColors.orange.withOpacity(0.4), borderWidth: 2,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('New Fundraiser', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
          GestureDetector(onTap: () => setState(() => showForm = false),
            child: const Icon(Icons.close, color: AppColors.grey, size: 20)),
        ]),
        const SizedBox(height: 12),
        // Type toggle
        Row(children: [
          for (final t in ['community', 'private'])
            Expanded(child: Padding(
              padding: EdgeInsets.only(right: t == 'community' ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => formType = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: formType == t ? AppColors.orange : AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: formType == t ? AppColors.orange : AppColors.border),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(t == 'community' ? Icons.groups_outlined : Icons.person_outline,
                      size: 16, color: formType == t ? Colors.white : AppColors.grey),
                    const SizedBox(width: 6),
                    Text(t == 'community' ? 'Community' : 'Private',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                        color: formType == t ? Colors.white : AppColors.dark, fontFamily: 'Nunito')),
                  ]),
                ),
              ),
            )),
        ]),
        const SizedBox(height: 12),
        const Text('TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
        const SizedBox(height: 5),
        TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'Campaign title…'), style: const TextStyle(fontFamily: 'Nunito')),
        const SizedBox(height: 10),
        const Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
        const SizedBox(height: 5),
        TextField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Tell people why this matters…'), style: const TextStyle(fontFamily: 'Nunito')),
        const SizedBox(height: 10),
        const Text('GOAL (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.grey, letterSpacing: 0.5, fontFamily: 'Nunito')),
        const SizedBox(height: 5),
        TextField(controller: _goalCtrl, keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Target amount', prefixText: '₹ '),
          style: const TextStyle(fontFamily: 'Nunito')),
        const SizedBox(height: 14),
        AppBtn(label: '🚀  Launch Campaign', color: AppColors.green, full: true, onTap: () {
          if (_titleCtrl.text.isEmpty || _goalCtrl.text.isEmpty) return;
          setState(() {
            funds.insert(0, Fundraiser(
              id: DateTime.now().millisecondsSinceEpoch, type: formType,
              title: _titleCtrl.text, goal: int.tryParse(_goalCtrl.text) ?? 0,
              raised: 0, desc: _descCtrl.text, backers: 0));
            _titleCtrl.clear(); _goalCtrl.clear(); _descCtrl.clear(); showForm = false;
          });
        }),
      ]),
    );
  }

  // ── FUNDRAISER CARD ──
  Widget _fundraiserCard(Fundraiser f) {
    final color      = f.type == 'community' ? AppColors.green : AppColors.purple;
    final pct        = (f.raised / f.goal * 100).clamp(0.0, 100.0);
    final isExpanded = expandedId == f.id;
    final isDonating = donatingId == f.id;
    final isComplete = f.raised >= f.goal;

    return AppCard(
      borderColor: color.withOpacity(0.25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(f.type == 'community' ? Icons.groups_outlined : Icons.person_outline,
                  size: 13, color: color),
                const SizedBox(width: 4),
                Text(f.type == 'community' ? 'Community' : 'Private',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, fontFamily: 'Nunito')),
              ]),
            ),
            if (isComplete) ...[
              const SizedBox(width: 8),
              AppChip(label: '✓ Fully Funded', color: AppColors.green, small: true),
            ],
          ]),
          Text('${f.backers} backers', style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
        ]),
        const SizedBox(height: 10),

        // Title + desc
        Text(f.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Nunito')),
        if (f.desc.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(f.desc,
            maxLines: isExpanded ? 10 : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.greyDark, fontFamily: 'Nunito', height: 1.5)),
          if (f.desc.length > 80)
            GestureDetector(
              onTap: () => setState(() => expandedId = isExpanded ? null : f.id),
              child: Text(isExpanded ? 'Show less' : 'Read more',
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
            ),
        ],
        const SizedBox(height: 14),

        // Progress row
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Circle
          SizedBox(width: 56, height: 56, child: CustomPaint(
            painter: _CirclePainter(pct: f.raised / f.goal, color: color),
            child: Center(child: Text('${pct.round()}%',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito'))),
          )),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedBar(value: pct, color: color, height: 9),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('₹${f.raised}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color, fontFamily: 'Nunito')),
                const Text('raised', style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₹${f.goal}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
                const Text('goal', style: TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
              ]),
            ]),
          ])),
        ]),
        const SizedBox(height: 14),

        // Donate input or button
        if (isDonating)
          Row(children: [
            Expanded(child: TextField(
              controller: _amtCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '₹ Enter amount', prefixText: '₹ '),
              style: const TextStyle(fontFamily: 'Nunito'),
            )),
            const SizedBox(width: 8),
            AppBtn(label: 'Give', color: AppColors.green, small: true, onTap: () {
              final a = int.tryParse(_amtCtrl.text) ?? 0;
              if (a > 0) {
                setState(() {
                  f.raised = (f.raised + a).clamp(0, f.goal);
                  f.backers++;
                  donatingId = null;
                  _amtCtrl.clear();
                });
              }
            }),
            const SizedBox(width: 6),
            AppBtn(label: '✕', color: AppColors.grey, outline: true, small: true,
              onTap: () => setState(() => donatingId = null)),
          ])
        else
          Row(children: [
            Expanded(child: AppBtn(
              label: isComplete ? '🎉 Fully Funded' : 'Donate Now',
              color: isComplete ? AppColors.green : AppColors.orange,
              outline: !isComplete,
              disabled: isComplete,
              full: true,
              onTap: () => setState(() => donatingId = f.id),
            )),
            const SizedBox(width: 8),
            // Share button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.grey, size: 18),
                onPressed: () {},
                tooltip: 'Share',
              ),
            ),
          ]),
      ]),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double pct;
  final Color color;
  _CirclePainter({required this.pct, required this.color});
  @override void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2; final r = cx - 4;
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = color.withOpacity(0.15)..strokeWidth = 6..style = PaintingStyle.stroke);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.5708, pct.clamp(0, 1) * 6.2832, false,
      Paint()..color = color..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(_) => true;
}