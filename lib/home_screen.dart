import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'osint_logic.dart';

const Color bgColor = Color(0xFF0F172A);
const Color cardColor = Color(0xFF1E293B);
const Color inputColor = Color(0xFF334155);
const Color neonGreen = Color(0xFF00FF94);
const Color neonBlue = Color(0xFF38BDF8);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _mainController = TextEditingController();
  final TextEditingController _domainController = TextEditingController(); // Controller baru untuk domain
  
  OsintType _selectedType = OsintType.phone;
  List<OsintTarget> _results = [];
  bool _showTutorial = true;

  void _search() {
    if (_mainController.text.isEmpty) return;
    setState(() {
      _results = OsintLogic.generateDorks(
        _mainController.text, 
        _selectedType,
        customDomain: _domainController.text, // Kirim data domain
      );
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Row(
          children: const [
            Icon(Icons.radar, color: neonGreen),
            SizedBox(width: 10),
            Text("OSINT STALKER V2", style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _mainController.clear();
              _domainController.clear();
              setState(() => _results.clear());
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showTutorial)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(0.1),
                  border: Border.all(color: neonBlue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("💡 PANDUAN CUSTOM SEARCH", style: TextStyle(color: neonBlue, fontWeight: FontWeight.bold)),
                        InkWell(
                          onTap: () => setState(() => _showTutorial = false),
                          child: const Icon(Icons.close, color: neonBlue, size: 16),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Untuk mencari target di website spesifik, isi kolom 'Custom Domain'.\n"
                      "• Contoh: ketik 'linkedin.com' untuk mencari profil kerja.\n"
                      "• Contoh: ketik 'tokopedia.com' untuk mencari jejak toko.\n"
                      "• Tidak perlu mengetik 'site:', sistem akan menambahkannya otomatis.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

            // === SECTION INPUT UTAMA ===
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: inputColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  DropdownButton<OsintType>(
                    value: _selectedType,
                    dropdownColor: inputColor,
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: neonGreen),
                    items: const [
                      DropdownMenuItem(value: OsintType.phone, child: Padding(padding: EdgeInsets.only(left:8.0), child: Icon(Icons.phone_android, color: Colors.white))),
                      DropdownMenuItem(value: OsintType.email, child: Padding(padding: EdgeInsets.only(left:8.0), child: Icon(Icons.alternate_email, color: Colors.white))),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _mainController,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: _selectedType == OsintType.phone ? "Nomor Target (0857...)" : "Email Target",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      keyboardType: _selectedType == OsintType.phone ? TextInputType.number : TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: inputColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _domainController,
                      style: const TextStyle(color: neonBlue),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.travel_explore, color: neonBlue, size: 20),
                        hintText: "Custom Domain (Opsional, cth: linkedin.com)",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _search,
                  child: const Icon(Icons.search, color: Colors.black),
                )
              ],
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: _results.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fingerprint, size: 60, color: Colors.grey[700]),
                      const SizedBox(height: 10),
                      Text("SYSTEM READY", style: TextStyle(color: Colors.grey[600], letterSpacing: 2)),
                    ],
                  )
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: index == 0 ? neonBlue.withOpacity(0.5) : Colors.transparent), // Highlight hasil pertama (Custom)
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: FaIcon(
                            item.title.contains("WhatsApp") ? FontAwesomeIcons.whatsapp : 
                            item.title.contains("Social") ? FontAwesomeIcons.usersViewfinder :
                            FontAwesomeIcons.google,
                            color: item.title.contains("Custom") ? neonBlue : neonGreen,
                            size: 20,
                          ),
                        ),
                        title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(item.description, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                        onTap: () => _launchUrl(item.url),
                      ),
                    );
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }
}