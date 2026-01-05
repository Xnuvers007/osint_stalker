import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'osint_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  OsintType _selectedType = OsintType.phone;
  List<OsintTarget> _results = [];

  void _search() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _results = OsintLogic.generateDorks(_controller.text, _selectedType);
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
      backgroundColor: const Color(0xFF0F172A), // Dark Navy
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("OSINT STALKER", style: TextStyle(color: createGreen)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              _controller.clear();
              setState(() => _results.clear());
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // INPUT SECTION
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Dropdown Type
                  DropdownButton<OsintType>(
                    value: _selectedType,
                    dropdownColor: const Color(0xFF334155),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: createGreen),
                    items: const [
                      DropdownMenuItem(value: OsintType.phone, child: Icon(Icons.phone, color: Colors.white)),
                      DropdownMenuItem(value: OsintType.email, child: Icon(Icons.email, color: Colors.white)),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(width: 10),
                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _selectedType == OsintType.phone ? "Ex: 0857xxxx / 62857xxxx" : "Ex: target@gmail.com",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  // Button
                  IconButton(
                    icon: const Icon(Icons.search, color: createGreen),
                    onPressed: _search,
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // RESULT LIST
            Expanded(
              child: _results.isEmpty 
              ? Center(child: Text("Ready to Scan", style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: createGreen.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: ListTile(
                        leading: FaIcon(
                          _selectedType == OsintType.phone ? FontAwesomeIcons.phoneFlip : FontAwesomeIcons.at,
                          color: createGreen,
                        ),
                        title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(item.description, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        trailing: const Icon(Icons.open_in_new, color: Colors.white),
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

const Color createGreen = Color(0xFF00FF94); // Hacker Green Color