enum OsintType { phone, email }

class OsintTarget {
  final String title;
  final String url;
  final String description;

  OsintTarget({required this.title, required this.url, required this.description});
}

class OsintLogic {
  
  static String sanitizePhone(String input) {
    String clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) {
      clean = '62${clean.substring(1)}';
    }
    return clean;
  }

  static String _generatePermutations(String cleanPhone) {
    if (cleanPhone.length < 10) return '"$cleanPhone"';

    String local = '0${cleanPhone.substring(2)}';
    
    String p1 = local.substring(0, 4);
    String p2 = local.substring(4, 8);
    String p3 = local.substring(8);
    
    // Variasi Format
    List<String> formats = [
      '"$cleanPhone"',                // "628123456789"
      '"+$cleanPhone"',               // "+628123456789"
      '"$local"',                     // "0857123456789"
      '"$p1-$p2-$p3"',                // "0857-1234-56789"
      '"$p1 $p2 $p3"',                // "0857 1234 56789"
      '"+62 ${cleanPhone.substring(2, 5)}-${cleanPhone.substring(5, 9)}-${cleanPhone.substring(9)}"', // +62 857-1234-56789
      '"+62 ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5, 9)} ${cleanPhone.substring(9)}"', // +62 857 1234 56789
    ];

    return formats.join(' | ');
  }

  static List<OsintTarget> generateDorks(String input, OsintType type, {String? customDomain}) {
    List<OsintTarget> targets = [];
    
    if (type == OsintType.phone) {
      String phone = sanitizePhone(input);
      String permutationString = _generatePermutations(phone); 

      if (customDomain != null && customDomain.isNotEmpty) {
        String cleanDomain = customDomain.replaceAll('site:', '').trim();
        
        targets.add(OsintTarget(
          title: "Custom Search: $cleanDomain",
          url: 'https://www.google.com/search?q=site:$cleanDomain ($permutationString)',
          description: "Mencari semua variasi nomor hanya di dalam $cleanDomain",
        ));
      }

      targets.add(OsintTarget(
        title: "Deep Broad Search",
        url: 'https://www.google.com/search?q=$permutationString',
        description: "Mencari SEMUA kemungkinan format penulisan nomor.",
      ));

      targets.add(OsintTarget(
        title: "Social Media Lookup",
        url: 'https://www.google.com/search?q=site:facebook.com | site:instagram.com | site:twitter.com | site:linkedin.com ($permutationString)',
        description: "Scan profil FB, IG, Twitter, LinkedIn.",
      ));

      targets.add(OsintTarget(
        title: "File & Database Leaks",
        url: 'https://www.google.com/search?q=filetype:xls OR filetype:xlsx OR filetype:csv OR filetype:pdf OR filetype:txt ($permutationString)',
        description: "Mencari di file Excel/PDF publik.",
      ));

      targets.add(OsintTarget(
        title: "WhatsApp Direct Check",
        url: 'https://wa.me/$phone',
        description: "Mengecek status WA aktif/tidak.",
      ));
      
      targets.add(OsintTarget(
        title: "Truecaller Search",
        url: 'https://www.truecaller.com/search/id/$phone',
        description: "Cek tags nama di Truecaller.",
      ));

    } else {
      String email = input.trim();
      
      if (customDomain != null && customDomain.isNotEmpty) {
        String cleanDomain = customDomain.replaceAll('site:', '').trim();
        targets.add(OsintTarget(
          title: "Custom Search: $cleanDomain",
          url: 'https://www.google.com/search?q=site:$cleanDomain "$email"',
          description: "Mencari email ini spesifik di $cleanDomain",
        ));
      }

      targets.add(OsintTarget(
        title: "Have I Been Pwned",
        url: 'https://haveibeenpwned.com/account/$email',
        description: "Cek kebocoran data breach.",
      ));

      targets.add(OsintTarget(
        title: "Config & Password Exposure",
        url: 'https://www.google.com/search?q=site:pastebin.com OR site:github.com "$email" AND (password OR pass OR key OR token)',
        description: "Mencari kredensial bocor.",
      ));
    }

    return targets;
  }
}