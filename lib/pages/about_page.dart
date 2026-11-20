import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/pages/licenses_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri about_url = Uri.parse('https://www.instagram.com/___indrajith._/');
final Uri github_url = Uri.parse(
  'https://github.com/indrajithlal/Money-Manager',
);
final Uri privacy_policy_url = Uri.parse(
  'https://github.com/indrajithlal/Money-Manager/blob/main/PRIVACY_POLICY.md',
);
final Uri kofi_url = Uri.parse('https://ko-fi.com/indrajith_lal');
const String upi_id = 'indrajithlal.official@okhdfcbank';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchExternalUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchUpi(BuildContext context) async {
    final Uri upiUri = Uri.parse('upi://pay?pa=$upi_id&pn=Indrajith&cu=INR');
    try {
      final launched = await launchUrl(
        upiUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _copyUpiToClipboard(context);
      }
    } catch (_) {
      if (context.mounted) {
        _copyUpiToClipboard(context);
      }
    }
  }

  void _copyUpiToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: upi_id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI ID copied to clipboard: $upi_id'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: dark_blue, size: 24),
            const SizedBox(width: 8),
            Text(
              "Privacy Policy",
              style: TextStyle(
                color: dark4,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Money Manager is built as a 100% offline, privacy-first personal finance app.\n",
                style: TextStyle(color: dark4, fontSize: 14),
              ),
              _buildBulletPoint(
                "Zero Data Collection",
                "No analytics, tracking, or personal data collected.",
              ),
              _buildBulletPoint(
                "100% Local Storage",
                "All financial records and backups stay solely on your device.",
              ),
              _buildBulletPoint(
                "On-Device Security",
                "Biometric authentication is managed locally by your OS.",
              ),
              _buildBulletPoint(
                "No External Servers",
                "No accounts, no cloud sync, and no third-party telemetry.",
              ),
              const SizedBox(height: 8),
              Text(
                "Read the full policy on GitHub for complete details.",
                style: TextStyle(
                  color: dark3,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchExternalUrl(privacy_policy_url);
            },
            child: Text(
              "View on GitHub",
              style: TextStyle(color: dark_blue, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.check_circle_outline, color: green, size: 16),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: dark4, fontSize: 13),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w500,
            color: white3,
          ),
        ),
        elevation: 0,
        backgroundColor: dark4,
        foregroundColor: white3,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: white3),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: white3,
      body: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Material(
                color: white1,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Center(
                          child: Image.asset('assets/app_icon.png'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Money Manager",
                        style: TextStyle(
                          color: dark_blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "v1.0.0",
                        style: TextStyle(
                          color: dark1,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: white2,
                        child: ListTile(
                          onTap: () {
                            _launchExternalUrl(about_url);
                          },
                          leading: const SizedBox(
                            height: 60,
                            width: 60,
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/profilepic.jpg',
                              ),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                          title: Text(
                            'Developer',
                            style: TextStyle(
                              color: red,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Text(
                            //user?.email?.split("@")[0] ?? 'UserName',
                            "Indrajith",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: dark1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Material(
                color: white1,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: Column(
                    children: [
                      Material(
                        //width: double.infinity,
                        color: white2,
                        child: ListTile(
                          title: Text(
                            "Development",
                            style: TextStyle(
                              color: red,
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                          ),
                          leading: Icon(Icons.code, size: 23, color: red),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          _launchExternalUrl(github_url);
                        },
                        title: Text(
                          "Github",
                          style: TextStyle(
                            color: dark1,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        leading: Icon(
                          Icons.cloud_download_outlined,
                          size: 23,
                          color: dark_blue,
                        ),
                        trailing: Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: dark1,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LicensesPage(),
                            ),
                          );
                        },
                        title: Text(
                          "Licenses",
                          style: TextStyle(
                            color: dark1,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        leading: Icon(
                          Icons.library_books_outlined,
                          size: 23,
                          color: dark_blue,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: dark1,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          _showPrivacyPolicyDialog(context);
                        },
                        title: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            color: dark1,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        leading: Icon(
                          Icons.privacy_tip_outlined,
                          size: 23,
                          color: dark_blue,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: dark1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Material(
                color: white1,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: Column(
                    children: [
                      Material(
                        //width: double.infinity,
                        color: white2,
                        child: ListTile(
                          title: Text(
                            "Donate",
                            style: TextStyle(
                              color: red,
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                          ),
                          leading: Icon(
                            Icons.monetization_on_outlined,
                            size: 23,
                            color: red,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () => _launchUpi(context),
                        onLongPress: () => _copyUpiToClipboard(context),
                        title: Text(
                          "Gpay / UPI",
                          style: TextStyle(
                            color: dark1,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          upi_id,
                          style: TextStyle(
                            color: dark1,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        leading: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 23,
                          color: dark_blue,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.copy, size: 18, color: dark1),
                          tooltip: "Copy UPI ID",
                          onPressed: () => _copyUpiToClipboard(context),
                        ),
                      ),
                      ListTile(
                        onTap: () => _launchExternalUrl(kofi_url),
                        title: Text(
                          "Ko-fi",
                          style: TextStyle(
                            color: dark1,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "ko-fi.com/indrajith_lal",
                          style: TextStyle(
                            color: dark1,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        leading: Icon(Icons.coffee, size: 23, color: dark_blue),
                        trailing: Icon(
                          Icons.open_in_new,
                          size: 18,
                          color: dark1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
