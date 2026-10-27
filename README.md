# FeelMate 💙

[![Flutter](https://img.shields.io/badge/Flutter-3.5.3-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3-blue.svg?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange.svg?logo=firebase)](https://firebase.google.com)
[![TensorFlow Lite](https://img.shields.io/badge/TFLite-On--Device%20Inference-orange.svg?logo=tensorflow)](https://www.tensorflow.org/lite)
[![Google ML Kit](https://img.shields.io/badge/ML%20Kit-Face%20Detection-blue.svg?logo=google)](https://developers.google.com/ml-kit)

**FeelMate** is a mobile emotional monitoring and mental health companionship application. Developed as a **Bachelor's Thesis (Skripsi) Project**, it aims to support users in tracking their emotional health, recognizing emotions from facial expressions using on-device AI, and providing a safe, empathetic conversation partner.

*FeelMate adalah aplikasi pemantauan emosi dan pendamping kesehatan mental berbasis mobile. Dikembangkan sebagai **Proyek Skripsi**, aplikasi ini bertujuan untuk membantu pengguna melacak kesehatan emosional mereka, mengenali emosi melalui ekspresi wajah menggunakan AI on-device, serta menyediakan teman bicara yang aman dan empatis.*

---

## 🌟 Key Features / Fitur Utama

- **🧠 On-Device Facial Emotion Recognition (FER)**:
  - Uses live front-facing camera or gallery photo input.
  - Utilizes **Google ML Kit Face Detection** for fast and accurate face detection and cropping.
  - Runs local **TensorFlow Lite (`tflite_flutter`)** inference using a custom CNN model trained on FER2013 (`facialemotionmodel.tflite`) recognizing 7 emotional states: **Happy, Sad, Angry, Fear, Disgust, Surprise, Neutral**.
  - **100% On-Device & Privacy-Preserving**: No facial images are ever uploaded to cloud servers for inference.
  *(Pemindaian emosi wajah 100% berjalan di perangkat secara luring menggunakan Google ML Kit dan TensorFlow Lite, menjaga privasi pengguna tanpa mengunggah foto ke server luar.)*

- **💬 AI Companion ("Gemini Basic")**:
  - An empathetic, client-side conversational AI that responds to user mood states and provides emotional validation.
  - Built-in mental health safety net: detects distress patterns and crisis keywords to immediately offer crisis hotline contacts (LISA Hotline & Kemenkes Sejiwa 119 ext 8).
  - Guides users through calming techniques such as **Box Breathing (4-4-4-4)**, **4-7-8 Breathing**, and **5-4-3-2-1 Grounding**.
  *(Asisten AI chat empatis yang merespons suasana hati pengguna, memandu latihan pernapasan/grounding, serta menyiagakan bantuan darurat jika terdeteksi indikasi krisis.)*

- **📊 Mood Diary & History**:
  - Daily impression logs where users can write down journal entries, pick emoticons, and review past emotional states over time.
  *(Jurnal suasana hati interaktif untuk mencatat keseharian, memilih emotikon, dan meninjau riwayat emosi.)*

- **☁️ Dual Storage (Offline-First & Cloud Sync)**:
  - **SQLite (`sqflite`)**: Primary local storage ensuring core diary features work seamlessly without internet connection.
  - **Firebase (Auth & Cloud Firestore)**: Cloud synchronization for user accounts, scan history, and remote backup.
  *(Penyimpanan ganda: SQLite untuk ketersediaan offline-first dan Firestore untuk sinkronisasi akun saat online.)*

---

## 🏗️ Architecture & Project Structure / Arsitektur Proyek

FeelMate adopts the **BLoC Pattern (Business Logic Component)** and Repository Pattern to ensure clean separation between UI and business logic.

*FeelMate mengadopsi **Pola BLoC** dan Repository Pattern untuk pemisahan logika bisnis dari UI agar kode lebih terstruktur dan mudah diuji.*

```
lib/
├── blocs/          # State Management (Auth, Emotion, Logs, Impression)
├── models/         # Data Models (UserModel, EmotionalLogModel, ImpressionModel)
├── pages/          # UI Screens (Auth, Splash, Dashboard, Camera Scan, Chat, Profile)
├── repositories/   # Repository layer abstracting local and remote data
├── services/       # Services (TFLite FER Service, Firebase Auth, Firestore)
├── utils/          # Styles, color palettes (Inside Out theme), and emotion data
└── main.dart       # Application entry point & theme configuration
```

### Machine Learning Pipeline (`trainmodel_faceemotionrecognition-master/`)
- Includes Keras training scripts and Jupyter Notebook (`trainmodel.ipynb`) on FER2013 dataset.
- Export and conversion pipeline to `.tflite` format (`convert_tflite.py`).

---

## 🛠️ Technology Stack / Teknologi yang Digunakan

- **Frontend**: Flutter & Dart (Material 3 UI, Google Fonts)
- **State Management**: `flutter_bloc` & `equatable`
- **Machine Learning**: TensorFlow Lite (`tflite_flutter`), Google ML Kit (`google_mlkit_face_detection`)
- **Database**: SQLite (`sqflite`), Firebase Cloud Firestore
- **Authentication**: Firebase Authentication
- **Media**: `camera`, `image_picker`, `image`

---

## 🚀 Getting Started / Cara Memulai

### Prerequisites / Prasyarat
- Flutter SDK (v3.5.3 or later)
- Android Studio with Android SDK (Physical device or Android Emulator recommended)
- A Firebase project configured for Android

### Setup Steps / Langkah Pengaturan

1. **Clone this repository / Klon repositori ini**:
   ```bash
   git clone <your-repository-url>
   cd FeelMate
   ```

2. **Install dependencies / Pasang dependensi**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase / Konfigurasi Firebase**:
   - Register your Android app inside your Firebase Console (`google-services.json`).
   - Enable **Email/Password Provider** in Firebase Authentication.
   - Create a **Cloud Firestore Database**.

4. **Run on Android / Jalankan di perangkat Android**:
   > **Note:** Because `tflite_flutter` uses native FFI binaries, run the application on an Android device or emulator (Web/Chrome is not supported for on-device TFLite).
   ```bash
   flutter run -d android
   ```

---

## 🔒 License / Lisensi

This project is created for academic and personal thesis research.  
*Proyek ini dibuat untuk keperluan akademik dan penelitian skripsi.*
