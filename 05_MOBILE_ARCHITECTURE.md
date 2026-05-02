# 05 — Mobile Architecture (Flutter)

> **AirShield Mobile** · Flutter 3.10+ · Dart · BLoC Pattern
> Source: `airshield_mobile/lib/`

---

## MỤC LỤC

1. [Kiến Trúc Tổng Quan](#1-kiến-trúc-tổng-quan)
2. [Cấu Trúc Thư Mục](#2-cấu-trúc-thư-mục)
3. [Feature Architecture (Phân Tích Từng Feature)](#3-feature-architecture)
4. [Screens Inventory — Danh Sách Màn Hình](#4-screens-inventory)
5. [BLoC Pattern Chi Tiết](#5-bloc-pattern-chi-tiết)
6. [Services & Utilities](#6-services--utilities)
7. [API Client (Dio)](#7-api-client-dio)
8. [Theme System](#8-theme-system)
9. [Key Widgets](#9-key-widgets)
10. [Navigation Pattern](#10-navigation-pattern)
11. [Data Models (Freezed)](#11-data-models-freezed)
12. [App Startup & Dependency Injection](#12-app-startup--dependency-injection)

---

## 1. Kiến Trúc Tổng Quan

AirShield Mobile sử dụng **Feature-First Architecture** kết hợp **BLoC Pattern** cho state management. Mỗi feature được tổ chức theo 2 tầng:

```
┌────────────────────────────────────────────────────────────────────┐
│                    Presentation Layer                              │
│         Pages (UI) + BLoC (State) + Widgets (Reusable)            │
├────────────────────────────────────────────────────────────────────┤
│                      Data Layer                                    │
│          Repositories (API calls) + Models (JSON parsing)          │
├────────────────────────────────────────────────────────────────────┤
│                     Core Layer                                     │
│   ApiClient · LocationService · SecureStorage · Theme · i18n      │
└────────────────────────────────────────────────────────────────────┘
```

> **Lưu ý**: Không có tầng **Domain** riêng biệt (không có Use Cases, Entities). Repository trực tiếp được inject vào BLoC. Đây là kiến trúc gọn hơn Clean Architecture đầy đủ — phù hợp với quy mô dự án.

### Quan Hệ Component

```
main.dart
  │
  ├── MultiBlocProvider (5 global BLoCs)
  │       ├── AuthBloc ──────► AuthRepository ──► ApiClient + SecureStorage
  │       ├── DashboardBloc ─► DashboardRepository ─► ApiClient + LocationService
  │       ├── ThemeBloc ─────► PreferencesStorage
  │       ├── LanguageBloc ──► PreferencesStorage
  │       └── NotificationsBloc ─► NotificationService
  │
  └── MaterialApp
          └── AuthWrapper
                  ├── LoginPage (Unauthenticated)
                  └── DashboardPage (Authenticated)
                          └── [Navigator.push to sub-pages]
```

---

## 2. Cấu Trúc Thư Mục

```
airshield_mobile/lib/
│
├── main.dart                           ← App entry, DI, global BLoC setup
│
├── core/                               ← Shared infrastructure
│   ├── network/
│   │   └── api_client.dart             ← Dio HTTP client (interceptors)
│   ├── services/
│   │   └── location_service.dart       ← GPS (geolocator)
│   ├── storage/
│   │   ├── secure_storage.dart         ← JWT token (flutter_secure_storage)
│   │   └── preferences_storage.dart    ← Settings (shared_preferences)
│   ├── theme/
│   │   ├── app_theme.dart              ← Light/Dark ThemeData
│   │   └── theme_bloc.dart             ← ThemeBloc
│   ├── l10n/
│   │   ├── app_localizations.dart      ← i18n delegate
│   │   └── language_bloc.dart          ← LanguageBloc
│   ├── utils/
│   │   ├── error_handler.dart          ← Global error catching + Sentry
│   │   └── validators.dart             ← Form validation helpers
│   └── widgets/
│       ├── common_widgets.dart         ← Reusable UI components
│       └── error_boundary.dart         ← Global error boundary widget
│
└── features/                           ← Feature modules
    ├── auth/
    │   ├── data/
    │   │   ├── models/user.dart         ← User model (Freezed)
    │   │   └── repositories/auth_repository.dart
    │   └── presentation/
    │       ├── bloc/auth_bloc.dart
    │       └── pages/ login_page.dart, register_page.dart
    │
    ├── dashboard/
    │   ├── data/
    │   │   ├── models/ dashboard_data.dart, aqi_forecast.dart,
    │   │   │          aqi_history.dart, aqi_data_point.dart
    │   │   └── repositories/dashboard_repository.dart
    │   └── presentation/
    │       ├── bloc/ dashboard_bloc.dart, aqi_history_bloc.dart
    │       ├── pages/ dashboard_page.dart, aqi_history_page.dart
    │       └── widgets/ aqi_history_chart.dart, loading_widget.dart, error_widget.dart
    │
    ├── map/
    │   ├── data/
    │   │   ├── models/station.dart      ← Station model (Freezed)
    │   │   └── repositories/map_repository.dart
    │   └── presentation/
    │       ├── bloc/map_bloc.dart
    │       └── pages/map_page.dart
    │
    ├── smart_home/
    │   ├── data/
    │   │   ├── models/ device.dart, device_activity.dart
    │   │   └── repositories/smart_home_repository.dart
    │   └── presentation/
    │       ├── bloc/smart_home_bloc.dart
    │       ├── pages/ devices_page.dart, device_details_page.dart
    │       └── widgets/device_card.dart
    │
    ├── chatbot/
    │   ├── data/
    │   │   ├── models/chat_message.dart
    │   │   └── repositories/chatbot_repository.dart
    │   └── presentation/
    │       ├── bloc/chatbot_bloc.dart
    │       ├── pages/chatbot_page.dart
    │       └── widgets/ chat_bubble.dart, chat_input.dart
    │
    ├── automation/
    │   ├── data/
    │   │   ├── models/automation_rule.dart
    │   │   └── repositories/automation_repository.dart
    │   └── presentation/
    │       ├── bloc/automation_bloc.dart
    │       └── pages/ automation_rules_page.dart, create_rule_page.dart
    │
    ├── profile/
    │   ├── data/
    │   │   ├── models/ health_condition.dart, saved_location.dart
    │   │   └── repositories/profile_repository.dart
    │   └── presentation/
    │       ├── bloc/ profile_bloc.dart, locations_bloc.dart
    │       ├── pages/ profile_page.dart, edit_profile_page.dart,
    │       │         health_preferences_page.dart, saved_locations_page.dart,
    │       │         settings_page.dart, about_page.dart,
    │       │         privacy_policy_page.dart, terms_page.dart
    │       └── widgets/profile_menu_item.dart
    │
    └── notifications/
        ├── data/
        │   ├── models/notification.dart
        │   └── services/notification_service.dart
        └── presentation/
            ├── bloc/notifications_bloc.dart
            └── pages/notifications_page.dart
```

**Thống kê:** 8 features · 19 screens · 12 BLoCs · 70 file .dart viết tay

---

## 3. Feature Architecture

### Feature: Auth

```
auth/
├── data/
│   ├── models/
│   │   └── user.dart              ← User (Freezed + json_serializable)
│   │       user.freezed.dart      ← [generated]
│   │       user.g.dart            ← [generated]
│   └── repositories/
│       └── auth_repository.dart   ← IAuthRepository + AuthRepository impl
│
└── presentation/
    ├── bloc/
    │   └── auth_bloc.dart         ← AuthBloc, AuthEvent, AuthState
    └── pages/
        ├── login_page.dart        ← Email/password form
        └── register_page.dart     ← Registration form
```

**Data flow**: `LoginPage → AuthBloc.add(LoginRequested) → AuthRepository.login() → ApiClient.post(/auth/login) → SecureStorage.saveToken() → AuthBloc.emit(Authenticated)`

---

### Feature: Dashboard

```
dashboard/
├── data/
│   ├── models/
│   │   ├── dashboard_data.dart     ← DashboardData (Freezed)
│   │   ├── aqi_forecast.dart       ← AqiForecastResponse (Freezed)
│   │   ├── aqi_history.dart        ← AqiHistoryResponse (Freezed)
│   │   └── aqi_data_point.dart     ← AQIDataPoint (plain Dart)
│   └── repositories/
│       └── dashboard_repository.dart  ← IDashboardRepository + impl
│
└── presentation/
    ├── bloc/
    │   ├── dashboard_bloc.dart     ← DashboardBloc
    │   └── aqi_history_bloc.dart   ← AqiHistoryBloc
    ├── pages/
    │   ├── dashboard_page.dart     ← Main home screen (AQI + chart + actions)
    │   └── aqi_history_page.dart   ← Detailed history with time range picker
    └── widgets/
        ├── aqi_history_chart.dart    ← fl_chart LineChart (history + forecast)
        ├── dashboard_loading_widget.dart  ← Skeleton loading
        └── dashboard_error_widget.dart    ← Error + retry
```

**Data flow**: `DashboardPage → DashboardBloc.add(LoadDashboardData) → DashboardRepository.getDashboardData() → LocationService.getCurrentLocation() → ApiClient.get(/air-quality/current?lat=&lon=) → DashboardBloc.emit(DashboardLoaded)`

---

### Feature: Smart Home

```
smart_home/
├── data/
│   ├── models/
│   │   ├── device.dart            ← SmartDevice, DeviceMode enum
│   │   └── device_activity.dart   ← DeviceActivity log
│   └── repositories/
│       └── smart_home_repository.dart  ← SmartHomeRepository
│
└── presentation/
    ├── bloc/
    │   └── smart_home_bloc.dart   ← SmartHomeBloc
    ├── pages/
    │   ├── devices_page.dart       ← List of devices
    │   └── device_details_page.dart ← Power/mode control UI
    └── widgets/
        └── device_card.dart        ← Device card with toggle
```

**Data flow**: `DeviceDetailsPage → SmartHomeBloc.add(TogglePower) → SmartHomeRepository.togglePower() → ApiClient.post(/smart-home/devices/{id}/command) → SmartHomeBloc.emit(SmartHomeLoaded with updated device)`

---

### Feature: Chatbot

```
chatbot/
├── data/
│   ├── models/
│   │   └── chat_message.dart      ← ChatMessage, MessageRole enum
│   └── repositories/
│       └── chatbot_repository.dart ← ChatbotRepository
│
└── presentation/
    ├── bloc/
    │   └── chatbot_bloc.dart      ← ChatbotBloc
    ├── pages/
    │   └── chatbot_page.dart      ← Chat UI (message list)
    └── widgets/
        ├── chat_bubble.dart       ← Message bubble (user/assistant)
        └── chat_input.dart        ← Text input + send button
```

**Đặc biệt**: `ChatbotBloc` được tạo **mới mỗi lần mở** chatbot page (không phải global BLoC), đảm bảo clean state cho mỗi conversation. Scope được tạo bằng `BlocProvider` nội tuyến trong `MaterialPageRoute`.

---

## 4. Screens Inventory

### 4.1 Danh Sách Tất Cả Màn Hình

| # | Screen Name | File | BLoC | Điều hướng |
|---|-------------|------|------|-----------|
| 1 | **Login** | `auth/pages/login_page.dart` | `AuthBloc` | Entry (nếu chưa auth) |
| 2 | **Register** | `auth/pages/register_page.dart` | `AuthBloc` | Push từ Login |
| 3 | **Dashboard** | `dashboard/pages/dashboard_page.dart` | `DashboardBloc` + `NotificationsBloc` | Entry (sau auth) |
| 4 | **AQI History** | `dashboard/pages/aqi_history_page.dart` | `AqiHistoryBloc` | Push từ Dashboard (tap AQI card) |
| 5 | **Map** | `map/pages/map_page.dart` | `MapBloc` | Push từ Dashboard / Bottom Nav |
| 6 | **Chatbot** | `chatbot/pages/chatbot_page.dart` | `ChatbotBloc` (local) | Push từ FAB |
| 7 | **Devices** | `smart_home/pages/devices_page.dart` | `SmartHomeBloc` | Push từ Bottom Nav |
| 8 | **Device Details** | `smart_home/pages/device_details_page.dart` | `SmartHomeBloc` | Push từ Devices |
| 9 | **Automation Rules** | `automation/pages/automation_rules_page.dart` | `AutomationBloc` | Push từ Settings/Profile |
| 10 | **Create Rule** | `automation/pages/create_rule_page.dart` | `AutomationBloc` | Push từ Automation Rules |
| 11 | **Notifications** | `notifications/pages/notifications_page.dart` | `NotificationsBloc` | Push từ AppBar |
| 12 | **Profile** | `profile/pages/profile_page.dart` | `ProfileBloc` | Push từ Bottom Nav |
| 13 | **Edit Profile** | `profile/pages/edit_profile_page.dart` | `ProfileBloc` | Push từ Profile |
| 14 | **Health Preferences** | `profile/pages/health_preferences_page.dart` | `ProfileBloc` | Push từ Profile |
| 15 | **Saved Locations** | `profile/pages/saved_locations_page.dart` | `LocationsBloc` | Push từ Profile |
| 16 | **Settings** | `profile/pages/settings_page.dart` | `ThemeBloc` + `LanguageBloc` | Push từ Dashboard AppBar |
| 17 | **About** | `profile/pages/about_page.dart` | — | Push từ Profile |
| 18 | **Privacy Policy** | `profile/pages/privacy_policy_page.dart` | — | Push từ Profile |
| 19 | **Terms of Service** | `profile/pages/terms_page.dart` | — | Push từ Profile |

**Tổng**: 19 màn hình · 2 màn hình static (Privacy, Terms) · 17 màn hình có state

### 4.2 Navigation Map

```
AuthWrapper
  │
  ├── LoginPage ──────────────────► RegisterPage
  │                                      │
  └── DashboardPage (Home) ◄─────────────┘ (sau đăng ký thành công)
        │
        ├── [AppBar] ─── NotificationsPage
        │             └─ SettingsPage
        │
        ├── [AQI Card tap] ─── AQIHistoryPage
        │
        ├── [Quick Actions] ─── DevicesPage ─── DeviceDetailsPage
        │                   └─ MapPage
        │
        ├── [FAB] ─── ChatbotPage
        │
        └── [Bottom Nav]
              ├── [0] Home (current)
              ├── [1] MapPage
              ├── [2] DevicesPage ─── DeviceDetailsPage
              └── [3] ProfilePage
                        ├── EditProfilePage
                        ├── HealthPreferencesPage
                        ├── SavedLocationsPage
                        ├── AutomationRulesPage ─── CreateRulePage
                        ├── AboutPage
                        ├── PrivacyPolicyPage
                        └── TermsPage
```

---

## 5. BLoC Pattern Chi Tiết

### 5.1 Phân Loại BLoC

| Scope | BLoC | Vị trí tạo | Lifecycle |
|-------|------|-----------|-----------|
| **Global** | `AuthBloc` | `main.dart` | Suốt app lifetime |
| **Global** | `DashboardBloc` | `main.dart` | Suốt app lifetime |
| **Global** | `ThemeBloc` | `main.dart` | Suốt app lifetime |
| **Global** | `LanguageBloc` | `main.dart` | Suốt app lifetime |
| **Global** | `NotificationsBloc` | `main.dart` | Suốt app lifetime |
| **Feature** | `ChatbotBloc` | `DashboardPage._openChatbot()` | Chỉ khi Chatbot mở |
| **Feature** | `SmartHomeBloc` | `DevicesPage` | Khi vào Devices |
| **Feature** | `MapBloc` | `MapPage` | Khi vào Map |
| **Feature** | `ProfileBloc` | `ProfilePage` | Khi vào Profile |
| **Feature** | `LocationsBloc` | `SavedLocationsPage` | Khi vào Saved Locations |
| **Feature** | `AqiHistoryBloc` | `AQIHistoryPage` | Khi vào History |
| **Feature** | `AutomationBloc` | `AutomationRulesPage` | Khi vào Automation |

---

### 5.2 AuthBloc — Chi Tiết

**File**: `features/auth/presentation/bloc/auth_bloc.dart`

#### Events

| Event | Fields | Mô tả |
|-------|--------|-------|
| `CheckAuthStatus` | — | App khởi động → kiểm tra SecureStorage |
| `LoginRequested` | `email, password` | User submit login form |
| `RegisterRequested` | `name, email, password` | User submit register form |
| `LogoutRequested` | — | User tap logout |

#### States

| State | Fields | Mô tả |
|-------|--------|-------|
| `AuthInitial` | — | Đang kiểm tra (hiển thị splash) |
| `AuthLoading` | — | Đang gọi API |
| `Authenticated` | `user: User` | Đã đăng nhập, có user data |
| `Unauthenticated` | — | Chưa đăng nhập |
| `AuthError` | `message: String` | Lỗi (sai mật khẩu, network...) |

#### Business Logic Flow

```dart
// 1. App start → CheckAuthStatus
_onCheckAuthStatus:
  isLoggedIn = await _repository.isLoggedIn()       // Kiểm tra SecureStorage
  if (isLoggedIn):
    user = await _repository.getCurrentUser()        // Gọi GET /auth/me
    if (user != null): emit(Authenticated(user))
    else: emit(Unauthenticated())
  else: emit(Unauthenticated())

// 2. Login
_onLoginRequested:
  emit(AuthLoading)
  response = await _repository.login(LoginRequest)   // POST /auth/login (form-encoded)
  await SecureStorage.saveToken(response.access_token)
  emit(Authenticated(user: response.user))
  // catch AuthException → emit(AuthError)

// 3. Logout
_onLogoutRequested:
  await _repository.logout()                         // Clear SecureStorage + ApiClient token
  emit(Unauthenticated)
```

#### AuthWrapper Integration

```dart
// main.dart - AuthWrapper
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      // Trigger dashboard load immediately after login
      context.read<DashboardBloc>().add(const LoadDashboardData());
    }
  },
  builder: (context, state) {
    if (state is AuthInitial) return SplashScreen();       // Loading indicator
    if (state is Authenticated) return DashboardPage();    // Main app
    return LoginPage();                                     // Default: login
  },
)
```

---

### 5.3 DashboardBloc — Chi Tiết

**File**: `features/dashboard/presentation/bloc/dashboard_bloc.dart`

#### Events

| Event | Fields | Mô tả |
|-------|--------|-------|
| `LoadDashboardData` | — | Load lần đầu (triggered by AuthWrapper) |
| `RefreshDashboardData` | — | Pull-to-refresh (giữ data cũ trong lúc refresh) |

#### States

| State | Fields | Mô tả |
|-------|--------|-------|
| `DashboardInitial` | — | Chưa load |
| `DashboardLoading` | — | Đang fetch |
| `DashboardLoaded` | `data, historyData, forecastData` | Có đủ dữ liệu |
| `DashboardError` | `message: String` | Lỗi fetch |

#### Business Logic Flow

```dart
_onLoadDashboardData:
  emit(DashboardLoading)
  data = await _repository.getDashboardData()           // GET /air-quality/current
  historyData = AqiHistoryMock.getMockHistory()         // Mock history (24h)
  forecastData = await _repository.getAqiForecast()    // GET /air-quality/forecast
  emit(DashboardLoaded(data, historyData, forecastData))

_onRefreshDashboardData:
  currentState = state                                   // Snapshot trước khi refresh
  // KHÔNG emit Loading (giữ UI hiện tại)
  try:
    ... [same as Load] ...
    emit(DashboardLoaded(...))
  catch:
    if (currentState is DashboardLoaded):
      emit(currentState)                                 // Giữ data cũ khi refresh thất bại
    else:
      emit(DashboardLoaded với mock data)                // Fallback
```

**Đặc điểm quan trọng**: Refresh không xóa UI (không emit `DashboardLoading`), giúp UX mượt mà hơn.

---

### 5.4 SmartHomeBloc — Chi Tiết

**File**: `features/smart_home/presentation/bloc/smart_home_bloc.dart`

#### Events

| Event | Fields | Mô tả |
|-------|--------|-------|
| `LoadDevices` | — | Fetch danh sách thiết bị |
| `TogglePower` | `deviceId` | Bật/tắt thiết bị |
| `ChangeMode` | `deviceId, mode: DeviceMode` | Đổi chế độ |
| `AddDevice` | `deviceName, provider` | Đăng ký thiết bị mới |
| `RenameDevice` | `deviceId, newName` | Đổi tên thiết bị |

#### States

| State | Fields | Mô tả |
|-------|--------|-------|
| `SmartHomeInitial` | — | Chưa load |
| `SmartHomeLoading` | — | Đang fetch |
| `SmartHomeLoaded` | `devices: List<SmartDevice>` | Có danh sách thiết bị |
| `SmartHomeError` | `message` | Lỗi |

#### Optimistic Update Pattern

```dart
_onTogglePower:
  currentState = state (if not SmartHomeLoaded → return early)
  
  // Gọi API ngay, KHÔNG emit loading (optimistic)
  updatedDevice = await _repository.togglePower(deviceId)
  
  // Update duy nhất thiết bị đó trong list
  updatedDevices = currentState.devices.map((d) {
    if (d.deviceId == deviceId) return updatedDevice;
    return d;
  }).toList()
  
  emit(SmartHomeLoaded(devices: updatedDevices))
  // Nếu lỗi → emit(currentState) — revert về trạng thái trước
```

---

### 5.5 ChatbotBloc — Chi Tiết

**File**: `features/chatbot/presentation/bloc/chatbot_bloc.dart`

#### Events

| Event | Fields | Mô tả |
|-------|--------|-------|
| `SendMessage` | `message: String` | Gửi tin nhắn mới |
| `ClearChat` | — | Reset conversation |
| `LoadSession` | `sessionId: String` | Tải session cũ |

#### States — Có messages trong MỌI state

```dart
abstract class ChatbotState {
  final List<ChatMessage> messages;  // Luôn có messages
  final String? sessionId;
}

class ChatbotInitial extends ChatbotState {}   // messages = []
class ChatbotLoading extends ChatbotState {}   // messages = [...user_msg] (đang chờ AI)
class ChatbotReady extends ChatbotState {}     // messages = [...user+ai]
class ChatbotError extends ChatbotState {
  final String error;
}
```

**Thiết kế đặc biệt**: Messages được giữ ngay cả trong trạng thái Loading/Error — UI không bị "nhảy" khi chờ response.

#### Business Logic Flow

```dart
_onSendMessage:
  // 1. Thêm tin nhắn user ngay lập tức
  userMessage = ChatMessage(role: user, content: event.message)
  emit(ChatbotLoading(messages: [...state.messages, userMessage]))
  
  // 2. Gọi API
  response = await _repository.sendMessage(
    message: event.message,
    sessionId: state.sessionId,
    includeAqiContext: true,
  )
  
  // 3. Thêm AI response
  emit(ChatbotReady(messages: [...updatedMessages, response]))
  // catch → emit(ChatbotError) — giữ messages để user thấy lịch sử
```

---

## 6. Services & Utilities

### 6.1 LocationService

**File**: `core/services/location_service.dart`
**Package**: `geolocator`

```dart
class LocationService {
  // Fallback tọa độ Hà Nội nếu GPS lỗi
  static const _hanoiFallback = LocationData(
    latitude: 21.0285,
    longitude: 105.8542,
  );

  Future<LocationData> getCurrentLocation() async {
    // 1. Kiểm tra GPS enabled
    if (!await Geolocator.isLocationServiceEnabled()) return _hanoiFallback;
    
    // 2. Kiểm tra/yêu cầu permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return _hanoiFallback;
    
    // 3. Lấy vị trí (timeout 10s, accuracy: low)
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    ).timeout(const Duration(seconds: 10));
    
    return LocationData(latitude: position.latitude, longitude: position.longitude);
    // catch → return _hanoiFallback
  }
}
```

**Fallback strategy**: Mọi lỗi (GPS tắt, quyền bị từ chối, timeout) → trả về tọa độ Hà Nội. App vẫn hoạt động mà không crash.

### 6.2 SecureStorageService

**File**: `core/storage/secure_storage.dart`
**Package**: `flutter_secure_storage`

| Platform | Storage Backend |
|---------|----------------|
| Android | `EncryptedSharedPreferences` |
| iOS | `Keychain` (accessibility: first_unlock) |

```dart
// Các keys được lưu
static const _accessTokenKey  = 'access_token';
static const _refreshTokenKey = 'refresh_token';  // Chưa có refresh token flow
static const _userIdKey       = 'user_id';

// Methods
saveAccessToken(token), getAccessToken()
saveUserId(id), getUserId()
isLoggedIn()    → token != null && token.isNotEmpty
clearAll()      → xóa toàn bộ (logout)
```

### 6.3 PreferencesStorage

**File**: `core/storage/preferences_storage.dart`
**Package**: `shared_preferences`

Lưu preferences không nhạy cảm:
- Theme mode (dark/light)
- Ngôn ngữ (vi/en)
- Các cài đặt người dùng khác

### 6.4 NotificationService (Mobile)

**File**: `features/notifications/data/services/notification_service.dart`
**Package**: `firebase_messaging`

Xử lý FCM push notifications:
- Nhận notification từ backend (khi AQI vượt ngưỡng)
- Cập nhật badge count trong `NotificationsBloc`
- Lưu notification history local

### 6.5 ErrorHandler

**File**: `core/utils/error_handler.dart`

```dart
class ErrorHandler {
  static void initialize() {
    // Catch unhandled Flutter errors
    FlutterError.onError = (details) {
      // Log to Sentry if configured
    };
    
    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      // Log to Sentry
      return true;
    };
  }
}
```

**Sentry Integration**: Kích hoạt qua build-time env var `SENTRY_DSN`. Tỷ lệ trace: production = 20%, development = 100%.

---

## 7. API Client (Dio)

**File**: `core/network/api_client.dart`

### 7.1 Platform-Aware Base URL

```dart
String _getBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  if (kDebugMode && Platform.isAndroid) return 'http://10.0.2.2:8000';  // Android emulator
  return 'http://localhost:8000';                                          // iOS/Desktop
}
```

**Lý do**: Android Emulator routing — `localhost` trong emulator trỏ đến emulator VM, không phải máy host. `10.0.2.2` là alias của máy host.

### 7.2 Interceptors

```
Request
  │
  ├── LogInterceptor (debug only)
  │     - Log request URL + body
  │     - KHÔNG log headers (bảo vệ Bearer token)
  │
  ├── Auth Interceptor (onRequest)
  │     - Read token từ SecureStorage
  │     - Inject "Authorization: Bearer <token>"
  │
  └── [Gửi HTTP Request]
        │
        ├── Auth Interceptor (onError)
        │     - 401? → clearAll() SecureStorage
        │     - App tự điều hướng về Login (qua AuthBloc)
        │
        └── Response → trả về caller
```

### 7.3 Timeout Configuration

| Timeout | Giá trị |
|---------|---------|
| `connectTimeout` | 30 giây |
| `receiveTimeout` | 30 giây |
| `sendTimeout` | 30 giây |

### 7.4 Auth Repository — Login (form-encoded)

```dart
// POST /auth/login dùng OAuth2PasswordRequestForm của FastAPI
// Phải gửi form-encoded, KHÔNG phải JSON
final response = await _apiClient.post(
  '/api/v1/auth/login',
  data: {'username': email, 'password': password},
  options: Options(contentType: Headers.formUrlEncodedContentType),
);
```

---

## 8. Theme System

**File**: `core/theme/app_theme.dart`

### 8.1 Brand Colors

```dart
class AppTheme {
  // Brand
  static const Color primaryGreen  = Color(0xFF4CAF50);   // AirShield green
  static const Color darkGreen     = Color(0xFF2E7D32);
  static const Color accentOrange  = Color(0xFFFF9800);   // Warning
  static const Color errorRed      = Color(0xFFF44336);

  // Dark Theme (default)
  static const Color darkBackground = Color(0xFF1A1A2E);  // Screen background
  static const Color darkSurface    = Color(0xFF16213E);  // Cards
  static const Color darkCard       = Color(0xFF0F3460);  // Deep cards

  // Light Theme
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightCard       = Color(0xFFE8F5E9); // Light green tint
}
```

### 8.2 AQI Color Coding

| AQI Range | Color | Status |
|-----------|-------|--------|
| 0–50 | `#4CAF50` (Green) | Good |
| 51–100 | `#FFC107` (Yellow) | Moderate |
| 101–150 | `#FF9800` (Orange) | Unhealthy for Sensitive |
| 151–200 | `#F44336` (Red) | Unhealthy |
| 201–300 | `#9C27B0` (Purple) | Very Unhealthy |
| >300 | `#B71C1C` (Dark Red) | Hazardous |

### 8.3 Typography

Font: **Google Fonts Poppins** — dùng xuyên suốt app (không có fallback font khác).

```dart
// Text styles xuyên suốt app
displayLarge:   Poppins Bold 32px    ← AQI number (72px ở AQI card)
displaySmall:   Poppins SemiBold 24
headlineMedium: Poppins SemiBold 20
titleLarge:     Poppins SemiBold 18  ← Section headers
bodyLarge:      Poppins Regular 16
bodyMedium:     Poppins Regular 14   ← white70/black54
bodySmall:      Poppins Regular 12   ← Timestamps, labels
```

### 8.4 ThemeBloc

```dart
// Events
class LoadTheme extends ThemeEvent {}
class ToggleTheme extends ThemeEvent {}

// States
class ThemeState {
  final ThemeMode themeMode; // dark / light / system
}
```

Theme được persist qua `PreferencesStorage` và reload khi app khởi động.

---

## 9. Key Widgets

### 9.1 AqiHistoryChart

**File**: `features/dashboard/presentation/widgets/aqi_history_chart.dart`
**Package**: `fl_chart`

Chart kết hợp hiển thị **lịch sử 24h** (xanh lá, solid) + **dự báo 24h** (vàng, dashed):

```dart
LineChart(LineChartData(
  lineBarsData: [
    // Đường lịch sử (solid green)
    LineChartBarData(
      spots: historySpots,
      isCurved: true, curveSmoothness: 0.3,
      color: Color(0xFF4CAF50),
      barWidth: 3,
      belowBarData: BarAreaData(   // Gradient fill bên dưới
        gradient: LinearGradient(colors: [green.withAlpha(0.3), green.withAlpha(0)])
      ),
    ),
    // Đường dự báo (dashed amber)
    LineChartBarData(
      spots: [history.last, ...forecastSpots],  // Kết nối từ điểm cuối history
      color: Colors.amber,
      dashArray: [5, 5],    // Dashed line
      barWidth: 2,
    ),
  ],
  lineTouchData: LineTouchData(    // Interactive tooltip
    touchTooltipData: LineTouchTooltipData(
      getTooltipItems: (spots) => ... // "AQI: 78\n14:00"
    )
  ),
))
```

**Tooltip**: Tap trên chart hiển thị `AQI: value` + timestamp. Dự báo có prefix `"(Forecast) AQI:"`.

---

### 9.2 DashboardLoadingWidget

**File**: `features/dashboard/presentation/widgets/dashboard_loading_widget.dart`

Skeleton loading sử dụng shimmer effect — hiển thị placeholder có shape giống content thật trong lúc fetch data.

---

### 9.3 DashboardErrorWidget

**File**: `features/dashboard/presentation/widgets/dashboard_error_widget.dart`

```dart
DashboardErrorWidget(
  message: state.message,
  onRetry: () => context.read<DashboardBloc>().add(const LoadDashboardData()),
)
```

Hiển thị error message + nút "Retry" để thử lại.

---

### 9.4 ChatBubble

**File**: `features/chatbot/presentation/widgets/chat_bubble.dart`

```dart
// Bubble phân biệt user (phải, xanh) vs assistant (trái, dark)
ChatBubble(
  message: msg,                      // ChatMessage object
  isUser: msg.role == MessageRole.user,
)
```

Alignment và màu sắc khác nhau tùy `role`.

---

### 9.5 DeviceCard

**File**: `features/smart_home/presentation/widgets/device_card.dart`

```dart
DeviceCard(
  device: device,
  onTogglePower: () => context.read<SmartHomeBloc>().add(TogglePower(deviceId: device.deviceId)),
  onTap: () => Navigator.push(... DeviceDetailsPage ...),
)
```

Hiển thị tên thiết bị, provider, trạng thái (on/off), filter life % và toggle switch.

---

### 9.6 ProfileMenuItem

**File**: `features/profile/presentation/widgets/profile_menu_item.dart`

Widget tái sử dụng cho các mục menu trong Profile page:

```dart
ProfileMenuItem(
  icon: Icons.health_and_safety,
  title: 'Health Preferences',
  onTap: () => Navigator.push(... HealthPreferencesPage ...),
  trailing: const Icon(Icons.chevron_right),
)
```

---

### 9.7 ErrorBoundary

**File**: `core/widgets/error_boundary.dart`

Global error boundary wrap toàn bộ app. Khi widget tree throw uncaught exception → hiển thị friendly error screen thay vì crash. Liên kết với `ErrorHandler` để gửi lên Sentry.

---

## 10. Navigation Pattern

AirShield dùng **Imperative Navigator 1.0** (`Navigator.push/pop`). Không dùng GoRouter hay AutoRoute.

### 10.1 Đặc Điểm

| Đặc điểm | Chi tiết |
|---------|---------|
| Pattern | Imperative Navigator 1.0 |
| Routing | `MaterialPageRoute` (không có named routes) |
| Home | `AuthWrapper` → quyết định Login hoặc Dashboard |
| Deep links | Chưa hỗ trợ |
| Back button | `Navigator.pop()` mặc định Flutter |

### 10.2 Mở Chatbot (Local BLoC)

```dart
// Dashboard → Chatbot (tạo ChatbotBloc mới mỗi lần)
void _openChatbot(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => ChatbotBloc(
          repository: ChatbotRepository(apiClient: ApiClient()),
        ),
        child: const ChatbotPage(),
      ),
    ),
  );
}
```

Khi `ChatbotPage` pop khỏi stack → `ChatbotBloc` bị `dispose()` → session tự nhiên kết thúc.

### 10.3 Bottom Navigation (Không phải persistent)

`DashboardPage` có `BottomNavigationBar` nhưng navigation là `Navigator.push` (không `replace`), tức là DashboardPage vẫn còn trong stack. Khi user back từ MapPage/DevicesPage/ProfilePage → quay lại Dashboard.

---

## 11. Data Models (Freezed)

### 11.1 Code Generation

Các model dùng `freezed` + `json_serializable`:

```
dashboard_data.dart         ← viết tay
dashboard_data.freezed.dart ← [generated: Freezed]
dashboard_data.g.dart       ← [generated: json_serializable]
```

### 11.2 Ví Dụ Model (DashboardData)

```dart
@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    required int aqi,
    required String aqiStatus,
    required String aqiColor,        // Hex string, e.g. "#4CAF50"
    required List<Pollutant> pollutants,
    required String healthRecommendation,
    required String location,
    required DateTime lastUpdated,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}
```

### 11.3 Các Model Dùng Freezed

| Model | File | Freezed |
|-------|------|---------|
| `User` | `auth/data/models/user.dart` | ✅ |
| `DashboardData` | `dashboard/data/models/dashboard_data.dart` | ✅ |
| `AqiForecastResponse` | `dashboard/data/models/aqi_forecast.dart` | ✅ |
| `AqiHistoryResponse` | `dashboard/data/models/aqi_history.dart` | ✅ |
| `Station` | `map/data/models/station.dart` | ✅ |
| `ChatMessage` | `chatbot/data/models/chat_message.dart` | ❌ Plain Dart |
| `SmartDevice` | `smart_home/data/models/device.dart` | ❌ Plain Dart |

---

## 12. App Startup & Dependency Injection

AirShield dùng **manual DI** (không dùng `get_it` hay `injectable`). Dependencies được tạo trong `_AirShieldAppState.initState()` và truyền xuống qua constructor injection:

```dart
void initState() {
  // 1. Infrastructure
  _secureStorage    = SecureStorageService();
  _apiClient        = ApiClient(storage: _secureStorage);    // inject storage

  // 2. Services
  _locationService  = LocationService();

  // 3. Repositories
  _authRepository   = AuthRepository(
    apiClient: _apiClient,
    storage: _secureStorage,
  );
  _dashboardRepository = DashboardRepository(
    apiClient: _apiClient,
    locationService: _locationService,
  );
  _notificationService = NotificationService();
}
```

### Dependency Graph

```
PreferencesStorage ──────────────────────────────────────► ThemeBloc
                                                          ► LanguageBloc

SecureStorageService ─────────────────────────────────────► ApiClient
                     └────────────────────────────────────► AuthRepository

ApiClient ────────────────────────────────────────────────► AuthRepository
         └────────────────────────────────────────────────► DashboardRepository

LocationService ──────────────────────────────────────────► DashboardRepository

AuthRepository ───────────────────────────────────────────► AuthBloc
DashboardRepository ──────────────────────────────────────► DashboardBloc
NotificationService ──────────────────────────────────────► NotificationsBloc
```

### App Startup Sequence

```
1. main() → PreferencesStorage.init()
2. SentryFlutter.init() (nếu SENTRY_DSN có giá trị)
3. ErrorHandler.initialize()
4. AirShieldApp → _AirShieldAppState.initState() → khởi tạo tất cả dependencies
5. MultiBlocProvider → tạo 5 global BLoCs
6. AuthBloc.add(CheckAuthStatus) → gọi SecureStorage.isLoggedIn()
7. LanguageBloc.add(LoadLanguage) → load locale từ SharedPreferences
8. ThemeBloc.add(LoadTheme) → load theme từ SharedPreferences
9. NotificationsBloc.add(LoadNotifications) → load notification list
10. AuthWrapper hiển thị: AuthInitial → splash / Authenticated → Dashboard / Unauthenticated → Login
```

---

*Tài liệu này được tạo từ source code trực tiếp của AirShield Mobile.*
*Source: `airshield_mobile/lib/`*
