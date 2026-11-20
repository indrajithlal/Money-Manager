# Privacy Policy for Money Manager

**Last updated:** November 2026

Money Manager is built as a **100% offline, privacy-first personal finance application**. Your privacy is of the utmost importance to us. This Privacy Policy outlines our principles and clarifies that no personal or financial data is ever collected, transmitted, or shared.

---

### 1. Zero Data Collection
- Money Manager **does not collect, transmit, store, or share** any personal information or financial data.
- We do not run any remote servers, analytics platforms, advertising SDKs, tracking pixels, or telemetry systems.

### 2. Local Storage Only
- All your transactions, categories, budgets, group expenses, and settlements are stored solely on your device using a local SQLite database.
- Database backups created by the app are stored exclusively in the location on your device that you specify. They are never automatically uploaded to any cloud service or third party.

### 3. Permissions Used
Money Manager requests only the minimum permissions necessary for its offline features:
- **Biometric / Fingerprint Authentication (`USE_BIOMETRIC` / `USE_FINGERPRINT`)**: Used exclusively to lock and unlock the app locally using your device's secure biometric authentication hardware. Biometric data is managed by your operating system and is never accessible to this app.
- **Storage / File Access**: Used only when you explicitly choose to create a database backup, restore from a backup file, or export a PDF settlement report.
- **Query Packages / URL Launching**: Used solely when you click external links (such as viewing project source code on GitHub or donating via UPI / Ko-fi).

### 4. Internet Access
- Money Manager **does not require internet access** to operate.
- Network requests occur only when you explicitly interact with external links (e.g., viewing project source code on GitHub or opening Ko-fi / UPI in your external browser or payment app).

### 5. Third-Party Services
- The application does not integrate any third-party services that track users across apps or websites.
- When opening external donation links (Ko-fi or UPI), your interaction is handled directly by your browser or chosen payment app under their respective privacy policies.

### 6. Open Source & Auditability
- Money Manager is an open-source project. Its entire source code is publicly auditable on GitHub:
  [https://github.com/indrajithlal/Money-Manager](https://github.com/indrajithlal/Money-Manager)

---

### Contact
If you have questions or suggestions regarding this Privacy Policy, please open an issue on GitHub:
[https://github.com/indrajithlal/Money-Manager/issues](https://github.com/indrajithlal/Money-Manager/issues)
