# Common Widgets Library

A comprehensive collection of reusable UI components for the IT Job Finder app, designed following the Design System v2 specifications.

## Table of Contents

- [Installation](#installation)
- [State Components](#state-components)
- [Button Components](#button-components)
- [Chip Components](#chip-components)
- [Card Components](#card-components)
- [Input Components](#input-components)

## Installation

Import all common widgets at once:

```dart
import 'package:it_job_finder/widgets/common/index.dart';
```

Or import specific widgets individually:

```dart
import 'package:it_job_finder/widgets/common/empty_state.dart';
import 'package:it_job_finder/widgets/common/primary_button.dart';
```

---

## State Components

### EmptyState

Displays a consistent empty state UI across the app.

**Usage:**

```dart
EmptyState(
  icon: Icons.inbox,
  title: 'No Jobs Found',
  message: 'Try adjusting your search criteria or check back later for new opportunities.',
  actionLabel: 'Browse All Jobs',
  onAction: () {
    // Handle action
  },
)
```

**Properties:**

- `icon` (required): IconData to display
- `title` (required): Main heading text
- `message` (required): Descriptive message
- `actionLabel` (optional): Button label
- `onAction` (optional): Button callback

---

### ErrorState

Displays consistent error UI with retry capability.

**Usage:**

```dart
ErrorState(
  title: 'Connection Failed',
  message: 'Unable to connect to the server. Please check your internet connection and try again.',
  actionLabel: 'Try Again',
  onRetry: () {
    // Retry logic
  },
)
```

**Properties:**

- `title` (optional): Error heading
- `message` (required): Error description
- `actionLabel` (optional): Retry button label
- `onRetry` (optional): Retry callback

---

### LoadingState

Displays consistent loading UI with optional message.

**Usage:**

```dart
// Full screen loading
LoadingState(
  message: 'Loading jobs...',
)

// Inline loading
LoadingState(
  fullScreen: false,
)
```

**Properties:**

- `message` (optional): Loading message
- `fullScreen` (default: true): Whether to center in full screen

---

### ShimmerLoading

Animated shimmer effect for skeleton loaders.

**Usage:**

```dart
ShimmerLoading(
  width: 200,
  height: 20,
  borderRadius: BorderRadius.circular(8),
)
```

**Properties:**

- `width` (required): Width of shimmer
- `height` (required): Height of shimmer
- `borderRadius` (optional): Custom border radius

---

## Button Components

### PrimaryButton

Primary action button with consistent styling.

**Usage:**

```dart
PrimaryButton(
  label: 'Apply Now',
  icon: Icons.send,
  onPressed: () {
    // Handle press
  },
  isLoading: false,
  isFullWidth: true,
  size: ButtonSize.medium,
)
```

**Properties:**

- `label` (required): Button text
- `onPressed` (optional): Tap callback
- `icon` (optional): Leading icon
- `isLoading` (default: false): Show loading indicator
- `isFullWidth` (default: false): Expand to full width
- `size` (default: medium): ButtonSize enum (small, medium, large)

---

### SecondaryButton

Outlined button for secondary actions.

**Usage:**

```dart
SecondaryButton(
  label: 'Save for Later',
  icon: Icons.bookmark_border,
  onPressed: () {
    // Handle press
  },
)
```

**Properties:** Same as PrimaryButton

---

### AppTextButton

Minimal text-only button (renamed to avoid conflict with Flutter's TextButton).

**Usage:**

```dart
AppTextButton(
  label: 'Learn More',
  icon: Icons.info_outline,
  onPressed: () {
    // Handle press
  },
)
```

**Properties:**

- `label` (required): Button text
- `onPressed` (optional): Tap callback
- `icon` (optional): Leading icon
- `size` (default: medium): ButtonSize enum

---

## Chip Components

### StatusChip

Displays status with color-coded styling.

**Usage:**

```dart
// Application status
StatusChip.applicationStatus(
  ApplicationStatus.approved,
  size: ChipSize.medium,
)

// Job type
StatusChip.jobType('Full-time')

// Experience level
StatusChip.experienceLevel('Senior')

// Custom chip
StatusChip(
  label: 'Featured',
  color: Colors.blue,
  icon: Icons.star,
)
```

**Properties:**

- `label` (required): Chip text
- `color` (required): Chip color
- `icon` (optional): Leading icon
- `size` (default: medium): ChipSize enum (small, medium, large)

---

### SelectableChip

Interactive chip for filters and selections.

**Usage:**

```dart
SelectableChip(
  label: 'Full-time',
  isSelected: _selectedFilters.contains('Full-time'),
  onTap: () {
    // Toggle selection
  },
  size: ChipSize.medium,
)
```

**Properties:**

- `label` (required): Chip text
- `isSelected` (required): Selection state
- `onTap` (required): Tap callback
- `size` (default: medium): ChipSize enum

---

## Card Components

### CustomCard

Basic card with consistent styling.

**Usage:**

```dart
CustomCard(
  onTap: () {
    // Handle tap
  },
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Text('Card content'),
)
```

**Properties:**

- `child` (required): Card content
- `onTap` (optional): Tap callback
- `padding` (optional): Inner padding
- `margin` (optional): Outer margin
- `elevation` (optional): Shadow elevation
- `color` (optional): Background color
- `borderRadius` (optional): Custom border radius

---

### HeaderCard

Card with header and body sections.

**Usage:**

```dart
HeaderCard(
  title: 'Job Details',
  subtitle: 'Posted 2 days ago',
  trailing: Icon(Icons.bookmark),
  body: Column(
    children: [
      // Card content
    ],
  ),
  onTap: () {
    // Handle tap
  },
)
```

**Properties:**

- `title` (required): Header title
- `subtitle` (optional): Header subtitle
- `trailing` (optional): Widget in header trailing position
- `body` (required): Body content
- `onTap` (optional): Tap callback
- `margin` (optional): Outer margin

---

### IconCard

Card with icon and text for feature displays.

**Usage:**

```dart
IconCard(
  icon: Icons.work,
  title: 'My Applications',
  subtitle: '5 active applications',
  iconColor: AppColors.primary,
  onTap: () {
    // Navigate
  },
)
```

**Properties:**

- `icon` (required): Icon to display
- `title` (required): Main text
- `subtitle` (optional): Secondary text
- `iconColor` (optional): Icon color (default: primary)
- `onTap` (optional): Tap callback

---

### InfoCard

Card for displaying key-value information pairs.

**Usage:**

```dart
InfoCard(
  items: [
    InfoItem(
      label: 'Location',
      value: 'San Francisco, CA',
      icon: Icons.location_on,
    ),
    InfoItem(
      label: 'Salary',
      value: '\$120k - \$150k',
      icon: Icons.attach_money,
    ),
  ],
)
```

**Properties:**

- `items` (required): List of InfoItem objects
- `margin` (optional): Outer margin

**InfoItem Properties:**

- `label` (required): Label text
- `value` (required): Value text
- `icon` (optional): Leading icon

---

## Input Components

### CustomInput

Standard text input field.

**Usage:**

```dart
CustomInput(
  label: 'Email',
  hint: 'Enter your email',
  controller: _emailController,
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    return null;
  },
  onChanged: (value) {
    // Handle change
  },
)
```

**Properties:**

- `label` (optional): Field label
- `hint` (optional): Placeholder text
- `errorText` (optional): Error message
- `controller` (optional): TextEditingController
- `keyboardType` (optional): Input type
- `obscureText` (default: false): Hide text (for passwords)
- `enabled` (default: true): Enable/disable input
- `maxLines` (default: 1): Maximum lines
- `maxLength` (optional): Maximum characters
- `prefixIcon` (optional): Leading icon
- `suffixIcon` (optional): Trailing widget
- `validator` (optional): Validation function
- `onChanged` (optional): Change callback
- `onTap` (optional): Tap callback

---

### SearchInput

Search field with clear functionality.

**Usage:**

```dart
SearchInput(
  hint: 'Search jobs...',
  controller: _searchController,
  onChanged: (value) {
    // Handle search
  },
  onClear: () {
    // Handle clear
  },
)
```

**Properties:**

- `hint` (optional): Placeholder text
- `controller` (optional): TextEditingController
- `onChanged` (optional): Change callback
- `onClear` (optional): Clear callback

---

### DropdownInput

Dropdown selection field.

**Usage:**

```dart
DropdownInput<String>(
  label: 'Experience Level',
  hint: 'Select level',
  value: _selectedLevel,
  prefixIcon: Icons.work,
  items: [
    DropdownMenuItem(value: 'junior', child: Text('Junior')),
    DropdownMenuItem(value: 'mid', child: Text('Mid-level')),
    DropdownMenuItem(value: 'senior', child: Text('Senior')),
  ],
  onChanged: (value) {
    setState(() => _selectedLevel = value);
  },
)
```

**Properties:**

- `label` (optional): Field label
- `hint` (optional): Placeholder text
- `value` (optional): Selected value
- `items` (required): List of DropdownMenuItem
- `onChanged` (optional): Change callback
- `prefixIcon` (optional): Leading icon
- `enabled` (default: true): Enable/disable input
- `errorText` (optional): Error message

---

## Enums

### ButtonSize
- `small`: Compact button
- `medium`: Standard button (default)
- `large`: Large button

### ChipSize
- `small`: Compact chip
- `medium`: Standard chip (default)
- `large`: Large chip

---

## Best Practices

1. **Consistency**: Always use these components instead of creating custom widgets for common patterns
2. **Accessibility**: Components include proper touch targets and semantic labels
3. **Theming**: All components respect the app's design system colors and sizing
4. **Performance**: Components are optimized and use const constructors where possible
5. **Customization**: Use the provided properties for customization rather than wrapping in custom widgets

---

## Design System Reference

All components follow the [Design System v2](../../../docs/DESIGN_SYSTEM.md) specifications including:

- Colors from `AppColors`
- Sizes from `AppSizes`
- Elevations from `AppElevations`
- Durations from `AppDurations`

---

## Examples

See the `/examples` directory for complete usage examples and screen implementations.

---

## Support

For questions or issues with these components, please refer to the main project documentation or contact the development team.
