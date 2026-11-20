# Money Manager

An offline personal finance and expense tracking app for Android built with Flutter.

## Features

- **Income & Expense Tracking**: Log transactions across customizable categories and accounts (cash, bank, cards). Filter and search transaction history.
- **Statistics & Analytics**: Monthly summaries (savings rate, daily average), category breakdown charts, daily spending bar chart, and 6-month cashflow trends.
- **Split Expenses**: Create group expense sessions, calculate minimal settlement paths ("who owes whom"), and export itemized PDF reports.
- **Offline & Private**: Runs 100% offline. Data is stored locally in an SQLite database with optional biometric authentication.
- **Backup & Restore**: Export and import `.db` database files directly to device storage.
- **Customization**: Multiple currency symbols, custom date formats, and Nord-inspired theme.

## Installation

Download the latest APK from the [Releases](https://github.com/indrajithlal/Money-Manager/releases) page and install it on your device (Android 5.0+).

## Building from Source

### Prerequisites
- Flutter SDK (3.22+)
- Android SDK / JDK 17+

### Build Steps

```bash
# Clone the repository
git clone https://github.com/indrajithlal/Money-Manager.git
cd Money-Manager

# Fetch dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

The compiled APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Privacy

Money Manager does not collect, transmit, or share any personal data. All data remains on your local device. See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for details.

## License

This project is open-source under the [GPL-3.0 License](LICENSE).
