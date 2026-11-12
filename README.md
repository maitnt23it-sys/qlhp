# QLHocPhan - Quan ly giang vien

## 1. Backend (Node.js + MongoDB Atlas)
cd backend
npm install
cp .env.example .env     # sua MONGO_URI, JWT_SECRET, ADMIN_USER, ADMIN_PASS
npm start                # http://localhost:5000

Atlas: Network Access -> cho phep IP cua ban (hoac 0.0.0.0/0 khi test).
Database: QLHocPhan | Collection: GiangVien 

## 2. Flutter
cd flutter_app
flutter create .        
flutter pub get

flutter run -d chrome    # web
flutter run              # mobile (Android
 emulator dung 10.0.2.2; may that doi IP trong lib/services/api_service.dart)

Android: them <uses-permission android:name="android.permission.INTERNET"/> vao
android/app/src/main/AndroidManifest.xml va android:usesCleartextTraffic="true" trong <application>.
iOS: image_picker can NSPhotoLibraryUsageDescription / NSCameraUsageDescription trong Info.plist.

## 3. Xuat file CSDL de nop
mongoexport --uri="<MONGO_URI>" --collection=GiangVien --out=GiangVien.json --jsonArray









npm start  
flutter run -d chrome  