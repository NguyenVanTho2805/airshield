# 06 — Thuật Toán & Công Thức Toán Học

> **AirShield** — Tài liệu lý thuyết cho Chương 2 Khoá Luận
> Trích xuất từ source code: `app/services/`, `app/api/v1/`, `app/core/`

---

## MỤC LỤC

1. [Prophet Time-Series Forecasting](#1-prophet-time-series-forecasting)
2. [Chỉ Số AQI & Cá Nhân Hóa Sức Khỏe](#2-chỉ-số-aqi--cá-nhân-hóa-sức-khỏe)
3. [Thuật Toán Tìm Tuyến Đường Sạch](#3-thuật-toán-tìm-tuyến-đường-sạch)
4. [Trust Score — Xác Minh Báo Cáo Cộng Đồng](#4-trust-score--xác-minh-báo-cáo-cộng-đồng)
5. [JWT Authentication](#5-jwt-authentication)
6. [Bcrypt Password Hashing](#6-bcrypt-password-hashing)
7. [Tuya HMAC-SHA256 Request Signing](#7-tuya-hmac-sha256-request-signing)
8. [Bảng Tổng Hợp Thuật Toán](#8-bảng-tổng-hợp-thuật-toán)

---

## 1. Prophet Time-Series Forecasting

> **File**: `app/services/forecast_service.py`
> **Thư viện**: Facebook Prophet (Taylor & Letham, 2018)

### 1.1 Mô Hình Toán Học Tổng Quát

Prophet mô hình hoá chuỗi thời gian như tổng của ba thành phần cộng tính:

$$y(t) = g(t) + s(t) + h(t) + \varepsilon_t$$

| Ký hiệu | Tên | Ý nghĩa |
|---------|-----|---------|
| $y(t)$ | Giá trị thực | AQI tại thời điểm $t$ |
| $g(t)$ | Trend (xu hướng) | Biến động dài hạn, phi tuần hoàn |
| $s(t)$ | Seasonality (mùa vụ) | Chu kỳ tuần, ngày |
| $h(t)$ | Holidays (ngày lễ) | Tác động đặc biệt (tắt trong AirShield) |
| $\varepsilon_t$ | Error term | Nhiễu ngẫu nhiên, $\varepsilon_t \sim \mathcal{N}(0, \sigma^2)$ |

---

### 1.2 Thành Phần Trend — g(t)

Prophet sử dụng **piecewise linear trend** với các changepoints tự động phát hiện:

$$g(t) = (k + \mathbf{a}(t)^T \boldsymbol{\delta}) \cdot t + (m + \mathbf{a}(t)^T \boldsymbol{\gamma})$$

Trong đó:
- $k$ — tốc độ tăng trưởng cơ sở (base growth rate)
- $\boldsymbol{\delta} \in \mathbb{R}^S$ — véc-tơ điều chỉnh tốc độ tại $S$ changepoints
- $m$ — offset ban đầu
- $\boldsymbol{\gamma}$ — điều chỉnh offset tại changepoints
- $\mathbf{a}(t) \in \{0,1\}^S$ — véc-tơ chỉ định changepoint nào đang hoạt động

**Changepoint Prior:**

$$\delta_j \sim \text{Laplace}(0, \tau)$$

Trong code AirShield:
```python
changepoint_prior_scale = 0.05   # τ = 0.05 (nhỏ → ít linh hoạt, tránh overfit)
```

$\tau$ nhỏ → trend ít bị ảnh hưởng bởi biến động cục bộ → phù hợp với dataset ngắn 7 ngày.

---

### 1.3 Thành Phần Seasonality — s(t)

Seasonality được xấp xỉ bằng **chuỗi Fourier**:

$$s(t) = \sum_{n=1}^{N} \left( a_n \cos\left(\frac{2\pi n t}{P}\right) + b_n \sin\left(\frac{2\pi n t}{P}\right) \right)$$

Trong đó:
- $P$ — chu kỳ (period): $P = 7$ (ngày) cho weekly, $P = 1$ (ngày) cho daily
- $N$ — số hạng Fourier: $N = 3$ (weekly), $N = 4$ (daily)
- $a_n, b_n$ — hệ số Fourier, được học từ dữ liệu

**Vector tham số**: $\boldsymbol{\beta} = [a_1, b_1, \ldots, a_N, b_N]^T \sim \mathcal{N}(\mathbf{0}, \sigma^2_s \mathbf{I})$

**Trong AirShield** (từ `forecast_service.py`):

| Seasonality | Bật/Tắt | Period $P$ | Lý do |
|------------|---------|-----------|-------|
| `yearly_seasonality` | **Tắt** (`False`) | 365.25 ngày | Chỉ có 7 ngày data |
| `weekly_seasonality` | **Bật** (`True`) | 7 ngày | AQI cuối tuần ≠ ngày thường |
| `daily_seasonality` | **Bật** (`True`) | 1 ngày | AQI giờ cao điểm ≠ ban đêm |

---

### 1.4 Input/Output Format

**Input (DataFrame chuẩn Prophet):**

| Cột | Kiểu | Mô tả | Ví dụ |
|-----|------|-------|-------|
| `ds` | `datetime64` | Timestamp (naive, không có timezone) | `2026-04-19 08:00:00` |
| `y` | `float64` | Giá trị AQI | `78.0` |

```python
# Data preparation từ code
df = pd.DataFrame([
    {
        "ds": log.recorded_at.replace(tzinfo=None),  # Strip timezone
        "y": float(log.aqi)
    }
    for log in logs  # 7 ngày lịch sử, tối thiểu 10 records
])
```

**Output (Forecast DataFrame):**

| Cột | Mô tả |
|-----|-------|
| `ds` | Timestamp dự báo |
| `yhat` | Giá trị dự báo trung tâm |
| `yhat_lower` | Khoảng tin cậy dưới (80%) |
| `yhat_upper` | Khoảng tin cậy trên (80%) |
| `trend` | Thành phần xu hướng |
| `weekly` | Thành phần chu kỳ tuần |
| `daily` | Thành phần chu kỳ ngày |

**Post-processing (giới hạn AQI hợp lệ):**

$$\hat{y}_{clipped} = \max\left(0,\ \min\left(500,\ \text{round}(\hat{y})\right)\right)$$

---

### 1.5 Pipeline Huấn Luyện

```
Bước 1: Thu thập dữ liệu
  Input: (lat, lon) → tìm station gần nhất → lấy 7 ngày AQI từ DB
  Điều kiện: |records| ≥ 10

Bước 2: Chuẩn bị DataFrame
  df = [(ds=timestamp_naive, y=aqi) for log in logs]

Bước 3: Khởi tạo model
  m = Prophet(
      yearly_seasonality  = False,
      weekly_seasonality  = True,     (Fourier N=3, P=7)
      daily_seasonality   = True,     (Fourier N=4, P=1)
      changepoint_prior_scale = 0.05  (Laplace τ=0.05)
  )

Bước 4: Fit (Stan MCMC / L-BFGS)
  m.fit(df)   ~1-3 giây với ~336 points

Bước 5: Tạo khung thời gian tương lai
  future = m.make_future_dataframe(periods=24, freq='h')

Bước 6: Dự báo
  forecast = m.predict(future)

Bước 7: Lọc và chuẩn hóa
  future_only = forecast[forecast['ds'] > df['ds'].max()].head(24)
  results = [max(0, min(500, round(row['yhat']))) for row in future_only]
```

**Fallback khi thiếu dữ liệu:**

$$\text{AQI}_{t+i} = \text{clip}\left(\text{AQI}_{t+i-1} + \Delta_i,\ 10,\ 300\right)$$

$$\Delta_i \sim \text{Uniform}(-5,\ +8) \quad \text{(xu hướng tăng nhẹ)}$$

---

## 2. Chỉ Số AQI & Cá Nhân Hóa Sức Khỏe

> **File**: `app/services/personalization_service.py`
> **API**: `GET /api/v1/user/health/recommendation`

### 2.1 Chỉ Số AQI Chuẩn EPA (Mỹ)

AirShield sử dụng chỉ số **US AQI** (aqius) từ IQAir. Công thức EPA:

$$\text{AQI} = \frac{I_{Hi} - I_{Lo}}{BP_{Hi} - BP_{Lo}} \times (C_p - BP_{Lo}) + I_{Lo}$$

Trong đó:
- $C_p$ — nồng độ chất ô nhiễm đo được
- $BP_{Lo}, BP_{Hi}$ — ngưỡng nồng độ breakpoint thấp/cao
- $I_{Lo}, I_{Hi}$ — chỉ số AQI tương ứng với breakpoint

**Bảng breakpoints PM2.5 (µg/m³) → AQI:**

| PM2.5 (µg/m³) | AQI | Mức độ |
|--------------|-----|--------|
| 0.0 – 12.0 | 0 – 50 | Tốt (Good) |
| 12.1 – 35.4 | 51 – 100 | Trung bình (Moderate) |
| 35.5 – 55.4 | 101 – 150 | Không tốt cho nhóm nhạy cảm |
| 55.5 – 150.4 | 151 – 200 | Không lành mạnh (Unhealthy) |
| 150.5 – 250.4 | 201 – 300 | Rất không lành mạnh |
| 250.5 – 500.4 | 301 – 500 | Nguy hiểm (Hazardous) |

---

### 2.2 Công Thức AQI Cảm Nhận (Perceived AQI)

$$\boxed{AQI_{perceived} = AQI_{actual} \times W_{health} \times S_{sensitivity}}$$

Trong đó:

$$W_{health} = \max\left(W_{age},\ W_{condition}\right)$$

$$S_{sensitivity} = 0.8 + (\text{level} - 1) \times 0.1, \quad \text{level} \in \{1, 2, 3, 4, 5\}$$

**Khai triển đầy đủ:**

$$AQI_{perceived} = AQI_{actual} \times \max\!\left(W_{age}(\text{birth\_year}),\ \max_{c \in \text{conditions}} W_c\right) \times \left(0.8 + 0.1 \times (\ell - 1)\right)$$

---

### 2.3 Bảng Trọng Số Bệnh Lý — $W_{condition}$

| Bệnh lý | Tag trong hệ thống | Trọng số $W_c$ | Lý do y tế |
|---------|-------------------|----------------|-----------|
| Không có bệnh | *(none)* | **1.0** | Baseline |
| Dị ứng | `"allergies"` | **1.5** | Nhạy với PM2.5, phấn hoa |
| Thai phụ | `"pregnant"` | **1.6** | Ảnh hưởng thai nhi, hệ miễn dịch thay đổi |
| Viêm xoang | `"sinus"` | **1.8** | Đường hô hấp trên nhạy cảm |
| Bệnh tim mạch | `"heart_disease"` | **2.2** | Tim phải làm việc nhiều hơn khi thiếu O₂ |
| **Hen suyễn** | `"asthma"` | **2.5** | Ô nhiễm kích thích cơn hen cấp tính |
| **COPD** | `"copd"` | **2.8** | Bệnh phổi tắc nghẽn mãn tính — nặng nhất |

---

### 2.4 Bảng Trọng Số Tuổi — $W_{age}$

| Nhóm tuổi | Điều kiện | Trọng số $W_{age}$ | Lý do y tế |
|----------|-----------|-------------------|-----------|
| Trung niên | $12 < \text{age} < 65$ | **1.0** | Baseline |
| Trẻ em | $\text{age} \leq 12$ | **1.3** | Phổi đang phát triển, thở nhiều hơn theo trọng lượng |
| Người cao tuổi | $\text{age} \geq 65$ | **1.5** | Sức đề kháng yếu, bệnh nền phổ biến hơn |

$$W_{age}(\text{birth\_year}) = \begin{cases} 1.5 & \text{nếu } (Y_{now} - \text{birth\_year}) \geq 65 \\ 1.3 & \text{nếu } (Y_{now} - \text{birth\_year}) \leq 12 \\ 1.0 & \text{ngược lại} \end{cases}$$

---

### 2.5 Bảng Sensitivity Factor — $S_{sensitivity}$

| Level | Giá trị $S$ | Ý nghĩa |
|-------|------------|---------|
| 1 | **0.8** | Tự đánh giá ít nhạy cảm (−20%) |
| 2 | **0.9** | Dưới trung bình (−10%) |
| 3 | **1.0** | Trung bình (mặc định, không điều chỉnh) |
| 4 | **1.1** | Trên trung bình (+10%) |
| 5 | **1.2** | Rất nhạy cảm (+20%) |

$$S(\ell) = 0.8 + 0.1(\ell - 1) = \frac{7 + \ell}{10}, \quad \ell \in \{1,2,3,4,5\}$$

---

### 2.6 Phân Loại Risk Level

$$\text{RiskLevel}(AQI_p) = \begin{cases} \texttt{LOW} & 0 \leq AQI_p \leq 50 \\ \texttt{MODERATE} & 50 < AQI_p \leq 100 \\ \texttt{HIGH} & 100 < AQI_p \leq 150 \\ \texttt{VERY\_HIGH} & 150 < AQI_p \leq 200 \\ \texttt{HAZARDOUS} & AQI_p > 200 \end{cases}$$

**Ngưỡng cảnh báo cao**: $AQI_{perceived} > 150$ → `is_high_risk = True` → hiển thị warning message đặc biệt.

### 2.7 Ví Dụ Tính Toán Số Trị

**Đầu vào:**
- $AQI_{actual} = 80$ (Moderate theo chuẩn EPA)
- Bệnh: hen suyễn (`asthma`, $W_c = 2.5$)
- Tuổi: 30 ($W_{age} = 1.0$)
- Sensitivity Level: 4 ($S = 1.1$)

**Tính toán:**
$$W_{health} = \max(1.0,\ 2.5) = 2.5$$
$$S = 0.8 + (4-1) \times 0.1 = 1.1$$
$$AQI_{perceived} = 80 \times 2.5 \times 1.1 = \mathbf{220}$$
$$\text{RiskLevel} = \texttt{HAZARDOUS} \quad (220 > 200)$$

→ Dù AQI thực chỉ 80 (Moderate), người bị hen suyễn nhạy cảm nhận được **nguy hiểm**.

---

## 3. Thuật Toán Tìm Tuyến Đường Sạch

> **File**: `app/services/routing_service.py`
> **API**: `POST /api/v1/routing/calculate`

### 3.1 Cost Function

$$\boxed{C(r) = \frac{d_r}{v} \times \left(1 + \alpha \times f_{AQI}(r)\right)}$$

Trong đó:

| Ký hiệu | Giá trị / Ý nghĩa |
|---------|------------------|
| $d_r$ | Khoảng cách tuyến đường $r$ (km) |
| $v$ | Tốc độ di chuyển (km/h) — phụ thuộc mode |
| $\alpha$ | Hệ số trọng số ô nhiễm = **0.5** (`ROUTING_ALPHA`) |
| $f_{AQI}(r)$ | AQI factor chuẩn hóa của tuyến $\in [0.0, 1.0]$ |

**$\frac{d_r}{v}$** = thời gian cơ bản (giờ); **$\alpha \times f_{AQI}$** = phạt ô nhiễm.

Khi $f_{AQI} = 0$ (không khí sạch hoàn toàn): $C = \frac{d}{v}$ (chỉ phụ thuộc thời gian).
Khi $f_{AQI} = 1.0$ (ô nhiễm cực đại): $C = \frac{d}{v} \times 1.5$ (tăng 50% chi phí).

---

### 3.2 Chuẩn Hóa AQI — $f_{AQI}$

Hàm chuẩn hóa phi tuyến (piecewise linear) ánh xạ AQI ∈ [0, 500] → factor ∈ [0.0, 1.0]:

$$f_{AQI}(x) = \begin{cases} \dfrac{x}{500} & 0 \leq x \leq 50 \\[6pt] 0.1 + \dfrac{x - 50}{250} & 50 < x \leq 100 \\[6pt] 0.3 + \dfrac{x - 100}{250} & 100 < x \leq 150 \\[6pt] 0.5 + \dfrac{x - 150}{250} & 150 < x \leq 200 \\[6pt] 0.7 + \dfrac{x - 200}{500} & 200 < x \leq 300 \\[6pt] \min\!\left(1.0,\ 0.9 + \dfrac{x - 300}{1000}\right) & x > 300 \end{cases}$$

**Bảng giá trị tham chiếu:**

| AQI $x$ | $f_{AQI}(x)$ | Đoạn |
|---------|------------|------|
| 0 | 0.000 | Tuyến tính [0, 50] |
| 50 | 0.100 | Breakpoint 1 |
| 100 | 0.300 | Breakpoint 2 |
| 150 | 0.500 | Breakpoint 3 |
| 200 | 0.700 | Breakpoint 4 |
| 300 | 0.900 | Breakpoint 5 |
| 500 | 1.000 | Saturated |

Hàm phi tuyến để **phân biệt tốt hơn** ở vùng AQI thấp (Tốt → Trung bình), trong khi vùng nguy hiểm (>300) tiến gần bão hoà.

---

### 3.3 Khoảng Cách Haversine

Khoảng cách đường thẳng giữa hai điểm trên bề mặt Trái Đất:

$$d = 2R \cdot \arcsin\!\left(\sqrt{\sin^2\!\frac{\Delta\phi}{2} + \cos\phi_1 \cdot \cos\phi_2 \cdot \sin^2\!\frac{\Delta\lambda}{2}}\right)$$

Trong đó:
- $R = 6371$ km (bán kính Trái Đất)
- $\phi_1, \phi_2$ — vĩ độ điểm đầu/cuối (radian)
- $\lambda_1, \lambda_2$ — kinh độ điểm đầu/cuối (radian)
- $\Delta\phi = \phi_2 - \phi_1$, $\Delta\lambda = \lambda_2 - \lambda_1$

```python
import math
def haversine_km(lat1, lon1, lat2, lon2) -> float:
    R = 6371
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
    dlat, dlon = lat2 - lat1, lon2 - lon1
    h = math.sin(dlat/2)**2 + math.cos(lat1)*math.cos(lat2)*math.sin(dlon/2)**2
    return R * 2 * math.asin(math.sqrt(h))
```

---

### 3.4 Tốc Độ Theo Phương Tiện

| Mode | $v$ (km/h) | Thực tế đô thị VN |
|------|-----------|------------------|
| `driving` | 40 | Tốc độ TB đường phố Hà Nội |
| `cycling` | 15 | Xe đạp |
| `walking` | 5 | Đi bộ |

---

### 3.5 So Sánh Fastest vs Cleanest Route

| | **Fastest Route** | **Cleanest Route** |
|---|------------------|--------------------|
| **Nguồn khoảng cách** | Google Maps (nếu có key) | Google Maps `avoid=highways` |
| **Fallback** | $d_{fast} = 1.3 \times d_{straight}$ | $d_{clean} = 1.6 \times d_{straight}$ |
| **AQI Factor** | $f_{AQI} = 0.5$ (đường lớn) | $f_{AQI} = 0.15$ (đường nhỏ, công viên) |
| **Objective** | $\min C = \frac{d_{fast}}{v}(1 + 0.5 \times 0.5)$ | $\min C = \frac{d_{clean}}{v}(1 + 0.5 \times 0.15)$ |
| **Ví dụ** ($d_{st}=5$ km, driving) | $C = \frac{6.5}{40}(1.25) \approx 0.203$ | $C = \frac{8.0}{40}(1.075) \approx 0.215$ |

**Kết luận**: Fastest có $C$ nhỏ hơn (ít chi phí hơn) nhưng phơi nhiễm ô nhiễm cao hơn. Cleanest trả thêm ~6% thời gian để giảm phơi nhiễm ô nhiễm ~70%.

### 3.6 Pseudocode Thuật Toán Routing

```
Algorithm FindCleanRoutes(origin, destination, mode):
  v ← speed_table[mode]                    // 40/15/5 km/h
  d_straight ← Haversine(origin, destination)

  // Fastest Route
  gmap_fast ← GoogleMaps(origin, destination, mode)
  if gmap_fast exists:
    d_fast, t_fast ← gmap_fast.distance_km, gmap_fast.duration_min
  else:
    d_fast ← 1.3 × d_straight              // Urban road factor
    t_fast ← (d_fast / v) × 60

  f_fast ← 0.5                             // Main road: moderate pollution
  C_fast ← (d_fast / v) × (1 + 0.5 × f_fast)

  // Cleanest Route  
  gmap_clean ← GoogleMaps(origin, destination, mode, avoid="highways")
  if gmap_clean exists:
    d_clean, t_clean ← gmap_clean.distance_km, gmap_clean.duration_min
  else:
    d_clean ← 1.6 × d_straight             // Side roads factor
    t_clean ← (d_clean / v) × 60

  f_clean ← 0.15                           // Parks/residential: low pollution
  C_clean ← (d_clean / v) × (1 + 0.5 × f_clean)

  return Route(fastest, C_fast), Route(cleanest, C_clean)
```

---

## 4. Trust Score — Xác Minh Báo Cáo Cộng Đồng

> **File**: `app/api/v1/community.py`
> **API**: `POST /api/v1/community/report/{id}/verify`

### 4.1 Mô Hình Điểm Tin Cậy

Trust Score được mô hình hóa như **bounded random walk** cập nhật theo từng hành động xác minh:

$$T_0 = 0.5 \quad \text{(khởi tạo)}$$

$$T_{n+1} = \begin{cases} \min\!\left(1.0,\ T_n + \delta^+\right) & \text{nếu xác nhận (verify)} \\ \max\!\left(0.0,\ T_n + \delta^-\right) & \text{nếu bác bỏ (reject)} \end{cases}$$

Trong đó:
$$\delta^+ = +0.1, \quad \delta^- = -0.15$$

---

### 4.2 Phân Loại Trạng Thái Tự Động

$$\text{Status}(T_n) = \begin{cases} \texttt{VERIFIED} & T_n \geq 0.7 \\ \texttt{REJECTED} & T_n \leq 0.1 \\ \texttt{PENDING} & 0.1 < T_n < 0.7 \end{cases}$$

---

### 4.3 Phân Tích Hội Tụ

**Số lần verify để đạt ngưỡng VERIFIED** (từ $T_0 = 0.5$):

$$T_0 + k \times \delta^+ \geq 0.7 \Rightarrow k \geq \frac{0.7 - 0.5}{0.1} = 2$$

→ Cần tối thiểu **2 lần verify** để báo cáo được xác nhận.

**Số lần reject để đạt ngưỡng REJECTED** (từ $T_0 = 0.5$):

$$T_0 + k \times \delta^- \leq 0.1 \Rightarrow k \geq \frac{0.5 - 0.1}{0.15} \approx 2.67 \Rightarrow k = 3$$

→ Cần tối thiểu **3 lần reject** để báo cáo bị loại bỏ.

**Lý do bất đối xứng** ($|\delta^-| > |\delta^+|$): Giảm tin cậy dễ hơn tăng — tránh spam report.

---

### 4.4 Bảng Trạng Thái Theo Số Lần Tương Tác

| Lần | Hành động | $T_n$ | Status |
|-----|-----------|-------|--------|
| 0 | Tạo báo cáo | 0.50 | PENDING |
| 1 | Verify | 0.60 | PENDING |
| 2 | Verify | 0.70 | **VERIFIED** |
| — | — | — | — |
| 1 | Reject | 0.35 | PENDING |
| 2 | Reject | 0.20 | PENDING |
| 3 | Reject | 0.05 | **REJECTED** |

### 4.5 Ràng Buộc Bổ Sung

- **Self-verification prevention**: Người tạo báo cáo không thể tự verify báo cáo của mình.
- **Precision**: `round(score, 2)` — làm tròn 2 chữ số thập phân, tránh floating-point drift.

---

## 5. JWT Authentication

> **File**: `app/core/auth.py`
> **Thư viện**: `python-jose`, `python-jose[cryptography]`

### 5.1 Cấu Trúc JWT Token

JWT có 3 phần, mỗi phần Base64URL-encoded, ngăn cách bằng dấu chấm:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9   ← Header (Base64URL)
.
eyJzdWIiOiI1NTBlODQwMC4uLiIsImV4cCI6MT...  ← Payload (Base64URL)
.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c  ← Signature (Base64URL)
```

**Header:**
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

**Payload (Claims):**
```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "exp": 1745625600,
  "iat": 1745020800
}
```

| Claim | Nội dung |
|-------|---------|
| `sub` (Subject) | UUID của user |
| `exp` (Expiration) | Unix timestamp hết hạn |
| `iat` (Issued At) | Unix timestamp tạo token |

---

### 5.2 Thuật Toán Ký — HMAC-SHA256 (HS256)

$$\text{Signature} = \text{HMAC-SHA256}\!\left(\text{Base64URL}(H) + \text{``."} + \text{Base64URL}(P),\ K_{secret}\right)$$

Trong đó:
- $H$ — Header JSON
- $P$ — Payload JSON
- $K_{secret}$ — `SECRET_KEY` (256-bit random string từ `.env`)

**HMAC** (Hash-based Message Authentication Code):

$$\text{HMAC}(K, m) = H\!\left((K \oplus \text{opad}) \| H\!\left((K \oplus \text{ipad}) \| m\right)\right)$$

Với SHA-256 làm hàm hash $H$, `opad = 0x5c5c...`, `ipad = 0x3636...`.

---

### 5.3 Quy Trình Tạo Token

```python
# app/core/auth.py
def create_access_token(subject: str) -> str:
    expire = datetime.now(UTC) + timedelta(minutes=60 * 24 * 7)  # 7 ngày
    payload = {
        "sub": subject,   # user UUID
        "exp": expire,    # expiration
        "iat": datetime.now(UTC),  # issued at
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")
```

**Thời gian hết hạn:**
$$\Delta t_{exp} = 60 \times 24 \times 7 = 10080 \text{ phút} = 7 \text{ ngày}$$

---

### 5.4 Quy Trình Xác Thực Token

```
Client gửi: Authorization: Bearer <token>
      │
      ▼
jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
      │
      ├── Lỗi JWTError? → 401 Unauthorized
      │
      ▼
user_id = payload["sub"]
      │
      ▼
SELECT * FROM users WHERE id = user_id
      │
      ├── Không tồn tại? → 401 Unauthorized
      ├── is_active = False? → 401 Unauthorized
      │
      └── ✅ → inject current_user vào handler
```

---

## 6. Bcrypt Password Hashing

> **File**: `app/core/auth.py`
> **Thư viện**: `passlib[bcrypt]`

### 6.1 Thuật Toán Bcrypt

Bcrypt là hàm hash mật khẩu **adaptive** — độ phức tạp tăng dần theo thời gian:

$$\text{bcrypt}(p, \text{salt}, \text{cost}) = \text{EksBlowfishSetup}(p, \text{salt}, \text{cost}) \rightarrow \text{ciphertext}$$

**Cấu trúc hash output:**

```
$2b$12$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
 │  │  └──────────────────────────────────────────────────────
 │  │    22 ký tự salt (Base64) + 31 ký tự hash (Base64)
 │  └── cost factor (rounds = 2^12 = 4,096 iterations)
 └── version (2b = bcrypt phiên bản 2b)
```

### 6.2 Tham Số

| Tham số | Giá trị | Mô tả |
|---------|---------|-------|
| **Version** | `2b` | Phiên bản bcrypt hiện đại |
| **Cost factor** | `12` (mặc định passlib) | $2^{12} = 4{,}096$ iterations |
| **Salt** | 16 bytes ngẫu nhiên | Tự động generate mỗi lần hash |
| **Output length** | 60 ký tự | Cố định |

### 6.3 Quy Trình

**Hash (khi tạo tài khoản):**
```python
hashed = pwd_context.hash(plain_password)
# → $2b$12$<22-char-salt><31-char-hash>
```

**Verify (khi đăng nhập):**
```python
is_valid = pwd_context.verify(plain_password, hashed_password)
# Trích xuất salt từ hashed_password → re-hash → so sánh constant-time
```

**Tại sao bcrypt thay vì SHA-256?**

| Thuộc tính | SHA-256 | bcrypt |
|-----------|---------|--------|
| Tốc độ | ~$10^9$/s (GPU) | ~$10^3$/s (thiết kế để chậm) |
| Salt | Thủ công | Tích hợp sẵn |
| Adaptive | ❌ | ✅ (tăng cost theo thời gian) |
| Rainbow table | Dễ bị | Chống tốt |

---

## 7. Tuya HMAC-SHA256 Request Signing

> **File**: `app/services/device_adapters/tuya_adapter.py`
> **API**: Tuya Cloud Open API

### 7.1 Chuỗi Ký

Tuya yêu cầu mỗi request phải có chữ ký HMAC-SHA256:

$$\text{sign\_str} = \underbrace{\text{client\_id}}_{\text{App ID}} + \underbrace{\text{access\_token}}_{\text{Platform token}} + \underbrace{t}_{\text{timestamp (ms)}} + \underbrace{\text{METHOD}}_{\text{HTTP method}} + \underbrace{\text{"}\backslash\text{n"}} + \underbrace{H_{256}(\text{body})}_{\text{SHA256 of request body}} + \underbrace{\text{"}\backslash\text{n"}} + \underbrace{\text{path}}_{\text{URL path}}$$

**Chữ ký:**

$$\text{sign} = \text{HMAC-SHA256}(\text{sign\_str},\ K_{client\_secret}).\text{hexdigest}().\text{upper}()$$

### 7.2 Request Headers

```
client_id:    <TUYA_CLIENT_ID>
access_token: <platform_token>  (trống khi lấy token lần đầu)
sign:         <HMAC-SHA256 uppercase hex>
sign_method:  HMAC-SHA256
t:            <timestamp milliseconds>
```

### 7.3 Luồng Xác Thực 2 Bước

```
Bước 1: Lấy Platform Access Token
  GET /v1.0/token?grant_type=1
  Headers: sign(client_id, "", t, "GET", path)
  Response: {access_token, expire_time: 7200}
  Cache: _token_expires = time.time() + 7200 - 60

Bước 2: Gửi lệnh thiết bị
  POST /v1.0/iot-03/devices/{id}/commands
  Headers: sign(client_id, access_token, t, "POST", path, body)
  Body: {"commands": [{"code": "switch_1", "value": true}]}
```

---

## 8. Bảng Tổng Hợp Thuật Toán

| # | Thuật toán | Độ phức tạp | Thư viện | Mục đích |
|---|-----------|-------------|---------|---------|
| 1 | **Prophet** | $O(n \log n)$ per fit | `prophet`, `pandas` | Dự báo AQI 24h |
| 2 | **Perceived AQI** | $O(k)$, $k$=số bệnh | Thuần Python | Cá nhân hóa ngưỡng nguy hiểm |
| 3 | **Haversine** | $O(1)$ | `math` | Khoảng cách Trái Đất |
| 4 | **AQI Cost Function** | $O(1)$ | Thuần Python | Tối ưu tuyến đường |
| 5 | **Trust Score** | $O(1)$ per update | Thuần Python | Xác minh báo cáo cộng đồng |
| 6 | **JWT HS256** | $O(1)$ | `python-jose` | Xác thực stateless |
| 7 | **bcrypt** | $O(2^{12})$ | `passlib` | Bảo vệ mật khẩu |
| 8 | **HMAC-SHA256** | $O(n)$ | `hmac`, `hashlib` | Xác thực Tuya API |

---

### Phụ Lục A: Ký Hiệu Toán Học

| Ký hiệu | Ý nghĩa |
|---------|---------|
| $\mathcal{N}(\mu, \sigma^2)$ | Phân phối chuẩn |
| $\text{Laplace}(0, \tau)$ | Phân phối Laplace tại 0 với scale $\tau$ |
| $\oplus$ | XOR (exclusive OR) |
| $\|$ | Ghép chuỗi (concatenation) |
| $\lfloor x \rfloor$ | Floor function |
| $\text{clip}(x, a, b)$ | $\max(a, \min(b, x))$ |

---

### Phụ Lục B: Bảng Tham Số Cố Định

| Tham số | Giá trị | Nguồn |
|---------|---------|-------|
| AQI alert threshold | 100 | `aqi_collector.py:AQI_ALERT_THRESHOLD` |
| High-risk threshold | 150 | `personalization_service.py:HIGH_RISK_THRESHOLD` |
| Prophet changepoint prior | 0.05 | `forecast_service.py` |
| Routing $\alpha$ | 0.5 | `config.py:ROUTING_ALPHA` |
| Trust score init | 0.5 | `community.py` |
| Trust $\delta^+$ | +0.1 | `community.py` |
| Trust $\delta^-$ | −0.15 | `community.py` |
| JWT expiry | 7 ngày | `config.py:ACCESS_TOKEN_EXPIRE_MINUTES` |
| bcrypt rounds | 12 | passlib default |
| Redis TTL AQI | 300s | `config.py:CACHE_TTL_AQI` |
| Redis TTL Forecast | 3600s | `config.py:CACHE_TTL_FORECAST` |
| Chat session TTL | 86400s | `chatbot_service.py:_SESSION_TTL` |
| AQI collector interval | 30 phút | APScheduler config |
| IQAir free tier | 10,000 calls/tháng | External limit |

---

*Tài liệu này trích xuất trực tiếp từ source code AirShield.*
*References: `app/services/`, `app/api/v1/`, `app/core/`, `app/tasks/`*
