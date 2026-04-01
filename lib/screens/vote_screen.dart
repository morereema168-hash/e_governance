import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});
  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final Map<String, List<Map<String, dynamic>>> picks = {
    'mega': [],
    'major': [],
    'smart': [],
  };
  int step = 0;
  bool done = false;
  bool encrypting = false;

  static const cityBudget = 300000000;
  static const ords = ['1st', '2nd', '3rd'];

  void toggle(String tid, String pid, int max) {
    setState(() {
      final cur = picks[tid]!;
      final idx = cur.indexWhere((p) => p['id'] == pid);
      if (idx >= 0) {
        cur.removeAt(idx);
        for (var i = 0; i < cur.length; i++) cur[i]['rank'] = i + 1;
      } else if (cur.length < max) {
        cur.add({'id': pid, 'rank': cur.length + 1});
      }
    });
  }

  int get totalAlloc {
    int t = 0;
    for (final tier in TIERS) {
      for (final p in picks[tier.id]!) {
        final proj = tier.projects.firstWhere((x) => x.id == p['id']);
        t += proj.budget;
      }
    }
    return t;
  }

  int get totalPickCount => picks.values.fold(0, (a, v) => a + v.length);

  void submit() async {
    setState(() => encrypting = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    setState(() {
      encrypting = false;
      done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (done) return _doneScreen();
    if (step == 0) return _introScreen();
    if (step >= 1 && step <= 3) return _tierScreen(TIERS[step - 1]);
    return _reviewScreen();
  }

  // ── DONE SCREEN ──
  Widget _doneScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          // Success header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 30, 18, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.green, Color(0xFF15803D)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Center(
                    child: Text('🔐', style: TextStyle(fontSize: 42)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ballot Submitted!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Encrypted · Anonymous · Blockchain-secured',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ballot ID: #VT-${DateTime.now().millisecondsSinceEpoch % 99999}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    _doneStatCard(
                      'Picks Made',
                      '$totalPickCount',
                      AppColors.orange,
                    ),
                    const SizedBox(width: 10),
                    _doneStatCard(
                      'Budget Covered',
                      fmtCr(totalAlloc),
                      AppColors.blue,
                    ),
                    const SizedBox(width: 10),
                    _doneStatCard(
                      'Tiers Voted',
                      '${picks.values.where((v) => v.isNotEmpty).length}/3',
                      AppColors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  'Your Ranked Priorities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 10),

                for (final t in TIERS) ...[
                  if (picks[t.id]!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: t.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: t.color,
                              letterSpacing: 0.7,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final pk in [
                      ...picks[t.id]!,
                    ]..sort((a, b) => a['rank'] - b['rank']))
                      Builder(
                        builder: (ctx) {
                          final proj = t.projects.firstWhere(
                            (x) => x.id == pk['id'],
                          );
                          return AppCard(
                            borderColor: t.color.withOpacity(0.3),
                            padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: t.color,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        t.color,
                                        t.color.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${pk['rank']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(proj.icon, color: proj.color, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        proj.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                      Text(
                                        '${ords[pk['rank'] - 1]} Priority · ${fmtCr(proj.budget)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.grey,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ],

                const SizedBox(height: 8),
                // What happens next
                AppCard(
                  bgColor: const Color(0xFFEEF2FF),
                  borderColor: const Color(0xFFC7D2FE),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What Happens Next?',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.blue,
                          fontSize: 14,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final step in [
                        [
                          '🗳️',
                          'Your vote joins the encrypted tally — no one can see it individually',
                        ],
                        [
                          '📊',
                          'Results published after voting closes on Dec 31',
                        ],
                        [
                          '🏗️',
                          'Top-ranked projects get priority in next FY budget',
                        ],
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                step[0],
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step[1],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doneStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.grey,
                fontFamily: 'Nunito',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── INTRO SCREEN ──
  Widget _introScreen() {
    final isWide = MediaQuery.of(context).size.width > 700;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          // Header
          ParticleBackground(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), AppColors.navyLight],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RANKED CHOICE VOTING',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFB923C),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Shape Rampur\'s Future',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Rank your preferred projects — your 1st pick carries most weight',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontFamily: 'Nunito',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TIERS
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                Text(
                                  '${t.sub} · Pick ${t.maxPick}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(isWide ? 24 : 14),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _introMain()),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: _introSidebar()),
                    ],
                  )
                : _introMain(),
          ),
        ],
      ),
    );
  }

  Widget _introMain() {
    return Column(
      children: [
        // How it works
        AppCard(
          bgColor: const Color(0xFFEEF2FF),
          borderColor: const Color(0xFFC7D2FE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'How Ranked Choice Works',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.blue,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.orange, AppColors.orangeDark],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          [
                            '1st pick = highest weight (3 pts)',
                            '2nd pick = medium weight (2 pts)',
                            '3rd pick = support weight (1 pt)',
                          ][i],
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Tier cards
        for (final t in TIERS)
          AppCard(
            borderColor: t.color.withOpacity(0.3),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coloured top strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [t.color, t.color.withOpacity(0.75)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Colors.white,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${t.projects.length} options · Pick ${t.maxPick}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.sub,
                        style: TextStyle(
                          fontSize: 12,
                          color: t.color,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.hint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.greyDark,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Project preview chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: t.projects
                            .map(
                              (p) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: p.color.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: p.color.withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(p.icon, size: 12, color: p.color),
                                    const SizedBox(width: 4),
                                    Text(
                                      p.cat,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: p.color,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Budget card
        AppCard(
          bgColor: AppColors.navy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL CITY BUDGET · FY 2025-26',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFFB923C),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '₹30 Crore',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your votes determine budget allocation priority for the year.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final t in TIERS)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: t.id != 'smart' ? 8 : 0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            color: t.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                t.sub,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: t.color,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              Text(
                                t.label.split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white60,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        AppBtn(
          label: 'Start Voting →',
          full: true,
          onTap: () => setState(() => step = 1),
        ),
      ],
    );
  }

  Widget _introSidebar() {
    return Column(
      children: [
        // Voting deadline
        AppCard(
          bgColor: AppColors.redLight,
          borderColor: AppColors.red.withOpacity(0.3),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.red, size: 26),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voting Closes',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.red,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      'December 31, 2025 · 11:59 PM',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyDark,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Participation stats
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Participation So Far',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 12),
              for (final row in [
                ['Votes Cast', '1,248', AppColors.orange],
                ['Eligible Voters', '4,500', AppColors.navy],
                ['Turnout', '27.7%', AppColors.green],
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        row[0] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Text(
                        row[1] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: row[2] as Color,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              AnimatedBar(value: 27.7, color: AppColors.orange, height: 7),
              const SizedBox(height: 4),
              const Text(
                '27.7% participation · goal: 50%',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.grey,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),

        // Top voted projects preview
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Currently Leading',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Based on votes so far',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 12),
              for (final item in [
                [TIERS[0].projects[0], TIERS[0].color, '68%'],
                [TIERS[1].projects[1], TIERS[1].color, '54%'],
                [TIERS[2].projects[2], TIERS[2].color, '61%'],
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (item[1] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          (item[0] as VoteProject).icon,
                          size: 14,
                          color: item[1] as Color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item[0] as VoteProject).title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedBar(
                              value: double.parse(
                                (item[2] as String).replaceAll('%', ''),
                              ),
                              color: item[1] as Color,
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item[2] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: item[1] as Color,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── TIER SCREEN ──
  Widget _tierScreen(VoteTier tier) {
    final tp = picks[tier.id]!;
    final isWide = MediaQuery.of(context).size.width > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // Tier header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tier.color, tier.color.withOpacity(0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STEP $step OF 3 · RANKED CHOICE',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        letterSpacing: 1,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    // Step dots
                    Row(
                      children: List.generate(
                        3,
                        (n) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: n + 1 == step ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: n < step
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            boxShadow: n + 1 == step
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tier.label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tier.hint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 14),
                // Slot indicators
                Row(
                  children: List.generate(
                    tier.maxPick,
                    (i) => Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.only(
                          right: i < tier.maxPick - 1 ? 5 : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i < tp.length
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${tp.length}/${tier.maxPick} selected'
                  '${tp.isEmpty
                      ? ' · Tap a project to rank it'
                      : tp.length < tier.maxPick
                      ? ' · Tap another to add'
                      : ' · All slots filled'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              isWide ? 24 : 14,
              14,
              isWide ? 24 : 14,
              0,
            ),
            child: Column(
              children: [
                // Selected summary strip
                if (tp.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: tier.color.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: tier.color.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.how_to_vote_outlined,
                          size: 16,
                          color: AppColors.greyDark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: ${tp.map((pk) {
                              final proj = tier.projects.firstWhere((x) => x.id == pk['id']);
                              return '${ords[pk['rank'] - 1]}: ${proj.title.split(' ').take(3).join(' ')}…';
                            }).join(' | ')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.dark,
                              fontFamily: 'Nunito',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Project cards
                isWide
                    ? GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio:
                            MediaQuery.of(context).size.width / 320,
                        children: tier.projects
                            .map((p) => _projectCard(p, tier, tp))
                            .toList(),
                      )
                    : Column(
                        children: tier.projects
                            .map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _projectCard(p, tier, tp),
                              ),
                            )
                            .toList(),
                      ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppBtn(
                        label: '← Back',
                        outline: true,
                        color: AppColors.navy,
                        onTap: () => setState(() => step--),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: AppBtn(
                        label: step == 3 ? 'Review Ballot →' : 'Next →',
                        color: tier.color,
                        disabled: tp.isEmpty,
                        onTap: tp.isEmpty ? null : () => setState(() => step++),
                      ),
                    ),
                  ],
                ),
                if (tp.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Select at least 1 to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _projectCard(
    VoteProject p,
    VoteTier tier,
    List<Map<String, dynamic>> tp,
  ) {
    final pick = tp.firstWhere((pk) => pk['id'] == p.id, orElse: () => {});
    final ranked = pick.isNotEmpty;
    final full = tp.length >= tier.maxPick && !ranked;

    return AnimatedScale(
      scale: ranked ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Opacity(
        opacity: full ? 0.45 : 1,
        child: GestureDetector(
          onTap: full ? null : () => toggle(tier.id, p.id, tier.maxPick),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ranked ? p.color.withOpacity(0.8) : AppColors.border,
                width: ranked ? 2 : 1,
              ),
              boxShadow: ranked
                  ? [
                      BoxShadow(
                        color: p.color.withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: ranked
                      ? p.color.withOpacity(0.08)
                      : Colors.white.withOpacity(0.7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rank banner
                      if (ranked)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [p.color, p.color.withOpacity(0.7)],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${ords[pick['rank'] - 1]} Priority',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              const Text(
                                'tap to remove',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon box with rank badge
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: ranked
                                            ? p.color.withOpacity(0.15)
                                            : AppColors.bg,
                                        border: Border.all(
                                          color: ranked
                                              ? p.color
                                              : AppColors.border,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        p.icon,
                                        size: 28,
                                        color: ranked
                                            ? p.color
                                            : AppColors.grey,
                                      ),
                                    ),
                                    if (ranked)
                                      Positioned(
                                        top: -8,
                                        right: -8,
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0, end: 1),
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.elasticOut,
                                          builder: (_, v, __) =>
                                              Transform.scale(
                                                scale: v,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            AppColors.orange,
                                                            AppColors
                                                                .orangeDark,
                                                          ],
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.orange
                                                            .withOpacity(0.4),
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${pick['rank']}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13,
                                                color: ranked
                                                    ? p.color
                                                    : AppColors.dark,
                                                fontFamily: 'Nunito',
                                              ),
                                            ),
                                          ),
                                          AppChip(
                                            label: p.cat,
                                            color: p.color,
                                            small: true,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        p.desc,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.grey,
                                          fontFamily: 'Nunito',
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ranked
                                        ? p.color.withOpacity(0.12)
                                        : AppColors.bg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 12,
                                        color: ranked
                                            ? p.color
                                            : AppColors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        fmtCr(p.budget),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: ranked
                                              ? p.color
                                              : AppColors.dark,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!ranked && !full)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.touch_app_outlined,
                                        size: 14,
                                        color: tier.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tap to rank',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: tier.color,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ],
                                  ),
                                if (full)
                                  const Text(
                                    'Slots full',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── REVIEW SCREEN ──
  Widget _reviewScreen() {
    final isWide = MediaQuery.of(context).size.width > 700;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          PageHeader(
            tag: 'REVIEW YOUR BALLOT',
            title: 'Your Ranked Choices',
            sub: 'Review carefully — changes can\'t be made after submitting',
            bottom: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR SELECTION',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        fmtCr(totalAlloc),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const Text(
                        ' allocated',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBar(
                    value: (totalAlloc / cityBudget * 100).clamp(0, 100),
                    color: AppColors.orange,
                    height: 7,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'of ₹30 Cr total budget',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Text(
                        '${totalPickCount} picks across ${picks.values.where((v) => v.isNotEmpty).length} tiers',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white60,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(isWide ? 24 : 14),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _reviewMain()),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: _reviewSidebar()),
                    ],
                  )
                : _reviewMain(),
          ),
        ],
      ),
    );
  }

  Widget _reviewMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blockchain badge
        AppCard(
          bgColor: const Color(0xFFEEF2FF),
          borderColor: const Color(0xFFC7D2FE),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock, color: AppColors.blue, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blockchain-secured ballot',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.blue,
                        fontSize: 13,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      'End-to-end encrypted · Anonymous · Tamper-proof',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4B5563),
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Per tier
        for (final t in TIERS) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: t.color,
                      letterSpacing: 0.7,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => setState(() => step = TIERS.indexOf(t) + 1),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          if (picks[t.id]!.isEmpty)
            AppCard(
              bgColor: AppColors.bg,
              borderColor: t.color.withOpacity(0.3),
              borderWidth: 1.5,
              child: Center(
                child: Text(
                  'No ${t.label} selected · Optional',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          for (final pk in [
            ...picks[t.id]!,
          ]..sort((a, b) => a['rank'] - b['rank']))
            Builder(
              builder: (ctx) {
                final proj = t.projects.firstWhere((x) => x.id == pk['id']);
                return AppCard(
                  borderColor: t.color.withOpacity(0.3),
                  padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 56,
                        decoration: BoxDecoration(
                          color: t.color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [t.color, t.color.withOpacity(0.5)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${pk['rank']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(proj.icon, color: proj.color, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              proj.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            Text(
                              '${['1st', '2nd', '3rd'][pk['rank'] - 1]} · ${fmtCr(proj.budget)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],

        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppBtn(
                label: '← Edit',
                outline: true,
                color: AppColors.navy,
                onTap: () => setState(() => step = 3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: AppBtn(
                label: encrypting ? 'Encrypting…' : '🔐  Submit Ballot',
                color: AppColors.green,
                disabled: encrypting,
                onTap: submit,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewSidebar() {
    return Column(
      children: [
        // Budget summary
        AppCard(
          bgColor: AppColors.orangeLight,
          borderColor: AppColors.orange.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budget Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 12),
              for (final t in TIERS) ...[
                Builder(
                  builder: (ctx) {
                    final alloc = picks[t.id]!.fold(0, (a, p) {
                      final proj = t.projects.firstWhere(
                        (x) => x.id == p['id'],
                      );
                      return a + proj.budget;
                    });
                    if (alloc == 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: t.color,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.label,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyDark,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                fmtCr(alloc),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: t.color,
                                  fontSize: 13,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          AnimatedBar(
                            value: (alloc / cityBudget * 100).clamp(0, 100),
                            color: t.color,
                            height: 5,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const Divider(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: BudgetArcVisualizer(
                    percentage: (totalAlloc / cityBudget * 100)
                        .clamp(0, 100)
                        .toDouble(),
                    color: AppColors.orange,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Selected',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  Text(
                    fmtCr(totalAlloc),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${(totalAlloc / cityBudget * 100).round()}% of total budget',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),

        // Submission reminder
        AppCard(
          bgColor: AppColors.greenLight,
          borderColor: AppColors.green.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Before You Submit',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.green,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 10),
              for (final item in [
                'You can only vote once',
                'Ballot cannot be changed after submission',
                'Results published December 31',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ParticleBackground extends StatefulWidget {
  final Widget child;
  const ParticleBackground({Key? key, required this.child}) : super(key: key);
  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 15),
  )..repeat();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (ctx, _) => CustomPaint(
      painter: _ParticlePainter(_ctrl.value),
      child: widget.child,
    ),
  );
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFB923C).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final rPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final rnd = math.Random(1234);
    for (int i = 0; i < 40; i++) {
      final x = rnd.nextDouble() * size.width;
      final yOffset = rnd.nextDouble() * size.height;
      final speed = 0.1 + rnd.nextDouble() * 0.9;
      final y = (yOffset - (progress * size.height * speed)) % size.height;
      final r = 0.5 + rnd.nextDouble() * 2.5;
      final p = rnd.nextBool() ? paint : rPaint;

      canvas.drawCircle(
        Offset(x, y),
        r,
        p..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class BudgetArcVisualizer extends StatelessWidget {
  final double percentage;
  final Color color;
  const BudgetArcVisualizer({
    Key? key,
    required this.percentage,
    required this.color,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) => SizedBox(
        height: 100,
        child: CustomPaint(painter: _ArcPainter(val, color)),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double percent;
  final Color color;
  _ArcPainter(this.percent, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.height - 20;
    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    final sweepAngle = math.pi * (percent / 100).clamp(0.0, 1.0);
    if (sweepAngle > 0) {
      fgPaint.shader = SweepGradient(
        center: Alignment.bottomCenter,
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: [color.withOpacity(0.4), color, Colors.white],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        sweepAngle,
        false,
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 24
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        sweepAngle,
        false,
        fgPaint,
      );
    }

    // Draw text in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${percent.round()}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 24,
          fontFamily: 'Nunito',
          shadows: [
            Shadow(
              color: color.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 - 10,
      ),
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.percent != percent || old.color != color;
}
