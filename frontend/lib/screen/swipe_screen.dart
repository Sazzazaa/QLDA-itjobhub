import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../widgets/candidate_card.dart';
import '../widgets/swipe_deck.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final SwipeDeckController<Candidate> _controller = SwipeDeckController<Candidate>();
  late List<Candidate> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = Candidate.samples();
  }

  void _onEnd() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã hết hồ sơ. Kéo để tải thêm...')),
    );
  }

  Candidate? _topCandidate() => _controller.current;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Coder • HR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Bộ lọc',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Bộ lọc (demo)'),
                  content: const Text('Thêm màn hình lọc và API sau.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0B1220),
              const Color(0xFF111A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _candidates.isEmpty
                ? const Center(child: Text('Không có ứng viên'))
                : SwipeDeck<Candidate>(
                    items: _candidates,
                    controller: _controller,
                    itemBuilder: (c, _) => CandidateCard(candidate: c),
                    onSwipe: (c, res) {
                      // TODO: send like/dislike to backend and check for match
                      debugPrint('HR ${res == SwipeResult.like ? 'AGREE' : 'PASS'} -> ${c.name}');
                    },
                    onEmpty: _onEnd,
                  ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _round(
                color: Colors.red,
                icon: Icons.close,
                onTap: _controller.swipeLeft,
              ),
              _round(
                color: Colors.blue,
                icon: Icons.info_outline,
                onTap: () {
                  final c = _topCandidate();
                  if (c == null) return;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => _CandidateDetail(candidate: c),
                  );
                },
              ),
              _round(
                color: Colors.green,
                icon: Icons.favorite,
                onTap: _controller.swipeRight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _round({required Color color, required IconData icon, required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 34,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}

class _CandidateDetail extends StatelessWidget {
  final Candidate candidate;
  const _CandidateDetail({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundImage: NetworkImage(candidate.avatarUrl), radius: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(candidate.name, style: Theme.of(context).textTheme.titleLarge),
                        Text(candidate.title, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: candidate.skills
                    .map((s) => Chip(label: Text(s), avatar: const Icon(Icons.code, size: 16)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 6),
                  Text(candidate.location),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.payments_outlined),
                  const SizedBox(width: 6),
                  Text('Mong muốn: \$${candidate.expectedSalary}/mo'),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  // TODO: mở viewer CV
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Xem CV'),
              ),
            ],
          ),
        );
      },
    );
  }
}
