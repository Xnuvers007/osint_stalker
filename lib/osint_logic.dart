enum OsintType { phone, email }

class OsintTarget {
  final String title;
  final String url;
  final String description;

  OsintTarget({required this.title, required this.url, required this.description});
}

class OsintLogic {
  // Membersihkan input nomor HP Indonesia agar formatnya standar (62...)
  static String sanitizePhone(String input) {
    String clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) {
      clean = '62${clean.substring(1)}';
    }
    return clean;
  }

  static List<OsintTarget> generateDorks(String input, OsintType type) {
    List<OsintTarget> targets = [];
    
    if (type == OsintType.phone) {
      String phone = sanitizePhone(input); // Format: 62857...
      String local = "0${phone.substring(2)}"; // Format: 0857...
      
      // 1. Google Dork Umum (Broad Search)
      targets.add(OsintTarget(
        title: "Google Broad Search",
        url: 'https://www.google.com/search?q="$phone" OR "$local" OR "+$phone"',
        description: "Mencari format nomor umum di seluruh web.",
      ));

      // 2. Social Media Specific
      targets.add(OsintTarget(
        title: "Social Media Lookup",
        url: 'https://www.google.com/search?q=site:facebook.com OR site:instagram.com OR site:twitter.com OR site:linkedin.com "$phone" OR "$local"',
        description: "Mencari jejak di FB, IG, Twitter, LinkedIn.",
      ));

      // 3. Document/File Leak
      targets.add(OsintTarget(
        title: "File & Database Leaks",
        url: 'https://www.google.com/search?q=filetype:xls OR filetype:xlsx OR filetype:csv OR filetype:pdf OR filetype:txt "$phone" OR "$local"',
        description: "Mencari nomor di dalam file Excel/PDF yang terindeks.",
      ));

      // 4. WhatsApp API Check (Direct Chat)
      targets.add(OsintTarget(
        title: "WhatsApp Direct Check",
        url: 'https://wa.me/$phone',
        description: "Mengecek apakah nomor aktif di WA dan melihat foto profil.",
      ));
      
      // 5. Truecaller Search (Web)
      targets.add(OsintTarget(
        title: "Truecaller Search",
        url: 'https://www.truecaller.com/search/id/$phone',
        description: "Cek database Truecaller (Login required).",
      ));

    } else {
      // LOGIKA UNTUK EMAIL
      String email = input.trim();
      
      // 1. Have I Been Pwned
      targets.add(OsintTarget(
        title: "Have I Been Pwned",
        url: 'https://haveibeenpwned.com/account/$email',
        description: "Cek apakah email bocor di data breach besar.",
      ));

      // 2. Google Dork Password/Config
      targets.add(OsintTarget(
        title: "Config & Password Exposure",
        url: 'https://www.google.com/search?q=site:pastebin.com OR site:github.com "$email" AND (password OR pass OR key OR token)',
        description: "Mencari kredensial yang bocor di Pastebin/Github.",
      ));
      
      // 3. Gravatar Check
      targets.add(OsintTarget(
        title: "Gravatar Profile",
        url: 'http://en.gravatar.com/site/check/$email',
        description: "Mencari foto profil global yang terhubung ke email.",
      ));
    }

    return targets;
  }
}