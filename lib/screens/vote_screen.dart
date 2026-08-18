import 'package:flutter/material.dart';
import '../theme.dart'; // ADDED: Import theme to access AppColors

class MockMultiPoll {
  final String id;
  final String author;
  final String time;
  final String question;
  final List<String> options;
  final List<int> votes;
  final Set<int> selectedOptions; // Stores multiple selections
  bool isSubmitted; // Tracks if the user has finalized their vote

  MockMultiPoll({
    required this.id,
    required this.author,
    required this.time,
    required this.question,
    required this.options,
    required this.votes,
    required this.selectedOptions,
    this.isSubmitted = false,
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
      
      // Prevent changing selection if the poll is already submitted
      if (poll.isSubmitted) return;

      if (poll.selectedOptions.contains(optionIndex)) {
        poll.selectedOptions.remove(optionIndex);
        poll.votes[optionIndex]--;
      } else {
        poll.selectedOptions.add(optionIndex);
        poll.votes[optionIndex]++;
      }
    });
  }

  void _submitVote(int pollIndex) {
    setState(() {
      polls[pollIndex].isSubmitted = true;
    });
    
    // Optional: Show a quick confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your vote has been submitted successfully!', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER - Using a robust Container with DecorationImage
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fist.jpeg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            child: Container(
              // Dark/Navy Overlay ensuring readability while letting the image peek through
              color: AppColors.navy.withOpacity(0.75), 
              // INCREASED PADDING HERE: Top went from 48 to 72, Bottom went from 24 to 40
              padding: const EdgeInsets.fromLTRB(20, 72, 20, 40),
              width: double.infinity,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MAHAD NAGAR PANCHAYAT',
                    style: TextStyle(
                      fontSize: 10, 
                      color: Color(0xFFFB923C), // AppColors.orange brightened
                      fontWeight: FontWeight.w800, 
                      letterSpacing: 1,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Civic Polls',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Vote on multiple issues that matter to Mahad. You can select more than one option per poll.',
                    style: TextStyle(
                      fontSize: 13, 
                      color: Colors.white70, 
                      height: 1.4,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
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
    
    // Calculate total votes for this poll to show the bottom tally
    final totalVotes = poll.votes.fold(0, (sum, count) => sum + count);

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
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
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.poll_outlined, size: 16, color: AppColors.orange),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poll.author, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
                      Text(poll.time, style: const TextStyle(fontSize: 11, color: AppColors.grey, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Multi-Select', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.navy, fontFamily: 'Nunito')),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            // Question
            Text(
              poll.question,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, height: 1.3, fontFamily: 'Nunito'),
            ),
            const SizedBox(height: 16),

            // Options (Exactly 4)
            ...List.generate(4, (optionIndex) {
              final isSelected = poll.selectedOptions.contains(optionIndex);

              return GestureDetector(
                onTap: () => _toggleVote(pollIndex, optionIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    // Fills the container with a soft orange tint when selected
                    color: isSelected ? AppColors.orange.withOpacity(0.15) : (isDark ? Colors.grey.shade900 : Colors.transparent), 
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.orange : AppColors.border,
                      width: isSelected ? 2.0 : 1.0, 
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        // Checkbox
                        Icon(
                          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 18,
                          color: isSelected ? AppColors.orange : AppColors.grey,
                        ),
                        const SizedBox(width: 10),
                        
                        // Option Text
                        Expanded(
                          child: Text(
                            poll.options[optionIndex],
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Nunito',
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.orange : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 8),
            
            // Tally and Submit Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalVotes total votes',
                  style: const TextStyle(fontSize: 11, color: AppColors.grey, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                ),
                
                // Done / Submit Button
                ElevatedButton(
                  onPressed: (poll.selectedOptions.isEmpty || poll.isSubmitted) 
                      ? null 
                      : () => _submitVote(pollIndex),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    poll.isSubmitted ? 'Submitted ✓' : 'Submit Vote',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'Nunito'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}