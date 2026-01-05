import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../osint_logic.dart';

// Theme Colors
const Color bgColor = Color(0xFF0A0E1A);
const Color cardColor = Color(0xFF151B2E);
const Color inputColor = Color(0xFF1E2642);
const Color neonGreen = Color(0xFF00FF94);
const Color neonBlue = Color(0xFF38BDF8);
const Color neonPurple = Color(0xFFA855F7);
const Color neonOrange = Color(0xFFFB923C);

class DorkTemplatesScreen extends StatefulWidget {
  const DorkTemplatesScreen({super.key});

  @override
  State<DorkTemplatesScreen> createState() => _DorkTemplatesScreenState();
}

class _DorkTemplatesScreenState extends State<DorkTemplatesScreen> {
  final TextEditingController _targetController = TextEditingController();
  String _selectedTemplate = '';

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka: $urlString'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchWithTemplate(DorkTemplate template) {
    if (_targetController.text.isEmpty) {
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

    String query = OsintLogic.applyDorkTemplate(template, _targetController.text);
    String url = OsintLogic.buildSearchUrl(SearchEngine.google, query);
    _launchUrl(url);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final templates = OsintLogic.getDorkTemplates();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.code, color: neonPurple, size: 24),
            SizedBox(width: 10),
            Text(
              'DORK TEMPLATES',
              style: TextStyle(
                color: neonPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Target Input
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [neonPurple.withOpacity(0.1), neonBlue.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: neonPurple.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _targetController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Masukkan target (email, nomor, username, dll)',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Icon(Icons.search, color: neonPurple),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

          // Info Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: neonBlue.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: neonBlue, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap template untuk langsung mencari target dengan dork tersebut di Google.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Dork Operators Reference
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildOperatorChip('site:', 'Cari di domain tertentu'),
                  _buildOperatorChip('intitle:', 'Cari di judul halaman'),
                  _buildOperatorChip('intext:', 'Cari di isi halaman'),
                  _buildOperatorChip('inurl:', 'Cari di URL'),
                  _buildOperatorChip('filetype:', 'Cari tipe file'),
                  _buildOperatorChip('ext:', 'Cari ekstensi file'),
                  _buildOperatorChip('cache:', 'Lihat cache Google'),
                  _buildOperatorChip('related:', 'Situs terkait'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Templates List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _buildTemplateCard(template, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorChip(String operator, String description) {
    return Tooltip(
      message: description,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: inputColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          operator,
          style: const TextStyle(
            color: neonGreen,
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(DorkTemplate template, int index) {
    bool isSelected = _selectedTemplate == template.name;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTemplate = template.name);
        _searchWithTemplate(template);
      },
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: template.template));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Template disalin!'),
            backgroundColor: neonGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? neonPurple : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: neonPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTemplateIcon(template.name),
                    color: neonPurple,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        template.description,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: neonGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_arrow, color: neonGreen, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: inputColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                template.template,
                style: const TextStyle(
                  color: neonBlue,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: template.operators.map((op) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: neonOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    op.name,
                    style: const TextStyle(color: neonOrange, fontSize: 9),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms)
      .slideX(begin: 0.1, end: 0);
  }

  IconData _getTemplateIcon(String name) {
    switch (name) {
      case 'Social Media': return Icons.people;
      case 'Document Leaks': return Icons.description;
      case 'Paste Sites': return Icons.paste;
      case 'Code Repos': return Icons.code;
      case 'Forums': return Icons.forum;
      case 'E-commerce': return Icons.shopping_cart;
      case 'Job Sites': return Icons.work;
      case 'Dating Sites': return Icons.favorite;
      case 'Credentials': return Icons.lock;
      case 'Config Files': return Icons.settings;
      default: return Icons.search;
    }
  }
}
