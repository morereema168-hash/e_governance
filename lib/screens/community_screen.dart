import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────
// ANIMATIONS:
//  • Tab switch     — slide + fade transition
//  • Cards          — staggered fade-up entry (index × 60ms delay)
//  • Notices        — slide in from right (index × 70ms delay)
//  • Like button    — heart scale bounce + particle burst
//  • Like count     — tick-up slide transition
//  • Poll vote      — per-bar progress animate 0 → value on vote
//  • Poll footer    — animated switcher text
//  • Join event     — scale bounce + ripple flash on join
//  • Volunteer count— animated switcher number fade
//  • Event progress — animated bar on mount + on update
//  • Compose box    — SizeTransition expand/collapse
//  • Post btn       — scale press feedback
//  • Filter chips   — animated colour/border transition
//  • Header stats   — count-up from 0 on first load
// ─────────────────────────────────────────────────────────────

class CommunityScreen extends StatefulWidget {
  final AppUser user;
  const CommunityScreen({super.key, required this.user});
  @override State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {

  String sub = 'feed';

  late AnimationController _tabCtrl;
  late Animation<Offset>   _slideIn;
  late Animation<double>   _fadeIn;

  late AnimationController _headerCtrl;
  late Animation<double>   _headerAnim;

  bool _composeExpanded = false;
  late AnimationController _composeCtrl;
  late Animation<double>   _composeAnim;

  final _postCtrl = TextEditingController();
  String filter   = 'All';
  final tags      = ['All', 'Infrastructure', 'Water', 'Cleanliness', 'Roads'];

  final List<Post> posts = [
    Post(id:1, user:'Priya Desai', av:'PD', time:'2h ago',
      body:'Footpath on MG Road is broken — kids going to school are at risk! #MGRoad #Infrastructure',
      likes:34, comments:8, liked:false),
    Post(id:2, user:'Rahul More', av:'RM', time:'4h ago',
      body:'Huge shoutout to the sanitation team in Sector 4 today! #Cleanliness #Ward4',
      likes:61, comments:12, liked:false),
    Post(id:3, user:'Meera Joshi', av:'MJ', time:'1d ago',
      body:'Water supply irregular for 10 days. Who is accountable? #WaterCrisis #Ward3',
      likes:89, comments:27, liked:false),
  ];

  final List<Map<String, dynamic>> events = [
    {'title':'Tree Plantation Drive',  'date':'Sun Dec 22','time':'7:00 AM','loc':'Gandhi Chowk', 'joined':34,'cap':60,'me':false,'color':AppColors.green},
    {'title':'Swachh Bharat Clean-Up', 'date':'Sat Dec 21','time':'6:30 AM','loc':'Market Road',  'joined':18,'cap':40,'me':false,'color':AppColors.blue},
    {'title':'Senior Citizen Help Day','date':'Mon Dec 23','time':'9:00 AM','loc':'Ward 3 Hall',  'joined':9, 'cap':20,'me':false,'color':AppColors.purple},
  ];

  final List<Map<String, dynamic>> polls = [
    {
      'question': 'Which road needs repair most urgently?',
      'options':  ['MG Road', 'Station Road', 'Market Lane', 'Ward 3 Inner Road'],
      'votes':    [42, 28, 15, 19],
      'voted':    -1,
      'time':     '3h ago',
      'author':   'Ward Committee',
    },
    {
      'question': 'Best time for community clean-up drives?',
      'options':  ['Early Morning (6–8 AM)', 'Evening (5–7 PM)', 'Sunday Morning'],
      'votes':    [56, 31, 44],
      'voted':    -1,
      'time':     '1d ago',
      'author':   'Swachh Rampur Team',
    },
  ];

  final announcements = [
    {'title':'Water Supply Disruption – Dec 14', 'body':'Ward 3 & 4 will face a 6-hour cut from 6 AM.', 'type':'alert','time':'2h ago'},
    {'title':'Property Tax Deadline Extended',   'body':'New deadline: Dec 31. Avoid late payment penalties.', 'type':'info','time':'5h ago'},
    {'title':'Town Hall Meeting – Sunday 10 AM', 'body':'All residents invited. Municipal Hall, Gate 2.', 'type':'event','time':'1d ago'},
    {'title':'Swachh Bharat Drive – Ward 3',     'body':'Join the cleanliness drive this Saturday at 6:30 AM.', 'type':'event','time':'2d ago'},
    {'title':'Building Permit Counter Hours',    'body':'Engineering Dept now open Mon–Sat, 9 AM – 5 PM.', 'type':'info','time':'3d ago'},
  ];

  @override void initState() {
    super.initState();

    _tabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideIn = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOutCubic));
    _fadeIn  = CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOut);
    _tabCtrl.forward();

    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();

    _composeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 270));
    _composeAnim = CurvedAnimation(parent: _composeCtrl, curve: Curves.easeInOut);
  }

  @override void dispose() {
    _tabCtrl.dispose(); _headerCtrl.dispose(); _composeCtrl.dispose();
    _postCtrl.dispose();
    super.dispose();
  }

  void _switchTab(String tab) {
    if (tab == sub) return;
    setState(() => sub = tab);
    _tabCtrl.forward(from: 0);
  }

  void _submitPost() {
    if (_postCtrl.text.isEmpty) return;
    setState(() {
      posts.insert(0, Post(
        id: DateTime.now().millisecondsSinceEpoch,
        user: widget.user.name, av: widget.user.avatar,
        time: 'Just now', body: _postCtrl.text,
        likes: 0, comments: 0, liked: false));
      _postCtrl.clear();
      _composeExpanded = false;
    });
    _composeCtrl.reverse();
  }

  // ────────────────────────────────────────────
  @override Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Column(children: [
      _buildHeader(),
      _buildTabs(),
      Expanded(child: SlideTransition(
        position: _slideIn,
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(isWide ? 24 : 14, 16, isWide ? 24 : 14, 80),
            child: isWide ? _wideLayout() : _narrowLayout(),
          ),
        ),
      )),
    ]);
  }

  // ════════════════════════════════════════════
  // HEADER — count-up stats
  // ════════════════════════════════════════════
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
    decoration: const BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [AppColors.navy, AppColors.navyLight])),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('COMMUNITY HUB', style: TextStyle(fontSize: 10, color: Color(0xFFFB923C),
          fontWeight: FontWeight.w800, letterSpacing: 1, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      const Text('Rampur Speaks', style: TextStyle(fontSize: 22,
          fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
      const Text('Open discussions · Civic notices · Community service',
        style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Nunito')),
      const SizedBox(height: 14),
      AnimatedBuilder(
        animation: _headerAnim,
        builder: (_, __) => Row(children: [
          _animStat(2400, _headerAnim.value, 'Citizens'),  const SizedBox(width: 20),
          _animStat(186,  _headerAnim.value, 'Today'),     const SizedBox(width: 20),
          _animStat(3,    _headerAnim.value, 'Events'),    const SizedBox(width: 20),
          _animStat(2,    _headerAnim.value, 'Live Polls'),
        ]),
      ),
    ]),
  );

  Widget _animStat(int target, double p, String label) {
    final val = (target * p).round();
    final display = target >= 1000
        ? '${(val / 1000).toStringAsFixed(1)}K'
        : '$val';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(display, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
          color: Colors.white, fontFamily: 'Nunito')),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'Nunito')),
    ]);
  }

  // ════════════════════════════════════════════
  // TAB BAR — animated underline
  // ════════════════════════════════════════════
  Widget _buildTabs() {
    const tabs = [['feed','Discussions'],['service','Service'],['polls','Polls'],['notices','Notices']];
    return Container(
      color: AppColors.white,
      child: Row(children: tabs.map((t) {
        final active = sub == t[0];
        return Expanded(child: GestureDetector(
          onTap: () => _switchTab(t[0]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(
              color: active ? AppColors.orange : Colors.transparent, width: 3))),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w500,
                fontSize: 12, color: active ? AppColors.orange : AppColors.grey, fontFamily: 'Nunito'),
              child: Text(t[1], textAlign: TextAlign.center)),
          ),
        ));
      }).toList()),
    );
  }

  // ════════════════════════════════════════════
  // LAYOUTS
  // ════════════════════════════════════════════
  Widget _wideLayout() {
    if (sub == 'notices') return _noticesContent();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 6, child: _activeContent()),
      const SizedBox(width: 20),
      Expanded(flex: 4, child: _sidebar()),
    ]);
  }
  Widget _narrowLayout() => _activeContent();
  Widget _activeContent() {
    if (sub == 'feed')    return _feedContent();
    if (sub == 'service') return _serviceContent();
    if (sub == 'polls')   return _pollsContent();
    return _noticesContent();
  }

  // ════════════════════════════════════════════
  // SIDEBAR
  // ════════════════════════════════════════════
  Widget _sidebar() => Column(children: [
    _StaggerCard(index: 0, child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Trending Topics', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final t in [
        ['#WaterCrisis','89 posts',AppColors.teal],
        ['#MGRoad','42 posts',AppColors.orange],
        ['#Cleanliness','61 posts',AppColors.green],
        ['#Ward3','34 posts',AppColors.blue],
        ['#Infrastructure','28 posts',AppColors.purple],
      ])
        Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(t[0] as String, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                color: t[2] as Color, fontFamily: 'Nunito')),
            Text(t[1] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
    ]))),

    _StaggerCard(index: 1, child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Upcoming Events', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final e in events)
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
    ]))),

    _StaggerCard(index: 2, child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Active Citizens', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),
      for (final c in [
        ['Meera Joshi','MJ','89 likes',AppColors.teal],
        ['Rahul More','RM','61 likes',AppColors.blue],
        ['Priya Desai','PD','34 likes',AppColors.purple],
      ])
        Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            AppAvatar(initials: c[1] as String, color: c[3] as Color, size: 32),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c[0] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito')),
              Text(c[2] as String, style: const TextStyle(fontSize: 10, color: AppColors.grey, fontFamily: 'Nunito')),
            ])),
          ])),
    ]))),
  ]);

  // ════════════════════════════════════════════
  // FEED
  // ════════════════════════════════════════════
  Widget _feedContent() {
    final filtered = filter == 'All'
        ? posts
        : posts.where((p) => p.body.toLowerCase().contains(filter.toLowerCase())).toList();

    return Column(children: [
      // Compose
      _AnimatedCompose(
        user: widget.user, controller: _composeCtrl, animation: _composeAnim,
        postCtrl: _postCtrl, expanded: _composeExpanded,
        onTap: () { setState(() => _composeExpanded = true); _composeCtrl.forward(); },
        onPost: _submitPost,
        onCancel: () { setState(() => _composeExpanded = false); _composeCtrl.reverse(); },
      ),
      const SizedBox(height: 10),

      // Filter chips
      SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal,
        children: tags.map((t) => Padding(padding: const EdgeInsets.only(right: 6),
          child: _AnimatedChip(label: t, active: filter == t, color: AppColors.orange,
            onTap: () => setState(() => filter = t)))).toList())),
      const SizedBox(height: 8),

      Padding(padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${filtered.length} posts', style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
          const Text('Sorted by: Latest', style: TextStyle(fontSize: 12, color: AppColors.orange, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
        ])),

      ...List.generate(filtered.length, (i) => _StaggerCard(
        index: i,
        child: _PostCard(
          post: filtered[i],
          onLike: () => setState(() {
            filtered[i].liked = !filtered[i].liked;
            filtered[i].likes += filtered[i].liked ? 1 : -1;
          }),
          onParseTags: _parseTags,
        ),
      )),
    ]);
  }

  Widget _parseTags(String text) => RichText(text: TextSpan(
    style: const TextStyle(fontSize: 14, color: AppColors.dark, fontFamily: 'Nunito', height: 1.65),
    children: text.split(RegExp(r'(?=#)|(?<=#\S)(?=\s|$)')).expand((p) {
      if (p.startsWith('#'))
        return [TextSpan(text: p, style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800))];
      return [TextSpan(text: p)];
    }).toList(),
  ));

  // ════════════════════════════════════════════
  // SERVICE
  // ════════════════════════════════════════════
  Widget _serviceContent() => Column(children: [
    _StaggerCard(index: 0, child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF15803D)]),
        borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _svcStat('3',  'Events'),
        _vDivider(),
        _svcStat('61', 'Volunteers'),
        _vDivider(),
        _svcStat('2',  'This Week'),
      ]),
    )),
    const SizedBox(height: 4),
    ...List.generate(events.length, (i) => _StaggerCard(
      index: i + 1,
      child: _EventCard(
        event: events[i],
        onToggle: (joined) => setState(() {
          events[i]['me']     = joined;
          events[i]['joined'] = (events[i]['joined'] as int) + (joined ? 1 : -1);
        }),
      ),
    )),
  ]);

  Widget _svcStat(String v, String l) => Column(children: [
    Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito')),
    Text(l, style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'Nunito')),
  ]);
  Widget _vDivider() => Container(width: 1, height: 30, color: Colors.white24);

  // ════════════════════════════════════════════
  // POLLS
  // ════════════════════════════════════════════
  Widget _pollsContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Community Polls', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
    const SizedBox(height: 4),
    const Text('Vote on issues that matter to Rampur', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
    const SizedBox(height: 14),
    ...List.generate(polls.length, (i) => _StaggerCard(
      index: i,
      child: _PollCard(
        poll: polls[i],
        onVote: (idx) => setState(() {
          polls[i]['voted'] = idx;
          (polls[i]['votes'] as List<int>)[idx]++;
        }),
      ),
    )),
  ]);

  // ════════════════════════════════════════════
  // NOTICES
  // ════════════════════════════════════════════
  Widget _noticesContent() {
    const typeData = {
      'alert': [AppColors.red,  AppColors.redLight,  Icons.warning_amber_rounded],
      'event': [AppColors.gold, AppColors.goldLight,  Icons.event_outlined],
      'info':  [AppColors.blue, AppColors.blueLight,  Icons.info_outline],
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Official Notices', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      const Text('From Nagar Panchayat & Ward Office', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
      const SizedBox(height: 14),
      ...List.generate(announcements.length, (i) {
        final a  = announcements[i];
        final td = typeData[a['type']]!;
        return _SlideInCard(index: i, child: AppCard(
          borderColor: (td[0] as Color).withOpacity(0.3),
          bgColor: td[1] as Color,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (td[0] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
              child: Icon(td[2] as IconData, color: td[0] as Color, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(a['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito'))),
                Text(a['time'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
              ]),
              const SizedBox(height: 4),
              Text(a['body'] as String,
                style: const TextStyle(fontSize: 12, color: AppColors.greyDark, fontFamily: 'Nunito')),
            ])),
          ]),
        ));
      }),
      const SizedBox(height: 4),
      _SlideInCard(index: announcements.length, child: AppCard(
        bgColor: AppColors.orangeLight,
        borderColor: AppColors.orange.withOpacity(0.35),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.notifications_active_outlined, color: AppColors.orange, size: 22)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Stay Updated', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito')),
            Text('Enable push notifications to get alerts instantly', style: TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
          ])),
          const SizedBox(width: 8),
          AppChip(label: 'Enable', color: AppColors.orange),
        ]),
      )),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// ANIMATED COMPOSE BOX
// ══════════════════════════════════════════════════════════════
class _AnimatedCompose extends StatelessWidget {
  final AppUser user;
  final AnimationController controller;
  final Animation<double> animation;
  final TextEditingController postCtrl;
  final bool expanded;
  final VoidCallback onTap, onPost, onCancel;
  const _AnimatedCompose({
    required this.user, required this.controller, required this.animation,
    required this.postCtrl, required this.expanded,
    required this.onTap, required this.onPost, required this.onCancel,
  });

  @override Widget build(BuildContext context) => GestureDetector(
    onTap: expanded ? null : onTap,
    child: AppCard(
      bgColor: AppColors.orangeLight,
      borderColor: AppColors.orange.withOpacity(0.4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          AppAvatar(initials: user.avatar),
          const SizedBox(width: 10),
          Expanded(child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: expanded
              ? TextField(
                  key: const ValueKey('exp'),
                  controller: postCtrl, maxLines: 3, autofocus: true,
                  decoration: const InputDecoration(hintText: 'Share your thoughts… use #hashtags', fillColor: Colors.white, filled: true),
                  style: const TextStyle(fontFamily: 'Nunito'))
              : Container(
                  key: const ValueKey('col'),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: const Text("What's on your mind?", style: TextStyle(color: AppColors.grey, fontFamily: 'Nunito', fontSize: 14))),
          )),
        ]),
        SizeTransition(
          sizeFactor: animation, axisAlignment: -1,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Wrap(spacing: 6, children: const [
                _MiniChip(label: '# Tag',   color: AppColors.orange),
                _MiniChip(label: '📷 Photo',color: AppColors.blue),
                _MiniChip(label: '📊 Poll', color: AppColors.purple),
              ]),
              Row(children: [
                TextButton(onPressed: onCancel,
                  child: const Text('Cancel', style: TextStyle(color: AppColors.grey, fontFamily: 'Nunito'))),
                _PressableBtn(label: 'Post', onTap: onPost),
              ]),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

class _MiniChip extends StatelessWidget {
  final String label; final Color color;
  const _MiniChip({required this.label, required this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'Nunito')),
  );
}

// ── Scale-press post button ──
class _PressableBtn extends StatefulWidget {
  final String label; final VoidCallback onTap;
  const _PressableBtn({required this.label, required this.onTap});
  @override State<_PressableBtn> createState() => _PressableBtnState();
}
class _PressableBtnState extends State<_PressableBtn> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _s = Tween<double>(begin: 1, end: 0.91).animate(CurvedAnimation(parent: _c, curve: Curves.easeIn));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp: (_) { _c.reverse(); widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(scale: _s, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.orange, AppColors.orangeDark]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.orange.withOpacity(0.38), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontFamily: 'Nunito', fontSize: 13)),
    )),
  );
}

// ── Animated filter chip ──
class _AnimatedChip extends StatelessWidget {
  final String label; final bool active; final Color color; final VoidCallback onTap;
  const _AnimatedChip({required this.label, required this.active, required this.color, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
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

// ══════════════════════════════════════════════════════════════
// POST CARD + ANIMATED LIKE BUTTON
// ══════════════════════════════════════════════════════════════
class _PostCard extends StatelessWidget {
  final Post post; final VoidCallback onLike; final Widget Function(String) onParseTags;
  const _PostCard({required this.post, required this.onLike, required this.onParseTags});
  @override Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        AppAvatar(initials: post.av, color: AppColors.navy),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(post.user, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Nunito')),
          Text(post.time, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
        ]),
      ]),
      const Icon(Icons.more_horiz, color: AppColors.grey, size: 20),
    ]),
    const SizedBox(height: 10),
    onParseTags(post.body),
    const SizedBox(height: 10),
    const Divider(),
    const SizedBox(height: 6),
    Row(children: [
      _LikeButton(liked: post.liked, count: post.likes, onTap: onLike),
      const SizedBox(width: 16),
      Row(children: [
        const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.grey),
        const SizedBox(width: 4),
        Text('${post.comments}', style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
      ]),
      const SizedBox(width: 16),
      const Row(children: [
        Icon(Icons.share_outlined, size: 18, color: AppColors.grey),
        SizedBox(width: 4),
        Text('Share', style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w700, fontFamily: 'Nunito', fontSize: 13)),
      ]),
      const Spacer(),
      const Icon(Icons.bookmark_border, size: 18, color: AppColors.grey),
    ]),
  ]));
}

class _LikeButton extends StatefulWidget {
  final bool liked; final int count; final VoidCallback onTap;
  const _LikeButton({required this.liked, required this.count, required this.onTap});
  @override State<_LikeButton> createState() => _LikeButtonState();
}
class _LikeButtonState extends State<_LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale, _burst;
  bool _showParticles = false;

  @override void initState() {
    super.initState();
    _c     = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin:1.0,end:1.45).chain(CurveTween(curve:Curves.easeOut)), weight:40),
      TweenSequenceItem(tween: Tween(begin:1.45,end:0.88).chain(CurveTween(curve:Curves.easeIn)), weight:30),
      TweenSequenceItem(tween: Tween(begin:0.88,end:1.0).chain(CurveTween(curve:Curves.easeOut)), weight:30),
    ]).animate(_c);
    _burst = CurvedAnimation(parent: _c, curve: const Interval(0, 0.5, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  void _tap() {
    if (!widget.liked) {
      setState(() => _showParticles = true);
      _c.forward(from: 0).then((_) { if (mounted) setState(() => _showParticles = false); });
    }
    widget.onTap();
  }

  @override Widget build(BuildContext context) => GestureDetector(
    onTap: _tap,
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, __) => SizedBox(
        width: 60, height: 28,
        child: Stack(alignment: Alignment.centerLeft, children: [
          if (_showParticles)
            ...List.generate(6, (i) {
              final angle = (i / 6) * 2 * math.pi;
              final r = _burst.value * 16;
              return Positioned(
                left: 9 + r * math.cos(angle),
                top:  10 + r * math.sin(angle),
                child: Opacity(
                  opacity: (1 - _burst.value).clamp(0.0, 1.0),
                  child: Container(width: 4, height: 4,
                    decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle))),
              );
            }),
          Row(children: [
            ScaleTransition(scale: widget.liked ? _scale : const AlwaysStoppedAnimation(1.0),
              child: Icon(widget.liked ? Icons.favorite : Icons.favorite_border,
                size: 18, color: widget.liked ? AppColors.red : AppColors.grey)),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, -0.6), end: Offset.zero).animate(anim),
                child: FadeTransition(opacity: anim, child: child)),
              child: Text('${widget.count}', key: ValueKey(widget.count),
                style: TextStyle(color: widget.liked ? AppColors.red : AppColors.grey,
                    fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
            ),
          ]),
        ]),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// EVENT CARD — ripple flash + counter + progress bar animation
// ══════════════════════════════════════════════════════════════
class _EventCard extends StatefulWidget {
  final Map<String, dynamic> event; final void Function(bool) onToggle;
  const _EventCard({required this.event, required this.onToggle});
  @override State<_EventCard> createState() => _EventCardState();
}
class _EventCardState extends State<_EventCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _ripple, _btnScale;
  bool _flashing = false;
  late int _display;

  @override void initState() {
    super.initState();
    _display = widget.event['joined'] as int;
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _ripple   = CurvedAnimation(parent: _c, curve: const Interval(0, 0.55, curve: Curves.easeOut));
    _btnScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin:1.0,end:1.05).chain(CurveTween(curve:Curves.easeOut)), weight:40),
      TweenSequenceItem(tween: Tween(begin:1.05,end:1.0).chain(CurveTween(curve:Curves.easeIn)),  weight:60),
    ]).animate(CurvedAnimation(parent: _c, curve: const Interval(0, 0.5)));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  void _toggle() {
    final joining = !(widget.event['me'] as bool);
    setState(() {
      _flashing = joining;
      _display  = (widget.event['joined'] as int) + (joining ? 1 : -1);
    });
    _c.forward(from: 0).then((_) { if (mounted) setState(() => _flashing = false); });
    widget.onToggle(joining);
  }

  @override Widget build(BuildContext context) {
    final e      = widget.event;
    final color  = e['color'] as Color;
    final isFull = (e['joined'] as int) >= (e['cap'] as int);
    final joined = e['me'] as bool;
    final pct    = ((e['joined'] as int) / (e['cap'] as int) * 100).clamp(0, 100).toDouble();

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Stack(children: [
        AppCard(borderColor: color.withOpacity(0.3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 8),
              Text(e['title'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
            ]),
            AnimatedSwitcher(duration: const Duration(milliseconds: 200),
              child: isFull
                ? AppChip(key: const ValueKey('f'), label: 'Full', color: AppColors.red, small: true)
                : AppChip(key: ValueKey(e['joined']),
                    label: '${(e['cap'] as int)-(e['joined'] as int)} spots left',
                    color: color, small: true)),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 16, runSpacing: 6, children: [
            _det(Icons.calendar_today_outlined, e['date'] as String),
            _det(Icons.access_time,             e['time'] as String),
            _det(Icons.location_on_outlined,    e['loc']  as String),
          ]),
          const SizedBox(height: 12),
          _AnimatedBar(value: pct, color: color),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
              child: Text('$_display/${e['cap']} volunteers joined',
                key: ValueKey(_display),
                style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito'))),
            Text('${pct.round()}% full',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'Nunito')),
          ]),
          const SizedBox(height: 12),
          ScaleTransition(scale: _btnScale,
            child: GestureDetector(
              onTap: (isFull && !joined) ? null : _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: joined ? Colors.transparent : (isFull ? AppColors.grey : color),
                  borderRadius: BorderRadius.circular(12),
                  border: joined ? Border.all(color: AppColors.green, width: 2) : null,
                  boxShadow: joined || isFull ? [] : [BoxShadow(color: color.withOpacity(0.33), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Center(child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    joined ? '✓ Joined · Leave' : isFull ? 'Event Full' : 'Join Event',
                    key: ValueKey(joined),
                    style: TextStyle(color: joined ? AppColors.green : Colors.white,
                        fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
                )),
              ),
            )),
        ])),
        if (_flashing) Positioned.fill(child: IgnorePointer(child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Opacity(opacity: (1 - _ripple.value).clamp(0.0, 0.22),
            child: Container(color: color))))),
      ]),
    );
  }
  Widget _det(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: AppColors.grey),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
  ]);
}

// ── Self-animating progress bar (0 → value on mount, re-animates on update) ──
class _AnimatedBar extends StatefulWidget {
  final double value; final Color color;
  const _AnimatedBar({required this.value, required this.color});
  @override State<_AnimatedBar> createState() => _AnimatedBarState();
}
class _AnimatedBarState extends State<_AnimatedBar> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _a = Tween<double>(begin: 0, end: widget.value)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _c.forward();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override void didUpdateWidget(_AnimatedBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _a = Tween<double>(begin: _a.value, end: widget.value)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
      _c.forward(from: 0);
    }
  }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => ClipRRect(borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: _a.value / 100, minHeight: 7,
        backgroundColor: widget.color.withOpacity(0.12),
        valueColor: AlwaysStoppedAnimation(widget.color))),
  );
}

// ══════════════════════════════════════════════════════════════
// POLL CARD — animated progress bars on vote
// ══════════════════════════════════════════════════════════════
class _PollCard extends StatefulWidget {
  final Map<String, dynamic> poll; final void Function(int) onVote;
  const _PollCard({required this.poll, required this.onVote});
  @override State<_PollCard> createState() => _PollCardState();
}
class _PollCardState extends State<_PollCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<Animation<double>> _bars;

  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _buildBars(from: 0);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  void _buildBars({double from = 0}) {
    final votes = widget.poll['votes'] as List<int>;
    final total = votes.fold(0, (a, b) => a + b).toDouble();
    _bars = votes.map((v) => Tween<double>(begin: from, end: total == 0 ? 0 : v / total)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut))).toList();
  }

  void _vote(int idx) {
    if ((widget.poll['voted'] as int) >= 0) return;
    widget.onVote(idx);
    setState(() { _buildBars(); });
    _c.forward(from: 0);
  }

  @override Widget build(BuildContext context) {
    final options  = widget.poll['options'] as List<String>;
    final votes    = widget.poll['votes']   as List<int>;
    final voted    = widget.poll['voted']   as int;
    final total    = votes.fold(0, (a, b) => a + b);
    final hasVoted = voted >= 0;

    return AppCard(borderColor: AppColors.purple.withOpacity(0.25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.purpleLight, borderRadius: BorderRadius.circular(8)),
          child: const Text('POLL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.purple, fontFamily: 'Nunito'))),
        const SizedBox(width: 8),
        Text(widget.poll['author'] as String, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontFamily: 'Nunito')),
        const Spacer(),
        Text(widget.poll['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito')),
      ]),
      const SizedBox(height: 10),
      Text(widget.poll['question'] as String,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Nunito')),
      const SizedBox(height: 12),

      ...List.generate(options.length, (i) {
        final isVoted = voted == i;
        return GestureDetector(
          onTap: hasVoted ? null : () => _vote(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isVoted ? AppColors.purpleLight : AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isVoted ? AppColors.purple : AppColors.border,
                width: isVoted ? 2 : 1)),
            child: hasVoted
              ? AnimatedBuilder(animation: _c, builder: (_, __) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(options[i], style: TextStyle(
                      fontWeight: isVoted ? FontWeight.w800 : FontWeight.w500, fontSize: 13, fontFamily: 'Nunito',
                      color: isVoted ? AppColors.purple : AppColors.dark)),
                    Text('${(votes[i]/total*100).round()}%',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                        color: isVoted ? AppColors.purple : AppColors.grey, fontFamily: 'Nunito')),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: _bars.length > i ? _bars[i].value : 0, minHeight: 5,
                      backgroundColor: AppColors.purple.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(isVoted ? AppColors.purple : AppColors.grey.withOpacity(0.35)))),
                ]))
              : Text(options[i], style: const TextStyle(fontSize: 13, fontFamily: 'Nunito')),
          ),
        );
      }),

      const SizedBox(height: 4),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          hasVoted ? '$total votes · Thanks for voting!' : 'Tap an option to cast your vote',
          key: ValueKey(hasVoted),
          style: TextStyle(fontSize: 11, fontFamily: 'Nunito',
            color: hasVoted ? AppColors.green : AppColors.grey,
            fontWeight: hasVoted ? FontWeight.w700 : FontWeight.w500)),
      ),
    ]));
  }
}

// ══════════════════════════════════════════════════════════════
// STAGGER CARD — fade + slide up, index-based delay
// ══════════════════════════════════════════════════════════════
class _StaggerCard extends StatefulWidget {
  final int index; final Widget child;
  const _StaggerCard({required this.index, required this.child});
  @override State<_StaggerCard> createState() => _StaggerCardState();
}
class _StaggerCardState extends State<_StaggerCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  @override void initState() {
    super.initState();
    _c     = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fade  = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 65), () { if (mounted) _c.forward(); });
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => FadeTransition(opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child));
}

// ══════════════════════════════════════════════════════════════
// SLIDE-IN CARD — slides from right (notices)
// ══════════════════════════════════════════════════════════════
class _SlideInCard extends StatefulWidget {
  final int index; final Widget child;
  const _SlideInCard({required this.index, required this.child});
  @override State<_SlideInCard> createState() => _SlideInCardState();
}
class _SlideInCardState extends State<_SlideInCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  @override void initState() {
    super.initState();
    _c     = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _fade  = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 70), () { if (mounted) _c.forward(); });
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => FadeTransition(opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child));
}