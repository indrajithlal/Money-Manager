import 'package:money_manager/constants/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri about_url = Uri.parse('https://www.instagram.com/___indrajith._/');
final Uri github_url = Uri.parse(
  'https://github.com/indrajith69/money-manager',
);
final Uri privacy_policy_url = Uri.parse(
  'https://gist.github.com/indrajith69/d5505bf32fb861018cb5e8e888265f9f',
);
final Uri gpay_url = Uri.parse('https://www.google.com');

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchUrl(Uri _url) async {
    // 1. Check if the URL can be launched
    if (!await launchUrl(_url)) {
      // 2. If launching failed, throw an error or show a user message
      throw Exception('Could not launch $_url');
    }
    // 3. The launchUrl function handles the redirection if it is possible
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
                      Container(
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
                        "v0.0.1",
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
                            print("clicked");
                            _launchUrl(about_url);
                          },
                          leading: const SizedBox(
                            height: 60,
                            width: 60,
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/profilepic.jpeg',
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
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: dark1,
                          ),
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
                            print("clicked");
                            _launchUrl(github_url);
                          },
                          title: Text(
                            "Github",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            "See Project Code on Github",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          leading: Icon(
                            Icons.cloud_download_outlined,
                            size: 23,
                            color: dark_blue,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            print("clicked");
                            _launchUrl(privacy_policy_url);
                          },
                          title: Text(
                            "Licenses",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            "Licenses and Agreements",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          leading: Icon(
                            Icons.library_books_outlined,
                            size: 23,
                            color: dark_blue,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "App Version",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            "v0.0.1",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          leading: Icon(
                            Icons.phone_android,
                            size: 23,
                            color: dark_blue,
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
                          title: Text(
                            "Gpay/UPI",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            "indrajithlal.official@okhdfcbank",
                            style: TextStyle(
                              color: dark1,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          leading: Icon(
                            Icons.currency_rupee,
                            size: 23,
                            color: dark_blue,
                          ),
                        ),
                        ListTile(
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
                          leading: Icon(
                            Icons.coffee,
                            size: 23,
                            color: dark_blue,
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
