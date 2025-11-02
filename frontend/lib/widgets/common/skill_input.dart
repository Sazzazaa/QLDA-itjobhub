import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'skill_tag.dart';

/// Skill Input
/// 
/// An autocomplete input for adding skills with suggestions
/// 
/// Example:
/// ```dart
/// SkillInput(
///   selectedSkills: _skills,
///   onSkillsChanged: (skills) => setState(() => _skills = skills),
///   suggestions: ['Flutter', 'Dart', 'Firebase', 'React'],
/// )
/// ```
class SkillInput extends StatefulWidget {
  final List<String> selectedSkills;
  final ValueChanged<List<String>> onSkillsChanged;
  final List<String>? suggestions;
  final Future<List<String>> Function(String)? onSearchSkills;
  final String? label;
  final String? hint;
  final int? maxSkills;
  final bool enabled;

  const SkillInput({
    super.key,
    required this.selectedSkills,
    required this.onSkillsChanged,
    this.suggestions,
    this.onSearchSkills,
    this.label,
    this.hint,
    this.maxSkills,
    this.enabled = true,
  });

  @override
  State<SkillInput> createState() => _SkillInputState();
}

class _SkillInputState extends State<SkillInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _filteredSuggestions = [];
      });
      return;
    }

    // Filter suggestions based on input
    final query = value.toLowerCase();
    final filtered = (widget.suggestions ?? [])
        .where((skill) =>
            skill.toLowerCase().contains(query) &&
            !widget.selectedSkills.contains(skill))
        .toList();

    setState(() {
      _filteredSuggestions = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });

    // Call async search if provided
    if (widget.onSearchSkills != null) {
      widget.onSearchSkills!(value).then((results) {
        if (_controller.text == value) {
          setState(() {
            _filteredSuggestions = results
                .where((skill) => !widget.selectedSkills.contains(skill))
                .toList();
            _showSuggestions = _filteredSuggestions.isNotEmpty;
          });
        }
      });
    }
  }

  void _addSkill(String skill) {
    if (skill.isEmpty) return;
    if (widget.selectedSkills.contains(skill)) return;
    if (widget.maxSkills != null &&
        widget.selectedSkills.length >= widget.maxSkills!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxSkills} skills allowed'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final updatedSkills = [...widget.selectedSkills, skill];
    widget.onSkillsChanged(updatedSkills);
    _controller.clear();
    setState(() {
      _showSuggestions = false;
      _filteredSuggestions = [];
    });
    _focusNode.unfocus();
  }

  void _removeSkill(String skill) {
    final updatedSkills = widget.selectedSkills.where((s) => s != skill).toList();
    widget.onSkillsChanged(updatedSkills);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
        ],

        // Selected skills
        if (widget.selectedSkills.isNotEmpty) ...[
          Wrap(
            spacing: AppSizes.spacingS,
            runSpacing: AppSizes.spacingS,
            children: widget.selectedSkills
                .map((skill) => SkillTag(
                      label: skill,
                      onDelete: widget.enabled ? () => _removeSkill(skill) : null,
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSizes.spacingM),
        ],

        // Input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Type a skill...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: _onTextChanged,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addSkill(value.trim());
            }
          },
          textInputAction: TextInputAction.done,
        ),

        // Suggestions dropdown
        if (_showSuggestions && _filteredSuggestions.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacingS),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.1).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
              itemCount: _filteredSuggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final skill = _filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    skill,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () => _addSkill(skill),
                );
              },
            ),
          ),
        ],

        // Helper text
        if (widget.maxSkills != null) ...[
          const SizedBox(height: AppSizes.spacingS),
          Text(
            '${widget.selectedSkills.length}/${widget.maxSkills} skills',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Simple Skill Picker
/// 
/// A simpler version with predefined skills only
class SimpleSkillPicker extends StatelessWidget {
  final List<String> availableSkills;
  final List<String> selectedSkills;
  final ValueChanged<List<String>> onSkillsChanged;
  final String? label;

  const SimpleSkillPicker({
    super.key,
    required this.availableSkills,
    required this.selectedSkills,
    required this.onSkillsChanged,
    this.label,
  });

  void _toggleSkill(String skill) {
    final isSelected = selectedSkills.contains(skill);
    final updated = isSelected
        ? selectedSkills.where((s) => s != skill).toList()
        : [...selectedSkills, skill];
    onSkillsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
        ],
        Wrap(
          spacing: AppSizes.spacingS,
          runSpacing: AppSizes.spacingS,
          children: availableSkills
              .map((skill) => SkillTag(
                    label: skill,
                    isSelected: selectedSkills.contains(skill),
                    onTap: () => _toggleSkill(skill),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
