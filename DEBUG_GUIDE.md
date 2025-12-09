# 🔍 Debug Guide - Cara Lihat Log

## 📱 Cara Melihat Log di Terminal

Sambil aplikasi running, buka terminal baru dan jalankan:

```bash
adb logcat | findstr "flutter\|API\|PickImage\|Compress\|Provider\|Permission"
```

## 📊 Expected Output Saat Upload Foto

### ✅ SUKSES - Flow Lengkap:

```
=== START PICK IMAGE ===
[PickImage] Source: Gallery
[PickImage] Opening gallery...
[PickImage] Image selected: /path/to/image.jpg
[PickImage] File size: 2048 KB
[PickImage] Starting compression...
[Compress] Original image: /path/to/image.jpg
[Compress] Original size: 2048 KB
[Compress] Compressing to: /data/.../compressed_xxx.jpg
[Compress] Compressed size: 512 KB
[Compress] Reduction: 75.0%
[PickImage] Compression done. Using: /data/.../compressed_xxx.jpg
[PickImage] Starting face analysis...
[Provider] Starting face analysis...
==========================================
[API] Starting face analysis
[API] Image path: /data/.../compressed_xxx.jpg
[API] API URL: https://epsilon-raimulabs.hf.space/predict
[API] File exists: YES
[API] File size: 512 KB (524288 bytes)
[API] Creating multipart file...
[API] Multipart file added successfully
[API] Sending request to server...
[API] This may take 10-30 seconds...
[API] Response received!
[API] Status code: 200
[API] Response body length: 450 chars
[API] Response body: {"final_prediction":"OVAL","svm":"OVAL","mlp":"OVAL","knn":"OVAL","confidence":"3/3","image":"base64..."}
[API] Parsing JSON response...
[API] ✓ Face shape detected: OVAL
[API] SVM: OVAL
[API] MLP: OVAL
[API] KNN: OVAL
[API] Confidence: 3/3
[API] Success! Returning result.
==========================================
[Provider] Analysis successful: OVAL
[PickImage] Analysis complete. Error: null, Result: OVAL
[PickImage] Navigating to Result Page
=== END PICK IMAGE ===
```

### ❌ ERROR - No Face Detected:

```
[API] Response body: {"error":"No face detected in image"}
[API] ✗ ERROR during face analysis
[API] Error: Exception: No face detected in image
[Provider] Analysis failed: Exception: No face detected in image
[Provider] Error message set to: Wajah tidak terdeteksi. Pastikan foto wajah Anda jelas dan menghadap kamera.
[PickImage] Analysis complete. Error: Wajah tidak terdeteksi..., Result: null
[PickImage] Navigating to Error Page
```

### ❌ ERROR - Connection/Timeout:

```
[API] Sending request to server...
[API] This may take 10-30 seconds...
[API] REQUEST TIMEOUT after 60 seconds
[API] ✗ ERROR during face analysis
[API] Error: Exception: Request timeout
```

### ❌ ERROR - Server Error:

```
[API] Response received!
[API] Status code: 500
[API] Server error: 500
```

## 🎯 Testing Steps:

1. **Buka Terminal untuk Log:**
   ```bash
   adb logcat -c  # Clear log dulu
   adb logcat | findstr "flutter\|API\|PickImage"
   ```

2. **Di HP - Test Galeri:**
   - Tap tombol galeri (bawah kiri)
   - Pilih foto wajah yang jelas
   - Akan muncul preview dialog
   - Tap "Lanjutkan"
   - Tunggu loading (10-30 detik)
   - Lihat hasilnya

3. **Di HP - Test Kamera:**
   - Tap tombol kamera (tengah besar)
   - Ambil foto selfie
   - Akan muncul preview dialog
   - Tap "Lanjutkan"
   - Tunggu loading
   - Lihat hasilnya

4. **Cek Log:**
   - Lihat output di terminal
   - Cari error jika gagal
   - Catat status code & response body

## 🐛 Troubleshooting by Log:

| Log Output | Artinya | Solusi |
|------------|---------|---------|
| `No permissions found in manifest` | Normal warning, bisa diabaikan | - |
| `REQUEST TIMEOUT` | Server lambat/tidak respons | Check internet, coba lagi |
| `Status code: 500` | Server error | Coba lagi, atau foto bermasalah |
| `error: No face detected` | Wajah tidak terdeteksi | Gunakan foto yang lebih jelas |
| `File tidak ditemukan` | Path error | Bug - restart app |
| `Exception: Gagal menganalisis` | Generic error | Check log detail di atasnya |

## 💡 Tips:

- **Gunakan foto wajah frontal yang jelas**
- **Pencahayaan bagus** (tidak gelap/silau)
- **Wajah mengisi frame** (tidak terlalu jauh)
- **Koneksi internet stabil**
- **Tunggu loading sampai selesai** (10-30 detik normal)

## 📸 Test Photo Guidelines:

✅ **Good:**
- Frontal face
- Clear features
- Good lighting
- Neutral expression
- Single person

❌ **Bad:**
- Side profile
- Dark/shadowy
- Blurry
- Sunglasses/mask
- Multiple faces
- Face too small

## 🔗 Check API Status:

Buka browser di HP/PC:
```
https://epsilon-raimulabs.hf.space/
```

Harus loading halaman upload. Kalau error 503/502 → API server down.
