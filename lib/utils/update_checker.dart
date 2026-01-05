import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Update Checker - Check for new releases from GitHub
class UpdateChecker {
  static const String _githubApiUrl = 
    'https://api.github.com/repos/Xnuvers007/osint_stalker/releases/latest';
  static const String _releasesUrl = 
    'https://github.com/Xnuvers007/osint_stalker/releases';

  /// Parse version string to comparable integer
  /// e.g., "3.0.0" -> 300, "1.0" -> 100, "2.1.5" -> 215
  static int _parseVersion(String version) {
    // Remove 'v' prefix if exists
    String cleanVersion = version.toLowerCase().replaceAll('v', '').trim();
    
    // Split by dots and parse
    List<String> parts = cleanVersion.split('.');
    int major = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    int minor = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    int patch = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    
    return (major * 10000) + (minor * 100) + patch;
  }

  /// Fetch latest release info from GitHub
  static Future<Map<String, dynamic>?> getLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(_githubApiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'OSINT-Stalker-App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Get download URL for APK
        String? downloadUrl;
        if (data['assets'] != null) {
          for (var asset in data['assets']) {
            if (asset['name'].toString().toLowerCase().endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'];
              break;
            }
          }
        }

        return {
          'version': data['tag_name'] ?? data['name'] ?? 'Unknown',
          'name': data['name'] ?? 'New Release',
          'body': data['body'] ?? 'No description available.',
          'published_at': data['published_at'] ?? '',
          'html_url': data['html_url'] ?? _releasesUrl,
          'download_url': downloadUrl ?? data['html_url'] ?? _releasesUrl,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  /// Check if update is available
  static Future<UpdateInfo?> checkForUpdate({String? currentVersion}) async {
    try {
      // Get current app version
      String appVersion;
      if (currentVersion != null) {
        appVersion = currentVersion;
      } else {
        try {
          final packageInfo = await PackageInfo.fromPlatform();
          appVersion = packageInfo.version;
        } catch (e) {
          appVersion = '3.1.0'; // Fallback version
        }
      }

      final latestRelease = await getLatestRelease();
      if (latestRelease == null) return null;

      final latestVersion = latestRelease['version'] as String;
      
      int currentParsed = _parseVersion(appVersion);
      int latestParsed = _parseVersion(latestVersion);

      if (latestParsed > currentParsed) {
        return UpdateInfo(
          currentVersion: appVersion,
          latestVersion: latestVersion,
          releaseName: latestRelease['name'],
          releaseNotes: latestRelease['body'],
          downloadUrl: latestRelease['download_url'],
          htmlUrl: latestRelease['html_url'],
          publishedAt: latestRelease['published_at'],
        );
      }
      
      return null; // No update available
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return null;
    }
  }

  /// Show update dialog
  static Future<void> showUpdateDialog(BuildContext context, UpdateInfo updateInfo) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF94).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.system_update, color: Color(0xFF00FF94)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Update Tersedia! 🚀',
                style: TextStyle(
                  color: Color(0xFF00FF94),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2642),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Versi Saat Ini',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        Text(
                          'v${updateInfo.currentVersion}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white38),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Versi Terbaru',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        Text(
                          updateInfo.latestVersion,
                          style: const TextStyle(
                            color: Color(0xFF00FF94),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                updateInfo.releaseName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    updateInfo.releaseNotes,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Nanti Saja',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _launchDownloadUrl(updateInfo.downloadUrl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF94),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.download, size: 18),
            label: const Text(
              'Download Update',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _launchDownloadUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Show "No update" snackbar
  static void showNoUpdateSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.black),
            SizedBox(width: 10),
            Text(
              'Aplikasi sudah versi terbaru! ✓',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00FF94),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show checking update snackbar
  static void showCheckingSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Memeriksa update...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF38BDF8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message ?? 'Gagal memeriksa update. Periksa koneksi internet.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Update info model
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseName;
  final String releaseNotes;
  final String downloadUrl;
  final String htmlUrl;
  final String publishedAt;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseName,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.htmlUrl,
    required this.publishedAt,
  });
}
