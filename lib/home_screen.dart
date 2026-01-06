import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'osint_logic.dart';
import 'screens/donate_screen.dart';
import 'screens/dork_templates_screen.dart';
import 'screens/auth_screen.dart';
import 'utils/update_checker.dart';
import 'utils/notification_service.dart';

// Theme Colors
const Color bgColor = Color(0xFF0A0E1A);
const Color cardColor = Color(0xFF151B2E);
const Color inputColor = Color(0xFF1E2642);
const Color neonGreen = Color(0xFF00FF94);
const Color neonBlue = Color(0xFF38BDF8);
const Color neonPurple = Color(0xFFA855F7);
const Color neonOrange = Color(0xFFFB923C);
const Color neonRed = Color(0xFFEF4444);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _mainController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  
  OsintType _selectedType = OsintType.phone;
  List<OsintTarget> _results = [];
  bool _showTutorial = true;
  bool _useAdvancedDorks = true;
  Set<SearchEngine> _selectedEngines = {SearchEngine.google};
  String _filterCategory = 'All';
  
  // Double back to exit
  DateTime? _lastBackPressed;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Check for updates on app start
    _checkForUpdates(showNoUpdateMessage: false);
  }
  
  /// Check for updates from GitHub
  Future<void> _checkForUpdates({bool showNoUpdateMessage = true}) async {
    final updateInfo = await UpdateChecker.checkForUpdate(currentVersion: '3.1.0');
    if (!mounted) return;
    
    if (updateInfo != null) {
      UpdateChecker.showUpdateDialog(context, updateInfo);
    } else if (showNoUpdateMessage) {
      UpdateChecker.showNoUpdateSnackBar(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mainController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  void _search() {
    if (_mainController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.black),
              SizedBox(width: 10),
              Text('Masukkan target terlebih dahulu!', style: TextStyle(color: Colors.black)),
            ],
          ),
          backgroundColor: neonOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    setState(() {
      _results = OsintLogic.generateDorks(
        _mainController.text, 
        _selectedType,
        customDomain: _domainController.text,
        selectedEngines: _selectedEngines.toList(),
        useAdvancedDorks: _useAdvancedDorks,
      );
      _filterCategory = 'All';
    });

    HapticFeedback.mediumImpact();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka: $urlString'),
            backgroundColor: neonRed,
          ),
        );
      }
    }
  }

  List<String> get _categories {
    Set<String> cats = {'All'};
    for (var r in _results) {
      cats.add(r.category);
    }
    return cats.toList();
  }

  List<OsintTarget> get _filteredResults {
    if (_filterCategory == 'All') return _results;
    return _results.where((r) => r.category == _filterCategory).toList();
  }

  Widget _buildSearchTypeChip(OsintType type, String label, IconData icon) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? neonGreen.withOpacity(0.2) : inputColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? neonGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? neonGreen : Colors.white54, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? neonGreen : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineChip(SearchEngine engine) {
    final info = OsintLogic.engines[engine]!;
    bool isSelected = _selectedEngines.contains(engine);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected && _selectedEngines.length > 1) {
            _selectedEngines.remove(engine);
          } else {
            _selectedEngines.add(engine);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(int.parse(info.color.replaceFirst('#', '0xFF'))).withOpacity(0.2) : inputColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(int.parse(info.color.replaceFirst('#', '0xFF'))) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(info.icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              info.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        
        final now = DateTime.now();
        if (_lastBackPressed == null || 
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.exit_to_app, color: Colors.black, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Tekan back sekali lagi untuk keluar aplikasi',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: neonOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        drawer: _buildDrawer(),
        appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: neonGreen.withOpacity(0.3 + (_pulseController.value * 0.3)),
                          blurRadius: 10 + (_pulseController.value * 10),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.radar, color: neonGreen, size: 22),
                  );
                },
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OSINT STALKER",
                    style: TextStyle(
                      color: neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "v3.0 PRO",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined, color: Colors.white54),
              tooltip: 'Clear',
              onPressed: () {
                _mainController.clear();
                _domainController.clear();
                setState(() {
                  _results.clear();
                  _filterCategory = 'All';
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: neonRed),
              tooltip: 'Donate',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DonateScreen()),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          // --- PERUBAHAN UTAMA DIMULAI DI SINI ---
          // Menggunakan CustomScrollView agar seluruh halaman bisa di-scroll
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Tutorial Card
                    if (_showTutorial) _buildTutorialCard(),
        
                    // Search Type Selection
                    const Text(
                      "TIPE PENCARIAN",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSearchTypeChip(OsintType.phone, 'Phone', Icons.phone_android),
                          const SizedBox(width: 8),
                          _buildSearchTypeChip(OsintType.email, 'Email', Icons.alternate_email),
                          const SizedBox(width: 8),
                          _buildSearchTypeChip(OsintType.username, 'Username', Icons.person_outline),
                          const SizedBox(width: 8),
                          _buildSearchTypeChip(OsintType.name, 'Name', Icons.badge_outlined),
                          const SizedBox(width: 8),
                          _buildSearchTypeChip(OsintType.domain, 'Domain', Icons.language),
                          const SizedBox(width: 8),
                          _buildSearchTypeChip(OsintType.ip, 'IP Address', Icons.router_outlined),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
        
                    // Main Input
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [neonGreen.withOpacity(0.1), neonBlue.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: neonGreen.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _mainController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: _getHintText(),
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: Icon(_getTypeIcon(), color: neonGreen, size: 22),
                          suffixIcon: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: neonGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.search, color: Colors.black, size: 20),
                            ),
                            onPressed: _search,
                          ),
                        ),
                        keyboardType: _getKeyboardType(),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
        
                    // Custom Domain Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: inputColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _domainController,
                        style: const TextStyle(color: neonBlue, fontSize: 14),
                        decoration: InputDecoration(
                          icon: const Icon(Icons.travel_explore, color: neonBlue, size: 18),
                          hintText: "Custom Domain (opsional, cth: linkedin.com)",
                          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
        
                    const SizedBox(height: 12),
        
                    // Search Engines Selection
                    const Text(
                      "SEARCH ENGINES",
                      style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: SearchEngine.values.map((e) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _buildEngineChip(e),
                        )).toList(),
                      ),
                    ),
        
                    const SizedBox(height: 12),
        
                    // Advanced Dorks Toggle
                    Row(
                      children: [
                        Switch(
                          value: _useAdvancedDorks,
                          onChanged: (v) => setState(() => _useAdvancedDorks = v),
                          activeColor: neonPurple,
                        ),
                        const Text(
                          'Advanced Dorks (intitle, intext, inurl, filetype)',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
        
                    const SizedBox(height: 10),
        
                    // Category Filter
                    if (_results.isNotEmpty) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            bool isSelected = _filterCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _filterCategory = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? neonPurple.withOpacity(0.3) : inputColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? neonPurple : Colors.transparent,
                                    ),
                                  ),
                                  child: Text(
                                    cat == 'All' ? '🎯 All (${_results.length})' : '$cat (${_results.where((r) => r.category == cat).length})',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white54,
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ]),
                ),
              ),
        
              // Results Section (Menggunakan SliverList atau SliverToBoxAdapter)
              if (_results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _filteredResults[index];
                        return _buildResultCard(item, index);
                      },
                      childCount: _filteredResults.length,
                    ),
                  ),
                ),
                
              // Tambahan padding bawah agar tidak tertutup navbar (jika ada)
              const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTutorialCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [neonBlue.withOpacity(0.1), neonPurple.withOpacity(0.1)],
        ),
        border: Border.all(color: neonBlue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: neonBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lightbulb_outline, color: neonBlue, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "PANDUAN PENGGUNAAN",
                    style: TextStyle(color: neonBlue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _showTutorial = false),
                child: const Icon(Icons.close, color: neonBlue, size: 18),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "• Pilih tipe pencarian (Phone, Email, Username, dll)\n"
            "• Masukkan target di kolom input\n"
            "• (Opsional) Tambahkan custom domain untuk pencarian spesifik\n"
            "• Pilih search engines yang ingin digunakan\n"
            "• Aktifkan 'Advanced Dorks' untuk dorking lengkap\n"
            "• Tap hasil untuk membuka di browser",
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2 + (_pulseController.value * 0.2)),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 60,
                  color: Colors.grey.withOpacity(0.3 + (_pulseController.value * 0.2)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            "SYSTEM READY",
            style: TextStyle(
              color: Colors.white24,
              letterSpacing: 4,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Masukkan target untuk memulai pencarian",
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(OsintTarget item, int index) {
    Color accentColor = _getAccentColor(item.category);
    
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: accentColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _launchUrl(item.url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(item.icon, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: accentColor.withOpacity(0.5), size: 14),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms)
      .slideX(begin: 0.1, end: 0);
  }

  Color _getAccentColor(String category) {
    switch (category) {
      case 'Custom': return neonBlue;
      case 'Social Media': return const Color(0xFF1DA1F2);
      case 'Advanced Dork': return neonPurple;
      case 'Document': return neonOrange;
      case 'Leak': return neonRed;
      case 'Direct': return neonGreen;
      case 'E-Commerce': return const Color(0xFF00C853);
      case 'Professional': return const Color(0xFF0077B5);
      case 'Breach': return neonRed;
      case 'Security': return neonRed;
      case 'External': return const Color(0xFF6366F1);
      default: return neonGreen;
    }
  }

Widget _buildDrawer() {
    return Drawer(
      backgroundColor: cardColor,
      child: SafeArea(
        // --- PERBAIKAN: Gunakan CustomScrollView agar bisa di-scroll ---
        child: CustomScrollView(
          slivers: [
            // Bagian Menu (Header & Item List)
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [neonGreen.withOpacity(0.2), neonBlue.withOpacity(0.2)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: neonGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.radar, color: neonGreen, size: 30),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OSINT STALKER',
                            style: TextStyle(
                              color: neonGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'by Xnuvers007',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10),
                _buildDrawerItem(Icons.home_outlined, 'Home', () => Navigator.pop(context)),
                _buildDrawerItem(Icons.code, 'Dork Templates', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DorkTemplatesScreen()));
                }),
                _buildDrawerItem(Icons.favorite_outline, 'Donate / Support', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateScreen()));
                }),
                _buildDrawerItem(Icons.system_update, 'Check Update', () {
                  Navigator.pop(context);
                  UpdateChecker.showCheckingSnackBar(context);
                  _checkForUpdates(showNoUpdateMessage: true);
                }),
                _buildDrawerItem(Icons.lock_outline, 'App Lock Settings', () {
                  Navigator.pop(context);
                  _showAppLockSettings();
                }),
                _buildDrawerItem(Icons.notifications_outlined, 'Notification Settings', () {
                  Navigator.pop(context);
                  _showNotificationSettings();
                }),
                const Divider(color: Colors.white10),
                _buildDrawerItem(Icons.info_outline, 'About', () {
                  Navigator.pop(context);
                  _showAboutDialog();
                }),
              ]),
            ),

            // Bagian Footer (Copyright) - Otomatis menyesuaikan posisi
            SliverFillRemaining(
              hasScrollBody: false, // Penting! Agar Spacer() bekerja dengan benar
              child: Column(
                children: [
                  const Spacer(), // Mendorong text ke paling bawah
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '© 2026 Xnuvers007\nAll Rights Reserved',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700], fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.radar, color: neonGreen),
            SizedBox(width: 10),
            Text('OSINT STALKER', style: TextStyle(color: neonGreen)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 3.0 PRO', style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            Text(
              'Advanced OSINT tool dengan:\n'
              '• Multi Search Engine Support\n'
              '• Advanced Google Dorking\n'
              '• Phone, Email, Username, Domain, IP Search\n'
              '• Document & Credential Leak Detection\n'
              '• Social Media Lookup',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              'Developed by Xnuvers007',
              style: TextStyle(color: neonBlue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: neonGreen)),
          ),
        ],
      ),
    );
  }

  void _showAppLockSettings() async {
    final isEnabled = await AppLockManager.isAppLockEnabled();
    final hasPin = await AppLockManager.hasPinSet();
    final canUseBio = await AppLockManager.canUseBiometrics();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: neonPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock, color: neonPurple),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'App Lock Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // App Lock Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasPin ? Icons.lock : Icons.lock_open,
                          color: isEnabled ? neonGreen : Colors.white54,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'App Lock',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              hasPin 
                                ? (isEnabled ? 'Aktif' : 'Nonaktif') 
                                : 'PIN belum diatur',
                              style: TextStyle(
                                color: isEnabled ? neonGreen : Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: isEnabled && hasPin,
                      onChanged: hasPin ? (value) async {
                        if (value) {
                          await AppLockManager.enableAppLock();
                        } else {
                          await AppLockManager.disableAppLock();
                        }
                        setModalState(() {});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    value ? Icons.lock : Icons.lock_open,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    value ? 'App Lock diaktifkan' : 'App Lock dinonaktifkan',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              backgroundColor: neonGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      } : null,
                      activeColor: neonGreen,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Biometric info
              if (canUseBio)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: neonBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: neonBlue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.fingerprint, color: neonBlue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Biometric tersedia! Fingerprint/Face ID akan otomatis digunakan.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (!canUseBio)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: neonOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: neonOrange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: neonOrange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Biometric tidak tersedia. Hanya PIN yang akan digunakan.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Buttons
              Row(
                children: [
                  // Setup/Change PIN button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuthScreen(
                              mode: hasPin ? AuthMode.changePin : AuthMode.setupPin,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(hasPin ? Icons.edit : Icons.add),
                      label: Text(hasPin ? 'Ubah PIN' : 'Buat PIN'),
                    ),
                  ),
                  
                  if (hasPin) ...[
                    const SizedBox(width: 12),
                    // Remove PIN button
                    ElevatedButton.icon(
                      onPressed: () async {
                        await AppLockManager.disableAppLock();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text('PIN dihapus', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              backgroundColor: neonRed,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonRed.withOpacity(0.2),
                        foregroundColor: neonRed,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus'),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case OsintType.phone: return "Nomor Target (0857...)";
      case OsintType.email: return "Email Target (user@email.com)";
      case OsintType.username: return "Username Target";
      case OsintType.name: return "Nama Lengkap Target";
      case OsintType.domain: return "Domain Target (example.com)";
      case OsintType.ip: return "IP Address (192.168.x.x)";
    }
  }

  IconData _getTypeIcon() {
    switch (_selectedType) {
      case OsintType.phone: return Icons.phone_android;
      case OsintType.email: return Icons.alternate_email;
      case OsintType.username: return Icons.person_outline;
      case OsintType.name: return Icons.badge_outlined;
      case OsintType.domain: return Icons.language;
      case OsintType.ip: return Icons.router_outlined;
    }
  }

  TextInputType _getKeyboardType() {
    switch (_selectedType) {
      case OsintType.phone: return TextInputType.phone;
      case OsintType.email: return TextInputType.emailAddress;
      case OsintType.ip: return TextInputType.number;
      default: return TextInputType.text;
    }
  }

  void _showNotificationSettings() async {
    final notificationService = NotificationService();
    bool isPermissionGranted = await notificationService.isPermissionGranted();
    bool notificationsEnabled = await NotificationSettingsManager.isNotificationEnabled();

    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: neonOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.notifications, color: neonOrange, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Notification Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Permission status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPermissionGranted ? neonGreen.withOpacity(0.3) : neonRed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPermissionGranted ? Icons.check_circle : Icons.warning_rounded,
                        color: isPermissionGranted ? neonGreen : neonRed,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPermissionGranted ? 'Permission Granted' : 'Permission Required',
                              style: TextStyle(
                                color: isPermissionGranted ? neonGreen : neonRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPermissionGranted 
                                  ? 'Notifikasi sudah diizinkan'
                                  : 'Izinkan notifikasi untuk fitur lengkap',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (!isPermissionGranted)
                        TextButton(
                          onPressed: () async {
                            final granted = await notificationService.requestPermission();
                            setModalState(() {
                              isPermissionGranted = granted;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: neonOrange.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Izinkan', style: TextStyle(color: neonOrange)),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Enable notifications toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Colors.white70),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enable Notifications',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Terima notifikasi dari aplikasi',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: notificationsEnabled && isPermissionGranted,
                        onChanged: isPermissionGranted ? (value) async {
                          await NotificationSettingsManager.setNotificationEnabled(value);
                          setModalState(() {
                            notificationsEnabled = value;
                          });
                        } : null,
                        activeColor: neonGreen,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Quick notification actions
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickNotificationButton(
                        'Test Notification',
                        Icons.notifications_none,
                        neonGreen,
                        isPermissionGranted && notificationsEnabled
                            ? () async {
                                await notificationService.showNotification(
                                  title: '🔔 Test Notification',
                                  body: 'Notifikasi berfungsi dengan baik!',
                                );
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickNotificationButton(
                        'Tips',
                        Icons.lightbulb_outline,
                        neonBlue,
                        isPermissionGranted && notificationsEnabled
                            ? () async {
                                await notificationService.showTipsNotification();
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickNotificationButton(
                        'Security Reminder',
                        Icons.security,
                        neonPurple,
                        isPermissionGranted && notificationsEnabled
                            ? () async {
                                await notificationService.showSecurityReminder();
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickNotificationButton(
                        'Clear All',
                        Icons.clear_all,
                        neonRed,
                        isPermissionGranted
                            ? () async {
                                await notificationService.cancelAllNotifications();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Semua notifikasi dihapus'),
                                      backgroundColor: cardColor,
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickNotificationButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
        foregroundColor: onPressed != null ? color : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
