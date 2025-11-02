# Component Library Quick Start

A lightning-fast guide to start using the shared component library in your screens.

## 1. Import Components

Add this single import to any screen file:

```dart
import 'package:it_job_finder/widgets/common/index.dart';
```

## 2. Replace Common Patterns

### Empty States

**Old way:**
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.inbox, size: 60),
      SizedBox(height: 16),
      Text('No data'),
    ],
  ),
)
```

**New way:**
```dart
EmptyState(
  icon: Icons.inbox,
  title: 'No Jobs Found',
  message: 'Try adjusting your filters',
)
```

---

### Loading States

**Old way:**
```dart
Center(child: CircularProgressIndicator())
```

**New way:**
```dart
LoadingState(message: 'Loading jobs...')
```

---

### Error States

**Old way:**
```dart
Center(
  child: Text('Error occurred'),
)
```

**New way:**
```dart
ErrorState(
  message: 'Failed to load jobs',
  onRetry: _loadJobs,
)
```

---

### Buttons

**Old way:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Submit'),
)
```

**New way:**
```dart
PrimaryButton(
  label: 'Submit',
  onPressed: () {},
  isFullWidth: true,
)
```

---

### Status Badges

**Old way:**
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.green.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Approved', style: TextStyle(color: Colors.green)),
)
```

**New way:**
```dart
StatusChip.applicationStatus(ApplicationStatus.approved)
```

---

### Cards

**Old way:**
```dart
Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [...],
  ),
  child: Text('Content'),
)
```

**New way:**
```dart
CustomCard(
  child: Text('Content'),
)
```

---

### Text Inputs

**Old way:**
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(),
  ),
)
```

**New way:**
```dart
CustomInput(
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icons.email,
  controller: _emailController,
)
```

---

### Search Fields

**Old way:**
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Search',
    prefixIcon: Icon(Icons.search),
  ),
)
```

**New way:**
```dart
SearchInput(
  hint: 'Search jobs...',
  onChanged: (query) => _search(query),
)
```

---

## 3. Complete Screen Example

```dart
import 'package:flutter/material.dart';
import 'package:it_job_finder/widgets/common/index.dart';
import 'package:it_job_finder/core/constants/app_constants.dart';

class JobListScreen extends StatefulWidget {
  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  bool _isLoading = true;
  String? _error;
  List<Job> _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load jobs from API
      final jobs = await jobService.getJobs();
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jobs')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchInput(
              hint: 'Search jobs...',
              onChanged: (query) {
                // Handle search
              },
            ),
          ),

          // Filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SelectableChip(
                  label: 'Full-time',
                  isSelected: true,
                  onTap: () {},
                ),
                SizedBox(width: 8),
                SelectableChip(
                  label: 'Remote',
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadJobs,
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return LoadingState(message: 'Loading jobs...');
    }

    if (_error != null) {
      return ErrorState(
        message: _error!,
        onRetry: _loadJobs,
      );
    }

    if (_jobs.isEmpty) {
      return EmptyState(
        icon: Icons.work_off,
        title: 'No Jobs Found',
        message: 'Try adjusting your search filters',
        actionLabel: 'Reset Filters',
        onAction: () {
          // Reset filters
        },
      );
    }

    return ListView.builder(
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        final job = _jobs[index];
        return CustomCard(
          onTap: () {
            // Navigate to job details
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job title
              Text(
                job.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              
              // Company
              Text(
                job.company,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12),
              
              // Status chips
              Wrap(
                spacing: 8,
                children: [
                  StatusChip.jobType(job.type),
                  StatusChip.experienceLevel(job.level),
                ],
              ),
              SizedBox(height: 12),
              
              // Apply button
              PrimaryButton(
                label: 'Apply Now',
                icon: Icons.send,
                onPressed: () {
                  // Apply to job
                },
                isFullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## 4. Tips for Success

### ✅ DO
- Import from `widgets/common/index.dart`
- Use factory methods (e.g., `StatusChip.applicationStatus()`)
- Set `isFullWidth: true` for full-width buttons
- Use `const` when possible for better performance
- Check the README.md for all available properties

### ❌ DON'T
- Don't create custom widgets for things that already exist
- Don't hardcode colors - use `AppColors`
- Don't hardcode spacing - use `AppSizes`
- Don't wrap components unnecessarily
- Don't forget to handle loading and error states
- Don't confuse `AppTextButton` with Flutter's built-in `TextButton`

## 5. Common Combinations

### Filter Section
```dart
Wrap(
  spacing: 8,
  children: filters.map((filter) => 
    SelectableChip(
      label: filter.name,
      isSelected: filter.isSelected,
      onTap: () => _toggleFilter(filter),
    )
  ).toList(),
)
```

### Job Card
```dart
CustomCard(
  onTap: () => _viewJob(job),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(job.title, style: Theme.of(context).textTheme.titleLarge),
      SizedBox(height: 8),
      StatusChip.jobType(job.type),
      SizedBox(height: 12),
      SecondaryButton(
        label: 'View Details',
        icon: Icons.arrow_forward,
        onPressed: () => _viewJob(job),
        isFullWidth: true,
      ),
    ],
  ),
)
```

### Form Section
```dart
Column(
  children: [
    CustomInput(
      label: 'Email',
      prefixIcon: Icons.email,
      controller: _emailController,
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    ),
    SizedBox(height: 16),
    CustomInput(
      label: 'Password',
      prefixIcon: Icons.lock,
      obscureText: true,
      controller: _passwordController,
    ),
    SizedBox(height: 24),
    PrimaryButton(
      label: 'Login',
      onPressed: _submit,
      isLoading: _isSubmitting,
      isFullWidth: true,
    ),
  ],
)
```

---

## Need More Help?

- 📖 Read the full [README.md](README.md) for detailed documentation
- 🎨 Check [DESIGN_SYSTEM.md](../../../docs/DESIGN_SYSTEM.md) for design tokens
- 📝 See [COMPONENT_LIBRARY_SUMMARY.md](../../../COMPONENT_LIBRARY_SUMMARY.md) for implementation details

Happy coding! 🚀
