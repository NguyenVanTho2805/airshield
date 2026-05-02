# Phase 5 Notifications - Testing Guide

## Quick Start Testing

### Prerequisites
- Flutter mobile app environment (Android/iOS)
- Run: `flutter run` on a mobile device or emulator

### Initial App State
When you start the app, the notification system is pre-loaded with **2 unread notifications** and **5 total notifications**:

1. ⚠️ **High AQI Alert** (Unread) - "AQI reached 152, unhealthy levels"
2. ✨ **Automation Triggered** (Unread) - "Rule executed, Living Room Purifier turned on"
3. 📱 **Device Connected** (Read)
4. ℹ️ **Welcome Message** (Read)
5. ⚠️ **Good Air Quality** (Read)

---

## Testing Checklist

### ✅ Access Points
Test all ways to access the Notifications page:

1. **Dashboard AppBar** → Tap bell icon (🔔) → Opens NotificationsPage
2. **Profile Menu** → Tap "Notifications" menu item → Opens NotificationsPage

Expected: Both routes open the same NotificationsPage

---

### ✅ Badge Count Display

**On Dashboard:**
- [ ] Bell icon shows red badge with "2" (unread count)
- [ ] Badge is circular, red background, white text
- [ ] Badge positioned at top-right of bell icon

**Badge Updates:**
- [ ] Mark 1 notification as read → Badge changes to "1"
- [ ] Mark all as read → Badge disappears
- [ ] Delete 1 unread notification → Badge decrements
- [ ] Simulate new notification → Badge increments

---

### ✅ Notifications List Display

**Visual Elements:**
- [ ] Notifications sorted by timestamp (newest first)
- [ ] Each notification shows:
  - Type-specific icon (⚠️ 📱 ✨ ℹ️)
  - Type-specific color (Red/Blue/Green/Gray)
  - Title (bold if unread, normal if read)
  - Message text
  - Timestamp ("2 hours ago", "1 day ago", etc.)

**Unread vs Read:**
- [ ] Unread notifications have **bold title**
- [ ] Read notifications have normal weight title
- [ ] Visual distinction is clear

---

### ✅ Interaction Testing

#### Mark as Read
- [ ] Tap unread notification card
- [ ] Title changes from bold to normal
- [ ] Badge count decreases by 1
- [ ] Notification stays in list

#### Delete Notification
- [ ] Swipe notification card to the left
- [ ] Red "Delete" button appears
- [ ] Tap delete button
- [ ] Notification removed from list
- [ ] If unread, badge count decreases

#### Mark All as Read
- [ ] Tap "Mark all as read" button in AppBar menu
- [ ] All notification titles become normal weight
- [ ] Badge disappears
- [ ] Notifications remain in list

#### Clear All
- [ ] Tap "Clear All" button in AppBar menu
- [ ] Confirmation dialog appears
- [ ] Confirm → All notifications deleted
- [ ] Empty state displays

---

### ✅ Empty State
- [ ] Clear all notifications
- [ ] Page shows:
  - Icon (🔔 with slash)
  - "No notifications" message
  - Friendly subtitle

---

### ✅ Notification Simulation (Testing Feature)

**Access:**
- [ ] Tap "+" button in NotificationsPage AppBar
- [ ] Simulation dialog appears

**Simulate Each Type:**
1. **AQI Alert**
   - [ ] Select "AQI Alert" → Tap "Simulate"
   - [ ] New notification appears at top of list
   - [ ] Icon: ⚠️, Color: Red
   - [ ] Marked as unread
   - [ ] Badge count +1

2. **Device Status**
   - [ ] Select "Device Status" → Simulate
   - [ ] Icon: 📱, Color: Blue
   - [ ] Shows device-related message

3. **Automation**
   - [ ] Select "Automation" → Simulate
   - [ ] Icon: ✨, Color: Green
   - [ ] Shows automation message

4. **System**
   - [ ] Select "System" → Simulate
   - [ ] Icon: ℹ️, Color: Gray
   - [ ] Shows system message

---

### ✅ Localization Testing

#### English (EN)
- [ ] Change app language to English (Settings → Language → English)
- [ ] Navigate to NotificationsPage
- [ ] Verify text:
  - Title: "Notifications"
  - Empty state: "No notifications" / "You're all caught up!"
  - Buttons: "Clear all", "Mark all as read"
  - Dialog: "Clear all notifications?"

#### Vietnamese (VI)
- [ ] Change app language to Vietnamese
- [ ] Navigate to NotificationsPage
- [ ] Verify text:
  - Title: "Thông báo"
  - Empty state: "Không có thông báo" / "Bạn đã xem hết!"
  - Buttons: "Xóa tất cả", "Đánh dấu tất cả đã đọc"
  - Dialog: "Xóa tất cả thông báo?"

---

### ✅ Theme Testing

#### Dark Theme (Default)
- [ ] Notifications page uses dark background
- [ ] Notification cards have dark gray background
- [ ] Text is white/light gray
- [ ] Icons are visible and properly colored
- [ ] Badge is visible (red on dark)
- [ ] Empty state icon/text readable

#### Light Theme
- [ ] Settings → Theme → Light
- [ ] Navigate to NotificationsPage
- [ ] All text remains readable
- [ ] Notification cards properly styled
- [ ] Icons visible with appropriate colors
- [ ] Badge remains visible

---

### ✅ Navigation Flow

**From Dashboard:**
- [ ] Dashboard → Bell Icon → NotificationsPage
- [ ] Tap notification → Marked as read
- [ ] Back button → Returns to Dashboard
- [ ] Badge count updated on Dashboard

**From Profile:**
- [ ] Dashboard → Profile (bottom nav)
- [ ] Profile → "Notifications" menu
- [ ] Opens NotificationsPage
- [ ] Back → Returns to Profile
- [ ] Back → Returns to Dashboard

---

### ✅ Edge Cases

**Large Number of Notifications:**
- [ ] Simulate 15+ notifications
- [ ] List scrolls smoothly
- [ ] Badge shows "9+" when count > 9
- [ ] Performance remains good

**Rapid Actions:**
- [ ] Quickly tap multiple notifications
- [ ] Rapidly delete several notifications
- [ ] Badge updates correctly
- [ ] No crashes or UI glitches

**State Persistence:**
- [ ] Mark 2 notifications as read
- [ ] Close app completely
- [ ] Reopen app
- [ ] Note: Mock service resets to default state (expected)
- [ ] Future: Add local storage for persistence

---

## Expected Results Summary

✅ **Feature Complete:**
- All 4 notification types working (AQI, Device, Automation, System)
- Badge count updates in real-time
- Swipe-to-delete gesture works
- Mark as read/unread functionality
- Clear all with confirmation
- Empty state displays correctly
- Simulation for testing works
- English/Vietnamese translations complete
- Dark/Light theme support

✅ **UI/UX:**
- Beautiful, modern design
- Smooth animations
- Clear visual hierarchy
- Type-specific colors and icons
- Responsive to user actions

✅ **Navigation:**
- Multiple access points (Dashboard bell, Profile menu)
- Proper back navigation
- Badge updates across app

---

## Known Limitations

1. **No Persistence**: Notifications reset when app restarts (mock service)
2. **No Firebase Integration**: Simulated notifications only (can be added later)
3. **No Background Notifications**: App must be running to receive notifications

---

## Next Steps for Production

To make this production-ready:

1. **Local Storage**: Save notifications to device storage
2. **Firebase Integration**: 
   - Setup Firebase project
   - Add platform-specific configs
   - Implement FCM handlers
3. **Backend API**: Connect to real backend for AQI alerts
4. **Push Permissions**: Request notification permissions on first launch
5. **Deep Linking**: Tap notification → Navigate to relevant screen

---

## Quick Test Scenario (2 minutes)

1. Open app → Check bell badge shows "2" ✓
2. Tap bell → See 5 notifications (2 bold) ✓
3. Tap unread notification → Becomes normal, badge = "1" ✓
4. Tap "+" → Simulate "AQI Alert" → New notification appears ✓
5. Swipe notification → Delete → Gone from list ✓
6. Change to Vietnamese → All text translated ✓
7. Change to Light theme → UI readable ✓
8. Tap "Clear all" → Confirm → Empty state ✓

**If all pass: Phase 5 Complete! 🎉**
