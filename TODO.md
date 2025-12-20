# Screen Styling Update Plan

## Overview
Update screens in lib/ folder to match reference screen designs using CustomAppBar, animations, consistent theming, and widgets.

## Key Style Elements
- Replace standard AppBar with CustomAppBar
- Add AppAnimations.slideInFromBottom to list items and sections
- Use EmptyStateWidget for empty states
- Use LoadingOverlay or ShimmerList for loading states
- Apply GoogleFonts.poppins
- Use CustomScrollView with SliverToBoxAdapter
- Consistent gradients, rounded corners, shadows
- DashboardCard for grid items

## Files to Update

### Alumni Screens
- [x] lib/alumini/post_item.dart
  - Replace AppBar with CustomAppBar
  - Add animations

- [x] lib/alumini/post_job.dart
  - Replace AppBar with CustomAppBar
  - Add animations

### Library Screens
- [x] lib/library/library_screen.dart
  - Already uses CustomAppBar, check for animations

- [x] lib/library/manage_books.dart
  - Replace AppBar with CustomAppBar
  - Add animations

- [x] lib/library/library_analytics_screen.dart
  - Replace AppBar with CustomAppBar

- [x] lib/library/issue_history.dart
  - Replace AppBar with CustomAppBar

- [x] lib/library/issued_book_screen.dart
  - Replace AppBar with CustomAppBar

- [ ] lib/library/fine_payment_screen.dart
  - Replace AppBar with CustomAppBar

### Admin Screens
- [x] lib/admin/admin_jobs.dart
  - Replace AppBar with CustomAppBar

- [x] lib/admin/admin_users.dart
  - Replace AppBar with CustomAppBar

- [ ] lib/admin/approve_users.dart
  - Replace AppBar with CustomAppBar

- [ ] lib/admin/post_event.dart
  - Replace AppBar with CustomAppBar

- [ ] lib/admin/post_global_notice.dart
  - Replace AppBar with CustomAppBar

- [ ] lib/admin/admin_library.dart
  - Replace AppBar with CustomAppBar

### Profile Screens
- [ ] lib/profile/terms_conditions.dart
  - Replace AppBar with CustomAppBar

- [ ] lib/profile/mentor_education_form.dart
  - Replace AppBar with CustomAppBar

### Alumni Screens (continued)
- [ ] lib/alumini/chat_screen.dart
  - Replace AppBar with CustomAppBar

- [ ] lib/alumini/alumini_dashboard.dart
  - Check for CustomAppBar and animations

### Mentor Screens (continued)
- [ ] lib/mentor/post_event.dart
  - Replace AppBar with CustomAppBar

## Implementation Steps
1. Update each file systematically
2. Import necessary widgets and animations
3. Replace AppBar with CustomAppBar
4. Wrap list items with AppAnimations.slideInFromBottom
5. Replace custom empty states with EmptyStateWidget
6. Add GoogleFonts.poppins to text
7. Apply consistent theming
8. Test changes for functionality

## Dependencies
- Ensure all imports are correct
- Check for any missing widgets or utilities
- Verify theme consistency
