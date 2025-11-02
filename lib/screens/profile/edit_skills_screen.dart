import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/skill_input.dart';

/// Edit Skills Screen
/// 
/// Interface to manage user skills
class EditSkillsScreen extends StatefulWidget {
  final List<String> initialSkills;
  
  const EditSkillsScreen({
    super.key,
    required this.initialSkills,
  });

  @override
  State<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends State<EditSkillsScreen> {
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.initialSkills);
  }

  void _saveSkills() {
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one skill'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    Navigator.pop(context, _skills);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Skills'),
        actions: [
          TextButton(
            onPressed: _saveSkills,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    Expanded(
                      child: Text(
                        'Add Your Skills',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingM),
                Text(
                  'List your technical and soft skills. This helps match you with relevant job opportunities.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingXL),

          // Skills Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Skills',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _skills.isEmpty
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_skills.length} ${_skills.length == 1 ? 'skill' : 'skills'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _skills.isEmpty
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),

          // Skill Input Component
          SkillInput(
            selectedSkills: _skills,
            onSkillsChanged: (skills) {
              setState(() {
                _skills = skills;
              });
            },
            maxSkills: 30,
            hint: 'Type a skill and press enter',
          ),
          const SizedBox(height: AppSizes.spacingXL),

          // Suggestions Section (Optional)
          if (_skills.isEmpty) ...[
            Text(
              'Popular Skills',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getPopularSkills().map((skill) {
                return ActionChip(
                  label: Text(skill),
                  avatar: const Icon(Icons.add, size: 16),
                  onPressed: () {
                    setState(() {
                      if (!_skills.contains(skill)) {
                        _skills.add(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.spacingL),
          ],

          // Tips Section
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tips for Adding Skills',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingM),
                _buildTip('Include both technical and soft skills'),
                _buildTip('Be specific (e.g., "React.js" not just "JavaScript")'),
                _buildTip('Add skills relevant to your target jobs'),
                _buildTip('Keep your list updated with new skills'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getPopularSkills() {
    return [
      'Flutter',
      'React',
      'Node.js',
      'Python',
      'Java',
      'JavaScript',
      'TypeScript',
      'SQL',
      'Git',
      'Docker',
      'AWS',
      'Agile',
    ];
  }
}
