import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_anything/widgets/banner_ad_widget.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _appBar(context, ref),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _greetingCard(user),
                  const SizedBox(height: 28),
                  _sectionTitle('Start a new quiz'),
                  const SizedBox(height: 12),
                  _uploadCard(context),
                  const SizedBox(height: 28),
                  _sectionTitle('Quiz modes'),
                  const SizedBox(height: 12),
                  _modeGrid(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: BannerAdWidget(),
      ),
    );
  }

  Widget _appBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF0F0FF),
      elevation: 0,
      floating: true,
      pinned: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B74FF), Color(0xFF3B37C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Study Anything',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF1a1a2e),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E8F5), width: 1),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF6C63FF),
              size: 18,
            ),
          ),
          onPressed: () async {
            await ref.read(authProvider.notifier).signOut();
            if (context.mounted) context.go('/login');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1a1a2e),
      ),
    );
  }

  Widget _greetingCard(User? user) {
    final name =
        user?.displayName ?? user?.email?.split('@').first ?? 'Student';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B74FF), Color(0xFF3B37C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withAlpha(77),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withAlpha(77), width: 1),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name! 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ready to study today?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text('🔥', style: const TextStyle(fontSize: 16)),
                Text(
                  'Study',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/upload'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E8F5), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                size: 32,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload PDF & Start Test',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1a1a2e),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload any chapter or document and generate a smart quiz',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B74FF), Color(0xFF3B37C8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Get Started →',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeGrid() {
    final items = [
      _ModeItem(
        'MCQs',
        Icons.check_circle_outline_rounded,
        const Color(0xFF4CAF50),
        const Color(0xFFE8F5E9),
        '10 questions',
      ),
      _ModeItem(
        'Short Q',
        Icons.short_text_rounded,
        const Color(0xFF2196F3),
        const Color(0xFFE3F2FD),
        '5 questions',
      ),
      _ModeItem(
        'Long Q',
        Icons.article_outlined,
        const Color(0xFFFF9800),
        const Color(0xFFFFF3E0),
        '3 questions',
      ),
      _ModeItem(
        'Conceptual',
        Icons.lightbulb_outline_rounded,
        const Color(0xFF9C27B0),
        const Color(0xFFF3E5F5),
        '5 questions',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: items.map((item) => _modeCard(item)).toList(),
    );
  }

  Widget _modeCard(_ModeItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8F5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.bg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1a1a2e),
            ),
          ),
          Text(
            item.sub,
            style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _ModeItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String sub;
  const _ModeItem(this.label, this.icon, this.color, this.bg, this.sub);
}
