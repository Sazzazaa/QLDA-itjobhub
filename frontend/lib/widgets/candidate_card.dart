import 'package:flutter/material.dart';
import '../models/candidate.dart';

class CandidateCard extends StatelessWidget {
  final Candidate candidate;

  const CandidateCard({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            candidate.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800),
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : Container(color: Colors.grey.shade700),
          ),
          // gradient overlay bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _Info(candidate: candidate),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final Candidate candidate;
  const _Info({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${candidate.name} • ${candidate.title}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${candidate.years} yrs • ${candidate.location} • \$${candidate.expectedSalary}/mo',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: candidate.skills.take(5).map((s) => _chip(s)).toList(),
        ),
      ],
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      );
}
