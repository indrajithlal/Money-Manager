import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/constants/theme_data.dart';

class LicensesPage extends StatefulWidget {
  const LicensesPage({super.key});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _PackageLicense {
  final String name;
  final String description;
  final bool isDirect;
  final List<List<LicenseParagraph>> licenses;

  _PackageLicense({
    required this.name,
    required this.description,
    required this.isDirect,
    required this.licenses,
  });
}

class _LicensesPageState extends State<LicensesPage> {
  bool _isLoading = true;
  int _selectedTab = 0; // 0: App Packages, 1: All & Engine
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  List<_PackageLicense> _allPackages = [];
  List<_PackageLicense> _directPackages = [];

  // Direct app dependencies with friendly descriptions
  static const Map<String, String> directPackageDescriptions = {
    'fl_chart': 'Interactive and customizable charts library for Flutter',
    'flutter_slidable': 'Smooth slidable list item actions for transactions',
    'sqflite': 'Local SQLite database storage engine for transactions & accounts',
    'pdf': 'Full-featured PDF creation library for split expense settlement reports',
    'printing': 'Native plugin to print and share PDF documents',
    'shared_preferences': 'Persistent key-value preferences for settings & currency',
    'intl': 'Internationalization, date formatting, and number formatting',
    'currency_picker': 'Currency selector with universal currency codes and symbols',
    'local_auth': 'Secure biometric fingerprint authentication',
    'file_picker': 'File selector for database backup and restore operations',
    'open_file': 'Native document viewer invocation for exported PDF reports',
    'url_launcher': 'External application and web browser URL dispatcher',
    'pie_chart': 'Animated category pie and donut visualizer',
    'path_provider': 'Filesystem locator for local application databases and exports',
    'grouped_list': 'Grouped transaction lists with sticky date headers',
    'cupertino_icons': 'iOS-style icon set assets',
    'flutter': 'The Flutter Framework and Material Design widgets',
  };

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLicenses() async {
    final Map<String, List<List<LicenseParagraph>>> packageMap = {};

    await for (final LicenseEntry entry in LicenseRegistry.licenses) {
      final paragraphs = entry.paragraphs.toList();
      for (final String package in entry.packages) {
        packageMap.putIfAbsent(package, () => []).add(paragraphs);
      }
    }

    final List<_PackageLicense> all = [];
    final List<_PackageLicense> direct = [];

    // Sort package names alphabetically
    final sortedNames = packageMap.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    for (final name in sortedNames) {
      final isDirect = directPackageDescriptions.containsKey(name);
      final desc = directPackageDescriptions[name] ?? 'Supporting runtime or engine library';
      final item = _PackageLicense(
        name: name,
        description: desc,
        isDirect: isDirect,
        licenses: packageMap[name]!,
      );

      all.add(item);
      if (isDirect) {
        direct.add(item);
      }
    }

    if (mounted) {
      setState(() {
        _allPackages = all;
        _directPackages = direct;
        _isLoading = false;
      });
    }
  }

  List<_PackageLicense> get _displayedPackages {
    final source = _selectedTab == 0 ? _directPackages : _allPackages;
    if (_searchQuery.trim().isEmpty) return source;
    final query = _searchQuery.toLowerCase().trim();
    return source.where((pkg) {
      return pkg.name.toLowerCase().contains(query) || pkg.description.toLowerCase().contains(query);
    }).toList();
  }

  void _showLicenseDetail(_PackageLicense package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: white1,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: dark3.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package.name,
                                style: TextStyle(
                                  color: dark4,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                package.description,
                                style: TextStyle(
                                  color: dark3,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: dark_blue, size: 20),
                          tooltip: "Copy License Text",
                          onPressed: () {
                            final fullText = package.licenses
                                .map((lic) => lic.map((p) => p.text).join('\n\n'))
                                .join('\n\n---\n\n');
                            Clipboard.setData(ClipboardData(text: fullText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('License copied for ${package.name}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: dark4, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Content
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: package.licenses.length,
                      itemBuilder: (context, licIndex) {
                        final paragraphs = package.licenses[licIndex];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: white2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: white3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: paragraphs.map((p) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: (p.indent * 16.0).clamp(0.0, 64.0),
                                  bottom: 8.0,
                                ),
                                child: Text(
                                  p.text,
                                  style: TextStyle(
                                    color: dark4,
                                    fontSize: 12.5,
                                    fontFamily: 'monospace',
                                    height: 1.45,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white3,
      appBar: AppBar(
        title: Text(
          "Licenses",
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: dark_blue),
                  const SizedBox(height: 16),
                  Text(
                    "Loading licenses...",
                    style: TextStyle(color: dark3, fontSize: 15),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Top App Banner Card
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: white1,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: dark4.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: white2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Image.asset('assets/app_icon.png'),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Money Manager",
                                style: TextStyle(
                                  color: dark_blue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "Free & Open-Source Software",
                                style: TextStyle(
                                  color: dark3,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Distributed under open-source terms. Tap any package to review its full license.",
                                style: TextStyle(
                                  color: dark1,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: white1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: dark4, fontSize: 14),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search package or library...",
                        hintStyle: TextStyle(color: dark3, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: dark3, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: dark3, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = "";
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tab Switcher (App Packages vs All / Engine)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: white2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedTab != 0) {
                                setState(() => _selectedTab = 0);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? dark_blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _selectedTab == 0
                                    ? [
                                        BoxShadow(
                                          color: dark_blue.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "App Packages (${_directPackages.length})",
                                  style: TextStyle(
                                    color: _selectedTab == 0 ? white1 : dark1,
                                    fontSize: 13,
                                    fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedTab != 1) {
                                setState(() => _selectedTab = 1);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? dark_blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _selectedTab == 1
                                    ? [
                                        BoxShadow(
                                          color: dark_blue.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "All & Engine (${_allPackages.length})",
                                  style: TextStyle(
                                    color: _selectedTab == 1 ? white1 : dark1,
                                    fontSize: 13,
                                    fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Package List
                Expanded(
                  child: _displayedPackages.isEmpty
                      ? Center(
                          child: Text(
                            "No matching licenses found",
                            style: TextStyle(color: dark3, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          itemCount: _displayedPackages.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final pkg = _displayedPackages[index];
                            final licenseCount = pkg.licenses.length;

                            return Material(
                              color: white1,
                              borderRadius: BorderRadius.circular(12),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                onTap: () => _showLicenseDetail(pkg),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pkg.name,
                                        style: TextStyle(
                                          color: dark4,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pkg.isDirect
                                            ? light_blue.withValues(alpha: 0.25)
                                            : white2,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "$licenseCount ${licenseCount == 1 ? 'license' : 'licenses'}",
                                        style: TextStyle(
                                          color: pkg.isDirect ? dark_blue : dark3,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    pkg.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: dark3,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                  color: dark3,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
