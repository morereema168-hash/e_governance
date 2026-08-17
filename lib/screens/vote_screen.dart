import 'package:flutter/material.dart';

const Color primaryAccent = Color(0xFF2563EB);

class MockMultiPoll {
  final String id;
  final String author;
  final String time;
  final String question;
  final List<String> options;
  final List<int> votes;
  final Set<int> selectedOptions; // Stores multiple selections

  MockMultiPoll({
    required this.id,
    required this.author,
    required this.time,
    required this.question,
    required this.options,
    required this.votes,
    required this.selectedOptions,
  });
}

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> with TickerProviderStateMixin {
  
  // Mahad-specific mock polls, exactly 4 options each
  final List<MockMultiPoll> polls = [
    MockMultiPoll(
      id: 'p1',
      author: 'Mahad Nagar Panchayat',
      time: '2h ago',
      question: 'Which civic facilities require immediate upgrade in your ward? (Select all that apply)',
      options: ['Underground Drainage', 'Street Lighting', 'Public Parks', 'Road Resurfacing'],
      votes: [142, 89, 45, 210],
      selectedOptions: {},
    ),
    MockMultiPoll(
      id: 'p2',
      author: 'Waste Management Dept',
      time: '5h ago',
      question: 'What are your preferred timings for daily garbage collection?',
      options: ['Early Morning (6 AM - 8 AM)', 'Late Morning (9 AM - 11 AM)', 'Evening (5 PM - 7 PM)', 'Night (8 PM - 10 PM)'],
      votes: [310, 85, 120, 40],
      selectedOptions: {},
    ),
    MockMultiPoll(
      id: 'p3',
      author: 'City Planning Committee',
      time: '1d ago',
      question: 'Where should the new community health clinics be prioritized?',
      options: ['Ward 2', 'Ward 7', 'Ward 12', 'Ward 15'],
      votes: [56, 198, 77, 134],
      selectedOptions: {},
    ),
  ];

  void _toggleVote(int pollIndex, int optionIndex) {
    setState(() {
      final poll = polls[pollIndex];
      if (poll.selectedOptions.contains(optionIndex)) {
        poll.selectedOptions.remove(optionIndex);
        poll.votes[optionIndex]--;
      } else {
        poll.selectedOptions.add(optionIndex);
        poll.votes[optionIndex]++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MAHAD NAGAR PANCHAYAT',
                  style: TextStyle(fontSize: 10, color: primaryAccent, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
                const SizedBox(height: 6),
                Text(
                  'Civic Polls',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vote on multiple issues that matter to Mahad. You can select more than one option per poll.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),

          // POLLS FEED
          Padding(
            padding: EdgeInsets.all(isWide ? 24 : 14),
            child: isWide
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: polls.length,
                    itemBuilder: (context, index) => _buildPollCard(index),
                  )
                : Column(
                    children: List.generate(polls.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPollCard(index),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard(int pollIndex) {
    final poll = polls[pollIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate total votes for this poll to size the progress bars
    final totalVotes = poll.votes.fold(0, (sum, count) => sum + count);

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poll Header (Author & Time)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.poll_outlined, size: 16, color: primaryAccent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poll.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(poll.time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: primaryAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Multi-Select', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryAccent)),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            // Question
            Text(
              poll.question,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.3),
            ),
            const SizedBox(height: 16),

            // Options (Exactly 4)
            ...List.generate(4, (optionIndex) {
              final isSelected = poll.selectedOptions.contains(optionIndex);
              final voteCount = poll.votes[optionIndex];
              final percentage = totalVotes == 0 ? 0.0 : (voteCount / totalVotes);

              return GestureDetector(
                onTap: () => _toggleVote(pollIndex, optionIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryAccent.withOpacity(0.08) : (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? primaryAccent : Colors.grey.withOpacity(0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Progress Bar Background
                      if (poll.selectedOptions.isNotEmpty || totalVotes > 0)
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            // Checkbox
                            Icon(
                              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                              size: 18,
                              color: isSelected ? primaryAccent : Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            
                            // Option Text
                            Expanded(
                              child: Text(
                                poll.options[optionIndex],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? primaryAccent : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                            ),
                            
                            // Percentage / Vote Count
                            if (poll.selectedOptions.isNotEmpty || totalVotes > 0)
                              Text(
                                '${(percentage * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? primaryAccent : Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 8),
            Text(
              '$totalVotes total votes across all options',
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}