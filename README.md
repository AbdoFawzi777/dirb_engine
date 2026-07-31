# Dirb Engine (`dirb_engine`)

> Dictionary-Based Web Content Audit Engine  
> **Author & Original Architect:** [Abdallah Fawzi Ali Mahmoud](https://github.com/AbdoFawzi777)  
> **Part of the RedOps Hub Monorepo Suite**

---

## 📌 Overview
`dirb_engine` is a production-grade, standalone Flutter package engineered for high-performance mobile security auditing. Built with pure Dart and native Flutter MethodChannels/Isolates, it delivers enterprise-level capability directly on Android & iOS devices without relying on external Linux command-line dependencies.

---

## 🚀 New Capabilities & Features (v2.0)
- **Dictionary Audit Modes:** Fast wordlist-driven directory and object existence checking.
- **Case-Sensitive & Insensitive Search:** Handles case-sensitive Linux paths as well as case-insensitive Windows IIS endpoints.
- **Custom Authentication Support:** Injects custom session tokens, cookies, and HTTP Basic auth headers.
- **Structured Log Output:** Produces clean JSON logs compatible with executive reporting tools.

---

## 🛠 Usage & Integration

Add `dirb_engine` to your Flutter `pubspec.yaml`:

```yaml
dependencies:
  dirb_engine:
    path: ../packages/dirb_engine
```

### Basic Example

```dart
import 'package:dirb_engine/dirb_engine.dart';

void main() async {
  final engine = DirbEngine();
  
  print('Starting Dirb Engine audit...');
  final results = await engine.execute(
    target: '192.168.1.1',
  );
  
  print('Audit Complete!');
}
```

---

## 🔒 Security & Privacy
- **Zero Telemetry:** No analytics, tracking, or network calls home.
- **Encrypted Local Storage:** Integrates seamlessly with RedOps Hub AES-256 local database.
- **Thread Safety:** All heavy operations execute inside Dart Isolates to maintain 60fps UI rendering.

---

## 👤 Author & Copyright

**Abdallah Fawzi Ali Mahmoud**  
Lead Developer & Security Architect of RedOps Hub  
- **GitHub:** [@AbdoFawzi777](https://github.com/AbdoFawzi777)  
- **Telegram:** [@ABdo_FawZi1](https://telegram.me/ABdo_FawZi1)  
- **Website:** [RedOps Hub Platform](https://redops-hub.web.app)

*Copyright (c) 2026 Abdallah Fawzi Ali Mahmoud. All rights reserved.*
