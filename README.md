# Budget Manager PK 🇵🇰

A comprehensive budget management Flutter app specifically designed for Pakistani users. This app helps you track your income, expenses, set budgets, achieve savings goals, and manage your finances with support for Pakistani Rupee (PKR) and local payment methods.

## 🌟 Features

### Core Features
- **Income and Expense Tracking** - Track all your financial transactions with PKR currency support
- **Category-based Management** - Organize expenses with Pakistani lifestyle-relevant categories
- **Budget Planning** - Set and monitor weekly, monthly, quarterly, and yearly budgets
- **Savings Goals** - Create and track progress towards your financial goals
- **Bill Reminders** - Never miss a payment with recurring bill reminders
- **Financial Analytics** - Beautiful charts and reports to understand your spending patterns
- **Multi-account Support** - Manage cash, bank accounts, and mobile wallets

### Pakistan-Specific Features
- **Local Payment Methods** - Support for JazzCash, Easypaisa, and other Pakistani mobile wallets
- **Pakistani Banks** - Pre-configured list of major Pakistani banks
- **Urdu Language Support** - Complete app localization in Urdu
- **PKR Currency** - Native support for Pakistani Rupee with proper formatting
- **Local Categories** - Expense categories relevant to Pakistani lifestyle (utilities, transport, etc.)

### Technical Features
- **Material Design 3** - Modern, beautiful UI with Material You components
- **Dark Mode** - Complete dark theme support
- **Offline Storage** - Works without internet using local Hive database
- **Responsive Design** - Optimized for various screen sizes
- **Smooth Animations** - Polished user experience with fluid transitions
- **State Management** - Robust state management using Riverpod

## 📱 Screenshots

*Screenshots will be added here*

## 🏗️ Architecture

The app follows **Clean Architecture** principles with a feature-based folder structure:

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration and themes
│   ├── providers/          # Global state providers
│   └── services/           # Core services (Hive, Notifications)
├── features/               # Feature modules
│   ├── auth/              # Authentication and onboarding
│   ├── dashboard/         # Main dashboard
│   ├── transactions/      # Transaction management
│   ├── budgets/          # Budget planning
│   ├── goals/            # Savings goals
│   ├── accounts/         # Account management
│   ├── categories/       # Category management
│   ├── reminders/        # Bill reminders
│   └── settings/         # App settings
├── generated/            # Generated localization files
└── l10n/                # Localization resources
```

Each feature follows the structure:
- `data/models/` - Data models with Hive annotations
- `providers/` - Riverpod state management
- `presentation/screens/` - UI screens
- `presentation/widgets/` - Reusable widgets

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10+
- **Language**: Dart 3.0+
- **State Management**: Riverpod 2.4+
- **Local Database**: Hive 2.2+
- **Charts**: FL Chart 0.65+
- **Localization**: Flutter Intl
- **Icons**: Phosphor Flutter
- **Animations**: Lottie

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mohammad-Ali-Soomro/Budget-App.git
   cd Budget-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📊 Data Models

The app uses Hive for local storage with the following main models:

- **UserModel** - User profile and preferences
- **TransactionModel** - Income, expense, and transfer records
- **CategoryModel** - Expense and income categories
- **AccountModel** - Bank accounts, cash, mobile wallets
- **BudgetModel** - Budget planning and tracking
- **GoalModel** - Savings goals and progress
- **ReminderModel** - Bill reminders and notifications

## 🎨 Design System

### Color Palette
- **Primary Green**: #2E7D32 (Pakistani flag inspired)
- **Secondary Blue**: #1976D2
- **Accent Orange**: #FF9800
- **Accent Red**: #E53935
- **Success**: #4CAF50
- **Warning**: #FFC107

### Typography
- **Primary Font**: Roboto (English)
- **Secondary Font**: Noto Sans Urdu (Urdu text)

## 🌍 Localization

The app supports:
- **English** (en) - Default language
- **Urdu** (ur) - Complete translation

To add new languages:
1. Create new ARB file in `lib/l10n/`
2. Add translations
3. Run `flutter gen-l10n`

## 🔧 Configuration

### Pakistani Banks
Pre-configured banks include:
- HBL, UBL, NBP, MCB, ABL
- Standard Chartered, Faysal Bank
- Bank Alfalah, Askari Bank, etc.

### Mobile Wallets
Supported mobile payment methods:
- JazzCash, Easypaisa
- UBL Omni, HBL Konnect
- Sadapay, Nayapay, Oraan

### Default Categories
Pakistani lifestyle categories:
- Food & Dining, Transportation
- Utilities (WAPDA, K-Electric, Gas)
- Healthcare, Education
- Religious (Zakat, Sadaqah)
- Family, Business

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## 📈 Performance

- **App Size**: ~15MB (release APK)
- **Startup Time**: <2 seconds
- **Memory Usage**: <100MB average
- **Battery Optimization**: Minimal background processing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Mohammad Ali Soomro**
- GitHub: [@Mohammad-Ali-Soomro](https://github.com/Mohammad-Ali-Soomro)
- Email: 157400016+Mohammad-Ali-Soomro@users.noreply.github.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Pakistani developer community
- Open source contributors
- Material Design team for design guidelines

## 📞 Support

For support, email 157400016+Mohammad-Ali-Soomro@users.noreply.github.com or create an issue on GitHub.

---

**Made with ❤️ for Pakistan 🇵🇰**
