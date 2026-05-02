---
name: security-review
description: "Kiểm tra bảo mật toàn diện AirShield: Backend API, Mobile App, Database, Infrastructure."
triggers:
  - "trước khi deploy production"
  - "thêm endpoint mới"
  - "thay đổi authentication"
  - "thêm external API mới"
  - "review định kỳ (hàng tháng)"
---

# Security Review Skill — AirShield

> Tham chiếu: `rules/api-conventions.md` PHẦN 5 & 6 (Caching, Rate Limiting, CORS)

---

## Thứ tự thực hiện (7 phases)

```
Phase 1: Secrets Scanning      ← Luôn làm đầu tiên
Phase 2: Authentication        ← Điểm yếu phổ biến nhất
Phase 3: Input Validation      ← SQL injection, schema bypass
Phase 4: API Security          ← CORS, rate limit, error leak
Phase 5: Database Security     ← Credentials, privileges
Phase 6: Mobile App Security   ← Storage, network, build
Phase 7: Infrastructure        ← Docker, ports, images
```

---

## Phase 1: Secrets Scanning

```bash
# Scan API keys & passwords
grep -rn "API_KEY\|SECRET\|PASSWORD\|TOKEN" \
  --include="*.py" --include="*.dart" \
  app/ airshield_mobile/lib/

# Scan known key patterns
grep -rn "sk-\|AIza\|ghp_\|glpat-" --include="*.py" --include="*.dart" .

# Kiểm tra .env không bị commit
git ls-files | grep -i "\.env$"

# Kiểm tra .gitignore đủ entries
cat .gitignore | grep -E "\.env|secrets|credentials"
```

**FAIL nếu:**
- API key/password xuất hiện plain text trong source code
- `.env` file trong git tracking
- Firebase/Google credentials JSON trong git

---

## Phase 2: Authentication & Authorization

```bash
# Tìm endpoints thiếu auth protection
grep -rn "async def " app/api/ --include="*.py" | grep -v "get_current_user"

# Kiểm tra JWT config
grep -rn "SECRET_KEY\|ALGORITHM\|expire" app/core/auth.py
```

**Checklist:**
- [ ] JWT secret key ≥ 32 characters, random (không phải "mysecret")
- [ ] Token expiration ≤ 24 giờ
- [ ] Password hashing: `bcrypt`, cost factor ≥ 12
- [ ] Mọi sensitive endpoint có `Depends(get_current_user)`
- [ ] Không có admin endpoint mở public

---

## Phase 3: Input Validation

```bash
# Tìm raw SQL (SQL injection risk)
grep -rn 'text(\|execute(\|raw_sql\|f"SELECT\|f"INSERT\|f"UPDATE\|f"DELETE' \
  app/ --include="*.py"

# Tìm endpoints thiếu Pydantic schema
grep -rn "request\.json\|request\.body\|Request" \
  app/api/ --include="*.py"
```

**Checklist:**
- [ ] Mọi input qua Pydantic schema validation
- [ ] KHÔNG raw SQL (chỉ SQLAlchemy ORM)
- [ ] File upload: size limit + type whitelist
- [ ] Query params có type/range validation

---

## Phase 4: API Security

```bash
# Kiểm tra CORS
grep -rn "CORSMiddleware\|allow_origins\|allow_methods" main.py app/

# Kiểm tra rate limiting
grep -rn "RateLimiter\|rate_limit\|throttle" app/ --include="*.py"

# Kiểm tra error leak
grep -rn "traceback\|str(e)\|repr(e)" app/ --include="*.py"
```

**Checklist:**
- [ ] CORS origins cụ thể, không dùng `"*"` ở production
- [ ] Rate limiting: login (5/min), chatbot (20/min), api (60/min)
- [ ] Error responses không leak stack traces, DB schema
- [ ] HTTPS enforced ở production

---

## Phase 5: Database Security

```bash
# Kiểm tra connection string
grep -rn "DATABASE_URL\|postgresql" app/core/config.py

# Kiểm tra không có hardcode credentials
grep -rn "password\s*=\s*['\"]" app/ --include="*.py"
```

**Checklist:**
- [ ] DB credentials qua environment variables — không hardcode
- [ ] DB user có minimal privileges (không dùng superuser)
- [ ] Passwords được hash (bcrypt) trước khi lưu
- [ ] Connections dùng SSL/TLS ở production

---

## Phase 6: Mobile App Security

```bash
# Secrets trong Dart code
grep -rn "apiKey\|secret\|password\|token" \
  airshield_mobile/lib/ --include="*.dart"

# Network security
grep -rn "http://\|allowBadCertificates\|insecure" \
  airshield_mobile/lib/ --include="*.dart"
```

**Checklist:**
- [ ] JWT token lưu trong `flutter_secure_storage` (NOT SharedPreferences)
- [ ] API base URL đến từ config, không hardcode
- [ ] Không log request/response bodies chứa sensitive data
- [ ] ProGuard/obfuscation enabled cho release builds
- [ ] HTTPS only (không HTTP fallback)

---

## Phase 7: Infrastructure (Docker)

```bash
# Kiểm tra exposed ports và secrets
grep -n "ports:\|password\|secret\|API_KEY" docker-compose.yml

# Kiểm tra image tags
grep -n "image:" docker-compose.yml
```

**Checklist:**
- [ ] Port 5432 (PostgreSQL) không expose public ở production
- [ ] Port 6379 (Redis) không expose public ở production
- [ ] Redis có password ở production
- [ ] Docker images dùng specific tags, không `:latest`
- [ ] Không có secrets hardcode trong docker-compose.yml

---

## Output Format

```markdown
# 🔒 Security Review Report — AirShield
**Date**: YYYY-MM-DD
**Scope**: Full / Partial (specify)

## Summary
| Phase | Status | Issues |
|-------|--------|--------|
| 1. Secrets | ✅/🚫 | X |
| 2. Auth | ✅/🚫 | X |
| 3. Input Validation | ✅/🚫 | X |
| 4. API Security | ✅/🚫 | X |
| 5. Database | ✅/🚫 | X |
| 6. Mobile | ✅/🚫 | X |
| 7. Infrastructure | ✅/🚫 | X |

## 🚫 Critical (Phải sửa ngay)
- [P1-001] Mô tả · File: `path:line` · Fix: ...

## ⚠️ Warnings (Nên sửa)
- [P2-001] ...

## 💡 Recommendations
- ...

## Overall Score: X/10
```
