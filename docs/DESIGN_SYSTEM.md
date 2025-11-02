# ITJobHub Design System

## Overview
This document defines the design tokens, components, and patterns used throughout the ITJobHub application.

## Design Tokens

### Colors
```dart
// Primary
Primary: #2196F3 (Blue 500)
Primary Light: #42A5F5 (Blue 400)
Primary Dark: #1976D2 (Blue 700)

// Accent
Accent: #26C6DA (Cyan 400)

// Semantic
Success: #4CAF50 (Green 500)
Warning: #FF9800 (Orange 500)
Error: #F44336 (Red 500)
Info: #2196F3 (Blue 500)

// Status Colors
Pending: #FF9800 (Orange)
Reviewing: #2196F3 (Blue)
Interview: #9C27B0 (Purple)
Approved: #4CAF50 (Green)
Rejected: #F44336 (Red)

// Neutral
Background: #FAFAFA (Grey 50)
Surface: #FFFFFF (White)
Divider: #E0E0E0 (Grey 300)

// Text
Text Primary: #212121 (Grey 900)
Text Secondary: #757575 (Grey 600)
Text Hint: #BDBDBD (Grey 400)
```

### Typography Scale
```dart
Display Large: 32px / Bold
Display Medium: 28px / Bold
Display Small: 24px / Bold
Headline Large: 22px / Semi-Bold
Headline Medium: 20px / Semi-Bold
Headline Small: 18px / Semi-Bold
Title Large: 16px / Bold
Title Medium: 14px / Semi-Bold
Title Small: 12px / Semi-Bold
Body Large: 16px / Regular
Body Medium: 14px / Regular
Body Small: 12px / Regular
Label Large: 14px / Medium
Label Medium: 12px / Medium
Label Small: 10px / Medium
```

### Spacing Scale
```dart
XS: 4px
S: 8px
M: 16px
L: 24px
XL: 32px
XXL: 48px
```

### Border Radius
```dart
S: 4px
M: 8px
L: 12px
XL: 16px
XXL: 24px
Round: 999px (for pills/badges)
```

### Elevation
```dart
Level 0: 0dp (no shadow)
Level 1: 2dp (cards)
Level 2: 4dp (buttons)
Level 3: 8dp (bottom nav, app bar)
Level 4: 16dp (dialogs, bottom sheets)
Level 5: 24dp (modal sheets)
```

### Animation Durations
```dart
Fast: 150ms
Normal: 300ms
Slow: 500ms
```

## Core Components

### Buttons

#### Primary Button
- Background: Primary color
- Text: White
- Height: 48dp
- Border Radius: M (8px)
- Use for: Main actions (Submit, Apply, Save)

#### Secondary Button
- Background: Transparent
- Border: Primary color (1.5px)
- Text: Primary color
- Height: 48dp
- Border Radius: M (8px)
- Use for: Secondary actions (Cancel, Skip)

#### Text Button
- Background: Transparent
- Text: Primary color
- Padding: M horizontal, S vertical
- Use for: Tertiary actions (Learn More, View Details)

#### Icon Button
- Size: 40x40dp
- Icon: 24dp
- Background: Transparent or Light tint
- Use for: Actions with icons only

### Chips & Badges

#### Chip (Selectable)
- Height: 32dp
- Border Radius: Round
- Padding: M horizontal
- Background: Primary 10% (unselected), Primary (selected)
- Text: Primary (unselected), White (selected)
- Use for: Filters, categories, skills

#### Badge (Status)
- Height: 24dp
- Border Radius: Round
- Padding: S horizontal
- Background: Status color 10%
- Text: Status color
- Use for: Application status, job type

#### Match Score Badge
- Background: Success 10%
- Icon: Star
- Text: Success color, Bold
- Use for: AI match percentage

### Cards

#### Job Card
- Background: Surface
- Border Radius: L (12px)
- Elevation: Level 1
- Padding: M
- Contains: Logo, title, company, location, salary, skills, time

#### Application Card
- Background: Surface
- Border Radius: L (12px)
- Elevation: Level 1
- Padding: M
- Contains: Candidate avatar, name, job, status, match score

#### Candidate Card
- Background: Surface
- Border Radius: L (12px)
- Elevation: Level 1
- Padding: M
- Contains: Avatar, name, position, skills, experience, actions

### Inputs

#### Text Input
- Height: 48dp
- Border Radius: M (8px)
- Background: Surface
- Border: Divider color (1px), Primary on focus (2px)
- Padding: M

#### Search Input
- Height: 48dp
- Border Radius: L (12px)
- Background: Grey 100
- Icon: Search (prefix), Clear (suffix)
- No border (filled style)

#### Dropdown/Select
- Height: 48dp
- Border Radius: M (8px)
- Background: Surface
- Icon: Arrow down (suffix)

### Sheets & Dialogs

#### Bottom Sheet
- Border Radius: XL top corners (16px)
- Background: Surface
- Handle: 4px height, 40px width, Grey 300
- Max Height: 90% viewport

#### Dialog
- Border Radius: L (12px)
- Background: Surface
- Max Width: 90% or 400px
- Padding: L

### Empty & Error States

#### Empty State
- Icon: 60dp, Grey 400
- Title: Headline Small, Bold
- Description: Body Medium, Grey 600
- Action Button: Optional

#### Error State
- Icon: 60dp, Error color
- Title: Headline Small, Bold, Error color
- Description: Body Medium, Grey 600
- Retry Button: Primary

#### Loading State (Skeleton)
- Background: Grey 200
- Animation: Shimmer effect
- Border Radius: Matches content

## Patterns

### Navigation

#### Bottom Navigation (Candidate)
- Items: Jobs, Applications, Profile, (Saved)
- Height: 56dp
- Icons: 24dp
- Active: Primary color, Bold
- Inactive: Grey 600, Regular

#### Bottom Navigation (Employer)
- Items: Jobs, Applications, Company
- Same styling as candidate

#### App Bar
- Height: 56dp
- Background: Primary (or Surface for nested screens)
- Title: 20px, Semi-Bold
- Icons: 24dp

### Search & Filter

#### Search Header
- Search input with filter button
- Category chips below (horizontal scroll)
- Sticky at top

#### Filter Bottom Sheet
- Tabs or sections for filter types
- Checkboxes/Radio for selection
- Salary range slider
- Apply/Reset buttons at bottom

### Job Discovery Flow
```
Home (Job List) 
  → Search/Filter 
  → Job Detail 
  → Quick Apply Sheet 
  → Confirmation
```

### Application Flow
```
Applications List (Tabs)
  → Application Detail
  → Actions (Review/Approve/Reject)
  → Update Status
```

## Component Usage Guidelines

### DO ✅
- Use shared components from `lib/widgets/common/`
- Follow elevation hierarchy
- Use design tokens for all spacing, colors, typography
- Maintain 8dp spacing grid
- Use semantic colors for statuses
- Include empty/loading/error states
- Add keyboard navigation support
- Test with large text sizes

### DON'T ❌
- Create one-off styled widgets
- Use hardcoded colors or spacing
- Mix elevation levels inconsistently
- Forget focus states
- Ignore dark theme
- Skip accessibility labels

## Accessibility

### Minimum Touch Targets
- 48x48dp for all interactive elements

### Color Contrast
- Text: 4.5:1 for normal text, 3:1 for large text
- UI Elements: 3:1 minimum

### Screen Reader
- All interactive elements have labels
- Status changes announced
- Form errors read aloud

## Responsive Breakpoints

```dart
Mobile: 0-600dp
Tablet: 601-840dp
Desktop: 841dp+
```

Currently mobile-first; tablet/desktop layouts TBD.

## File Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   └── constants/
│       └── app_constants.dart
├── widgets/
│   └── common/
│       ├── buttons/
│       │   ├── app_button.dart
│       │   ├── icon_button_widget.dart
│       │   └── text_button_widget.dart
│       ├── cards/
│       │   ├── job_card_widget.dart
│       │   ├── candidate_card_widget.dart
│       │   └── application_card_widget.dart
│       ├── chips/
│       │   ├── filter_chip_widget.dart
│       │   ├── status_badge.dart
│       │   └── match_score_badge.dart
│       ├── inputs/
│       │   ├── app_text_field.dart
│       │   └── search_input.dart
│       ├── states/
│       │   ├── empty_state.dart
│       │   ├── error_state.dart
│       │   └── skeleton_loader.dart
│       └── sheets/
│           ├── bottom_sheet_wrapper.dart
│           └── dialog_wrapper.dart
```

## Version History

- v2.0 (Current): Enhanced design system with shared components
- v1.0: Initial theme implementation
