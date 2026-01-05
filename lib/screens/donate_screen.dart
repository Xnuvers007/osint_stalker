import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/qris_converter.dart';

// Theme Colors
const Color bgColor = Color(0xFF0A0E1A);
const Color cardColor = Color(0xFF151B2E);
const Color inputColor = Color(0xFF1E2642);
const Color neonGreen = Color(0xFF00FF94);
const Color neonBlue = Color(0xFF38BDF8);
const Color neonPurple = Color(0xFFA855F7);
const Color neonOrange = Color(0xFFFB923C);
const Color neonRed = Color(0xFFEF4444);
const Color neonPink = Color(0xFFEC4899);

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  String? _dynamicQris;
  bool _showQr = false;
  int _selectedAmount = 0;
  late AnimationController _heartController;

  // Predefined amounts
  final List<int> _presetAmounts = [5000, 10000, 25000, 50000, 100000, 250000];

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _generateQris() {
    int? amount;
    
    if (_selectedAmount > 0) {
      amount = _selectedAmount;
    } else if (_amountController.text.isNotEmpty) {
      amount = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    }

    if (amount == null || amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.black),
              SizedBox(width: 10),
              Text('Masukkan nominal yang valid!', style: TextStyle(color: Colors.black)),
            ],
          ),
          backgroundColor: neonOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      String qris = QrisConverter.convert(nominal: amount);
      setState(() {
        _dynamicQris = qris;
        _showQr = true;
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: neonRed,
        ),
      );
    }
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

  String _formatCurrency(int amount) {
    String str = amount.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _heartController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.9 + (_heartController.value * 0.2),
                  child: const Icon(Icons.favorite, color: neonPink, size: 24),
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'SUPPORT DEVELOPER',
              style: TextStyle(
                color: neonPink,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [neonPink.withOpacity(0.2), neonPurple.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: neonPink.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: neonPink.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.coffee, color: neonPink, size: 30),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xnuvers007',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Developer OSINT Stalker',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jika aplikasi ini membantu Anda, pertimbangkan untuk mendukung pengembangan lebih lanjut. '
                    'Setiap donasi sangat berarti! 🙏',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            // Trakteer Button
            const Text(
              'METODE DONASI',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Trakteer Card
            GestureDetector(
              onTap: () => _launchUrl('https://trakteer.id/Xnuvers007'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFBE1E2D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBE1E2D).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBE1E2D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_cafe, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trakteer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'trakteer.id/Xnuvers007',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new, color: Colors.white38),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // QRIS Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: neonGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.qr_code_2, color: neonGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QRIS DINAMIS',
                            style: TextStyle(
                              color: neonGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Masukkan nominal, generate QR',
                            style: TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Preset Amounts
                  const Text(
                    'Pilih Nominal:',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetAmounts.map((amount) {
                      bool isSelected = _selectedAmount == amount;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAmount = isSelected ? 0 : amount;
                            _amountController.clear();
                            _showQr = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? neonGreen.withOpacity(0.2) : inputColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? neonGreen : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            _formatCurrency(amount),
                            style: TextStyle(
                              color: isSelected ? neonGreen : Colors.white54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Custom Amount Input
                  const Text(
                    'Atau masukkan nominal custom:',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 15000',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(color: neonGreen),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedAmount = 0;
                          _showQr = false;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _generateQris,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code, color: Colors.black),
                          SizedBox(width: 10),
                          Text(
                            'GENERATE QRIS',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // QR Code Display
                  if (_showQr && _dynamicQris != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: _dynamicQris!,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatCurrency(_selectedAmount > 0 
                              ? _selectedAmount 
                              : int.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''))),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sora Store, PD AREN - TANGSEL',
                            style: TextStyle(color: Colors.black54, fontSize: 11),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: neonBlue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _dynamicQris!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('QRIS disalin ke clipboard!'),
                                  backgroundColor: neonBlue,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, color: neonBlue, size: 18),
                            label: const Text('Copy', style: TextStyle(color: neonBlue)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: neonPurple),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Share.share(
                                'Donasi ke Xnuvers007 via QRIS:\n$_dynamicQris',
                                subject: 'QRIS Donation',
                              );
                            },
                            icon: const Icon(Icons.share, color: neonPurple, size: 18),
                            label: const Text('Share', style: TextStyle(color: neonPurple)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Other Payment Methods
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: neonOrange, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'METODE LAIN',
                        style: TextStyle(
                          color: neonOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodTile(
                    icon: Icons.wallet,
                    title: 'GoPay / OVO / DANA',
                    subtitle: 'Transfer ke 085710815825',
                    color: const Color(0xFF00AA13),
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: '085710815825'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Nomor disalin ke clipboard!'),
                          backgroundColor: neonGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentMethodTile(
                    icon: Icons.code,
                    title: 'GitHub Sponsors',
                    subtitle: 'github.com/sponsors/Xnuvers007',
                    color: const Color(0xFF6E40C9),
                    onTap: () => _launchUrl('https://github.com/sponsors/Xnuvers007'),
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentMethodTile(
                    icon: Icons.coffee,
                    title: 'Buy Me a Coffee',
                    subtitle: 'buymeacoffee.com/xnuvers007',
                    color: const Color(0xFFFFDD00),
                    onTap: () => _launchUrl('https://www.buymeacoffee.com/xnuvers007'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Thank you message
            Center(
              child: Column(
                children: [
                  const Text(
                    '❤️ Terima Kasih Atas Dukungan Anda ❤️',
                    style: TextStyle(color: neonPink, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Developed with ☕ by Xnuvers007',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 14),
          ],
        ),
      ),
    );
  }
}
