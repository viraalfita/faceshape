# 🧪 Testing Guide - Face Shape Detection App

## 📱 Cara Testing di HP

### 1️⃣ Build & Install
```bash
flutter run --release
# atau
flutter build apk --release
```

### 2️⃣ Cek Logs Saat Testing

Sambungkan HP dengan USB debugging, lalu jalankan:
```bash
adb logcat | findstr "flutter"
```

Atau lihat log di Android Studio/VS Code terminal.

---

## 🔍 Yang Harus Dicek

### ✅ Permission Testing

**Test Kamera:**
1. Tap tombol kamera
2. Harus muncul popup "Allow Camera?"
3. Pilih "Allow" atau "While using the app"
4. Camera should open

**Test Galeri:**
1. Tap tombol galeri
2. Harus muncul popup "Allow Photos?"
3. Pilih "Allow" atau "Allow access to all photos"
4. Gallery should open

**Jika Tidak Muncul Popup:**
- Buka Settings → Apps → FaceShape
- Cek permissions (Camera & Storage)
- Reset permissions jika perlu
- Uninstall & reinstall app

---

## 📊 Expected Logs

### ✓ Sukses Upload:
```
[Permission] Requesting gallery permission...
[Permission] Photos status: granted
[PickImage] Image selected: /path/to/image.jpg
[Compress] Original size: 2048 KB
[Compress] Compressed size: 512 KB
[DEBUG] Starting face analysis for: /path/compressed_image.jpg
[DEBUG] File size: 524288 bytes
[DEBUG] Sending request to API...
[DEBUG] Response status code: 200
[DEBUG] Response body: {"final_prediction":"OVAL",...}
[DEBUG] Detected face shape: OVAL
[Provider] Analysis successful: OVAL
```

### ✗ Error - No Permission:
```
[Permission] Requesting gallery permission...
[Permission] Photos status: denied
[PickImage] Permission denied
```

### ✗ Error - No Face:
```
[DEBUG] Response body: {"error":"No face detected in image"}
[Provider] Analysis failed: Exception: No face detected in image
```

### ✗ Error - Timeout:
```
[DEBUG] Sending request to API...
[ERROR] Request timeout - server tidak merespons dalam 60 detik
```

---

## 🐛 Troubleshooting

### Problem: Permission tidak muncul
**Solution:**
```bash
# Uninstall app
adb uninstall com.faceshape.faceshape

# Clear data
adb shell pm clear com.faceshape.faceshape

# Reinstall
flutter run
```

### Problem: Wajah tidak terdeteksi
**Check:**
1. ✅ Foto wajah jelas & frontal?
2. ✅ Pencahayaan cukup?
3. ✅ File size tidak terlalu besar? (auto-compressed to ~500KB)
4. ✅ Internet connection?
5. ✅ API endpoint working? (check https://epsilon-raimulabs.hf.space/)

### Problem: App crash saat upload
**Check logs for:**
- OutOfMemory → Image too large (should be fixed with compression)
- Permission denied → Need to reinstall app
- Network error → Check internet connection

---

## 📸 Test Images

**Good Test Photos:**
- ✅ Clear frontal face
- ✅ Good lighting
- ✅ No blur
- ✅ Face fills frame
- ✅ Neutral expression

**Bad Test Photos:**
- ❌ Side profile
- ❌ Dark/shadowy
- ❌ Blurry
- ❌ Face too small
- ❌ Multiple faces
- ❌ Sunglasses/mask

---

## 🎯 Expected Behavior

1. **Tap Camera Button**
   - Permission popup → Allow
   - Camera opens (front-facing)
   - Take photo
   - Loading dialog "Menganalisis wajah..."
   - Navigate to Result Page (if success) or Error Page (if fail)

2. **Tap Gallery Button**
   - Permission popup → Allow
   - Gallery opens
   - Select photo
   - Image compressed (if > 500KB)
   - Loading dialog "Menganalisis wajah..."
   - Navigate to Result Page (if success) or Error Page (if fail)

3. **Error Page Shows:**
   - Error message (specific to error type)
   - Tips for better photos
   - Try Again button

---

## 🔧 Manual Permission Check (if needed)

```bash
# Check current permissions
adb shell dumpsys package com.faceshape.faceshape | findstr permission

# Grant permissions manually
adb shell pm grant com.faceshape.faceshape android.permission.CAMERA
adb shell pm grant com.faceshape.faceshape android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.faceshape.faceshape android.permission.WRITE_EXTERNAL_STORAGE

# For Android 13+
adb shell pm grant com.faceshape.faceshape android.permission.READ_MEDIA_IMAGES
```

---

## 📝 Report Issues

If testing fails, collect:
1. Full logs from `adb logcat`
2. Screenshot of error
3. Android version
4. Steps to reproduce
5. Test image (if face detection fails)
