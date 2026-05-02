# /review — Code Review Command

> Áp dụng rules từ: `rules/code-style.md`, `rules/api-conventions.md`, `rules/testing.md`

## Cú pháp

```bash
/review                      # Review tất cả thay đổi chưa commit
/review <file_path>          # Review file cụ thể
/review --module <tên>       # Review module cụ thể (aqs, chatbot, ...)
```

---

## Quy trình thực hiện

### Bước 1 — Thu thập thay đổi

```bash
git diff              # Thay đổi chưa staged
git diff --cached     # Thay đổi đã staged
git status            # Tổng quan
```

### Bước 2 — Checklist Backend (Python/FastAPI)

Tham chiếu: `rules/code-style.md` PHẦN 1, `rules/api-conventions.md` PHẦN 4

- [ ] **Async/Await**: DB calls và HTTP requests đều `async`
- [ ] **Type hints**: Đầy đủ annotations cho mọi function
- [ ] **Pydantic v2**: Request/Response qua schema, có `ConfigDict`
- [ ] **Error handling**: `HTTPException` với status code đúng
- [ ] **Authentication**: Endpoints cần auth có `Depends(get_current_user)`
- [ ] **No raw SQL**: Chỉ dùng SQLAlchemy ORM
- [ ] **No secrets**: Không hardcode API keys, passwords
- [ ] **Logging**: Có log cho operations quan trọng

### Bước 3 — Checklist Mobile (Flutter/Dart)

Tham chiếu: `rules/code-style.md` PHẦN 2

- [ ] **BLoC pattern**: State management qua BLoC, không `setState()`
- [ ] **Null safety**: Nullable types được xử lý đúng
- [ ] **Widget size**: Widget ≤ 100 dòng, tách sub-widgets nếu cần
- [ ] **Theme**: Dùng `Theme.of(context)`, không hardcode colors
- [ ] **Dispose**: Controllers và StreamSubscription đều `dispose()`
- [ ] **UI States**: Có Loading / Error / Empty state

### Bước 4 — Checklist Chung

Tham chiếu: `rules/testing.md`

- [ ] **Naming**: `snake_case` (Python), `camelCase` (Dart)
- [ ] **No TODO/FIXME**: Không để lại unresolved TODOs
- [ ] **Tests**: Logic mới có test, test pass trước commit
- [ ] **Docstrings**: Functions phức tạp có docstring

---

## Output Format

```markdown
## 📋 Code Review Report

**Files reviewed**: X file(s)
**Thay đổi**: [mô tả ngắn]

---

### ✅ Điểm tốt
- ...

### ⚠️ Cần cải thiện
- [MEDIUM] Mô tả vấn đề
  - File: `path/to/file.py:42`
  - Suggestion: ...

### 🚫 Phải sửa (Blocking)
- [HIGH] ...

---

### 📊 Tổng kết
- Issues: X tổng (High: X, Medium: X, Low: X)
- Verdict: ✅ APPROVED / ⚠️ NEEDS CHANGES / 🚫 REJECTED
```
