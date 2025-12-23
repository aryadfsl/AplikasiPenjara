# Quick Reference: Remaining Refactoring Tasks

## Copy-Paste Template for Each File

### Template Code (Copy & Adapt)

```dart
// STEP 1: Add this import at the top
import '../screens/[controller_name].dart';

// STEP 2: Replace class state variables with this:
class _PageNameState extends State<PageName> {
  late ControllerName _controller;

  @override
  void initState() {
    super.initState();
    _controller = ControllerName();
    // Call load method if controller has one
    _controller.loadData(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // STEP 3: In build(), replace all:
  // _variable → _controller.variable
  // _loadData() → _controller.loadData(context)
  // _formatDate() → _controller.formatDate()
  // etc...
}
```

## Remaining 5 Files Quick Tasks

### 1. admin_schedule_management.dart
**File Size**: 562 lines → ~280 lines  
**Controller Ready**: `admin_schedule_management_controller.dart` ✅

Key replacements:
```
_titleController → _controller.titleController
_schedules → _controller.schedules
_inmates → _controller.inmates
_isLoading → _controller.isLoading
_loadData() → _controller.loadData(context)
_addSchedule() → _controller.addSchedule(context)
_formatDate() → _controller.formatDate()
_getTypeIcon() → _controller.getTypeIcon() [if exists]
```

---

### 2. user_complaint_screen.dart
**File Size**: 562 lines → ~280 lines  
**Controller Ready**: `user_complaint_screen_controller.dart` ✅

Key replacements:
```
_formKey → _controller.formKey
_titleController → _controller.titleController
_descriptionController → _controller.descriptionController
_categories → _controller.categories
_priorities → _controller.priorities
_userComplaints → _controller.userComplaints
_isLoading → _controller.isLoading
_submitComplaint() → _controller.submitComplaint(context)
_loadUserComplaints() → _controller.loadUserComplaints(context)
_getStatusColor() → _controller.getStatusColor()
_getPriorityColor() → _controller.getPriorityColor()
```

---

### 3. user_schedule_screen.dart
**File Size**: 377 lines → ~190 lines  
**Controller Ready**: `user_schedule_screen_controller.dart` ✅

Key replacements:
```
_userSchedules → _controller.userSchedules
_isLoading → _controller.isLoading
_loadUserSchedules() → _controller.loadUserSchedules(context)
_getScheduleColor() → _controller.getScheduleColor()
_getScheduleIcon() → _controller.getScheduleIcon()
_formatDate() → _controller.formatDate() [if needed]
```

---

### 4. user_profile_screen.dart
**File Size**: 220 lines → ~120 lines  
**Controller Ready**: `user_profile_screen_controller.dart` ✅

Key replacements:
```
_formatDate() → _controller.formatDate()
_calculateRemainingTime() → _controller.calculateRemainingTime()
_calculateProgress() → _controller.calculateProgress()
```

---

### 5. add_schedule_dialog.dart
**File Size**: Small dialog  
**Controller**: Not needed - mostly UI

- Only refactor if it contains logic
- Otherwise, can remain as-is

---

## Verification Checklist (per file)

After refactoring each file, verify:

- [ ] Import statement added
- [ ] Controller initialized in initState()
- [ ] Controller disposed in dispose()
- [ ] All state variables replaced
- [ ] All method calls replaced
- [ ] No compilation errors: `flutter analyze`
- [ ] Page renders correctly in app
- [ ] All functionality works

---

## Expected Results After Completing All 5:

```
Total Lines Removed: ~2,000+
Files with Controllers: 11 (100%)
Files Pure UI: 11 (100%)
Average Reduction: 50%
```

---

## Need Help?

Refer to these completed files as examples:

**Simple Example** (65 lines):
- `lib/page/user_dashboard.dart`

**Complex Example** (280 lines):
- `lib/page/admin_inmate_management.dart`

**Medium Example** (200 lines):
- `lib/page/admin_complaint_management.dart`

---

## Command to Check Progress:

```bash
# Analyze all files
flutter analyze

# Count lines per file
wc -l lib/page/*.dart lib/screens/*.dart
```

---

## Time Estimate:

- Per file: 5-10 minutes
- All 5 files: 30-50 minutes total
- Testing: 10-15 minutes

**Total Time to Complete: ~1 hour**

---

## After Completion:

```bash
# Run final check
flutter analyze

# Test the app
flutter run

# Review changes
git diff lib/page/
git diff lib/screens/
```

That's it! 🎉
