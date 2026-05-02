# /fix-issue — Bug Fix Command

> Áp dụng rules từ: `rules/code-style.md`, `rules/api-conventions.md`, `rules/testing.md`

## Cú pháp

```bash
/fix-issue <mô tả lỗi>
/fix-issue "API /air-quality/current trả về 500"
/fix-issue "Dashboard không hiển thị forecast chart"
/fix-issue "Login screen crash khi nhập email sai format"
```

---

## Quy trình 5 bước

### Bước 1 — Xác định phạm vi

1. Đọc mô tả lỗi
2. Map sang module: **AQS** / **DPS** / **CGS** / **SHA** / **ACB** / **Mobile**
3. Xác định layer: API → Service → Model → Mobile

### Bước 2 — Điều tra

#### Backend issue
```bash
# Xem logs gần nhất
python -c "import glob; [print(open(f).read()[-2000:]) for f in glob.glob('app/logs/*.log')]"

# Chạy test liên quan
pytest tests/ -v -k "<keyword>" --tb=long

# Kiểm tra endpoint
# → app/api/v1/<module_name>.py
```

#### Mobile issue
```bash
flutter analyze                        # Static analysis
flutter test --name "<test_name>"      # Test cụ thể
```

#### Database issue
```bash
alembic history    # Xem migration history
alembic current    # Migration hiện tại
# → Kiểm tra app/models/
```

### Bước 3 — Tìm Root Cause

Trace theo luồng: **Endpoint → Service → Model → DB**

Lỗi phổ biến cần kiểm tra trước:
- ❗ **Missing `await`** — lỗi async/await hay gặp nhất
- ❗ **Pydantic schema mismatch** — field name khác, type sai
- ❗ **Missing auth dependency** — quên `Depends(get_current_user)`
- ❗ **Unhandled nullable** — Dart null safety bị bỏ qua
- ❗ **Redis cache stale** — data cũ, cần flush key

### Bước 4 — Implement Fix

Tham chiếu: `rules/code-style.md` cho pattern đúng

1. Sửa code tại **root cause** (không patch symptom)
2. Thêm/cập nhật test cho case gây lỗi
3. Chạy test để verify:
   ```bash
   # Backend
   pytest tests/ -v -k "<related_test>"

   # Mobile
   flutter test test/unit/...
   ```

### Bước 5 — Báo cáo

```markdown
## 🔧 Issue Fix Report

### Vấn đề
- Mô tả: ...
- Module: AQS / DPS / CGS / SHA / ACB / Mobile
- Severity: Critical / High / Medium / Low

### Root Cause
- File: `app/services/forecast_service.py:42`
- Nguyên nhân: Missing `await` trước DB call

### Giải pháp
- Thay đổi: thêm `await` tại line 42
- Files modified: `forecast_service.py`, `test_forecast_service.py`

### Verification
- Tests passed: ✅ `pytest tests/ -v -k "forecast"` → 5 passed
- Manual check: API /air-quality/forecast trả về 200 ✅

### Prevention
- Thêm linting rule cho missing await
- Bổ sung test case cho edge case này
```
