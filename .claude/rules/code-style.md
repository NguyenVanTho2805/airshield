# Code Style Rules — AirShield

> Tài liệu nền tảng. Được tham chiếu bởi: `commands/review.md`, `commands/fix-issue.md`.

---

## PHẦN 1: Python (Backend / FastAPI)

### 1.1 Công cụ bắt buộc

| Công cụ | Mục đích | Cấu hình |
|---------|---------|----------|
| **Black** | Formatter | `line-length = 88` |
| **isort** | Import sorter | `profile = black` |
| **Ruff** | Linter nhanh | thay thế Flake8 |

### 1.2 Quy tắc đặt tên

| Thành phần | Quy ước | Ví dụ |
|-----------|---------|-------|
| Files | `snake_case.py` | `chatbot_service.py` |
| Classes | `PascalCase` | `AirQualityReading` |
| Functions | `snake_case` | `get_current_aqi()` |
| Variables | `snake_case` | `aqi_value` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Private | `_prefix` | `_validate_input()` |

### 1.3 Type Hints — BẮT BUỘC

```python
# ✅ ĐÚNG
async def get_aqi(city: str, lat: float, lon: float) -> AQIResponse:
    ...

# ❌ SAI — thiếu type hints
async def get_aqi(city, lat, lon):
    ...
```

### 1.4 Async Pattern — BẮT BUỘC

```python
# ✅ ĐÚNG — async DB query
async def get_readings(db: AsyncSession) -> list[AirQualityReading]:
    result = await db.execute(select(AirQualityReading))
    return result.scalars().all()

# ❌ SAI — blocking call trong async context
def get_readings(db):
    return db.query(AirQualityReading).all()
```

### 1.5 Error Handling

```python
# ✅ ĐÚNG — specific exception + proper status code
from fastapi import HTTPException, status

async def get_device(device_id: str) -> Device:
    device = await device_repo.find(device_id)
    if not device:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Device {device_id} not found"
        )
    return device

# ❌ SAI — generic exception, no status code
async def get_device(device_id):
    try:
        return await device_repo.find(device_id)
    except:
        raise Exception("Error")
```

### 1.6 Docstrings

```python
async def calculate_aqi(pm25: float, pm10: float) -> int:
    """
    Tính chỉ số AQI từ nồng độ bụi mịn.

    Args:
        pm25: Nồng độ PM2.5 (µg/m³)
        pm10: Nồng độ PM10 (µg/m³)

    Returns:
        Chỉ số AQI (0–500)

    Raises:
        ValueError: Nếu giá trị âm
    """
```

---

## PHẦN 2: Dart (Mobile / Flutter)

### 2.1 Công cụ bắt buộc

| Công cụ | Mục đích | Cấu hình |
|---------|---------|----------|
| `dart format` | Formatter | max 80 chars/line |
| `flutter analyze` | Linter | `analysis_options.yaml` |

### 2.2 Quy tắc đặt tên

| Thành phần | Quy ước | Ví dụ |
|-----------|---------|-------|
| Files | `snake_case.dart` | `chat_input.dart` |
| Classes | `PascalCase` | `DashboardBloc` |
| Functions/Methods | `camelCase` | `fetchAqiData()` |
| Variables | `camelCase` | `currentAqi` |
| Private | `_prefix` | `_handleSubmit()` |
| BLoC Events | `PascalCase + verb` | `LoadDashboardData` |
| BLoC States | `PascalCase + noun` | `DashboardLoaded` |

### 2.3 BLoC Pattern — BẮT BUỘC

```dart
// Event
abstract class DashboardEvent {}
class LoadDashboard extends DashboardEvent {}

// State
abstract class DashboardState {}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final AqiData data;
  const DashboardLoaded(this.data);
}
class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
}
```

### 2.4 Widget Structure

```dart
// ✅ ĐÚNG — tách nhỏ, dùng const
class AqiCard extends StatelessWidget {
  const AqiCard({super.key, required this.aqiValue});
  final int aqiValue;

  @override
  Widget build(BuildContext context) {
    return Card(child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    // logic tách ra method riêng
  }
}

// ❌ SAI — quá lớn, hardcode
class AqiCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF123456), // hardcode!
      // ... 200 dòng trong 1 build method
    );
  }
}
```

### 2.5 Theme — BẮT BUỘC

```dart
// ✅ ĐÚNG
Text('AQI: 42', style: Theme.of(context).textTheme.headlineMedium)

// ❌ SAI
Text('AQI: 42', style: TextStyle(fontSize: 24, color: Colors.blue))
```

### 2.6 Dispose — BẮT BUỘC

```dart
@override
void dispose() {
  _controller.dispose();    // TextEditingController
  _subscription.cancel();   // StreamSubscription
  super.dispose();
}
```
