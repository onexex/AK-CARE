# AKOP MIYEMBRO (AK CARE) — Comprehensive Flutter Application Audit

**Date:** June 16, 2026  
**Auditor:** Senior Flutter UI/UX Architect & Mobile Performance Engineer  
**Version:** 1.0.0+1  
**Repositories Reviewed:**
- Flutter: `akop_member_app` (GitHub: `onexex/AK-CARE`)
- PHP Backend: `akop_member` (GitHub: `onexex/AK_CARE_PHP`)

---

## 1. Executive Summary

### Overall App Score: 4.7 / 10

The AKOP MIYEMBRO app is a functional Flutter application for managing health benefits, teleconsult requests, and member perks. The app demonstrates competent layout construction and a clear feature set. However, significant technical debt exists in state management, code organization, security, and performance optimization. The PHP backend has critical security vulnerabilities that must be addressed immediately.

---

### Strengths

1. **Clean visual identity** — Consistent green color palette, good use of rounded corners, card-based layouts, and gradient accents create a recognizable brand appearance.

2. **Complete feature coverage** — Login, dashboard, history, news (with search/filter), perks, teleconsult request/status tracking, and profile are all implemented and functional.

3. **Proper use of `mounted` checks** — `_LoginScreenState`, `_RequestStatusScreenState`, and `_HistoryScreenState` all check `mounted` before calling `setState`, preventing memory leaks from async operations.

4. **Pull-to-refresh implemented** — `RefreshIndicator` is used on history, news, and request status screens, providing a standard mobile UX pattern.

5. **Material Design 3 enabled** — `useMaterial3: true` is set in `main.dart`, with `ColorScheme.fromSeed()` providing dynamic color generation foundation.

---

### Critical Issues

1. **Hardcoded Laravel APP_KEY in PHP** (`verify_otp.php:7`) — Exposes the encryption key to anyone with source access. This is a Critical severity finding.

2. **No authentication tokens** — The app stores raw user JSON in `SharedPreferences` with no JWT, session token, or expiration. Session validity cannot be verified server-side.

3. **HTTP (not HTTPS)** for production domain — `AppConfig.serverIP = "akopmember.anakalusugan.com.ph"` uses `http://`. All credentials and OTPs travel in plaintext.

4. **Database root access with empty password** (`config.php:6-7`) — MySQL connection uses `root` with no password.

5. **No state management solution** — All screens manage their own state with `setState`. No Provider, Riverpod, BLoC, or even `InheritedWidget`. This causes code duplication and makes scaling difficult.

6. **Logout does not clear session** — `_showLogoutDialog` in `home_dashboard.dart:32` navigates to `LoginScreen` but never calls `prefs.remove('user_session')` or `prefs.clear()`, leaving the session on disk.

7. **No API service layer** — HTTP calls with `dart:convert` response parsing are duplicated across 5+ screens. A single API change requires touching every file.

---

## 2. UI/UX Findings — Screen-by-Screen Review

---

### 2.1 Login Screen (`lib/screens/login_screen.dart`)

**UI Score:** 7/10  
**UX Score:** 5/10  
**Priority:** High

#### Issues Found

| # | Issue | Location | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| 1 | **OTP displayed in SnackBar** | Line 49-53 | The OTP code is shown directly to the user via a SnackBar (`"OTP Sent: ${data['otp']}"`). Even if this is a development convenience, it creates a security-by-obscurity expectation that could leak into production. | Remove the SnackBar OTP display. Show generic "OTP sent to your device" messaging instead. |
| 2 | **No loading state on initial app launch** | `main.dart:58` | The `FutureBuilder` fallback returns a plain white `Scaffold` with no spinner or skeleton. Users see a blank white screen for 1–3 seconds while `_checkLoginStatus` runs. | Replace with a branded splash screen showing the logo and a `CircularProgressIndicator`. |
| 3 | **Floating decorative icons serve no purpose** | Lines 142-146 | Five `Positioned` icons with 0.05 opacity add visual noise. On smaller screens, they overlap the login card. | Remove them entirely or replace with a single subtle background pattern using `CustomPaint`. |
| 4 | **No "Forgot Phone Number" or help flow** | N/A | Users who don't know their registered number have no recourse. The commented-out "Contact Administrator" text (lines 365-369) suggests this was planned but abandoned. | Add a tappable "Need help?" link that opens an email or dialer intent to contact support. |
| 5 | **Error messages are generic** | Lines 61, 108 | Connection errors always show "Connection failed" and verification errors always show "Verification failed", regardless of the actual server error (timeout, 500, invalid number). | Surface the server's `data['message']` in error SnackBars instead of hardcoded strings. |
| 6 | **Phone number input has no formatting** | Lines 251-258 | Users can type any format. A `+63` prefix or spaces could cause mismatches with the database. | Auto-format to Philippine mobile format (`09XX-XXX-XXXX`) using a `TextInputFormatter` or mask. |

#### Recommended Code Changes

**Fix #1 — Remove OTP from SnackBar:**
```dart
// login_screen.dart, line 48-54 — REPLACE
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text("OTP Sent: ${data['otp']}"),
    backgroundColor: primaryGreen,
    behavior: SnackBarBehavior.floating,
  ),
);
// WITH:
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text("Verification code sent to your device"),
    backgroundColor: primaryGreen,
    behavior: SnackBarBehavior.floating,
  ),
);
```

**Fix #2 — Replace blank loading screen (`main.dart:58`):**
```dart
// main.dart, line 58 — REPLACE
return const Scaffold(backgroundColor: Colors.white);
// WITH:
return const Scaffold(
  backgroundColor: Colors.white,
  body: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image(image: AssetImage('assets/logo.png'), height: 80),
        SizedBox(height: 24),
        CircularProgressIndicator(
          color: Color.fromARGB(255, 36, 154, 25),
        ),
      ],
    ),
  ),
);
```

**Fix #5 — Surface server error messages:**
```dart
// login_screen.dart, lines 58-61 — REPLACE the catch block error message
_showError("Connection failed. Please try again.");
// WITH:
_showError(data['message'] ?? "Connection failed. Please try again.");
```

---

### 2.2 Home Dashboard (`lib/screens/home_dashboard.dart`)

**UI Score:** 5/10  
**UX Score:** 4/10  
**Priority:** High

#### Issues Found

| # | Issue | Location | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| 1 | **`StatelessWidget` with a stateful action** | Line 10 | `_showLogoutDialog` is defined as a method on `HomeDashboard`, a `StatelessWidget`. Dialogs should be handled by a `StatefulWidget` or external controller. | Convert to `StatefulWidget` or extract `_showLogoutDialog` into a standalone function/service. |
| 2 | **Logout does not clear session** | Lines 30-36 | `Navigator.pushAndRemoveUntil` routes to `LoginScreen` but the `user_session` key remains in `SharedPreferences`. On next app launch, the user is auto-logged-in. | Call `prefs.remove('user_session')` before navigating. |
| 3 | **Hardcoded "Recent Activity" is fake data** | Lines 182-186 | The `ListTile` showing "Teleconsult Completed — March 03, 2026" is static. It never updates and misleads users about actual recent activity. | Either fetch real recent activity from the backend, or replace with a dynamic summary (e.g., "You have X pending requests"). |
| 4 | **4-tile grid has no hierarchy** | Lines 112-169 | All 4 tiles (History, Perks, News, Profile) are equal visual weight. No indication of which is most-used or has pending items. | Add badges to tiles with pending counts (e.g., unread news, pending requests). Use size or color emphasis for primary actions. |
| 5 | **Profile tile uses "Settings" icon** | Line 155 | The Profile tile uses `Icons.settings`, which suggests app settings, not a user profile. | Change to `Icons.person` or `Icons.account_circle`. |
| 6 | **No greeting personalization** | Line 49 | `fullName` is shown in the header, but there's no time-based greeting ("Good morning, Juan"). | Add a dynamic greeting based on `DateTime.now().hour`. |
| 7 | **Color constant duplicated 20+ times** | Lines 57, 77, etc. | `Color.fromARGB(255, 36, 154, 25)` is repeated across every file. Changing the brand color requires a global find-and-replace. | Define `static const Color primaryGreen = Color(0xFF249A19);` in `AppConfig` or a new `app_theme.dart`. |

#### Recommended Code Changes

**Fix #2 — Proper logout:**
```dart
// home_dashboard.dart, lines 30-36 — REPLACE
onPressed: () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
},
// WITH:
onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_session');
  if (!context.mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
},
```

**Fix #6 — Add time-based greeting:**
```dart
// Add method:
String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
// In header section, add above fullName:
Text(_greeting(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
```

---

### 2.3 History Screen (`lib/screens/history_screen.dart`)

**UI Score:** 6/10  
**UX Score:** 5/10  
**Priority:** Medium

#### Issues Found

| # | Issue | Location | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| 1 | **No date grouping** | Lines 196-218 | List items are shown in flat order with only `created_at` as subtitle. Users can't quickly find consultations from a specific month. | Group items by month/year with sticky headers using `SliverList` + `SliverStickyHeader` or custom section headers. |
| 2 | **No search/filter by patient name** | N/A | If a user has many consultations, there's no way to filter. | Add a search bar at the top to filter by `p_patient`. |
| 3 | **Detail bottom sheet uses 85% screen height** | Line 58 | `MediaQuery.of(context).size.height * 0.85` is excessive. On tablets it creates a massive sheet. | Use `FractionallySizedBox` with `maxHeight` constraint, or use `DraggableScrollableSheet`. |
| 4 | **No empty state with illustration** | Lines 181-191 | "No history found." is just plain text centered on screen. | Add an illustration and a call-to-action ("Book your first teleconsult"). |
| 5 | **`_buildDetailRow` always shows a Divider even for "None" values** | Lines 143-160 | All fields render including empty ones, creating visual clutter. | Conditionally render rows only when `value` is non-null and non-empty. |
| 6 | **Status badge colors don't use theme** | Lines 103-113 | Colors are hardcoded (`Colors.green[100]`, `Colors.orange[100]`). These won't adapt to dark mode. | Use `Theme.of(context).colorScheme` with appropriate surface tones. |

---

### 2.4 News Screen (`lib/screens/news_screen.dart`)

**UI Score:** 7/10  
**UX Score:** 6/10  
**Priority:** Medium

#### Issues Found

| # | Issue | Location | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| 1 | **Image URL is never used** | Lines 243-246 | `NewsArticle.imageUrl` is parsed from the API but the tile always shows a placeholder icon (`Icons.article_rounded`). | Use `Image.network` with `errorBuilder` and `loadingBuilder` for a proper thumbnail, falling back to the icon. |
| 2 | **Category filter rebuilds entire list on tap** | Lines 157-161 | `setState` on category change causes `FutureBuilder` to rebuild the full list. Filtering should happen in the builder, not trigger a refetch. | Filter `_allNews` in memory instead of resetting `_newsFuture`. |
| 3 | **Search clears on refresh** | Line 72 | Pull-to-refresh calls `_searchController.clear()` which disrupts the user's search context. | Preserve the search query on refresh; only clear on explicit user action. |
| 4 | **No loading shimmer/skeleton** | Line 178-180 | The `CircularProgressIndicator` is functional but visually jarring. Users perceive the app as slow. | Add skeleton loader widgets (`shimmer` package) to indicate content loading. |
| 5 | **Detail modal button says "Back to News"** | Line 300 | This is redundant since users can swipe down to dismiss the bottom sheet. | Remove the button. The bottom sheet is already dismissible via drag handle. |

#### Recommended Code Changes

**Fix #1 — Use actual image from API:**
```dart
// news_screen.dart, lines 243-246 — REPLACE
Container(
  width: 90, height: 90,
  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
  child: const Icon(Icons.article_rounded, color: Color.fromARGB(255, 36, 154, 25), size: 40),
),
// WITH:
ClipRRect(
  borderRadius: BorderRadius.circular(15),
  child: news.imageUrl.isNotEmpty
    ? Image.network(
        news.imageUrl,
        width: 90, height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 90, height: 90,
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.article_rounded, color: Color.fromARGB(255, 36, 154, 25), size: 40),
        ),
      )
    : Container(
        width: 90, height: 90,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.article_rounded, color: Color.fromARGB(255, 36, 154, 25), size: 40),
      ),
),
```

---

### 2.5 Perks Screen (`lib/screens/perks_screen.dart`)

**UI Score:** 6/10  
**UX Score:** 5/10  
**Priority:** High

#### Issues Found

| # | Issue | Location | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| 1 | **`PerksScreen` is a `StatelessWidget` with async methods** | Line 9 | `_makePhoneCall`, `_showScheduleForm` are async methods on a StatelessWidget. This is architecturally incorrect—the widget cannot manage loading state. | Convert to `StatefulWidget`. |
| 2 | **Duplicate `setModalState(() => isLoading = false)` called twice** | Lines 180-181 | In the `catch` block of the teleconsult form, `setModalState(() => isLoading = false)` is called twice in succession — a clear copy-paste error. | Remove the duplicate line. |
| 3 | **3 empty `_buildPerkCard` onTap callbacks** | Lines 242, 244, 258 | "E-Prescription", "Pharmacy Disc.", and "Med Certificate" all have `() {}` empty callbacks. Users tap expecting action but nothing happens. | Either implement the features or show a "Coming Soon" dialog. Do not ship tappable cards with no response. |
| 4 | **Overlay notification pattern is custom and fragile** | Lines 417-455 | `_showTopNotification` creates `OverlayEntry` manually. If the user navigates away before the 3-second timer fires, the entry may not be removed, causing a memory leak. | Use `ScaffoldMessenger.showSnackBar` or the `fluttertoast` / `another_flushbar` package instead. |
| 5 | **Overlay notification logic duplicated across files** | `perks_screen.dart:417` and `request_status_screen.dart:167` | The identical 35-line `_showTopNotification` method exists in two files. | Extract into `lib/widgets/app_notification.dart` as a reusable function. |
| 6 | **Featured perk gradient is hardcoded** | Lines 285-290 | The gradient colors `Color.fromARGB(255, 36, 154, 25)` and `Color.fromARGB(255, 80, 180, 70)` are inlined. | Use `Theme.of(context).colorScheme` or `AppTheme` constants. |
| 7 | **Hotline number is hardcoded** | Line 267 | `'09352427713'` is embedded in the widget code. If the number changes, a new app build is required. | Fetch the hotline number from the backend or store it in `AppConfig`. |

#### Recommended Code Changes

**Fix #2 — Remove duplicate `setModalState` call:**
```dart
// perks_screen.dart, lines 179-183 — REPLACE
} catch (e) {
  setModalState(() => isLoading = false);
  setModalState(() => isLoading = false);  // DELETE THIS LINE
  _showTopNotification(context, "Error: $e", Colors.red);
}
// WITH:
} catch (e) {
  setModalState(() => isLoading = false);
  _showTopNotification(context, "Error: $e", Colors.red);
}
```

**Fix #3 — Show "Coming Soon" for unimplemented perks:**
```dart
// perks_screen.dart, lines 242, 244, 258 — REPLACE each () {} with:
() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("This feature is coming soon!")),
  );
},
```

---

### 2.6 Profile Screen (`lib/screens/profile_screen.dart`)

**UI Score:** 4/10  
**UX Score:** 3/10  
**Priority:** High

#### Issues Found

| # | Issue | Location | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| 1 | **"Edit Profile Information" button does nothing** | Lines 60-63 | The `onPressed` callback is empty. Users tap a prominent button with no result. | Implement edit functionality or remove the button. If coming soon, add a "Coming Soon" dialog. |
| 2 | **Mobile Number shows "Registered" instead of actual number** | Line 53 | The third info tile shows a static string "Registered" rather than the user's actual contact number from `userData`. | Display `userData['contact']` or a masked version like `09XX-XXX-1234`. |
| 3 | **No logout option** | N/A | The profile screen has no way to log out. Users must go back to the dashboard first. | Add a logout `ListTile` or button at the bottom of the profile. |
| 4 | **Avatar color is always red** | Line 32 | `backgroundColor: Colors.red` is hardcoded. It doesn't use the app's brand green. | Use the primary brand color for consistency. |
| 5 | **No section for account statistics** | N/A | No summary of consultation count, pending requests, or membership duration. | Add stats cards (e.g., "5 Consultations", "Member since 2024"). |
| 6 | **Info tiles only show 3 fields** | Lines 51-53 | `userData` contains `id`, `full_name`, `contact`, `rank` but only 3 are shown. | Show all available user fields in a structured list. |

#### Recommended Code Changes

**Fix #2 — Show actual mobile number:**
```dart
// profile_screen.dart, line 53 — REPLACE
_buildInfoTile("Mobile Number", "Registered", Icons.phone_android),
// WITH:
_buildInfoTile("Mobile Number", userData['contact'] ?? 'N/A', Icons.phone_android),
```

**Fix #4 — Use brand color for avatar:**
```dart
// profile_screen.dart, line 32 — REPLACE
backgroundColor: Colors.red,
// WITH:
backgroundColor: const Color.fromARGB(255, 36, 154, 25),
```

---

### 2.7 Request Status Screen (`lib/screens/request_status_screen.dart`)

**UI Score:** 6/10  
**UX Score:** 5/10  
**Priority:** Medium

#### Issues Found

| # | Issue | Location | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| 1 | **Uses `contact` as `user_id` for filtering** | Line 34 | `get_my_requests.php` is called with `user_id=$userId` where `userId` is `userData['contact']`. But `cancel_request.php` uses `request_id`. The inconsistency between using `contact` versus `id` across endpoints is confusing and error-prone. | Standardize on `id` (the primary key) across all API calls. |
| 2 | **Cancel confirmation dialog is missing** | Line 65 | `_cancelRequest` immediately calls `Navigator.pop(context)` then fires the cancel API. There's no "Are you sure?" confirmation. Accidental taps cancel requests irreversibly. | Add a confirmation `AlertDialog` before calling the cancel API. |
| 3 | **No filtering by status** | N/A | All requests (pending, confirmed, completed, cancelled) are shown in one flat list. | Add status filter chips or tabs (Pending / Confirmed / Completed / Cancelled). |
| 4 | **No pull-to-refresh on empty state** | Lines 216-219 | `_buildEmptyState` returns a plain `ListView` wrapping the empty illustration. `RefreshIndicator` only wraps the populated list. | Wrap the empty state in `RefreshIndicator` as well. |
| 5 | **Detail modal uses `showModalBottomSheet` with `shape`** | Line 96 | The `shape` parameter is used but `backgroundColor: Colors.transparent` is not set, which is inconsistent with other screens (history, news) that use transparent background with rounded container. | Standardize all bottom sheets to use the same pattern: transparent background + internal rounded container. |

---

### 2.8 Splash Screen (`lib/screens/splash_screen.dart`)

**UI Score:** N/A (unused)  
**UX Score:** N/A (unused)  
**Priority:** Low

#### Issue

The `SplashScreen` widget is defined but never referenced anywhere in the app. The native splash is handled by `flutter_native_splash`. This is dead code.

**Recommendation:** Delete `lib/screens/splash_screen.dart` to reduce confusion and bundle size.

---

### 2.9 Accessibility & Mobile Responsiveness Review

**Priority:** High

This section covers cross-cutting accessibility and responsiveness issues that affect multiple screens.

#### Accessibility Issues

| # | Issue | Screens Affected | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| A11Y-01 | **No semantic labels on icons** | All screens | `IconButton` widgets (logout, refresh) and decorative icons in login screen have no `semanticLabel`. Screen readers like TalkBack cannot describe these to visually impaired users. | Add `semanticLabel` to every `IconButton`: `IconButton(icon: const Icon(Icons.logout), semanticLabel: 'Log out', onPressed: ...)`. |
| A11Y-02 | **No `Semantics` widget wrapping** | All screens | None of the custom card widgets use `Semantics` or `MergeSemantics`. Screen readers navigate through individual `Container`, `Column`, `Row` widgets with no meaningful grouping. | Wrap tappable cards in `Semantics(button: true, label: 'History — View consultation records', child: ...)`. |
| A11Y-03 | **OTP TextField has `textAlign: TextAlign.center` with no `semanticLabel`** | `login_screen.dart:327` | The centered OTP field looks like a code entry but screen readers read it as a generic text field. Users don't know it's for a 6-digit OTP. | Add `semanticsLabel: 'Enter 6-digit verification code'` to the OTP TextField decoration. |
| A11Y-04 | **Insufficient color contrast on grey text** | Multiple | `Colors.grey[500]` (used for subtitles in login card, history details) on white background has a contrast ratio of ~3.5:1, below the WCAG AA minimum of 4.5:1 for body text. | Replace `Colors.grey[500]` with `Colors.grey[600]` or `Colors.grey[700]` for body text. |
| A11Y-05 | **Touch targets below 48×48dp** | `news_screen.dart:126-135` | The clear button in the search bar uses a default `IconButton` which may render below the minimum 48×48dp touch target on some devices. | Set `iconSize: 24` and ensure `padding` creates at least a 48×48dp hit area: `IconButton(padding: const EdgeInsets.all(12), ...)`. |
| A11Y-06 | **No `excludeFromSemantics` on decorative elements** | `login_screen.dart:142-146` | The floating decorative icons with 0.05 opacity are read by screen readers as real interactive elements, confusing users. | Add `excludeFromSemantics: true` to the `Opacity` widget or wrap in `ExcludeSemantics`. |
| A11Y-07 | **No text scaling support testing** | All screens | `Text` widgets use hardcoded `fontSize` values. Users who increase system font size may see text overflow or clipped content. No `textScaleFactor` clamping is implemented. | Set `MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.3)` in `MaterialApp` builder to cap scaling while still allowing accessibility. |

**Code Fix — A11Y-01:**
```dart
// home_dashboard.dart, line 61-64 — REPLACE
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () => _showLogoutDialog(context),
)
// WITH:
IconButton(
  icon: const Icon(Icons.logout),
  semanticLabel: 'Log out',
  onPressed: () => _showLogoutDialog(context),
)
```

**Code Fix — A11Y-04 (contrast fix):**
```dart
// login_screen.dart, line 246 and similar — REPLACE
style: TextStyle(fontSize: 13, color: Colors.grey[500]),
// WITH:
style: TextStyle(fontSize: 13, color: Colors.grey[700]),
```

#### Mobile Responsiveness Issues

| # | Issue | Screens Affected | Why It's a Problem | Recommendation |
|---|---|---|---|---|
| RESP-01 | **No `LayoutBuilder` or `MediaQuery` breakpoints** | All screens | The app uses fixed padding (`EdgeInsets.all(20)`) and grid column counts (`crossAxisCount: 2`) that don't adapt to tablet or landscape modes. On a 10" tablet, the 2-column grid leaves excessive whitespace. | Use `LayoutBuilder` to switch between 2-column (phone), 3-column (small tablet), and 4-column (large tablet) layouts. |
| RESP-02 | **Bottom sheet height uses raw `MediaQuery` percentage** | `history_screen.dart:58`, `news_screen.dart:275` | `MediaQuery.of(context).size.height * 0.85` works on phones but creates sheets taller than the screen on landscape mode. | Use `MediaQuery.of(context).orientation` to set different heights: 0.85 for portrait, 0.95 for landscape. Or use `FractionallySizedBox` with `maxHeight` constraints. |
| RESP-03 | **No `SafeArea` on all screens** | `home_dashboard.dart`, `history_screen.dart`, `news_screen.dart`, `request_status_screen.dart` | Only `login_screen.dart` uses `SafeArea`. Other screens may have content hidden behind notches, camera cutouts, or navigation bars. | Wrap every `Scaffold` body in `SafeArea` or add `padding: MediaQuery.of(context).padding` to body containers. |
| RESP-04 | **Perk card `childAspectRatio: 1.1` doesn't scale** | `perks_screen.dart:239` | The 2-column grid with `childAspectRatio: 1.1` works for specific screen widths but squishes cards on narrow screens. | Calculate aspect ratio dynamically based on available width: `(availableWidth / columnCount) / cardHeight`. |
| RESP-05 | **Keyboard overflow on teleconsult form** | `perks_screen.dart:53` | The bottom sheet with teleconsult form uses `viewInsets.bottom + 20` padding, but on small screens with the keyboard open, the submit button may still be hidden. | Wrap the entire form in `SingleChildScrollView` with `reverse: true` so the submit button scrolls into view when the keyboard opens. Already partially done—verify it works on 4" screens. |
| RESP-06 | **No landscape layout optimization** | All screens | The dashboard grid, news tiles, and history cards all assume portrait orientation. In landscape, cards become extremely wide and text lines become uncomfortably long. | Either lock orientation to portrait for phone form factors, or add landscape layouts with wider grids (e.g., `crossAxisCount: isLandscape ? 4 : 2`). |

**Code Fix — RESP-01 (adaptive grid):**
```dart
// Replace hardcoded GridView.count in home_dashboard.dart:112-169
// WITH:
LayoutBuilder(
  builder: (context, constraints) {
    final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [ /* ... same tiles ... */ ],
    );
  },
)
```

---

### 2.10 Material Design 3 Compliance Summary

| Aspect | Current State | Gap | Recommendation |
|---|---|---|---|
| **`useMaterial3` flag** | Enabled in `main.dart:41` | Used, but no MD3-specific components leveraged (e.g., `NavigationBar`, `NavigationDrawer`, `SearchBar`, `DatePickerDialog` with MD3 input mode). | Replace the grid-based home navigation with `NavigationBar` (bottom nav) for primary destinations. Use `SearchAnchor` for the news search instead of inline `TextField`. |
| **Dynamic color** | `ColorScheme.fromSeed()` used | Dynamic color (`ColorScheme.fromImageProvider` / platform dynamic color) not utilized. On Android 12+, the app ignores the user's wallpaper-based color scheme. | Use `DynamicColorBuilder` from the `dynamic_color` package to support Material You theming: `colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen, dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot)`. |
| **Typography scale** | Inherited from Material 3 defaults | No custom `TextTheme` defined. All text uses inline `TextStyle` with hardcoded sizes, breaking the MD3 type scale hierarchy. | Define `textTheme: Theme.of(context).textTheme` and use named styles (`headlineMedium`, `titleLarge`, `bodyMedium`) instead of raw `fontSize` values. This ensures text scales consistently with the MD3 type ramp. |
| **Shape scale** | Rounded corners used (12, 15, 16, 18, 20, 25, 35) | Inconsistent corner radii across the app. MD3 defines a shape scale (extra-small through extra-large) that maps to component categories. | Define shape tokens: `ShapeToken.extraSmall` (4), `small` (8), `medium` (12), `large` (16), `extraLarge` (28). Map each to specific components. |
| **Elevation / surface tints** | Manual `BoxShadow` on cards | MD3 uses surface tint overlays instead of drop shadows in its specification. The app uses traditional `boxShadow` which is an M2 pattern. | Remove `BoxShadow` from cards and use `CardTheme` with MD3 elevation: `surfaceTintColor: Theme.of(context).colorScheme.surfaceTint`. |
| **Bottom sheets** | Custom `showModalBottomSheet` with rounded containers | MD3 bottom sheets have a standardized look with drag handle, surface tint, and proper insets. The app manually recreates this pattern inconsistently. | Use `showModalBottomSheet` with `useSafeArea: true` and `showDragHandle: true` (Flutter 3.16+). This automatically applies MD3 styling. |

---

## 3. Performance Findings

### 3.1 Missing `const` Widgets

**Impact:** Medium  
**Instances:** ~40+ across all files

**Location examples:**
- `main.dart:43` — `FutureBuilder<Widget>(` — not const
- `home_dashboard.dart:56-57` — `AppBar(title: const Text(...))` — AppBar itself is not const
- `login_screen.dart:223` — `Container(padding: const EdgeInsets.all(30),` — Container is not const
- `news_screen.dart:148` — `Padding(padding: const EdgeInsets.symmetric(horizontal: 5),` — Padding is not const
- `perks_screen.dart:231` — `Text("Other Benefits", style: ...)` — not const

**Fix:** Add `const` keyword to all widgets whose constructor parameters are compile-time constants. This reduces rebuild overhead significantly.

### 3.2 Unoptimized ListView Usage

**Impact:** Medium  
**Location:** `history_screen.dart:195`, `request_status_screen.dart:220`

Both `ListView.builder` usages lack `itemExtent` or `prototypeItem`. Flutter must measure every item to calculate scroll extent, causing jank during fast scrolling.

**Fix:**
```dart
// Add to ListView.builder:
ListView.builder(
  itemExtent: 72, // Fixed height for ListTile-based cards
  // ...
)
```

### 3.3 FutureBuilder Resets on Every Rebuild

**Impact:** High  
**Location:** `main.dart:43`, `history_screen.dart:170`, `news_screen.dart:174`

`FutureBuilder` in the `build` method recreates the future every time the widget rebuilds. The future is re-executed, causing duplicate network requests.

**Fix:** Store the future in `initState` (for `StatefulWidget`) or as a final field:
```dart
// history_screen.dart — ALREADY CORRECT (stored in initState:20-22)
// news_screen.dart — ALREADY CORRECT (stored in initState:59-61)

// main.dart:44 — PROBLEMATIC (inline FutureBuilder)
// Fix: Move _checkLoginStatus result to a field initialized before build
```

For `main.dart`, since `MyApp` is a `StatelessWidget`, convert the `FutureBuilder` to use a `late final` field initialized in `MyApp`'s constructor, or convert to `StatefulWidget`.

### 3.4 Large Build Methods

**Impact:** Medium  
**Location:** `perks_screen.dart:216-278` (62-line `build` method), `login_screen.dart:126-173` (47-line `build` method)

Large build methods are hard to read, harder to optimize, and cause the entire widget subtree to rebuild when any state changes.

**Fix:** Extract sections into separate widget classes or at minimum into separate build methods:
```dart
// Instead of:
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(children: [
      _buildSectionA(), // 20 lines
      _buildSectionB(), // 30 lines
      _buildSectionC(), // 30 lines
    ]),
  );
}
// Do:
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(children: [
      const SectionA(),
      const SectionB(),
      const SectionC(),
    ]),
  );
}
```

### 3.5 Image Loading Without Caching

**Impact:** Medium  
**Location:** `login_screen.dart:196` (`Image.asset`), `news_screen.dart` (placeholder only, no real images yet)

`Image.asset` is fine for bundled assets, but if `Image.network` is added (as recommended for news thumbnails), there's no caching layer.

**Fix:** Add `cached_network_image` package:
```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.1
```
```dart
CachedNetworkImage(
  imageUrl: news.imageUrl,
  width: 90, height: 90,
  fit: BoxFit.cover,
  placeholder: (_, __) => const Icon(Icons.article_rounded),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
)
```

### 3.6 Network Timeouts Not Uniform

**Impact:** Low  
**Location:** Various

- `login_screen.dart:39` — 4-second timeout
- `perks_screen.dart:160` — 10-second timeout
- `request_status_screen.dart:38`, `:73` — 10-second timeout
- `history_screen.dart`, `news_screen.dart` — No timeout specified

Inconsistent timeouts lead to unpredictable UX. Some requests hang indefinitely.

**Fix:** Define a global timeout in `AppConfig`:
```dart
static const Duration apiTimeout = Duration(seconds: 10);
```
Apply `.timeout(AppConfig.apiTimeout)` to every HTTP request.

---

## 4. Security Findings

### 4.1 Critical Severity

| # | Finding | Location | Detail | Fix |
|---|---|---|---|---|
| SEC-01 | **Hardcoded Laravel APP_KEY** | `verify_otp.php:7` | `$appKey = "base64:NusO0N5yu2WM4bbP7qDg9DfJc9FpglsPgtvSapEHxpM=";` — The encryption key is in source code. Anyone with access to the repo can decrypt all Laravel-encrypted data. | Move to environment variable or a `.env` file excluded from git. Use `$_ENV['APP_KEY']` or `getenv('APP_KEY')`. |
| SEC-02 | **Database root with no password** | `config.php:6-7` | `$username = "root"; $password = "";` — Full database access with no authentication. | Create a dedicated MySQL user with minimal privileges (SELECT, INSERT, UPDATE on specific tables) and a strong password. Store credentials in environment variables. |
| SEC-03 | **HTTP in production** | `config.dart:8` | `baseUrl = "http://$serverIP/api"` — All traffic (phone numbers, OTPs, personal data) is transmitted in plaintext. | Change to `https://`. Ensure the server has a valid SSL certificate. |

### 4.2 High Severity

| # | Finding | Location | Detail | Fix |
|---|---|---|---|---|
| SEC-04 | **No authentication tokens** | All screens | Login stores raw user JSON. No JWT, no session token, no expiration. The backend cannot verify request authenticity. | Implement JWT-based auth. On login, return a signed token. Store it in `flutter_secure_storage`. Send it as `Authorization: Bearer <token>` header on every request. |
| SEC-05 | **OTP logs never expire** | `check_user.php:26` | OTP codes are inserted into `otp_logs` but there's no cron job or TTL to clean old entries. The table grows indefinitely. | Add a `created_at` index and a cleanup script, or use `TIMESTAMP` with `ON DELETE` via a scheduled event. |
| SEC-06 | **No rate limiting on OTP endpoints** | `check_user.php`, `verify_otp.php` | An attacker can brute-force OTP verification or spam OTP generation requests. | Implement rate limiting (e.g., 5 OTP requests per phone number per hour, 3 verification attempts per OTP). |

### 4.3 Medium Severity

| # | Finding | Location | Detail | Fix |
|---|---|---|---|---|
| SEC-07 | **Sensitive data logged via `dev.log`** | `login_screen.dart:44` | `dev.log("Server Response: $data", name: "AUTH")` — The full server response (including OTP) is logged to the console. In release mode, `dart:developer` logs are stripped, but debug builds leak data. | Remove `dev.log` calls that print response bodies, or wrap in `assert()` / `kDebugMode` check. |
| SEC-08 | **`SharedPreferences` for sensitive session data** | `login_screen.dart:92` | User session (including `id`, `contact`, `full_name`) is stored in `SharedPreferences`, which is unencrypted on Android and stored in plaintext plist on iOS. | Use `flutter_secure_storage` for any PII (personally identifiable information). |

### 4.4 Low Severity

| # | Finding | Location | Detail | Fix |
|---|---|---|---|---|
| SEC-09 | **User ID exposed in GET URL** | `history_screen.dart:28` | `get_history.php?user_id=${widget.userId}` — The user ID is visible in URL query params, which get logged by proxies/CDNs. | Pass `user_id` via POST body or use JWT to identify the user server-side from the token. |
| SEC-10 | **No HTTPS enforcement via code** | `config.dart` | No certificate pinning or HTTPS-only enforcement. | Add `flutter_ssl_pinning` or at minimum use HTTPS with certificate validation. |

---

## 5. Code Quality Findings

### 5.1 Folder Organization

**Current structure:**
```
lib/
  main.dart
  core/
    config.dart
  models/          (empty)
  screens/
    login_screen.dart
    home_dashboard.dart
    history_screen.dart
    news_screen.dart
    perks_screen.dart
    profile_screen.dart
    request_status_screen.dart
    splash_screen.dart
  services/        (empty)
  widgets/         (empty)
```

**Issues:**
1. `models/` is empty — the `NewsArticle` model is defined directly in `news_screen.dart` (lines 8-38). Models should live in their own files.
2. `services/` is empty — all API logic is embedded in screen files.
3. `widgets/` is empty — no reusable widgets extracted despite clear duplication (`_showTopNotification`, card patterns, bottom sheet drag handles).
4. No `theme/` or `constants/` folder — brand colors, text styles, and spacing are duplicated across files.

**Recommended structure:**
```
lib/
  main.dart
  app.dart                    (MyApp extracted from main.dart)
  core/
    config.dart
    theme.dart                (AppTheme with colors, text styles)
    constants.dart            (API timeouts, app metadata)
  models/
    user.dart
    news_article.dart
    history_item.dart
    teleconsult_request.dart
  services/
    api_service.dart          (Base HTTP client with auth headers)
    auth_service.dart         (Login, logout, session management)
    history_service.dart
    news_service.dart
    perks_service.dart
  screens/
    login/
      login_screen.dart
    dashboard/
      home_dashboard.dart
    history/
      history_screen.dart
    news/
      news_screen.dart
    perks/
      perks_screen.dart
    profile/
      profile_screen.dart
    requests/
      request_status_screen.dart
  widgets/
    app_card.dart
    app_notification.dart
    app_bottom_sheet.dart
    menu_tile.dart
    info_tile.dart
    loading_shimmer.dart
```

### 5.2 State Management

**Current state:** No state management. Every screen uses `setState` and `SharedPreferences` directly.

**Impact:** As the app grows, sharing state between screens becomes impossible. The dashboard can't reflect pending request counts because `RequestStatusScreen` manages its own state independently.

**Recommendation:** Adopt **Riverpod** (lightweight, testable, good for this app size):
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
```

### 5.3 Anti-Patterns Identified

| Anti-Pattern | Location | Explanation |
|---|---|---|
| **StatelessWidget with side effects** | `home_dashboard.dart:10`, `perks_screen.dart:9` | Widgets that trigger navigation, show dialogs, or make API calls should be `StatefulWidget`. |
| **Inline JSON parsing without model classes** | `history_screen.dart:33`, `request_status_screen.dart:43` | `data['data']` returns `List<dynamic>` with no type safety. |
| **`FutureBuilder` in build with inline future** | `main.dart:43-44` | `future: _checkLoginStatus()` creates a new future every rebuild. |
| **Magic strings for SharedPreferences keys** | `main.dart:23`, `login_screen.dart:92`, etc. | `'user_session'` is repeated as a string literal. One typo breaks session persistence. |
| **Copy-pasted `_showTopNotification`** | `perks_screen.dart:417`, `request_status_screen.dart:167` | 35 identical lines duplicated. |
| **Empty `onPressed` callbacks** | `perks_screen.dart:242,244,258`, `profile_screen.dart:62` | Deceptive UI — tappable elements that do nothing. |
| **Comment language mixed (English + Filipino)** | Throughout all files | Some comments are in English, others in Filipino. Choose one language for maintainability. |
| **`.code-workspace` files in `lib/`** | `lib/core/akop_member_app.code-workspace`, `lib/screens/akop_member_app.code-workspace` | Workspace files don't belong in the source tree. Move to project root or `.vscode/`. |

### 5.4 Naming Convention Issues

| Issue | Location | Suggestion |
|---|---|---|
| `AppConfig` class | `config.dart:1` | Rename to `ApiConfig` or `AppConstants` to clarify it's not a full app configuration. |
| `_buildMenuTile` | `home_dashboard.dart:194` | Tile naming is inconsistent: dashboard uses `MenuTile`, perks uses `PerkCard`, profile uses `InfoTile`. Standardize naming. |
| `HistoryScreen` / `NewsScreen` / `PerksScreen` / `ProfileScreen` | All screens | Inconsistent — some are `StatefulWidget`, others `StatelessWidget`. This should be driven by whether the screen has mutable state, not by convenience. |
| `_historyFuture` | `history_screen.dart:16` | Hungarian-notation-ish naming. Prefer `_history` or use a state management solution that eliminates the need for future fields. |

---

## 6. Backend Integration Review (PHP API)

### 6.1 API Call Patterns

**Current approach:** Every screen calls `http.get`/`http.post` directly with `Uri.parse`, `json.decode`, and manual error handling.

**Problems:**
1. No base HTTP client — URL construction, headers, and error handling duplicated.
2. No request/response interceptors — can't add auth headers globally.
3. No retry logic — network failures give immediate error with no automatic retry.
4. No request deduplication — rapid taps can fire multiple identical requests.

**Recommendation:** Create `ApiService` class:
```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = AppConfig.baseUrl;
  String? _authToken;

  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers)
        .timeout(AppConfig.apiTimeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, String>? body}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(uri, headers: _headers, body: body)
        .timeout(AppConfig.apiTimeout);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') return data;
      throw ApiException(data['message'] ?? 'Unknown error');
    }
    throw ApiException('Server error: ${response.statusCode}');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
```

### 6.2 Slow Endpoints & Missing Caching

| Endpoint | Issue | Recommendation |
|---|---|---|
| `get_news.php` | Called on every screen visit. News content rarely changes. | Cache response in memory or `SharedPreferences` with a 5-minute TTL. Refresh on pull-to-refresh only. |
| `get_history.php` | `SELECT *` returns all columns. If `tblcrmlogsdata` has BLOB/text columns, this is wasteful. | Select only needed columns. Add pagination (`LIMIT 20 OFFSET 0`) for large datasets. |
| `get_my_requests.php` | No pagination. A user with 500+ requests gets all at once. | Add `LIMIT`/`OFFSET` with infinite scroll on the Flutter side. |

### 6.3 Authentication Flow Issue

**Current flow:**
1. User enters phone → `check_user.php` → OTP generated, stored in `otp_logs`, returned in response
2. User enters OTP → `verify_otp.php` → user data returned, stored in `SharedPreferences`
3. Subsequent requests: `SharedPreferences` → `user_session` → no server validation

**Problem:** The backend has no way to know if a request is from an authenticated user. Any `user_id` parameter can be manipulated.

**Recommended flow:**
1. `check_user.php` → returns `session_token` (short-lived, e.g., 5 minutes)
2. `verify_otp.php` → accepts `session_token` + `otp_code` → returns JWT access token + refresh token
3. All subsequent requests → `Authorization: Bearer <jwt>` → backend validates token signature and expiration
4. `refresh_token.php` → accepts refresh token → returns new JWT

### 6.4 PHP Code Issues

| File | Issue | Fix |
|---|---|---|
| `config.php` | `header('Content-Type: application/json')` is set globally but some endpoints also set it, causing potential double-headers. | Remove from `config.php`; add to each endpoint individually or use a middleware pattern. |
| `verify_otp.php` | `decryptLaravelData` function uses `@unserialize` which suppresses errors. If decryption fails, `null` is returned silently with no log. | Log decryption failures for debugging. |
| `get_history.php` | `$user_id = $_GET['user_id'] ?? ''` — no validation that this is a numeric ID. SQL injection possible if `bind_param` were removed. | Though `bind_param` prevents injection, validate `user_id` as integer with `intval()`. |
| `cancel_request.php` | **No authorization check.** Any user can cancel any request by guessing the `request_id`. The endpoint accepts `$_POST['id']` and updates the row with no owner verification. | Verify the request belongs to the authenticated user before cancelling: `UPDATE teleconsult_requests SET status = 'Cancelled' WHERE request_id = ? AND phone_number = ?`. |
| `save_teleconsult.php` | **SQL query omits `user_id` column.** Lines 22-24: `INSERT INTO teleconsult_requests (consultation_reason, preferred_date, phone_number) VALUES (?, ?, ?)` — `user_id` is received from `$_POST` but never inserted. The `teleconsult_requests` table likely has a `user_id` foreign key that ends up NULL. | Add `user_id` to the INSERT: `INSERT INTO teleconsult_requests (user_id, consultation_reason, preferred_date, phone_number) VALUES (?, ?, ?, ?)`. |
| `save_teleconsult.php` | **`ob_start()` and `ob_clean()` usage.** Lines 3, 14, 37, 48 — Output buffering is used to prevent stray output, but `ob_clean()` is called inconsistently (missing before first `echo` on line 3's `ob_start()`). This can cause "headers already sent" warnings. | Use a consistent output buffer pattern: call `ob_clean()` before every `echo json_encode(...)`, or better, use a `sendJson()` helper function. |
| `get_news.php` | **Returns raw array on success, plain text on failure.** Line 17: `echo "0 results"` — this is not valid JSON. When the Flutter app tries to `json.decode(response.body)`, it will throw a `FormatException`. The News screen's `FutureBuilder` will display the generic error from its `hasError` branch. | Return `json_encode([])` or `json_encode(["status" => "success", "data" => []])` for empty results. Never return plain text. |
| `get_news.php` | **Double `header('Content-Type')` call.** Lines 2 and 24 both set the header. PHP may emit a warning if output has already started. | Remove line 24 (the duplicate). |
| `get_news.php` | **No prepared statement.** Uses `$conn->query($sql)` with no parameterization. While there are no user inputs in this query, using `prepare()` consistently is best practice and prevents future injection if parameters are added. | Use `$conn->prepare()` even for parameterless queries to maintain a consistent pattern. |
| `get_my_requests.php` | **Uses `phone_number` as filter with `user_id` parameter name.** Line 15: `WHERE phone_number = ?` but the parameter is named `user_id` in `$_GET`. This conflates phone number with user ID — if a user changes their phone number, they lose access to old requests. | Rename the query parameter to `phone_number` or filter by actual `user_id` (primary key) which is stable. |
| `config.php` | **Connection opened but never closed.** `config.php` creates `$conn` in global scope. Each endpoint that includes it must manually close the connection. Some do (`get_news.php:21`, `save_teleconsult.php:57`, `get_my_requests.php:43`) but others don't (`check_user.php`, `verify_otp.php`, `get_history.php`). | Add `$conn->close()` in a `__destruct` or require all endpoints to close the connection. Or use a `finally` block. |

---

## 7. Recommended Refactoring Plan

### Phase 1 — Quick Wins (1–2 days)

These changes require minimal restructuring and deliver immediate value.

| # | Task | Effort | Files Affected |
|---|---|---|---|
| 1 | Extract brand color into `AppConfig.primaryGreen` | 30 min | All 7 screen files |
| 2 | Add `const` to all eligible widgets | 1 hour | All files |
| 3 | Fix logout to clear `SharedPreferences` | 15 min | `home_dashboard.dart` |
| 4 | Remove OTP from SnackBar display | 5 min | `login_screen.dart` |
| 5 | Fix duplicate `setModalState` call | 5 min | `perks_screen.dart:180-181` |
| 6 | Show "Coming Soon" for empty perk callbacks | 15 min | `perks_screen.dart` |
| 7 | Show actual mobile number in Profile | 5 min | `profile_screen.dart:53` |
| 8 | Replace blank loading screen with branded splash | 15 min | `main.dart:58` |
| 9 | Delete unused `splash_screen.dart` | 5 min | `screens/splash_screen.dart` |
| 10 | Remove `.code-workspace` files from `lib/` | 5 min | `core/`, `screens/` |

### Phase 2 — Medium Effort (3–5 days)

These require architectural changes but produce significant code quality improvements.

| # | Task | Effort | Files Affected |
|---|---|---|---|
| 11 | Create `ApiService` class with unified HTTP handling | 4 hours | New `services/api_service.dart`, all screens |
| 12 | Extract `NewsArticle` model to `models/news_article.dart` | 30 min | `news_screen.dart`, new `models/` |
| 13 | Extract reusable `AppNotification` widget | 1 hour | `perks_screen.dart`, `request_status_screen.dart`, new `widgets/` |
| 14 | Standardize all bottom sheets to single `AppBottomSheet` wrapper | 2 hours | `history_screen.dart`, `news_screen.dart`, `request_status_screen.dart` |
| 15 | Add `SharedPreferences` key constants class | 30 min | `main.dart`, `login_screen.dart`, all services |
| 16 | Convert `HomeDashboard` and `PerksScreen` to `StatefulWidget` | 1 hour | `home_dashboard.dart`, `perks_screen.dart` |
| 17 | Add confirmation dialog to cancel request | 30 min | `request_status_screen.dart` |
| 18 | Add image caching (cached_network_image) | 1 hour | `pubspec.yaml`, `news_screen.dart` |
| 19 | Standardize API timeout across all requests | 30 min | `config.dart`, all screens |
| 20 | Add pull-to-refresh support to empty states | 1 hour | `history_screen.dart`, `request_status_screen.dart` |

### Phase 3 — Major Improvements (1–3 weeks)

These require significant architecture changes and should be planned carefully.

| # | Task | Effort | Description |
|---|---|---|---|
| 21 | Implement JWT authentication | 3 days | Add token-based auth to PHP backend and Flutter app |
| 22 | Migrate to Riverpod state management | 5 days | Replace all `setState` with Riverpod providers |
| 23 | Enforce HTTPS with certificate pinning | 1 day | Update `AppConfig`, add SSL pinning |
| 24 | Move sensitive storage to `flutter_secure_storage` | 1 day | Replace `SharedPreferences` for PII |
| 25 | Add skeleton loading shimmer to all list screens | 2 days | News, History, Request Status |
| 26 | Implement dark mode support | 2 days | Leverage existing `useMaterial3: true` |
| 27 | Add integration/unit tests | 3 days | Test auth flow, API services, models |
| 28 | PHP backend hardening | 3 days | JWT middleware, rate limiting, DB user hardening, env vars |
| 29 | Add offline support with local caching | 3 days | Cache news/history locally for offline viewing |
| 30 | Add analytics and crash reporting | 1 day | Firebase Crashlytics + Analytics |

---

## 8. Top 20 Improvements Ranked by Impact

| Rank | Improvement | Category | Impact | Effort |
|---|---|---|---|---|
| 1 | **Fix logout to clear SharedPreferences** | Security | Critical | 15 min |
| 2 | **Enforce HTTPS for production domain** | Security | Critical | 1 hour |
| 3 | **Move Laravel APP_KEY to environment variable** | Security | Critical | 30 min |
| 4 | **Create database user with restricted privileges** | Security | Critical | 1 hour |
| 5 | **Implement JWT authentication** | Security/Architecture | Critical | 3 days |
| 6 | **Create ApiService class (unified HTTP client)** | Architecture | High | 4 hours |
| 7 | **Extract brand colors into AppTheme constants** | Code Quality | High | 30 min |
| 8 | **Add `const` to all eligible widgets** | Performance | High | 1 hour |
| 9 | **Implement Riverpod state management** | Architecture | High | 5 days |
| 10 | **Move sensitive data to flutter_secure_storage** | Security | High | 1 day |
| 11 | **Remove OTP from SnackBar display** | Security | High | 5 min |
| 12 | **Add rate limiting to OTP endpoints** | Security | High | 2 hours |
| 13 | **Implement "Coming Soon" for empty perk buttons** | UX | Medium | 15 min |
| 14 | **Show real mobile number in Profile** | UX | Medium | 5 min |
| 15 | **Add confirmation dialog for cancel request** | UX | Medium | 30 min |
| 16 | **Extract reusable notification widget** | Code Quality | Medium | 1 hour |
| 17 | **Add image caching for news thumbnails** | Performance | Medium | 1 hour |
| 18 | **Standardize API timeouts** | Performance | Medium | 30 min |
| 19 | **Add skeleton loading shimmers** | UX | Medium | 2 days |
| 20 | **Delete unused splash_screen.dart** | Code Quality | Low | 5 min |

---

## 9. Appendix: Proposed `app_theme.dart`

```dart
// lib/core/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primaryGreen = Color(0xFF249A19);
  static const Color primaryGreenDark = Color(0xFF0D7A04);
  static const Color primaryGreenLight = Color(0xFF50B446);
  static const Color deepTeal = Color(0xFF004D40);
  static const Color bgLight = Color(0xFFF0F7F0);

  // Semantic Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF1976D2);

  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w500,
  );

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 25.0;

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
  );
}
```

---

## 10. Appendix: Proposed `api_constants.dart`

```dart
// lib/core/api_constants.dart
class ApiConstants {
  ApiConstants._();

  // SharedPreferences Keys
  static const String keyUserSession = 'user_session';
  static const String keyAuthToken = 'auth_token';

  // API Endpoints
  static const String checkUser = 'check_user.php';
  static const String verifyOtp = 'verify_otp.php';
  static const String getHistory = 'get_history.php';
  static const String getNews = 'get_news.php';
  static const String saveTeleconsult = 'save_teleconsult.php';
  static const String getMyRequests = 'get_my_requests.php';
  static const String cancelRequest = 'cancel_request.php';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration otpTimeout = Duration(seconds: 5);

  // Limits
  static const int maxOtpLength = 6;
  static const int newsPageSize = 20;
}
```

---

*End of Audit Report — AKOP MIYEMBRO v1.0.0+1*