# AirShield - Hướng Dẫn Cài Đặt

## 📱 Mobile App (Flutter)

### Bước 1: Di chuyển vào thư mục dự án
```bash
cd E:/de-an-ky-xuan/airshield/airshield_mobile
```

### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 3: Kiểm tra thiết bị có sẵn
```bash
flutter devices
```

### Bước 4: Chạy ứng dụng
```bash
# Chạy và chọn device
flutter run

# Hoặc chỉ định device cụ thể:
flutter run -d chrome          # Chạy trên Chrome
flutter run -d windows         # Chạy trên Windows (nếu có Visual Studio)
flutter run -d edge            # Chạy trên Edge browser
```

### Bước 5: Hot Reload trong khi app đang chạy
- Nhấn `r` - Reload
- Nhấn `R` - Hot restart  
- Nhấn `q` - Quit

---

## 🐍 Backend (Python)

### Bước 1: Di chuyển vào thư mục backend
```bash
cd E:/de-an-ky-xuan/airshield
```

### Bước 2: Tạo Virtual Environment (nếu chưa có)
```bash
python -m venv venv
```

### Bước 3: Kích hoạt Virtual Environment

**Windows (Git Bash):**
```bash
source venv/Scripts/activate
```

**Windows (CMD):**
```cmd
venv\Scripts\activate
```

**Windows (PowerShell):**
```powershell
venv\Scripts\Activate.ps1
```

### Bước 4: Cài đặt dependencies cơ bản (không cần PostgreSQL)
```bash
pip install fastapi "uvicorn[standard]" pydantic-settings python-dotenv
```

### Bước 5: Chạy server
```bash
python main.py
```

Server sẽ chạy tại: `http://localhost:8000`
- API Docs: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

### Bước 6 (Optional): Cài đặt full dependencies
Nếu bạn cần database (PostgreSQL):
```bash
# Cài Visual Studio Build Tools trước
# Download: https://visualstudio.microsoft.com/downloads/
# Chọn "Desktop development with C++"

pip install -r requirements.txt
```

---

## ⚠️ Troubleshooting

### Flutter Issues

**Lỗi: "No pubspec.yaml file found"**
```bash
# Đảm bảo bạn ở đúng thư mục
cd E:/de-an-ky-xuan/airshield/airshield_mobile
```

**Lỗi: "Unable to find suitable Visual Studio toolchain"**
```bash
# Chạy trên Chrome hoặc Edge thay vì Windows
flutter run -d chrome
```

**Lỗi compile**
```bash
# Clean và rebuild
flutter clean
flutter pub get
flutter run
```

### Python Issues

**Lỗi: "No module named 'fastapi'"**
```bash
# Đảm bảo virtual environment được activate
source venv/Scripts/activate  # Git Bash
venv\Scripts\activate         # CMD

# Rồi cài lại
pip install fastapi uvicorn[standard]
```

**Lỗi: "psycopg2 build failed"**
```bash
# Bỏ qua PostgreSQL packages, chỉ cài essentials
pip install fastapi "uvicorn[standard]" pydantic-settings python-dotenv
```

---

## 🎯 Quick Start (Copy & Paste)

### Mobile App
```bash
cd E:/de-an-ky-xuan/airshield/airshield_mobile
flutter pub get
flutter run -d chrome
```

### Backend  
```bash
cd E:/de-an-ky-xuan/airshield
source venv/Scripts/activate
pip install fastapi "uvicorn[standard]" pydantic-settings python-dotenv
python main.py
```

---

## 📚 Testing Notifications (Mobile)

Sau khi app chạy thành công, xem hướng dẫn test trong:
- [`TESTING_NOTIFICATIONS.md`](TESTING_NOTIFICATIONS.md)

---

## ✅ Checklist

### Mobile App
- [ ] Đã vào đúng thư mục `airshield_mobile`
- [ ] Chạy `flutter pub get` thành công
- [ ] `flutter devices` hiển thị ít nhất 1 device
- [ ] App chạy thành công trên Chrome/Edge

### Backend
- [ ] Virtual environment đã được tạo
- [ ] Virtual environment đã được activate  
- [ ] Dependencies đã được cài đặt
- [ ] Server chạy thành công tại port 8000

---

**Gặp vấn đề?**
1. Đọc kỹ error message
2. Check Troubleshooting section ở trên
3. Đảm bảo đúng thư mục làm việc
4. Kiểm tra network connection cho pip/pub
