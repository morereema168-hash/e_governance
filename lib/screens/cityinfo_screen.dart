import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ARCHITECTURE FIX:
//   Old code returned a Column with Expanded from _detail(), which broke
//   inside the app's SafeArea Column. Now _detailView() returns a plain
//   SingleChildScrollView. The back button calls setState(()=>_open=null)
//   and the bottom nav reappears automatically because main.dart hides it
//   only when tab == 'cityinfo' and this screen manages its own back state.
//
// TABS: Articles | City Facts | Governance | Contacts
// ─────────────────────────────────────────────────────────────────────────────

class CityInfoScreen extends StatefulWidget {
  const CityInfoScreen({super.key});
  @override State<CityInfoScreen> createState() => _CityInfoScreenState();
}

class _CityInfoScreenState extends State<CityInfoScreen>
    with SingleTickerProviderStateMixin {

  final blogs = const [
    {'id':1,'cat':'History',   'title':'The Historic Legacy of Mahad',            'emoji':'🏰','read':'4 min','time':'3d ago','col':AppColors.navy,
     'body':'Mahad holds a monumental place in Indian history. It is situated at the foothills of the Sahyadri ranges, serving as the gateway to the impregnable Raigad Fort, the glorious capital of Chhatrapati Shivaji Maharaj\'s Maratha Empire. Moreover, Mahad is globally recognized for the \'Mahad Satyagraha\' led by Dr. B. R. Ambedkar in 1927 at Chavdar Tale, a defining moment in India\'s social justice and civil rights movement.'},
    {'id':2,'cat':'Food',      'title':'Flavours of the Konkan',        'emoji':'🍽️','read':'3 min','time':'1d ago','col':AppColors.orange,
     'body':'As a vibrant hub in the Konkan region, Mahad\'s food scene is a delightful mix of traditional Maharashtrian and coastal flavors. Don\'t miss the spicy Misal Pav near Shivaji Chowk, or the authentic Konkani fish thalis and refreshing Solkadhi offered by local eateries. The weekly bazaars also bring in fresh coastal produce and traditional sweets like ukadiche modak that have been local favorites for generations.'},
    {'id':3,'cat':'Festivals', 'title':'Shiv Jayanti & Ganeshotsav', 'emoji':'🎉','read':'5 min','time':'5d ago','col':AppColors.green,
     'body':'Mahad celebrates its cultural heritage with immense fervor. Shiv Jayanti is observed with grand processions, dhol-tasha pathaks, and traditional lezim performances honoring Chhatrapati Shivaji Maharaj. Ambedkar Jayanti also sees thousands of followers gathering at Chavdar Tale to pay their respects. The city also comes alive during Ganeshotsav and Shimga (Holi), reflecting the true vibrant spirit of the Konkan.'},
    {'id':4,'cat':'Places',    'title':'Caves, Lakes, and Ancient Temples', 'emoji':'🛕','read':'3 min','time':'1w ago','col':AppColors.teal,
     'body':'Beyond its historical core, Mahad is flanked by natural and ancient wonders. The Gandharpale Caves, a fascinating group of 30 Buddhist caves situated on a hill right off the Mumbai-Goa highway, date back to the 3rd century. Down in the city, the ancient Vireshwar Temple and the scenic banks of the Savitri river offer peaceful and spiritual retreats for both locals and tourists.'},
    {'id':5,'cat':'Governance','title':'Mahad\'s Digital Civic Leap',  'emoji':'💡','read':'6 min','time':'2d ago','col':AppColors.blue,
     'body':'Once relying on traditional paper-based municipal records, the Mahad Nagar Panchayat has enthusiastically embraced digital transformation. With platforms like JanaSetu, citizens can now seamlessly report civic issues, track ward-level municipal projects, and participate in local polls. This e-governance leap has drastically reduced grievance resolution times, making Mahad a forward-thinking civic model in the Raigad district.'},
  ];

  String _subTab = 'articles';
  String _filter = 'All';
  final  _cats   = ['All', 'History', 'Food', 'Festivals', 'Places', 'Governance'];
  Map?   _open;

  late AnimationController _tabCtrl;
  late Animation<double>   _tabFade;

  @override void initState() {
    super.initState();
    _tabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _tabFade = CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOut);
    _tabCtrl.forward();
  }

  @override void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _switchTab(String t) {
    if (t == _subTab) return;
    setState(() { _subTab = t; _open = null; });
    _tabCtrl.forward(from: 0);
  }

  // ─────────────────────────────────────────────
  @override Widget build(BuildContext context) {
    if (_open != null) return _detailView(_open!);

    final isWide = MediaQuery.of(context).size.width > 700;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(children: [
        _buildHeader(),
        _buildSubTabs(),
        FadeTransition(
          opacity: _tabFade,
          child: Padding(
            padding: EdgeInsets.all(isWide ? 24 : 14),
            child: _buildContent(isWide),
          ),
        ),
      ]),
    );
  }

  Widget _buildContent(bool isWide) {
    switch (_subTab) {
      case 'facts':      return _factsContent(isWide);
      case 'governance': return _governanceContent(isWide);
      case 'contacts':   return _contactsContent(isWide);
      default:
        return isWide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 6, child: _articlesContent()),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: _articlesSidebar()),
            ])
          : _articlesContent();
    }
  }

  // ══════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
    decoration: const BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [AppColors.navy, AppColors.navyLight])),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('CITY INFORMATION', style: TextStyle(fontSize: 10, color: Color(0xFFFB923C),
          fontWeight: FontWeight.w800, letterSpacing: 1, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      const Text('Know Your Mahad', style: TextStyle(fontSize: 22,
          fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
      const Text('History · Culture · Food · Governance',
        style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
      const SizedBox(height: 16),
      const Row(children: [
        _SI(v:'5',    l:'Categories'), SizedBox(width:20),
        _SI(v:'5',    l:'Articles'),   SizedBox(width:20),
        _SI(v:'12K',  l:'Readers'),    SizedBox(width:20),
        _SI(v:'1869', l:'Founded'),
      ]),
    ]),
  );

  // ══════════════════════════════════════════════
  // SUB TABS — 4 tabs
  // ══════════════════════════════════════════════
  Widget _buildSubTabs() {
    const tabs = [
      ['articles',   'Articles',   Icons.article_outlined],
      ['facts',      'City Facts', Icons.info_outline],
      ['governance', 'Governance', Icons.account_balance_outlined],
      ['contacts',   'Contacts',   Icons.phone_outlined],
    ];
    return Container(
      color: AppColors.white,
      child: Row(children: tabs.map((t) {
        final active = _subTab == t[0];
        return Expanded(child: GestureDetector(
          onTap: () => _switchTab(t[0] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(
              color: active ? AppColors.orange : Colors.transparent, width: 3))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(t[2] as IconData, size: 15,
                color: active ? AppColors.orange : AppColors.grey),
              const SizedBox(height: 3),
              Text(t[1] as String, textAlign: TextAlign.center,
                style: TextStyle(fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 10.5, color: active ? AppColors.orange : AppColors.grey,
                  fontFamily: 'Nunito')),
            ]),
          ),
        ));
      }).toList()),
    );
  }

  // ══════════════════════════════════════════════
  // ARTICLES SIDEBAR (PC)
  // ══════════════════════════════════════════════
  Widget _articlesSidebar() => Column(children: [
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('City at a Glance', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final f in [
        [Icons.people_outline,             AppColors.orange, '~30,000', 'Population'],
        [Icons.location_city_outlined,     AppColors.blue,   '21',      'Wards'],
        [Icons.terrain_outlined,           AppColors.teal,   '4.8 km²', 'Area'],
        [Icons.calendar_today_outlined,    AppColors.navy,   '1869',    'Municipality Est.'],
        [Icons.how_to_vote_outlined,       AppColors.purple, '21+',     'Elected Members'],
        [Icons.account_balance_wallet_outlined, AppColors.green, '₹15 Cr','Annual Budget'],
      ])
        Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
          Container(padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: (f[1] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(f[0] as IconData, size: 14, color: f[1] as Color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f[2] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Nunito')),
            Text(f[3] as String, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
        ])),
    ])),

    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Browse by Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final cat in _cats.skip(1))
        GestureDetector(
          onTap: () => setState(() { _filter = cat; _subTab = 'articles'; }),
          child: Padding(padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _catColor(cat))),
              const SizedBox(width: 10),
              Expanded(child: Text(cat, style: TextStyle(fontSize: 13, fontFamily: 'Nunito',
                fontWeight: _filter == cat ? FontWeight.w800 : FontWeight.w500,
                color: _filter == cat ? AppColors.orange : AppColors.dark))),
              Text('${blogs.where((b)=>b['cat']==cat).length} articles',
                style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 10,
                color: _filter == cat ? AppColors.orange : AppColors.grey),
            ])),
        ),
    ])),

    AppCard(bgColor: AppColors.redLight, borderColor: AppColors.red.withOpacity(0.3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.emergency_outlined, color: AppColors.red, size: 16),
          SizedBox(width: 6),
          Text('Emergency Numbers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13,
              color: AppColors.red, fontFamily: 'Nunito')),
        ]),
        const SizedBox(height: 10),
        for (final r in [['Police','100'],['Ambulance','108'],['Fire','101'],['Municipal','02143-222011']])
          Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(r[0], style: const TextStyle(fontSize: 12, fontFamily: 'Nunito')),
            Text(r[1], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                color: AppColors.red, fontFamily: 'Nunito')),
          ])),
      ])),
  ]);

  // ══════════════════════════════════════════════
  // ARTICLES LIST
  // ══════════════════════════════════════════════
  Widget _articlesContent() {
    final shown = _filter == 'All' ? blogs : blogs.where((b) => b['cat'] == _filter).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 38, child: ListView(scrollDirection: Axis.horizontal,
        children: _cats.map((c) => Padding(padding: const EdgeInsets.only(right: 6),
          child: _FilterChip(label: c, active: _filter == c, color: AppColors.orange,
            onTap: () => setState(() => _filter = c)))).toList())),
      const SizedBox(height: 12),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${shown.length} article${shown.length != 1 ? 's' : ''}',
          style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
        if (_filter != 'All')
          GestureDetector(
            onTap: () => setState(() => _filter = 'All'),
            child: const Text('Clear filter', style: TextStyle(fontSize: 12,
                color: AppColors.orange, fontWeight: FontWeight.w700, fontFamily: 'Nunito'))),
      ]),
      const SizedBox(height: 10),

      // Featured
      if (_filter == 'All' && shown.isNotEmpty)
        GestureDetector(
          onTap: () => setState(() => _open = blogs[0]),
          child: AppCard(padding: EdgeInsets.zero, child: Stack(children: [
            Container(height: 180,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [
                blogs[0]['col'] as Color, (blogs[0]['col'] as Color).withOpacity(0.75)]))),
            Center(child: Text(blogs[0]['emoji'] as String, style: const TextStyle(fontSize: 64))),
            Positioned(top: 12, left: 12,
              child: AppChip(label: '⭐ Featured', color: AppColors.orange,
                bgColor: AppColors.orange.withOpacity(0.85), active: true, small: true)),
            Positioned(top: 12, right: 12, child: _readBadge(blogs[0]['read'] as String)),
            Positioned(bottom: 14, left: 14, right: 14,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AppChip(label: blogs[0]['cat'] as String,
                  color: Colors.white, bgColor: Colors.white.withOpacity(0.2), small: true),
                const SizedBox(height: 6),
                Text(blogs[0]['title'] as String, style: const TextStyle(fontWeight: FontWeight.w900,
                    fontSize: 17, color: Colors.white, fontFamily: 'Nunito')),
                const SizedBox(height: 2),
                Text(blogs[0]['time'] as String, style: const TextStyle(
                    fontSize: 11, color: Colors.white60, fontFamily: 'Nunito')),
              ])),
          ])),
        ),

      // List
      for (final b in (_filter == 'All' ? shown.skip(1).toList() : shown))
        GestureDetector(
          onTap: () => setState(() => _open = b),
          child: AppCard(padding: EdgeInsets.zero, child: Row(children: [
            SizedBox(width: 90, height: 90, child: Stack(children: [
              Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [
                b['col'] as Color, (b['col'] as Color).withOpacity(0.7)]))),
              Center(child: Text(b['emoji'] as String, style: const TextStyle(fontSize: 36))),
            ])),
            Expanded(child: Padding(padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AppChip(label: b['cat'] as String, color: b['col'] as Color, small: true),
                const SizedBox(height: 6),
                Text(b['title'] as String, style: const TextStyle(fontWeight: FontWeight.w800,
                    fontSize: 14, fontFamily: 'Nunito'),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.schedule, size: 11, color: AppColors.grey),
                  const SizedBox(width: 3),
                  Text('${b['read']} read', style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
                  const SizedBox(width: 10),
                  Text(b['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
                ]),
              ])),
            ),
            const Padding(padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.grey)),
          ])),
        ),
    ]);
  }

  Widget _readBadge(String read) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.schedule, size: 11, color: Colors.white), const SizedBox(width: 3),
      Text('$read read', style: const TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'Nunito')),
    ]),
  );

  // ══════════════════════════════════════════════
  // CITY FACTS
  // ══════════════════════════════════════════════
  Widget _factsContent(bool isWide) {
    final stats = [
      ['Population','30,000+','Steady growth since 2011',       AppColors.orange, Icons.people_outline],
      ['Area',      '~4.8 km²','21 administrative wards',        AppColors.teal,   Icons.map_outlined],
      ['Founded',   '1869',    'Municipal Council Est.',         AppColors.navy,   Icons.history_edu_outlined],
      ['Literacy',  '86%+',    'Highly educated demographic',    AppColors.green,  Icons.school_outlined],
      ['Hospitals', '1 Rural', '+ multiple private clinics',     AppColors.red,    Icons.local_hospital_outlined],
      ['Schools',   'Multiple','Historical institutions present',AppColors.purple, Icons.account_balance_outlined],
      ['Budget',    '₹15 Cr',  'Annual municipal budget',        AppColors.gold,   Icons.account_balance_wallet_outlined],
      ['Staff',     '~150',    'Municipal employees',            AppColors.blue,   Icons.badge_outlined],
    ];
    final landmarks = [
      {'n':'Raigad Fort',    't':'Heritage', 'e':'🏰','c':AppColors.navy},
      {'n':'Chavdar Tale',   't':'Historic', 'e':'💧','c':AppColors.orange},
      {'n':'Gandharpale Caves','t':'Ancient','e':'🪨','c':AppColors.teal},
      {'n':'Vireshwar Temple','t':'Religion','e':'🛕','c':AppColors.gold},
      {'n':'Shivaji Chowk',  't':'City Center','e':'🚩','c':AppColors.blue},
      {'n':'Savitri River',  't':'Nature',   'e':'🌊','c':AppColors.green},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _secHead('City Statistics', 'Key facts about Mahad Nagar Panchayat'),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: isWide ? 4 : 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10,
        childAspectRatio: isWide ? 1.65 : 1.65,
        children: stats.map((s) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16),
            border: Border(top: BorderSide(color: s[3] as Color, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(s[4] as IconData, size: 13, color: s[3] as Color), const SizedBox(width: 5),
              Expanded(child: Text(s[0] as String, style: const TextStyle(
                  fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito'))),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s[1] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: s[3] as Color, fontFamily: 'Nunito')),
              Text(s[2] as String, style: const TextStyle(fontSize: 9.5,
                  color: AppColors.greyDark, fontFamily: 'Nunito')),
            ]),
          ]),
        )).toList(),
      ),
      const SizedBox(height: 22),
      _secHead('Notable Landmarks', 'Places that define Mahad'),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: isWide ? 3 : 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
        children: landmarks.map((l) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (l['c'] as Color).withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (l['c'] as Color).withOpacity(0.25))),
          child: Row(children: [
            Text(l['e'] as String, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l['n'] as String, style: const TextStyle(fontWeight: FontWeight.w800,
                  fontSize: 12, fontFamily: 'Nunito'), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(l['t'] as String, style: TextStyle(fontSize: 10, color: l['c'] as Color,
                  fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
            ])),
          ]),
        )).toList(),
      ),
      const SizedBox(height: 22),
      AppCard(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MapWidget(label: 'Mahad · Ward Map', height: 180),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('City Map', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          const SizedBox(height: 4),
          const Text('Mahad is located in the Raigad district of Maharashtra, situated picturesquely on the banks of the Savitri River along the Mumbai-Goa highway.',
            style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito', height: 1.5)),
        ])),
      ])),
    ]);
  }

  // ══════════════════════════════════════════════
  // GOVERNANCE TAB  (Maharashtra NP Act, 1965)
  // ══════════════════════════════════════════════
  Widget _governanceContent(bool isWide) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

    // Intro card
    Container(
      padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
        borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MAHAD NAGAR PANCHAYAT', style: TextStyle(fontSize: 9, color: Color(0xFFFB923C),
            fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Governance Structure', style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Constituted under the Maharashtra Municipal Councils,\nNagar Panchayats & Industrial Townships Act, 1965.',
          style: TextStyle(fontSize: 11, color: Colors.white60, fontFamily: 'Nunito', height: 1.5)),
      ]),
    ),

    // Elected officials
    _secHead('Elected Officials', 'Chosen by citizens via adult franchise · 5-year term'),
    const SizedBox(height: 12),
    AppCard(child: Column(children: [
      _officialTile(Icons.account_balance,     AppColors.navy,   'Chairperson / President',
        'Head of the Nagar Panchayat. Chairs all council meetings and represents the body to the state government.'),
      const Divider(height: 20),
      _officialTile(Icons.how_to_vote_outlined, AppColors.blue,  'Ward Councillors (Elected Members)',
        'Elected ward members from Mahad\'s 21 wards. ⅓ seats reserved for SC/ST, OBC and women. Each member represents one ward.'),
      const Divider(height: 20),
      _officialTile(Icons.person_add_outlined,  AppColors.purple,'Nominated Members',
        'Appointed by the state government for expertise in areas relevant to urban local governance.'),
    ])),

    const SizedBox(height: 8),

    // Appointed officers
    _secHead('Appointed Administrative Officers', 'Appointed by the State Government of Maharashtra'),
    const SizedBox(height: 12),
    for (final o in [
      [Icons.manage_accounts_outlined,   AppColors.navy,   'Chief Officer (CEO)',        'Heads day-to-day administration. Controls all departments and staff. Appointed from the State Civil Services.'],
      [Icons.engineering_outlined,       AppColors.orange, 'Town Planning Engineer',     'Oversees roads, drainage, building permits, water infrastructure and all civic construction projects.'],
      [Icons.cleaning_services_outlined, AppColors.green,  'Sanitary Inspector',         'Manages garbage collection, drainage maintenance, public health inspections and cleanliness drives.'],
      [Icons.local_hospital_outlined,    AppColors.red,    'Medical Officer for Health', 'Responsible for public health, primary clinics, disease surveillance, vaccination camps and sanitation.'],
      [Icons.school_outlined,            AppColors.blue,   'Education Officer',          'Oversees municipal schools, mid-day meals, enrolment drives and educational infrastructure.'],
      [Icons.calculate_outlined,         AppColors.gold,   'Auditor / Accounts Officer', 'Manages budget, tax collection, financial records and ensures statutory compliance with the state.'],
    ])
      AppCard(borderColor: (o[1] as Color).withOpacity(0.2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (o[1] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(o[0] as IconData, color: o[1] as Color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o[2] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito')),
            const SizedBox(height: 4),
            Text(o[3] as String, style: const TextStyle(fontSize: 12, color: AppColors.greyDark,
                fontFamily: 'Nunito', height: 1.5)),
          ])),
        ])),

    const SizedBox(height: 8),

    // Revenue sources
    _secHead('Revenue Sources', 'Under the Maharashtra NP Act, 1965'),
    const SizedBox(height: 12),
    AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (int i = 0; i < 4; i++) ...[
        _revenueRow([
          ['40–50%','State Government Grants',   'General and specific-purpose grants via the Urban Development Department of Maharashtra.',       AppColors.blue],
          ['20–30%','Central Scheme Funds',      'Swachh Bharat Mission, PMAY (housing), AMRUT (urban infrastructure), Finance Commission grants.', AppColors.teal],
          ['15–25%','Local Taxes',               'Property tax, water tax, professional tax, advertisement tax.',                                   AppColors.orange],
          ['5–10%', 'Fees & Licences',           'Trade licences, building permits, occupancy certificates, market fees.',                          AppColors.green],
        ][i]),
        if (i < 3) const Divider(height: 20),
      ],
    ])),

    const SizedBox(height: 8),

    // Core functions
    _secHead('Core Functions', 'Services mandated under the Maharashtra NP Act, 1965'),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: [
      for (final f in [
        ['💧','Water Supply'],   ['🛣️','Roads & Drains'],   ['💡','Street Lighting'],
        ['🗑️','Solid Waste'],   ['🏥','Public Health'],    ['🔥','Fire Brigade'],
        ['🏫','Govt. Schools'],  ['🌳','Parks & Grounds'],  ['🏪','Market Places'],
        ['📋','Birth/Death Certs.'],['🏗️','Building Permits'],['🏷️','Trade Licences'],
        ['🚽','Sewage Treatment'],  ['♻️','Social Forestry'],  ['🤝','Social Welfare'],
      ])
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(f[0], style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(f[1], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                fontFamily: 'Nunito', color: AppColors.dark)),
          ]),
        ),
    ]),
  ]);

  Widget _officialTile(IconData icon, Color color, String title, String desc) =>
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
        const SizedBox(height: 3),
        Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.greyDark,
            fontFamily: 'Nunito', height: 1.5)),
      ])),
    ]);

  Widget _revenueRow(List<dynamic> r) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 52, padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(color: (r[3] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(r[0] as String, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: r[3] as Color, fontFamily: 'Nunito'))),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(r[1] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
      const SizedBox(height: 3),
      Text(r[2] as String, style: const TextStyle(fontSize: 11, color: AppColors.greyDark,
          fontFamily: 'Nunito', height: 1.4)),
    ])),
  ]);

  // ══════════════════════════════════════════════
  // CONTACTS TAB
  // ══════════════════════════════════════════════
  Widget _contactsContent(bool isWide) {
    final depts = [
      {'d':'Chief Officer',        'p':'02143-222010','h':'Mon–Sat  10AM–5PM', 'i':Icons.manage_accounts_outlined,   'c':AppColors.navy,   'r':'Head of Administration'},
      {'d':'Municipal Office',     'p':'02143-222011','h':'Mon–Sat  10AM–5PM', 'i':Icons.account_balance_outlined,   'c':AppColors.navy,   'r':'General Enquiries & Records'},
      {'d':'Engineering Dept.',    'p':'02143-222015','h':'Mon–Sat  10AM–5PM', 'i':Icons.engineering_outlined,       'c':AppColors.orange, 'r':'Roads, Drains, Building Permits'},
      {'d':'Water Supply Dept.',   'p':'02143-222022','h':'24 / 7 Helpline',   'i':Icons.water_drop_outlined,        'c':AppColors.teal,   'r':'Water Supply & New Connections'},
      {'d':'Sanitation Inspector', 'p':'02143-222030','h':'Mon–Sat  9AM–5PM',  'i':Icons.cleaning_services_outlined, 'c':AppColors.green,  'r':'Garbage, Drains, Cleanliness'},
      {'d':'Health Officer',       'p':'02143-222033','h':'Mon–Sat  9AM–5PM',  'i':Icons.local_hospital_outlined,    'c':AppColors.red,    'r':'Public Health & Clinics'},
      {'d':'Education Officer',    'p':'02143-222040','h':'Mon–Sat  10AM–4PM', 'i':Icons.school_outlined,            'c':AppColors.blue,   'r':'Municipal Schools & Enrolment'},
      {'d':'Fire & Emergency',     'p':'101',         'h':'24 / 7',            'i':Icons.local_fire_department,      'c':AppColors.orange, 'r':'Fire Brigade & Emergency Response'},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Emergency banner
      Container(
        padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.red, Color(0xFFB91C1C)]),
          borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.emergency_outlined, color: Colors.white, size: 20), SizedBox(width: 8),
            Text('Emergency Helplines', style: TextStyle(fontWeight: FontWeight.w900,
                fontSize: 15, color: Colors.white, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            for (final e in [['🚔 Police','100'],['🚑 Ambulance','108'],['🔥 Fire','101']])
              Expanded(child: Padding(padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.25))),
                  child: Column(children: [
                    Text(e[0], style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'Nunito')),
                    const SizedBox(height: 3),
                    Text(e[1], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                        color: Colors.white, fontFamily: 'Nunito')),
                  ])))),
          ]),
        ]),
      ),

      _secHead('Department Contacts', 'Official numbers · Mahad Nagar Panchayat'),
      const SizedBox(height: 14),

      if (isWide)
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 0, crossAxisSpacing: 12, childAspectRatio: 3.0,
          children: depts.map(_contactCard).toList(),
        )
      else
        for (final d in depts) _contactCard(d),

      const SizedBox(height: 8),
      AppCard(bgColor: AppColors.blueLight, borderColor: AppColors.blue.withOpacity(0.3),
        child: Row(children: const [
          Icon(Icons.info_outline, color: AppColors.blue, size: 18), SizedBox(width: 12),
          Expanded(child: Text(
            'For non-emergency complaints, use the Report tab in JanaSetu for faster official tracking and response.',
            style: TextStyle(fontSize: 12, color: AppColors.blue, fontFamily: 'Nunito', height: 1.5))),
        ])),
    ]);
  }

  Widget _contactCard(Map d) => AppCard(
    borderColor: (d['c'] as Color).withOpacity(0.25),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: (d['c'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(d['i'] as IconData, color: d['c'] as Color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d['d'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
        const SizedBox(height: 1),
        Text(d['r'] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
        Text(d['h'] as String, style: const TextStyle(fontSize: 10, color: AppColors.greyDark, fontFamily: 'Nunito')),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (d['c'] as Color).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: (d['c'] as Color).withOpacity(0.3))),
        child: Text(d['p'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
            color: d['c'] as Color, fontFamily: 'Nunito'))),
    ]),
  );

  // ══════════════════════════════════════════════
  // ARTICLE DETAIL — returns SingleChildScrollView, no Expanded
  // ══════════════════════════════════════════════
  Widget _detailView(Map b) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final color  = b['col'] as Color;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Back bar ──
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
          child: Row(children: [
            TextButton.icon(
              onPressed: () => setState(() => _open = null),
              icon: const Icon(Icons.arrow_back_ios_new, size: 15, color: AppColors.orange),
              label: const Text('City Info', style: TextStyle(color: AppColors.orange,
                  fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito'))),
            const Spacer(),
            AppChip(label: b['cat'] as String, color: color, small: true),
          ]),
        ),
        const Divider(height: 1),

        // ── Hero ──
        Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          decoration: BoxDecoration(gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _readBadge(b['read'] as String), const SizedBox(width: 8),
              Text(b['time'] as String, style: const TextStyle(fontSize: 11,
                  color: Colors.white60, fontFamily: 'Nunito')),
            ]),
            const SizedBox(height: 12),
            Text(b['title'] as String, style: const TextStyle(fontSize: 22,
                fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
          ]),
        ),

        // ── Content ──
        Padding(
          padding: EdgeInsets.all(isWide ? 28 : 18),
          child: isWide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 6, child: _articleBody(b, color)),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: _articleSidebar(b, color)),
              ])
            : _articleBody(b, color),
        ),
      ]),
    );
  }

  Widget _articleBody(Map b, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: Text(b['emoji'] as String, style: const TextStyle(fontSize: 60))),
    const SizedBox(height: 20),
    Text(b['body'] as String, style: const TextStyle(fontSize: 15, height: 1.9,
        fontFamily: 'Nunito', color: AppColors.dark)),
    const SizedBox(height: 24),
    Row(children: [
      Expanded(child: _actionBtn(Icons.share_outlined,  'Share')),
      const SizedBox(width: 10),
      Expanded(child: _actionBtn(Icons.bookmark_border, 'Save')),
    ]),
  ]);

  Widget _actionBtn(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 16, color: AppColors.grey), const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: AppColors.grey, fontFamily: 'Nunito')),
    ]),
  );

  Widget _articleSidebar(Map b, Color color) {
    final related = blogs.where((bl) => bl['cat'] == b['cat'] && bl['id'] != b['id']).toList();
    final toShow  = related.isNotEmpty ? related : blogs.where((bl) => bl['id'] != b['id']).take(3).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(bgColor: color.withOpacity(0.06), borderColor: color.withOpacity(0.22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('About this article', style: TextStyle(fontWeight: FontWeight.w900,
              fontSize: 14, color: color, fontFamily: 'Nunito')),
          const SizedBox(height: 10),
          _metaRow(Icons.category_outlined, b['cat'] as String),
          _metaRow(Icons.schedule,          '${b['read']} read'),
          _metaRow(Icons.access_time,       'Published ${b['time']}'),
        ])),
      if (toShow.isNotEmpty)
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('More Articles', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          const SizedBox(height: 12),
          for (final r in toShow)
            GestureDetector(
              onTap: () => setState(() => _open = r),
              child: Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [r['col'] as Color, (r['col'] as Color).withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(r['emoji'] as String, style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 12, fontFamily: 'Nunito'),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${r['read']} read', style: const TextStyle(
                      fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
                ])),
                const Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.grey),
              ])),
            ),
        ])),
    ]);
  }

  Widget _metaRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    Icon(icon, size: 13, color: AppColors.grey), const SizedBox(width: 6),
    Text(text, style: const TextStyle(fontSize: 12, fontFamily: 'Nunito', color: AppColors.greyDark)),
  ]));

  Widget _secHead(String title, String sub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
    const SizedBox(height: 2),
    Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
  ]);

  Color _catColor(String cat) {
    switch (cat) {
      case 'History':    return AppColors.navy;
      case 'Food':       return AppColors.orange;
      case 'Festivals':  return AppColors.green;
      case 'Places':     return AppColors.teal;
      case 'Governance': return AppColors.blue;
      default:           return AppColors.grey;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool active; final Color color; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.color, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? color : AppColors.border, width: 1.5)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppColors.grey, fontFamily: 'Nunito')),
    ),
  );
}

class _SI extends StatelessWidget {
  final String v, l;
  const _SI({required this.v, required this.l});
  @override Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
        color: Colors.white, fontFamily: 'Nunito')),
    Text(l, style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'Nunito')),
  ]);
}