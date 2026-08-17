import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../services/settings_provider.dart';

const Color primaryAccent = Color(0xFF2563EB);

class MockPost {
  final int id;
  final String user;
  final String av;
  final String time;
  final String body;
  final int ward;
  final String category;
  final String status;
  int score;
  int userVote;
  int comments;
  final String? media;
  final String? location;

  MockPost({
    required this.id, required this.user, required this.av,
    required this.time, required this.body, required this.ward,
    required this.category, required this.status, required this.score,
    required this.userVote, required this.comments,
    this.media, this.location,
  });
}

class CommunityScreen extends StatefulWidget {
  final AppUser user;
  const CommunityScreen({super.key, required this.user});
  @override State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {

  String sub = 'feed';
  String searchQuery = '';
  String activeSort = 'Hot';

  late AnimationController _tabCtrl;
  late Animation<Offset>   _slideIn;
  late Animation<double>   _fadeIn;

  bool _composeExpanded = false;
  late AnimationController _composeCtrl;
  late Animation<double>   _composeAnim;

  final _postCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  
  String? _attachedMedia;
  String _selectedCategory = 'General';
  final List<String> _categories = ['General', 'Infrastructure', 'Water', 'Cleanliness', 'Roads', 'Electricity'];

  final List<MockPost> posts = [
    MockPost(id: 1, user: 'Priya Desai', av: 'PD', time: '2h ago', ward: 4, category: 'Infrastructure', status: 'Open',
      body: 'Footpath on MG Road is broken — kids going to school are at risk! #MGRoad #Infrastructure',
      score: 5100, userVote: 0, comments: 2400, location: 'MG Road, Ward 4', media: 'broken_road.jpg'),
    MockPost(id: 2, user: 'Rahul More', av: 'RM', time: '4h ago', ward: 7, category: 'Cleanliness', status: 'Resolved',
      body: 'Huge shoutout to the sanitation team in Sector 4 today! #Cleanliness #Ward7',
      score: 1200, userVote: 1, comments: 84),
    MockPost(id: 3, user: 'Meera Joshi', av: 'MJ', time: '1d ago', ward: 3, category: 'Water', status: 'Acknowledged',
      body: 'Water supply irregular for 10 days. Who is accountable? #WaterCrisis #Ward3',
      score: 890, userVote: 0, comments: 127),
  ];

  @override void initState() {
    super.initState();
    _tabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideIn = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOutCubic));
    _fadeIn  = CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOut);
    _tabCtrl.forward();

    _composeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 270));
    _composeAnim = CurvedAnimation(parent: _composeCtrl, curve: Curves.easeInOut);
  }

  @override void dispose() {
    _tabCtrl.dispose(); _composeCtrl.dispose();
    _postCtrl.dispose(); _searchCtrl.dispose(); _locCtrl.dispose();
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
      posts.insert(0, MockPost(
        id: DateTime.now().millisecondsSinceEpoch,
        user: widget.user.name, av: widget.user.avatar,
        time: 'Just now', body: _postCtrl.text,
        ward: int.tryParse(widget.user.ward.toString()) ?? 1, 
        category: _selectedCategory, status: 'Open',
        score: 1, userVote: 1, comments: 0,
        location: _locCtrl.text.isNotEmpty ? _locCtrl.text : null,
        media: _attachedMedia,
      ));
      _postCtrl.clear();
      _locCtrl.clear();
      _attachedMedia = null;
      _composeExpanded = false;
    });
    _composeCtrl.reverse();
  }

  void _handleVote(int index, int voteType) {
    setState(() {
      final post = posts[index];
      if (post.userVote == voteType) {
        post.score -= voteType;
        post.userVote = 0;
      } else {
        post.score += voteType - post.userVote;
        post.userVote = voteType;
      }
    });
  }

  // ────────────────────────────────────────────
  @override Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Column(children: [
      _buildSearchBar(), 
      _buildTabs(context),
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
  // REDDIT-STYLE SEARCH BAR
  // ════════════════════════════════════════════
  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() => searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Find anything (e.g., #Water, Roads)',
          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  // TAB BAR 
  // ════════════════════════════════════════════
  Widget _buildTabs(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Removed Service and Notices
    final tabs = [
      ['feed', settings.t('feed')],
      ['polls', settings.t('polls')],
    ];
    
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(children: tabs.map((t) {
        final active = sub == t[0];
        return Expanded(child: GestureDetector(
          onTap: () => _switchTab(t[0]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(
              color: active ? primaryAccent : Colors.transparent, width: 3))),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                fontSize: 13, color: active ? primaryAccent : (isDark ? Colors.white54 : Colors.black54)),
              child: Text(t[1], textAlign: TextAlign.center)),
          ),
        ));
      }).toList()),
    );
  }

  Widget _wideLayout() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 7, child: _activeContent()),
      const SizedBox(width: 24),
      Expanded(flex: 3, child: _sidebar()),
    ]);
  }
  
  Widget _narrowLayout() => _activeContent();
  
  Widget _activeContent() {
    if (sub == 'feed') return _feedContent();
    if (sub == 'polls') return _pollsContent();
    return const SizedBox.shrink();
  }

  // ════════════════════════════════════════════
  // POPULAR COMMUNITIES SIDEBAR
  // ════════════════════════════════════════════
  Widget _sidebar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final popBg = isDark ? const Color(0xFF0F1A2C) : Colors.white; 
    
    return Card(
      color: popBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text('POPULAR HASHTAGS', style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5, 
              color: isDark ? Colors.white54 : Colors.black54
            )),
            const SizedBox(height: 16),
            _buildSidebarItem('#WaterCrisis', '23,639 posts', Colors.blue, 'W'),
            _buildSidebarItem('#Infrastructure', '22,472 posts', Colors.orange, 'I'),
            _buildSidebarItem('#Cleanliness', '749,500 posts', Colors.teal, 'C'),
            _buildSidebarItem('#Ward3', '1,072 posts', primaryAccent, '3'),
            _buildSidebarItem('#Electricity', '7,953 posts', Colors.red, 'E'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {}, 
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              child: const Text('See more', style: TextStyle(color: primaryAccent, fontSize: 12))
            )
          ]
        )
      )
    );
  }

  Widget _buildSidebarItem(String title, String subtitle, Color color, String initial) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            searchQuery = title;
            _searchCtrl.text = title;
          });
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 14, 
              backgroundColor: color.withOpacity(0.2), 
              child: Text(initial, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  // FEED + SORTING LOGIC
  // ════════════════════════════════════════════
  Widget _feedContent() {
    List<MockPost> filtered = searchQuery.isEmpty
        ? List.from(posts)
        : posts.where((p) => p.body.toLowerCase().contains(searchQuery.toLowerCase()) || 
                             p.category.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    if (activeSort == 'New') {
      filtered.sort((a, b) => b.id.compareTo(a.id));
    } else if (activeSort == 'Top') {
      filtered.sort((a, b) => b.score.compareTo(a.score));
    } else if (activeSort == 'Hot') {
      filtered.sort((a, b) => (b.score + (b.comments * 2)).compareTo(a.score + (a.comments * 2)));
    } else if (activeSort == 'Best') {
      filtered.sort((a, b) => b.comments.compareTo(a.comments));
    }

    return Column(children: [
      _AnimatedCompose(
        user: widget.user, controller: _composeCtrl, animation: _composeAnim,
        postCtrl: _postCtrl, locCtrl: _locCtrl, expanded: _composeExpanded,
        selectedCategory: _selectedCategory,
        categories: _categories,
        attachedImage: _attachedMedia,
        onCategoryChanged: (val) => setState(() => _selectedCategory = val!),
        onAttachMedia: () => setState(() => _attachedMedia = 'image_upload_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        onRemoveMedia: () => setState(() => _attachedMedia = null),
        onTap: () { setState(() => _composeExpanded = true); _composeCtrl.forward(); },
        onPost: _submitPost,
        onCancel: () { 
          setState(() { _composeExpanded = false; _attachedMedia = null; _locCtrl.clear(); }); 
          _composeCtrl.reverse(); 
        },
      ),
      const SizedBox(height: 12),
      
      _buildSortRow(),
      const SizedBox(height: 8),
      
      ...List.generate(filtered.length, (i) => _StaggerCard(
        index: i,
        child: _PostCard(
          post: filtered[i],
          onUpvote: () {
            final idx = posts.indexOf(filtered[i]);
            _handleVote(idx, 1);
          },
          onDownvote: () {
            final idx = posts.indexOf(filtered[i]);
            _handleVote(idx, -1);
          },
          onParseTags: _parseTags,
        ),
      )),
    ]);
  }

  Widget _buildSortRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        _buildSortBtn('Best', Icons.rocket_launch_outlined, activeSort == 'Best'),
        _buildSortBtn('Hot', Icons.local_fire_department_outlined, activeSort == 'Hot'),
        _buildSortBtn('New', Icons.new_releases_outlined, activeSort == 'New'),
        _buildSortBtn('Top', Icons.leaderboard_outlined, activeSort == 'Top'),
        const Spacer(),
        if (searchQuery.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                searchQuery = '';
                _searchCtrl.clear();
              });
            },
          )
      ],
    );
  }

  Widget _buildSortBtn(String label, IconData icon, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => setState(() => activeSort = label),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? primaryAccent : (isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              fontSize: 13, 
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? primaryAccent : (isDark ? Colors.white54 : Colors.black54)
            )),
          ],
        ),
      ),
    );
  }

  Widget _parseTags(String text) => RichText(text: TextSpan(
    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
    children: text.split(RegExp(r'(?=#)|(?<=#\S)(?=\s|$)')).expand((p) {
      if (p.startsWith('#')) {
        return [TextSpan(text: p, style: const TextStyle(color: primaryAccent, fontWeight: FontWeight.w600))];
      }
      return [TextSpan(text: p)];
    }).toList(),
  ));

  Widget _pollsContent() => const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Polls Tab Content Placeholder")));
}

// ══════════════════════════════════════════════════════════════
// POST CARD
// ══════════════════════════════════════════════════════════════
class _PostCard extends StatelessWidget {
  final MockPost post; 
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final Widget Function(String) onParseTags;
  
  const _PostCard({required this.post, required this.onUpvote, required this.onDownvote, required this.onParseTags});

  String _formatNumber(int num) {
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}k';
    return num.toString();
  }

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usernameNoSpace = post.user.replaceAll(' ', '');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: primaryAccent.withOpacity(0.2), 
                  child: Text(post.category.isNotEmpty ? post.category[0] : 'G', style: const TextStyle(color: primaryAccent, fontWeight: FontWeight.bold, fontSize: 10))
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('#${post.category}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(' • ', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                      Text('u/$usernameNoSpace', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                      Text(' • ', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                      Text(post.time, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, size: 20, color: isDark ? Colors.white54 : Colors.black54)
              ]
            ),
            const SizedBox(height: 12),
            
            if (post.location != null && post.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(post.location!, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ]
                )
              ),
              
            onParseTags(post.body),
            
            if (post.media != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage('https://picsum.photos/600/300'), 
                    fit: BoxFit.cover,
                  )
                ),
              ),
              
            const SizedBox(height: 12),
            
            Row(children: [
              _UpvoteDownvote(
                score: post.score, 
                userVote: post.userVote, 
                onUpvote: onUpvote, 
                onDownvote: onDownvote,
                formatNum: _formatNumber
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.chat_bubble_outline, 
                label: _formatNumber(post.comments),
              ),
              const SizedBox(width: 8),
              const _ActionButton(icon: Icons.share_outlined, label: 'Share'),
            ]),
          ]
        )
      )
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF272729) : Colors.grey.shade200, 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white70 : Colors.black87),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87
          ))
        ],
      ),
    );
  }
}

class _UpvoteDownvote extends StatelessWidget {
  final int score;
  final int userVote;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final String Function(int) formatNum;

  const _UpvoteDownvote({required this.score, required this.userVote, required this.onUpvote, required this.onDownvote, required this.formatNum});

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = isDark ? Colors.white70 : Colors.black87;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF272729) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_upward, size: 18, color: userVote == 1 ? Colors.deepOrange : defaultIconColor),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onPressed: onUpvote,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(formatNum(score), key: ValueKey(score),
              style: TextStyle(
                fontSize: 12,
                color: userVote == 1 ? Colors.deepOrange : (userVote == -1 ? Colors.deepPurple : defaultIconColor),
                fontWeight: FontWeight.w800)),
          ),
          IconButton(
            icon: Icon(Icons.arrow_downward, size: 18, color: userVote == -1 ? Colors.deepPurple : defaultIconColor),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onPressed: onDownvote,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// COMPOSE BOX 
// ══════════════════════════════════════════════════════════════
class _AnimatedCompose extends StatelessWidget {
  final AppUser user; final AnimationController controller; final Animation<double> animation;
  final TextEditingController postCtrl; final TextEditingController locCtrl; 
  final bool expanded;
  final String selectedCategory; final List<String> categories;
  final String? attachedImage;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onTap, onPost, onCancel, onAttachMedia, onRemoveMedia;
  
  const _AnimatedCompose({
    required this.user, required this.controller, required this.animation,
    required this.postCtrl, required this.locCtrl, required this.expanded,
    required this.selectedCategory, required this.categories,
    required this.attachedImage, required this.onCategoryChanged,
    required this.onTap, required this.onPost, required this.onCancel,
    required this.onAttachMedia, required this.onRemoveMedia,
  });

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: expanded ? null : onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            CircleAvatar(backgroundColor: primaryAccent, child: Text(user.avatar)),
            const SizedBox(width: 10),
            Expanded(child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: expanded
                ? TextField(
                    key: const ValueKey('exp'), controller: postCtrl, maxLines: 3, autofocus: true,
                    decoration: const InputDecoration(hintText: 'Create a post...', border: InputBorder.none))
                : Container(
                    key: const ValueKey('col'), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF272729) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4), 
                      border: Border.all(color: Colors.grey.withOpacity(0.2))
                    ),
                    child: Text("Create Post", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14))),
            )),
          ]),
          
          SizeTransition(
            sizeFactor: animation, axisAlignment: -1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              
              if (attachedImage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.image, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(child: Text(attachedImage!, style: const TextStyle(fontSize: 12))),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: onRemoveMedia,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ]
                  )
                ),

              TextField(
                controller: locCtrl,
                decoration: InputDecoration(
                  hintText: 'Add location (e.g., Ward 4)', 
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                )
              ),
              const SizedBox(height: 12),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isDense: true,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                          items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                          onChanged: onCategoryChanged,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.image_outlined, color: Colors.teal),
                      onPressed: onAttachMedia,
                      tooltip: 'Attach Image',
                    ),
                  ],
                ),
                Row(children: [
                  TextButton(onPressed: onCancel, child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                  ElevatedButton(
                    onPressed: onPost, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ), 
                    child: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ),
                ]),
              ]),
            ]),
          ),
        ])),
      ),
    );
  }
}

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
