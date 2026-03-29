import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class CityInfoScreen extends StatefulWidget {
  const CityInfoScreen({super.key});
  @override State<CityInfoScreen> createState() => _CityInfoScreenState();
}

class _CityInfoScreenState extends State<CityInfoScreen> {
  final blogs = const [
    {'id':1,'cat':'History','title':'The Ancient Forts of Rampur','emoji':'🏰','read':'4 min','time':'3d ago','col':AppColors.navy,
     'body':'Rampur\'s history dates to the 12th century when the Yadava dynasty established a fortified settlement. The ruins of Rampur Fort still stand, with intricate stone carvings attracting historians from across Maharashtra. The fort\'s eastern tower is particularly well-preserved, offering a glimpse into medieval Deccan architecture.'},
    {'id':2,'cat':'Food','title':'Top 7 Restaurants You Must Visit','emoji':'🍽️','read':'3 min','time':'1d ago','col':AppColors.orange,
     'body':'From legendary Poha at Sharma Nashta to the award-winning Mutton Curry at Hotel Rajwada — Rampur\'s food scene is a hidden gem. Don\'t miss the evening bhel at Gandhi Chowk. Local favourites also include the chaat stalls near Station Road that have been running for over 40 years.'},
    {'id':3,'cat':'Festivals','title':'Ganesh Chaturthi – City\'s Biggest Fest','emoji':'🎉','read':'5 min','time':'5d ago','col':AppColors.green,
     'body':'Every year Rampur transforms during Ganesh Chaturthi. 200+ Ganesh mandals, 11 days of processions, and a final immersion at the city lake that draws 50,000 people. The Ward 3 mandal is famous for its eco-friendly Ganesh idols made from clay and natural colours.'},
    {'id':4,'cat':'Places','title':'Hidden Gems – Rampur Lake & Sunset Point','emoji':'🌅','read':'3 min','time':'1w ago','col':AppColors.teal,
     'body':'Sunset Point near the old reservoir rewards a 20-minute trek with panoramic views. The lake hosts migratory birds from October to February. Early morning bird-watchers have spotted over 60 species including the Painted Stork and Indian Roller during peak season.'},
    {'id':5,'cat':'Governance','title':'Rampur\'s Digital Transformation Story','emoji':'💡','read':'6 min','time':'2d ago','col':AppColors.blue,
     'body':'Once known for slow civic services, Rampur Nagar Panchayat\'s digital overhaul — complaint tracking, digital voting, geo-tagged projects — has made it a state model for e-governance. The initiative has reduced complaint resolution time from 14 days to under 3 days on average.'},
  ];

  // Quick facts about the city
  static const facts = [
    {'icon': Icons.people_outline,         'label': 'Population',  'value': '1.2 Lakh'},
    {'icon': Icons.location_city_outlined,  'label': 'Wards',       'value': '12'},
    {'icon': Icons.terrain_outlined,        'label': 'Area',        'value': '42 km²'},
    {'icon': Icons.calendar_today_outlined, 'label': 'Founded',     'value': '1248 AD'},
  ];

  // City contacts
  static const contacts = [
    {'dept': 'Municipal Office',  'phone': '02462-220011', 'icon': Icons.account_balance_outlined,  'color': AppColors.navy},
    {'dept': 'Water Department',  'phone': '02462-220022', 'icon': Icons.water_drop_outlined,        'color': AppColors.teal},
    {'dept': 'Health Centre',     'phone': '02462-220033', 'icon': Icons.local_hospital_outlined,    'color': AppColors.red},
    {'dept': 'Fire & Emergency',  'phone': '101',          'icon': Icons.local_fire_department,      'color': AppColors.orange},
  ];

  final cats = ['All', 'History', 'Food', 'Festivals', 'Places', 'Governance'];
  String filter  = 'All';
  String subTab  = 'articles'; // articles | facts | contacts
  Map?   open;

  @override Widget build(BuildContext context) {
    if (open != null) return _detail(open!);
    final isWide = MediaQuery.of(context).size.width > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(children: [
        _buildHeader(),
        _buildSubTabs(),
        Padding(
          padding: EdgeInsets.all(isWide ? 24 : 14),
          child: subTab == 'articles'
              ? (isWide ? _wideArticles() : _narrowArticles())
              : subTab == 'facts'
                  ? _factsContent(isWide)
                  : _contactsContent(isWide),
        ),
      ]),
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CITY INFORMATION', style: TextStyle(fontSize: 10, color: Color(0xFFFB923C), fontWeight: FontWeight.w800, letterSpacing: 1, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        const Text('Know Your Rampur', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
        const Text('History · Culture · Food · Governance', style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
        const SizedBox(height: 16),
        Row(children: const [
          _SI(v: '5',   l: 'Categories'),  SizedBox(width: 20),
          _SI(v: '5',   l: 'Articles'),    SizedBox(width: 20),
          _SI(v: '12K', l: 'Readers'),     SizedBox(width: 20),
          _SI(v: '1248',l: 'Founded'),
        ]),
      ]),
    );
  }

  // ── SUB TABS ──
  Widget _buildSubTabs() {
    return Container(
      color: AppColors.white,
      child: Row(children: [
        for (final t in [['articles', 'Articles', Icons.article_outlined],
                         ['facts',    'City Facts', Icons.info_outline],
                         ['contacts', 'Contacts',  Icons.phone_outlined]])
          Expanded(child: GestureDetector(
            onTap: () => setState(() => subTab = t[0] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(
                color: subTab == t[0] ? AppColors.orange : Colors.transparent, width: 3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(t[2] as IconData, size: 14,
                  color: subTab == t[0] ? AppColors.orange : AppColors.grey),
                const SizedBox(width: 5),
                Text(t[1] as String, textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: subTab == t[0] ? FontWeight.w900 : FontWeight.w500,
                    fontSize: 12, color: subTab == t[0] ? AppColors.orange : AppColors.grey,
                    fontFamily: 'Nunito')),
              ]),
            ),
          )),
      ]),
    );
  }

  // ── WIDE ARTICLES LAYOUT ──
  Widget _wideArticles() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 6, child: _narrowArticles()),
      const SizedBox(width: 20),
      Expanded(flex: 4, child: _sidebar()),
    ]);
  }

  // ── SIDEBAR ──
  Widget _sidebar() {
    return Column(children: [
      // Quick facts mini
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('City at a Glance', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
          children: facts.map((f) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(f['icon'] as IconData, size: 16, color: AppColors.orange),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f['value'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Nunito')),
                Text(f['label'] as String, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
              ])),
            ]),
          )).toList(),
        ),
      ])),

      // Categories
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Browse by Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
        const SizedBox(height: 12),
        for (final cat in cats.skip(1))
          GestureDetector(
            onTap: () => setState(() { filter = cat; subTab = 'articles'; }),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: _catColor(cat))),
                const SizedBox(width: 10),
                Expanded(child: Text(cat,
                  style: TextStyle(fontSize: 13, fontFamily: 'Nunito',
                    fontWeight: filter == cat ? FontWeight.w800 : FontWeight.w500,
                    color: filter == cat ? AppColors.orange : AppColors.dark))),
                Text('${blogs.where((b) => b['cat'] == cat).length} articles',
                  style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.grey),
              ]),
            ),
          ),
      ])),

      // Emergency contacts mini
      AppCard(bgColor: AppColors.redLight, borderColor: AppColors.red.withOpacity(0.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.emergency_outlined, color: AppColors.red, size: 18),
            SizedBox(width: 8),
            Text('Emergency Numbers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.red, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 10),
          for (final c in contacts.take(2))
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(c['dept'] as String, style: const TextStyle(fontSize: 12, fontFamily: 'Nunito')),
                Text(c['phone'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.red, fontFamily: 'Nunito')),
              ])),
        ])),
    ]);
  }

  // ── NARROW ARTICLES ──
  Widget _narrowArticles() {
    final shown = filter == 'All' ? blogs : blogs.where((b) => b['cat'] == filter).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Filter chips
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal,
        children: cats.map((c) => Padding(padding: const EdgeInsets.only(right: 6),
          child: AppChip(label: c, color: AppColors.orange, active: filter == c,
            onTap: () => setState(() => filter = c)))).toList())),
      const SizedBox(height: 14),

      // Article count
      Text('${shown.length} article${shown.length != 1 ? 's' : ''}',
        style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 10),

      // Featured card
      if (filter == 'All')
        GestureDetector(
          onTap: () => setState(() => open = blogs[0]),
          child: AppCard(padding: EdgeInsets.zero, child: Column(children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  blogs[0]['col'] as Color,
                  (blogs[0]['col'] as Color).withOpacity(0.7)])),
              child: Stack(children: [
                Center(child: Text(blogs[0]['emoji'] as String,
                  style: const TextStyle(fontSize: 64))),
                Positioned(top: 12, left: 12,
                  child: AppChip(label: 'Featured', color: AppColors.orange,
                    bgColor: AppColors.orange.withOpacity(0.85), active: true, small: true)),
                // Read time badge
                Positioned(top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.schedule, size: 11, color: Colors.white),
                      const SizedBox(width: 3),
                      Text('${blogs[0]['read']} read',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'Nunito')),
                    ]),
                  )),
                Positioned(bottom: 12, left: 14, right: 14,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AppChip(label: blogs[0]['cat'] as String,
                      color: Colors.white, bgColor: Colors.white.withOpacity(0.25), small: true),
                    const SizedBox(height: 6),
                    Text(blogs[0]['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white, fontFamily: 'Nunito')),
                    const SizedBox(height: 2),
                    Text(blogs[0]['time'] as String,
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'Nunito')),
                  ])),
              ]),
            ),
          ])),
        ),

      // Article list
      for (final b in filter == 'All' ? shown.skip(1).toList() : shown)
        GestureDetector(
          onTap: () => setState(() => open = b),
          child: AppCard(padding: EdgeInsets.zero, child: Row(children: [
            // Thumbnail
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  b['col'] as Color,
                  (b['col'] as Color).withOpacity(0.7)])),
              child: Stack(children: [
                Center(child: Text(b['emoji'] as String,
                  style: const TextStyle(fontSize: 36))),
              ]),
            ),
            Expanded(child: Padding(padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AppChip(label: b['cat'] as String, color: b['col'] as Color, small: true),
                const SizedBox(height: 6),
                Text(b['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito'),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.schedule, size: 11, color: AppColors.grey),
                  const SizedBox(width: 3),
                  Text('${b['read']} read', style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time, size: 11, color: AppColors.grey),
                  const SizedBox(width: 3),
                  Text(b['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
                ]),
              ])),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.grey),
            ),
          ])),
        ),
    ]);
  }

  // ── FACTS CONTENT ──
  Widget _factsContent(bool isWide) {
    final statCards = [
      ['Population',   '1.2 Lakh', '↑ 3.2% since 2011', AppColors.orange,  Icons.people_outline],
      ['Area',         '42 km²',   '12 administrative wards', AppColors.teal, Icons.map_outlined],
      ['Founded',      '1248 AD',  'Yadava dynasty era', AppColors.navy,    Icons.history_edu_outlined],
      ['Literacy',     '84.6%',    'Above state average', AppColors.green,  Icons.school_outlined],
      ['Hospitals',    '3 Public', '+ 8 private clinics', AppColors.red,    Icons.local_hospital_outlined],
      ['Schools',      '24',       '6 higher secondary', AppColors.purple, Icons.account_balance_outlined],
    ];

    final landmarks = [
      {'name': 'Rampur Fort',       'type': 'Heritage', 'emoji': '🏰', 'col': AppColors.navy},
      {'name': 'Gandhi Chowk',      'type': 'Market',   'emoji': '🛒', 'col': AppColors.orange},
      {'name': 'City Lake',         'type': 'Nature',   'emoji': '🌊', 'col': AppColors.teal},
      {'name': 'Municipal Hall',    'type': 'Civic',    'emoji': '🏛️', 'col': AppColors.blue},
      {'name': 'Sunrise Temple',    'type': 'Religion', 'emoji': '🛕', 'col': AppColors.gold},
      {'name': 'Sunset Point',      'type': 'Tourism',  'emoji': '🌅', 'col': AppColors.green},
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('City Statistics', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      const Text('Key facts about Rampur Nagar Panchayat', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 14),

      GridView.count(
        crossAxisCount: isWide ? 3 : 2,
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: isWide ? 2.0 : 1.7,
        children: statCards.map((s) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(top: BorderSide(color: s[3] as Color, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(s[4] as IconData, size: 16, color: s[3] as Color),
              const SizedBox(width: 6),
              Text(s[0] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
            ]),
            const SizedBox(height: 6),
            Text(s[1] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: s[3] as Color, fontFamily: 'Nunito')),
            const SizedBox(height: 2),
            Text(s[2] as String, style: const TextStyle(fontSize: 10, color: AppColors.greyDark, fontFamily: 'Nunito')),
          ]),
        )).toList(),
      ),

      const SizedBox(height: 20),
      const Text('Notable Landmarks', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      const SizedBox(height: 12),

      GridView.count(
        crossAxisCount: isWide ? 3 : 2,
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2,
        children: landmarks.map((l) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (l['col'] as Color).withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (l['col'] as Color).withOpacity(0.25)),
          ),
          child: Row(children: [
            Text(l['emoji'] as String, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'Nunito'),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(l['type'] as String,
                style: TextStyle(fontSize: 10, color: l['col'] as Color, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
            ])),
          ]),
        )).toList(),
      ),

      const SizedBox(height: 20),
      // MapWidget placeholder
      AppCard(padding: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MapWidget(label: 'Rampur City · Ward Map', height: 180),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('City Map', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          const SizedBox(height: 4),
          const Text('Rampur spans 42 km² across 12 wards along the Godavari basin.',
            style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito', height: 1.5)),
        ])),
      ])),
    ]);
  }

  // ── CONTACTS CONTENT ──
  Widget _contactsContent(bool isWide) {
    final allContacts = [
      {'dept': 'Municipal Office',    'phone': '02462-220011', 'hours': 'Mon–Sat 10AM–5PM',  'icon': Icons.account_balance_outlined,  'color': AppColors.navy},
      {'dept': 'Water Department',    'phone': '02462-220022', 'hours': '24/7 helpline',      'icon': Icons.water_drop_outlined,        'color': AppColors.teal},
      {'dept': 'Health Centre',       'phone': '02462-220033', 'hours': 'Mon–Sat 8AM–8PM',   'icon': Icons.local_hospital_outlined,    'color': AppColors.red},
      {'dept': 'Fire & Emergency',    'phone': '101',          'hours': '24/7',               'icon': Icons.local_fire_department,      'color': AppColors.orange},
      {'dept': 'Roads & Infra',       'phone': '02462-220044', 'hours': 'Mon–Fri 10AM–5PM',  'icon': Icons.add_road,                   'color': AppColors.greyDark},
      {'dept': 'Sanitation',          'phone': '02462-220055', 'hours': 'Mon–Sat 7AM–3PM',   'icon': Icons.delete_outline,             'color': AppColors.green},
      {'dept': 'Electricity Dept',    'phone': '02462-220066', 'hours': '24/7 emergency',    'icon': Icons.bolt_outlined,              'color': AppColors.gold},
      {'dept': 'Grievance Cell',      'phone': '02462-220077', 'hours': 'Mon–Fri 10AM–4PM',  'icon': Icons.support_agent_outlined,     'color': AppColors.purple},
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Emergency banner
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.red, Color(0xFFB91C1C)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.emergency_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Emergency?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, fontFamily: 'Nunito')),
            Text('Police: 100  ·  Ambulance: 108  ·  Fire: 101',
              style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
          ])),
        ]),
      ),

      const Text('Department Contacts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      const Text('Official numbers for all municipal departments', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 14),

      if (isWide)
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 0, crossAxisSpacing: 12,
          childAspectRatio: 3.5,
          children: allContacts.map((c) => _contactCard(c)).toList(),
        )
      else
        for (final c in allContacts) _contactCard(c),

      const SizedBox(height: 16),
      // Office hours note
      AppCard(bgColor: AppColors.blueLight, borderColor: AppColors.blue.withOpacity(0.3),
        child: Row(children: [
          const Icon(Icons.info_outline, color: AppColors.blue, size: 20),
          const SizedBox(width: 12),
          const Expanded(child: Text(
            'For non-emergency complaints, use the Report tab in JanaSetu for faster tracking and official response.',
            style: TextStyle(fontSize: 12, color: AppColors.blue, fontFamily: 'Nunito', height: 1.5))),
        ])),
    ]);
  }

  Widget _contactCard(Map c) {
    return AppCard(
      borderColor: (c['color'] as Color).withOpacity(0.25),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (c['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c['dept'] as String,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
          const SizedBox(height: 2),
          Text(c['hours'] as String,
            style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (c['color'] as Color).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: (c['color'] as Color).withOpacity(0.3)),
          ),
          child: Text(c['phone'] as String,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
              color: c['color'] as Color, fontFamily: 'Nunito')),
        ),
      ]),
    );
  }

  // ── ARTICLE DETAIL ──
  Widget _detail(Map b) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final color  = b['col'] as Color;

    return WillPopScope(
      onWillPop: () async { setState(() => open = null); return false; },
      child: Column(children: [
        // Sticky white back bar
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
          child: Row(children: [
            TextButton.icon(
              onPressed: () => setState(() => open = null),
              icon: const Icon(Icons.arrow_back_ios_new, size: 15, color: AppColors.orange),
              label: const Text('City Info',
                style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito')),
            ),
            const Spacer(),
            AppChip(label: b['cat'] as String, color: color, small: true),
          ]),
        ),
        const Divider(height: 1),
        // Scrollable body
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.75)])),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.schedule, size: 11, color: Colors.white),
                    const SizedBox(width: 3),
                    Text('${b['read']} read', style: const TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'Nunito')),
                  ])),
                const SizedBox(height: 10),
                Text(b['title'] as String,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
                const SizedBox(height: 4),
                Text(b['time'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'Nunito')),
              ]),
            ),
            Padding(
              padding: EdgeInsets.all(isWide ? 24 : 18),
              child: isWide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 6, child: _detailBody(b)),
                      const SizedBox(width: 24),
                      Expanded(flex: 4, child: _detailSidebar(b)),
                    ])
                  : _detailBody(b),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _detailBody(Map b) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(b['emoji'] as String, style: const TextStyle(fontSize: 56))),
      const SizedBox(height: 20),
      Text(b['body'] as String,
        style: const TextStyle(fontSize: 15, height: 1.85, fontFamily: 'Nunito', color: AppColors.dark)),
      const SizedBox(height: 24),
      // Share / Save row
      Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bg, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.share_outlined, size: 16, color: AppColors.grey),
            SizedBox(width: 6),
            Text('Share', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey, fontFamily: 'Nunito')),
          ]),
        )),
        const SizedBox(width: 10),
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bg, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.bookmark_border, size: 16, color: AppColors.grey),
            SizedBox(width: 6),
            Text('Save', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey, fontFamily: 'Nunito')),
          ]),
        )),
      ]),
    ]);
  }

  Widget _detailSidebar(Map b) {
    final related = blogs.where((bl) => bl['cat'] == b['cat'] && bl['id'] != b['id']).toList();
    final others  = blogs.where((bl) => bl['id'] != b['id']).take(3).toList();
    final toShow  = related.isNotEmpty ? related : others;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(bgColor: (b['col'] as Color).withOpacity(0.07),
        borderColor: (b['col'] as Color).withOpacity(0.25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('About this article', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14,
            color: b['col'] as Color, fontFamily: 'Nunito')),
          const SizedBox(height: 10),
          _detailMeta(Icons.category_outlined,   b['cat'] as String),
          _detailMeta(Icons.schedule,             '${b['read']} read'),
          _detailMeta(Icons.access_time,          'Published ${b['time']}'),
        ])),

      if (toShow.isNotEmpty) ...[
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('More Articles', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
          const SizedBox(height: 12),
          for (final r in toShow)
            GestureDetector(
              onTap: () => setState(() => open = r),
              child: Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [r['col'] as Color, (r['col'] as Color).withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(r['emoji'] as String,
                    style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito'),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${r['read']} read', style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
                ])),
                const Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.grey),
              ])),
            ),
        ])),
      ],
    ]);
  }

  Widget _detailMeta(IconData icon, String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
      Icon(icon, size: 13, color: AppColors.grey),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12, fontFamily: 'Nunito', color: AppColors.greyDark)),
    ]));
  }

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

class _SI extends StatelessWidget {
  final String v, l;
  const _SI({required this.v, required this.l});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
    Text(l, style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'Nunito')),
  ]);
}