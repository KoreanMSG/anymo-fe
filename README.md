# HSIL Voice Recognition App

A Flutter application that records patient-doctor conversations and analyzes suicide risk levels.

## Features

1. **Home Screen (Audio List)**
   - Display list of recorded conversations
   - Navigate to analysis results page when selecting a conversation
   - Navigate to new recording page via floating button

2. **Voice Recognition Page**
   - Start/stop recording with button click
   - Automatically navigate to analysis results page after recording ends
   - Doctor/patient conversation start setting possible

3. **Voice Recognition Result Page**
   - Display conversation as chat interface (Telegram/WhatsApp style)
   - Display conversation analysis results (suicide risk level)
   - Display memo information

## Data Model

```dart
Chat
- id (Long)
- startWithDoctor (boolean): Whether it starts with a doctor
- text (String): Conversation content ('@@' separator)
- riskScore (int): Suicide risk level (1-100, low-high)
- memo (String): Additional memo
- createdAt (DateTime): Creation time
```

## Installation and Execution

1. Required Requirements:
   - Flutter SDK
   - Dart SDK

2. Clone Project:
   ```bash
   git clone [repository-url]
   cd HSIL-Korean-MSG/frontend
   ```

3. Install Dependencies:
   ```bash
   flutter pub get
   ```

4. Run App:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart               # App Entry Point
├── models/
│   └── chat_model.dart     # Data Model
├── screens/
│   ├── home_screen.dart    # Home Screen (Audio List)
│   ├── record_screen.dart  # Recording Page
│   └── result_screen.dart  # Analysis Results Page
├── services/
│   └── chat_service.dart   # Data Management Service
└── widgets/
    └── chat_bubble.dart    # Chat Bubble Widget
```

## Upcoming Features

- Actual Speech Recognition API Integration
- Recording File Storage and Management
- Detailed Analysis Results Information
