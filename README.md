# FeelMate 💙

[![Flutter](https://img.shields.io/badge/Flutter-3.5.3-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3-blue.svg?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange.svg?logo=firebase)](https://firebase.google.com)
[![Hugging Face](https://img.shields.io/badge/Hugging%20Face-ViT%20Expression-yellow.svg?logo=huggingface)](https://huggingface.co)

**FeelMate** is a mobile emotional monitoring and mental health companionship application. Developed as a **Bachelor's Thesis (Skripsi) Project**, it aims to support users in tracking their emotional health, recognizing emotions from facial expressions using AI, and providing a safe, empathetic conversation partner.

*FeelMate adalah aplikasi pemantauan emosi dan pendamping kesehatan mental berbasis mobile. Dikembangkan sebagai **Proyek Skripsi**, aplikasi ini bertujuan untuk membantu pengguna melacak kesehatan emosional mereka, mengenali emosi melalui ekspresi wajah menggunakan AI, serta menyediakan teman bicara yang aman dan empatis.*

---

## 🌟 Key Features / Fitur Utama

- **🧠 Facial Emotion Recognition (FER)**: Uses camera or gallery photo input to recognize 7 facial emotions (Happy, Sad, Angry, Fear, Disgust, Surprise, Neutral) utilizing a Vision Transformer model (`vit-face-expression`) hosted on the Hugging Face Inference API.
  *(Menggunakan input foto kamera/galeri untuk mengenali 7 emosi wajah menggunakan model Vision Transformer di Hugging Face Inference API.)*
- **💬 AI Companion ("Gemini Basic")**: An empathetic, client-side conversational AI that responds to user mood states, monitors stress patterns, triggers relaxation techniques (such as box breathing), and suggests crisis hotlines when needed.
  *(Asisten AI chat empatis yang merespons suasana hati pengguna, memantau tingkat stres, memandu latihan pernapasan, serta menyarankan bantuan darurat jika diperlukan.)*
- **📊 Mood Tracking & History**: An interactive log history where users can write down their thoughts, store details, and review emotional charts over time.
  *(Riwayat pencatatan suasana hati interaktif di mana pengguna dapat menulis pikiran mereka dan melihat grafik emosi dari waktu ke waktu.)*
- **☁️ Cloud & Local Sync**: Dual storage support utilizing **SQLite (`sqflite`)** for local caching and offline availability, coupled with **Firebase (Auth & Cloud Firestore)** for cloud sync.
  *(Penyimpanan ganda menggunakan SQLite untuk luring (offline) dan Firebase untuk sinkronisasi awan.)*

---

## 🏗️ Architecture & Project Structure / Arsitektur Proyek

FeelMate adopts the **BLoC Pattern (Business Logic Component)** to ensure a clean separation of concerns, testability, and responsiveness.

*FeelMate mengadopsi **Pola BLoC** untuk pemisahan logika bisnis dari UI agar kode lebih rapi dan mudah diuji.*

```
lib/
├── blocs/        # State Management (Auth, Emotion, Logs, Impression)
├── models/       # Data Models (User, EmotionalLog, Impression)
├── pages/        # UI Screen Views (Auth, Splash, Dashboard, Chat, Profile)
├── repositories/ # Repository layer fetching data from services
├── services/     # API Integrations (Hugging Face FER, Firebase Auth, Firestore)
├── utils/        # Styles, constants, and custom theme colors
└── main.dart     # Application entry point & configuration
```

---

## 🛠️ Technology Stack / Teknologi yang Digunakan

- **Frontend**: Flutter & Dart (Material 3 UI, Google Fonts)
- **State Management**: `flutter_bloc` & `equatable`
- **Database**: SQLite (`sqflite`), Firebase Cloud Firestore
- **Authentication**: Firebase Authentication
- **AI/ML Inference**: Hugging Face Inference API (`trpakov/vit-face-expression`)
- **HTTP client**: `http`

---

## 🚀 Getting Started / Cara Memulai

### Prerequisites / Prasyarat
- Flutter SDK installed (v3.5.3 or later)
- Android Studio or VS Code with Flutter extensions
- A Firebase project configured for Android/iOS

### Setup Steps / Langkah Pengaturan

1. **Clone this repository / Klon repositori ini**:
   ```bash
   git clone <your-repository-url>
   cd FeelMate-App-master
   ```

2. **Install dependencies / Pasang dependensi**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase / Konfigurasi Firebase**:
   - Register your Android/iOS app inside your Firebase Console.
   - Download the configurations or use `flutterfire configure` to generate `lib/firebase_options.dart`.
   - Enable **Email/Password Provider** in Firebase Authentication.
   - Create a **Cloud Firestore Database**.

4. **Run the application / Jalankan aplikasi**:
   ```bash
   flutter run
   ```

---

## 🔒 License / Lisensi

This project is created for academic and personal thesis research.
*Proyek ini dibuat untuk keperluan akademik dan penelitian skripsi.*
