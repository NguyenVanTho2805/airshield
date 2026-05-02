# Testing Rules — AirShield

> Tài liệu nền tảng. Được tham chiếu bởi: `commands/review.md`, `commands/fix-issue.md`.

---

## PHẦN 1: Nguyên Tắc Chung

**Test Pyramid** (ưu tiên từ cao đến thấp):

```
         ┌──────────┐
         │   E2E    │  ← ít nhất (chậm, tốn kém)
        ┌┴──────────┴┐
        │ Integration │ ← vừa phải
       ┌┴────────────┴┐
       │  Unit Tests   │ ← nhiều nhất (nhanh, rẻ)
       └──────────────┘
```

**Quy tắc bắt buộc:**
1. Mỗi feature mới **PHẢI có test** — không merge nếu thiếu test
2. **Coverage ≥ 80%** cho business logic (services)
3. **Test PHẢI pass** trước khi commit
4. External APIs (IQAir, Gemini) **PHẢI mock** — không gọi API thật trong test

---

## PHẦN 2: Backend Testing (Python / Pytest)

### 2.1 Cấu Trúc Thư Mục

```
tests/
├── conftest.py              # Shared fixtures — ĐỌC TRƯỚC
├── test_health_check.py     # Smoke tests
├── test_api_aqs.py          # API: Air Quality
├── test_api_chatbot.py      # API: Chatbot
├── test_api_modules.py      # API: Smart Home, Community
└── unit/                    # Unit tests (thêm dần)
    ├── test_forecast_service.py
    ├── test_chatbot_service.py
    └── test_personalization_service.py
```

### 2.2 Fixtures Có Sẵn (conftest.py)

```python
# client      — AsyncClient cho API testing
# db_session  — AsyncSession cho DB testing
# auth_headers — {"Authorization": "Bearer <token>"}
```

### 2.3 Viết API Test

```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_get_current_aqi(client: AsyncClient):
    """GET /api/v1/air-quality/current → 200 + valid AQI."""
    response = await client.get(
        "/api/v1/air-quality/current",
        params={"city": "Ho Chi Minh City"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "aqi" in data
    assert 0 <= data["aqi"] <= 500

@pytest.mark.asyncio
async def test_protected_without_token(client: AsyncClient):
    """Protected endpoint → 401 nếu không có token."""
    response = await client.get("/api/v1/user/health/profile")
    assert response.status_code == 401
```

### 2.4 Viết Unit Test (Service)

```python
import pytest
from unittest.mock import AsyncMock, patch
from app.services.forecast_service import ForecastService

@pytest.mark.asyncio
async def test_forecast_returns_valid_predictions():
    """ForecastService.predict() → 7 predictions trong range [0, 500]."""
    service = ForecastService()
    with patch.object(service, '_fetch_historical_data', new_callable=AsyncMock) as mock:
        mock.return_value = [{"aqi": 50, "timestamp": "..."}]
        result = await service.predict(city="Hanoi", days=7)

    assert len(result) == 7
    for p in result:
        assert 0 <= p.aqi <= 500
        assert p.date is not None
```

### 2.5 Chạy Tests

```bash
# Tất cả tests
pytest tests/ -v

# Test cụ thể
pytest tests/test_api_aqs.py -v

# Với coverage
pytest tests/ --cov=app --cov-report=html

# Filter theo keyword
pytest tests/ -v -k "chatbot"

# Debug (verbose output)
pytest tests/ -v --tb=long -s
```

---

## PHẦN 3: Mobile Testing (Flutter / Dart)

### 3.1 Cấu Trúc Thư Mục

```
airshield_mobile/test/
├── unit/
│   ├── bloc/
│   │   ├── dashboard_bloc_test.dart
│   │   └── chatbot_bloc_test.dart
│   └── models/
│       └── aqi_model_test.dart
├── widget/
│   ├── aqi_card_test.dart
│   └── chat_input_test.dart
└── integration/
    └── app_test.dart
```

### 3.2 BLoC Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('DashboardBloc', () {
    late DashboardBloc bloc;
    late MockDashboardRepository mockRepo;

    setUp(() {
      mockRepo = MockDashboardRepository();
      bloc = DashboardBloc(repository: mockRepo);
    });

    tearDown(() => bloc.close());

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Loaded] khi LoadDashboard được thêm',
      build: () {
        when(() => mockRepo.fetchAqi())
            .thenAnswer((_) async => AqiData(aqi: 42, city: 'Hanoi'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadDashboard()),
      expect: () => [isA<DashboardLoading>(), isA<DashboardLoaded>()],
    );
  });
}
```

### 3.3 Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AqiCard hiển thị đúng AQI value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AqiCard(aqiValue: 42))),
    );
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
  });
}
```

### 3.4 Chạy Tests

```bash
cd airshield_mobile

flutter test                                           # Tất cả
flutter test test/unit/bloc/dashboard_bloc_test.dart   # Cụ thể
flutter test --coverage                                # Với coverage
```

---

## PHẦN 4: Quy Tắc Đặt Tên Test

| Ngôn ngữ | Pattern | Ví dụ |
|---------|---------|-------|
| Python | `test_{action}_{condition}_{expected}` | `test_get_aqi_with_invalid_city_returns_404` |
| Dart | `'should {action} when {condition}'` | `'should emit Loaded when data fetched'` |

## PHẦN 5: Cấm Làm Trong Tests

| ❌ Không được | Lý do |
|--------------|-------|
| Gọi IQAir/Gemini API thật | Tốn quota, không ổn định |
| Test phụ thuộc thứ tự chạy | Fragile tests |
| Side effects lên DB production | Nguy hiểm |
| Hardcode data không qua fixtures | Khó maintain |
| `@pytest.mark.skip` không giải thích | Giấu lỗi |
