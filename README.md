# 📚 Study Anything — AI-Powered Study App

> Upload any PDF. Let AI generate questions. Test yourself. Master anything.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-orange?logo=firebase)
![Groq AI](https://img.shields.io/badge/Groq-LLaMA%203.3-green)
![License](https://img.shields.io/badge/License-MIT-purple)

---

## 🎯 Overview

**Study Anything** is a Flutter mobile application that transforms any PDF document into an interactive quiz using AI. Simply upload a chapter or study material, choose your preferred question type, and let the AI generate and evaluate your answers intelligently.

---

## ✨ Features

| Feature | Description |
|---|---|
| 📄 PDF Upload | Pick any PDF from your device |
| 🤖 AI Question Generation | Generates MCQs, Short, Long & Conceptual questions |
| 🧠 Smart Answer Evaluation | AI evaluates answers by meaning, not exact match |
| 🔐 Firebase Authentication | Google Sign-In & Email/Password with verification |
| 📊 Detailed Results | Score, grade, correct answers & explanations |
| 💡 Context-Aware Grading | Accepts correct answers even if worded differently |

---

## 🛠 Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter & Dart |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| AI / LLM | Groq API (LLaMA 3.3-70b) |
| State Management | Flutter Riverpod |
| Navigation | GoRouter |
| PDF Processing | Syncfusion Flutter PDF |
| Fonts | Google Fonts (Poppins) |

---

## 📱 App Flow

```
Login → Upload PDF → Select Question Type → Answer Questions → AI Evaluates → View Results
```

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK `^3.11.5`
- Dart SDK `^3.11.5`
- Firebase project
- Groq API key (free at [console.groq.com](https://console.groq.com))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ZiaKhanMohmand/study-anything-FLUTTER-APP-.git
   cd study-anything-FLUTTER-APP-
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Create `.env` file** in project root:
   ```
   GROQ_API_KEY=your_groq_api_key_here
   ```

4. **Add Firebase config**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔑 Environment Variables

| Variable | Description | Get it from |
|---|---|---|
| `GROQ_API_KEY` | Groq LLaMA API key | [console.groq.com](https://console.groq.com/keys) |

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── models/          # Data models
│   ├── services/        # Groq AI & PDF services
│   ├── constants/       # Prompts & app constants
│   └── router/          # GoRouter configuration
└── features/
    ├── auth/            # Login screen & auth provider
    ├── home/            # Home screen
    ├── upload/          # PDF upload screen
    ├── quiz/            # Mode select & quiz screen
    └── results/         # Results screen
```

---

## 🤖 AI Capabilities

- **Question Generation** — LLaMA 3.3-70b generates contextual questions from PDF content
- **Answer Evaluation** — AI evaluates answers semantically, not just by exact string match
- **Multiple Question Types:**
  - 📝 MCQs (10 questions)
  - ✏️ Short Questions (5 questions)
  - 📖 Long/Essay Questions (3 questions)
  - 💡 Conceptual Questions (5 questions)

---

## 👨‍💻 Developer

**Zia Khan Mohmand**
- GitHub: [@ZiaKhanMohmand](https://github.com/ZiaKhanMohmand)
- Linkedin: https://www.linkedin.com/in/ziakhanmohmand/

---

## 📄 License

This project is licensed under the MIT License.
