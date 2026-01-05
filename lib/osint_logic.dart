/// OSINT Logic - Advanced Dorking & Multi-Engine Search
/// Supports: Google, Bing, DuckDuckGo, Brave, Ecosia, Twitter/X, Yahoo, Yandex

enum OsintType { phone, email, username, domain, ip, name }

enum SearchEngine { 
  google, 
  bing, 
  duckduckgo, 
  brave, 
  ecosia, 
  twitter, 
  yahoo, 
  yandex,
  startpage,
  searx,
  qwant,
  wikipedia,
  swisscows,
  ask,
  baidu,
  dogpile,
  aol,
  mojeek
}

enum DorkOperator {
  site,
  intitle,
  intext,
  inurl,
  filetype,
  ext,
  cache,
  related,
  link,
  define,
  info,
  allintitle,
  allintext,
  allinurl,
  before,
  after,
}

class SearchEngineInfo {
  final String name;
  final String icon;
  final String baseUrl;
  final String color;

  const SearchEngineInfo({
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.color,
  });
}

class OsintTarget {
  final String title;
  final String url;
  final String description;
  final String category;
  final SearchEngine engine;
  final String icon;

  OsintTarget({
    required this.title,
    required this.url,
    required this.description,
    this.category = 'General',
    this.engine = SearchEngine.google,
    this.icon = '🔍',
  });
}

class DorkTemplate {
  final String name;
  final String template;
  final String description;
  final List<DorkOperator> operators;

  const DorkTemplate({
    required this.name,
    required this.template,
    required this.description,
    required this.operators,
  });
}

class OsintLogic {
  // Search Engine Configurations
  static const Map<SearchEngine, SearchEngineInfo> engines = {
    SearchEngine.google: SearchEngineInfo(
      name: 'Google',
      icon: '🔵',
      baseUrl: 'https://www.google.com/search?q=',
      color: '#4285F4',
    ),
    SearchEngine.bing: SearchEngineInfo(
      name: 'Bing',
      icon: '🟢',
      baseUrl: 'https://www.bing.com/search?q=',
      color: '#00809D',
    ),
    SearchEngine.duckduckgo: SearchEngineInfo(
      name: 'DuckDuckGo',
      icon: '🦆',
      baseUrl: 'https://duckduckgo.com/?q=',
      color: '#DE5833',
    ),
    SearchEngine.brave: SearchEngineInfo(
      name: 'Brave',
      icon: '🦁',
      baseUrl: 'https://search.brave.com/search?q=',
      color: '#FB542B',
    ),
    SearchEngine.ecosia: SearchEngineInfo(
      name: 'Ecosia',
      icon: '🌳',
      baseUrl: 'https://www.ecosia.org/search?q=',
      color: '#36B75C',
    ),
    SearchEngine.twitter: SearchEngineInfo(
      name: 'Twitter/X',
      icon: '🐦',
      baseUrl: 'https://twitter.com/search?q=',
      color: '#1DA1F2',
    ),
    SearchEngine.yahoo: SearchEngineInfo(
      name: 'Yahoo',
      icon: '🟣',
      baseUrl: 'https://search.yahoo.com/search?p=',
      color: '#6001D2',
    ),
    SearchEngine.yandex: SearchEngineInfo(
      name: 'Yandex',
      icon: '🔴',
      baseUrl: 'https://yandex.com/search/?text=',
      color: '#FF0000',
    ),
    SearchEngine.startpage: SearchEngineInfo(
      name: 'Startpage',
      icon: '🔒',
      baseUrl: 'https://www.startpage.com/sp/search?query=',
      color: '#6573FF',
    ),
    SearchEngine.searx: SearchEngineInfo(
      name: 'SearX',
      icon: '🔎',
      baseUrl: 'https://searx.be/search?q=',
      color: '#3498DB',
    ),
    SearchEngine.qwant: SearchEngineInfo(
      name: 'Qwant',
      icon: '🔷',
      baseUrl: 'https://www.qwant.com/?q=',
      color: '#5C97FF',
    ),
    SearchEngine.wikipedia: SearchEngineInfo(
      name: 'Wikipedia',
      icon: '📚',
      baseUrl: 'https://en.wikipedia.org/wiki/Special:Search?search=',
      color: '#000000',
    ),
    SearchEngine.swisscows: SearchEngineInfo(
      name: 'Swisscows',
      icon: '🐄',
      baseUrl: 'https://swisscows.com/web?query=',
      color: '#FF0000',
    ),
    SearchEngine.ask: SearchEngineInfo(
      name: 'Ask',
      icon: '❓',
      baseUrl: 'https://www.ask.com/web?q=',
      color: '#D6001C',
    ),
    SearchEngine.baidu: SearchEngineInfo(
      name: 'Baidu',
      icon: '🔴',
      baseUrl: 'https://www.baidu.com/s?wd=',
      color: '#2319DC',
    ),
    SearchEngine.dogpile: SearchEngineInfo(
      name: 'Dogpile',
      icon: '🐕',
      baseUrl: 'https://www.dogpile.com/serp?q=',
      color: '#63B600',
    ),
    SearchEngine.aol: SearchEngineInfo(
      name: 'AOL',
      icon: '💠',
      baseUrl: 'https://search.aol.com/aol/search?q=',
      color: '#FF0B00',
    ),
    SearchEngine.mojeek: SearchEngineInfo(
      name: 'Mojeek',
      icon: '🌍',
      baseUrl: 'https://www.mojeek.com/search?q=',
      color: '#008060',
    ),
  };

  // Common Dork Templates
  static const List<DorkTemplate> dorkTemplates = [
    DorkTemplate(
      name: 'Social Media',
      template: 'site:facebook.com | site:instagram.com | site:twitter.com | site:linkedin.com | site:tiktok.com',
      description: 'Search across major social platforms',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Document Leaks',
      template: 'filetype:pdf | filetype:doc | filetype:docx | filetype:xls | filetype:xlsx',
      description: 'Find exposed documents',
      operators: [DorkOperator.filetype],
    ),
    DorkTemplate(
      name: 'Paste Sites',
      template: 'site:pastebin.com | site:ghostbin.com | site:paste.ee | site:justpaste.it | site:hastebin.com | site:dpaste.org | site:ideone.com | site:codepad.org | site:paste2.org | site:slexy.org | site:snipplr.com',
      description: 'Search paste/dump sites',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Scribd & Documents',
      template: 'site:scribd.com | site:id.scribd.com | site:issuu.com | site:slideshare.net | site:academia.edu | site:researchgate.net | site:docdroid.net | site:calameo.com',
      description: 'Search document sharing platforms',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Leak Database Sites',
      template: 'site:raidforums.com | site:breached.to | site:leakbase.io | site:dehashed.com | site:snusbase.com | site:leakcheck.io | site:intelligence-x.com | site:pwndb2am4tzkvold.onion',
      description: 'Search known leak/breach databases',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Archive & Cache',
      template: 'site:archive.org | site:archive.is | site:webcache.googleusercontent.com | site:cached.com | site:cachedview.com | site:web.archive.org',
      description: 'Search archived/cached content',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Cloud Storage Leaks',
      template: 'site:drive.google.com | site:docs.google.com | site:dropbox.com | site:onedrive.live.com | site:1drv.ms | site:mega.nz | site:mediafire.com | site:zippyshare.com',
      description: 'Search exposed cloud storage files',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Indonesian Leaks',
      template: 'site:kaskus.co.id | site:brainly.co.id | site:kompasiana.com | site:id.quora.com | site:detik.com | site:tribunnews.com',
      description: 'Search Indonesian forums & sites for leaks',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Code Repos',
      template: 'site:github.com | site:gitlab.com | site:bitbucket.org',
      description: 'Search code repositories',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Forums',
      template: 'site:reddit.com | site:quora.com | site:stackoverflow.com | inurl:forum',
      description: 'Search forums and Q&A sites',
      operators: [DorkOperator.site, DorkOperator.inurl],
    ),
    DorkTemplate(
      name: 'E-commerce',
      template: 'site:tokopedia.com | site:shopee.co.id | site:bukalapak.com | site:lazada.co.id',
      description: 'Search Indonesian marketplaces',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Job Sites',
      template: 'site:linkedin.com/in | site:jobstreet.co.id | site:indeed.com | site:glints.com',
      description: 'Find professional profiles',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Dating Sites',
      template: 'site:tinder.com | site:bumble.com | site:okcupid.com | site:badoo.com',
      description: 'Search dating platforms',
      operators: [DorkOperator.site],
    ),
    DorkTemplate(
      name: 'Credentials',
      template: '(password | passwd | pwd | credentials | login) filetype:txt | filetype:log',
      description: 'Find exposed credentials',
      operators: [DorkOperator.filetype, DorkOperator.intext],
    ),
    DorkTemplate(
      name: 'Config Files',
      template: 'filetype:env | filetype:cfg | filetype:conf | filetype:ini | filetype:yml',
      description: 'Find configuration files',
      operators: [DorkOperator.filetype],
    ),
  ];

  /// Sanitize phone number to international format
  static String sanitizePhone(String input) {
    String clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) {
      clean = '62${clean.substring(1)}';
    }
    return clean;
  }

  /// Generate phone number permutations for better search
  static String _generatePhonePermutations(String cleanPhone) {
    if (cleanPhone.length < 10) return '"$cleanPhone"';

    String local = '0${cleanPhone.substring(2)}';
    
    String p1 = local.substring(0, 4);
    String p2 = local.length > 7 ? local.substring(4, 8) : local.substring(4);
    String p3 = local.length > 8 ? local.substring(8) : '';
    
    List<String> formats = [
      '"$cleanPhone"',
      '"+$cleanPhone"',
      '"$local"',
      '"$p1-$p2-$p3"',
      '"$p1 $p2 $p3"',
    ];

    if (cleanPhone.length >= 12) {
      formats.addAll([
        '"+62 ${cleanPhone.substring(2, 5)}-${cleanPhone.substring(5, 9)}-${cleanPhone.substring(9)}"',
        '"+62 ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5, 9)} ${cleanPhone.substring(9)}"',
      ]);
    }

    return formats.join(' | ');
  }

  /// Build search URL for specific engine
  static String buildSearchUrl(SearchEngine engine, String query) {
    final engineInfo = engines[engine]!;
    return '${engineInfo.baseUrl}${Uri.encodeComponent(query)}';
  }

  /// Generate comprehensive dorks for phone number
  static List<OsintTarget> generatePhoneDorks(String input, {
    String? customDomain,
    List<SearchEngine> selectedEngines = const [SearchEngine.google],
    bool useAdvancedDorks = true,
  }) {
    List<OsintTarget> targets = [];
    String phone = sanitizePhone(input);
    String permutations = _generatePhonePermutations(phone);
    String local = '0${phone.substring(2)}';

    // Custom domain search
    if (customDomain != null && customDomain.isNotEmpty) {
      String cleanDomain = customDomain.replaceAll('site:', '').trim();
      for (var engine in selectedEngines) {
        targets.add(OsintTarget(
          title: "🎯 Custom: $cleanDomain (${engines[engine]!.name})",
          url: buildSearchUrl(engine, 'site:$cleanDomain ($permutations)'),
          description: "Mencari semua variasi nomor di $cleanDomain",
          category: 'Custom',
          engine: engine,
          icon: engines[engine]!.icon,
        ));
      }
    }

    // Multi-engine broad search
    for (var engine in selectedEngines) {
      targets.add(OsintTarget(
        title: "🔍 Deep Search (${engines[engine]!.name})",
        url: buildSearchUrl(engine, permutations),
        description: "Pencarian mendalam semua format nomor",
        category: 'General',
        engine: engine,
        icon: engines[engine]!.icon,
      ));
    }

    // Social Media specific
    targets.add(OsintTarget(
      title: "📱 Social Media Lookup",
      url: buildSearchUrl(SearchEngine.google, 
        'site:facebook.com | site:instagram.com | site:twitter.com | site:linkedin.com | site:tiktok.com ($permutations)'),
      description: "Scan FB, IG, Twitter, LinkedIn, TikTok",
      category: 'Social Media',
      icon: '📱',
    ));

    // Twitter/X specific
    targets.add(OsintTarget(
      title: "🐦 Twitter/X Search",
      url: buildSearchUrl(SearchEngine.twitter, '$phone OR $local'),
      description: "Cari langsung di Twitter/X",
      category: 'Social Media',
      engine: SearchEngine.twitter,
      icon: '🐦',
    ));

    // Advanced dorks
    if (useAdvancedDorks) {
      // intitle dork
      targets.add(OsintTarget(
        title: "📄 intitle: Dork",
        url: buildSearchUrl(SearchEngine.google, 'intitle:"$local" | intitle:"$phone"'),
        description: "Cari nomor yang ada di judul halaman",
        category: 'Advanced Dork',
        icon: '📄',
      ));

      // intext dork
      targets.add(OsintTarget(
        title: "📝 intext: Dork",
        url: buildSearchUrl(SearchEngine.google, 'intext:"$local" | intext:"$phone"'),
        description: "Cari nomor yang ada di dalam teks halaman",
        category: 'Advanced Dork',
        icon: '📝',
      ));

      // inurl dork
      targets.add(OsintTarget(
        title: "🔗 inurl: Dork",
        url: buildSearchUrl(SearchEngine.google, 'inurl:$local | inurl:$phone'),
        description: "Cari nomor yang ada di URL",
        category: 'Advanced Dork',
        icon: '🔗',
      ));

      // File leaks
      targets.add(OsintTarget(
        title: "📁 Document Leaks",
        url: buildSearchUrl(SearchEngine.google, 
          'filetype:xls | filetype:xlsx | filetype:csv | filetype:pdf | filetype:txt ($permutations)'),
        description: "Cari di file Excel, PDF, CSV, TXT",
        category: 'Document',
        icon: '📁',
      ));

      // Paste sites
      targets.add(OsintTarget(
        title: "📋 Paste Sites",
        url: buildSearchUrl(SearchEngine.google, 
          'site:pastebin.com | site:paste.ee | site:justpaste.it | site:ghostbin.com | site:hastebin.com | site:dpaste.org ($permutations)'),
        description: "Cari di situs paste/dump",
        category: 'Leak',
        icon: '📋',
      ));

      // Scribd & Document Sharing
      targets.add(OsintTarget(
        title: "📚 Scribd & Docs",
        url: buildSearchUrl(SearchEngine.google, 
          'site:scribd.com | site:id.scribd.com | site:issuu.com | site:slideshare.net | site:academia.edu | site:researchgate.net ($permutations)'),
        description: "Cari di platform dokumen (Scribd, Issuu, dll)",
        category: 'Leak',
        icon: '📚',
      ));

      // Archive & Cache
      targets.add(OsintTarget(
        title: "📜 Archive & Cache",
        url: buildSearchUrl(SearchEngine.google, 
          'site:archive.org | site:archive.is | site:web.archive.org | site:cachedview.com ($permutations)'),
        description: "Cari di arsip dan cache web",
        category: 'Archive',
        icon: '📜',
      ));

      // Cloud Storage Leaks
      targets.add(OsintTarget(
        title: "☁️ Cloud Storage",
        url: buildSearchUrl(SearchEngine.google, 
          'site:drive.google.com | site:docs.google.com | site:dropbox.com | site:onedrive.live.com | site:mega.nz ($permutations)'),
        description: "Cari di cloud storage publik",
        category: 'Leak',
        icon: '☁️',
      ));

      // Indonesian Forums
      targets.add(OsintTarget(
        title: "🇮🇩 Forum Indonesia",
        url: buildSearchUrl(SearchEngine.google, 
          'site:kaskus.co.id | site:brainly.co.id | site:kompasiana.com | site:detik.com ($permutations)'),
        description: "Cari di forum dan situs Indonesia",
        category: 'Forum ID',
        icon: '🇮🇩',
      ));

      // E-commerce Indonesia
      targets.add(OsintTarget(
        title: "🛒 E-Commerce ID",
        url: buildSearchUrl(SearchEngine.google, 
          'site:tokopedia.com | site:shopee.co.id | site:bukalapak.com | site:lazada.co.id ($permutations)'),
        description: "Cari toko/profil di marketplace Indonesia",
        category: 'E-Commerce',
        icon: '🛒',
      ));

      // Job sites
      targets.add(OsintTarget(
        title: "💼 Job & Professional",
        url: buildSearchUrl(SearchEngine.google, 
          'site:linkedin.com | site:jobstreet.co.id | site:glints.com | site:indeed.com ($permutations)'),
        description: "Cari profil profesional/pekerjaan",
        category: 'Professional',
        icon: '💼',
      ));
    }

    // WhatsApp check
    targets.add(OsintTarget(
      title: "💬 WhatsApp Check",
      url: 'https://wa.me/$phone',
      description: "Cek status WhatsApp aktif/tidak",
      category: 'Direct',
      icon: '💬',
    ));

    // Truecaller
    targets.add(OsintTarget(
      title: "📞 Truecaller",
      url: 'https://www.truecaller.com/search/id/$phone',
      description: "Cek nama di database Truecaller",
      category: 'Direct',
      icon: '📞',
    ));

    // GetContact
    targets.add(OsintTarget(
      title: "📇 GetContact",
      url: 'https://www.getcontact.com/id/number/+$phone',
      description: "Cek nama di database GetContact",
      category: 'Direct',
      icon: '📇',
    ));

    // Sync.me
    targets.add(OsintTarget(
      title: "🔄 Sync.Me",
      url: 'https://sync.me/search/?number=%2B$phone',
      description: "Cek di database Sync.Me",
      category: 'Direct',
      icon: '🔄',
    ));

    return targets;
  }

  /// Generate comprehensive dorks for email
  static List<OsintTarget> generateEmailDorks(String input, {
    String? customDomain,
    List<SearchEngine> selectedEngines = const [SearchEngine.google],
    bool useAdvancedDorks = true,
  }) {
    List<OsintTarget> targets = [];
    String email = input.trim();
    String username = email.split('@').first;

    // Custom domain search
    if (customDomain != null && customDomain.isNotEmpty) {
      String cleanDomain = customDomain.replaceAll('site:', '').trim();
      for (var engine in selectedEngines) {
        targets.add(OsintTarget(
          title: "🎯 Custom: $cleanDomain (${engines[engine]!.name})",
          url: buildSearchUrl(engine, 'site:$cleanDomain "$email"'),
          description: "Mencari email di $cleanDomain",
          category: 'Custom',
          engine: engine,
          icon: engines[engine]!.icon,
        ));
      }
    }

    // Multi-engine search
    for (var engine in selectedEngines) {
      targets.add(OsintTarget(
        title: "🔍 Deep Search (${engines[engine]!.name})",
        url: buildSearchUrl(engine, '"$email"'),
        description: "Pencarian email lengkap",
        category: 'General',
        engine: engine,
        icon: engines[engine]!.icon,
      ));
    }

    // Have I Been Pwned
    targets.add(OsintTarget(
      title: "⚠️ Have I Been Pwned",
      url: 'https://haveibeenpwned.com/account/$email',
      description: "Cek kebocoran data breach",
      category: 'Breach',
      icon: '⚠️',
    ));

    // Hunter.io
    targets.add(OsintTarget(
      title: "🎯 Hunter.io",
      url: 'https://hunter.io/email-verifier/$email',
      description: "Verifikasi email dan temukan informasi",
      category: 'Verification',
      icon: '🎯',
    ));

    // Social Media
    targets.add(OsintTarget(
      title: "📱 Social Media",
      url: buildSearchUrl(SearchEngine.google, 
        'site:facebook.com | site:instagram.com | site:twitter.com | site:linkedin.com "$email"'),
      description: "Cari di social media",
      category: 'Social Media',
      icon: '📱',
    ));

    // Username search
    targets.add(OsintTarget(
      title: "👤 Username Search",
      url: buildSearchUrl(SearchEngine.google, '"$username"'),
      description: "Cari berdasarkan username: $username",
      category: 'Username',
      icon: '👤',
    ));

    if (useAdvancedDorks) {
      // intitle
      targets.add(OsintTarget(
        title: "📄 intitle: Dork",
        url: buildSearchUrl(SearchEngine.google, 'intitle:"$email"'),
        description: "Cari email di judul halaman",
        category: 'Advanced Dork',
        icon: '📄',
      ));

      // intext
      targets.add(OsintTarget(
        title: "📝 intext: Dork",
        url: buildSearchUrl(SearchEngine.google, 'intext:"$email"'),
        description: "Cari email di dalam teks halaman",
        category: 'Advanced Dork',
        icon: '📝',
      ));

      // Credential exposure
      targets.add(OsintTarget(
        title: "🔐 Credential Exposure",
        url: buildSearchUrl(SearchEngine.google, 
          'site:pastebin.com | site:github.com "$email" AND (password | pass | pwd | key | token | secret)'),
        description: "Cari kredensial yang bocor",
        category: 'Leak',
        icon: '🔐',
      ));

      // Scribd & Document Sharing
      targets.add(OsintTarget(
        title: "📚 Scribd & Docs",
        url: buildSearchUrl(SearchEngine.google, 
          'site:scribd.com | site:id.scribd.com | site:issuu.com | site:slideshare.net | site:academia.edu | site:docdroid.net "$email"'),
        description: "Cari di platform dokumen (Scribd, Issuu, dll)",
        category: 'Leak',
        icon: '📚',
      ));

      // Paste Sites Extended
      targets.add(OsintTarget(
        title: "📋 Paste Sites",
        url: buildSearchUrl(SearchEngine.google, 
          'site:pastebin.com | site:paste.ee | site:justpaste.it | site:ghostbin.com | site:hastebin.com | site:dpaste.org "$email"'),
        description: "Cari di situs paste/dump",
        category: 'Leak',
        icon: '📋',
      ));

      // Cloud Storage Leaks
      targets.add(OsintTarget(
        title: "☁️ Cloud Storage",
        url: buildSearchUrl(SearchEngine.google, 
          'site:drive.google.com | site:docs.google.com | site:dropbox.com | site:onedrive.live.com "$email"'),
        description: "Cari di cloud storage publik",
        category: 'Leak',
        icon: '☁️',
      ));

      // Archive Sites
      targets.add(OsintTarget(
        title: "📜 Archive Sites",
        url: buildSearchUrl(SearchEngine.google, 
          'site:archive.org | site:archive.is | site:web.archive.org "$email"'),
        description: "Cari di arsip web",
        category: 'Archive',
        icon: '📜',
      ));

      // Document leaks
      targets.add(OsintTarget(
        title: "📁 Document Search",
        url: buildSearchUrl(SearchEngine.google, 
          'filetype:pdf | filetype:doc | filetype:xls | filetype:csv "$email"'),
        description: "Cari di dokumen publik",
        category: 'Document',
        icon: '📁',
      ));

      // Code repositories
      targets.add(OsintTarget(
        title: "💻 Code Repos",
        url: buildSearchUrl(SearchEngine.google, 
          'site:github.com | site:gitlab.com | site:bitbucket.org "$email"'),
        description: "Cari di repository kode",
        category: 'Development',
        icon: '💻',
      ));

      // Forums
      targets.add(OsintTarget(
        title: "💬 Forums Search",
        url: buildSearchUrl(SearchEngine.google, 
          'site:reddit.com | site:quora.com | inurl:forum "$email"'),
        description: "Cari di forum dan Q&A",
        category: 'Forum',
        icon: '💬',
      ));
    }

    // Gravatar
    targets.add(OsintTarget(
      title: "🖼️ Gravatar",
      url: 'https://en.gravatar.com/$email',
      description: "Cek profil Gravatar",
      category: 'Profile',
      icon: '🖼️',
    ));

    // EmailRep
    targets.add(OsintTarget(
      title: "📊 EmailRep",
      url: 'https://emailrep.io/$email',
      description: "Cek reputasi email",
      category: 'Reputation',
      icon: '📊',
    ));

    return targets;
  }

  /// Generate dorks for username
  static List<OsintTarget> generateUsernameDorks(String input, {
    List<SearchEngine> selectedEngines = const [SearchEngine.google],
  }) {
    List<OsintTarget> targets = [];
    String username = input.trim();

    // NameChk
    targets.add(OsintTarget(
      title: "🔍 NameChk",
      url: 'https://namechk.com/',
      description: "Cek ketersediaan username di berbagai platform",
      category: 'Username Check',
      icon: '🔍',
    ));

    // Namecheckr
    targets.add(OsintTarget(
      title: "✅ Namecheckr",
      url: 'https://www.namecheckr.com/',
      description: "Alternatif cek username",
      category: 'Username Check',
      icon: '✅',
    ));

    // Social media direct links
    final socialPlatforms = {
      'Twitter/X': 'https://twitter.com/$username',
      'Instagram': 'https://instagram.com/$username',
      'Facebook': 'https://facebook.com/$username',
      'GitHub': 'https://github.com/$username',
      'LinkedIn': 'https://linkedin.com/in/$username',
      'TikTok': 'https://tiktok.com/@$username',
      'Reddit': 'https://reddit.com/user/$username',
      'YouTube': 'https://youtube.com/@$username',
      'Telegram': 'https://t.me/$username',
      'Pinterest': 'https://pinterest.com/$username',
      'Medium': 'https://medium.com/@$username',
      'Twitch': 'https://twitch.tv/$username',
      'SoundCloud': 'https://soundcloud.com/$username',
      'Spotify': 'https://open.spotify.com/user/$username',
    };

    for (var entry in socialPlatforms.entries) {
      targets.add(OsintTarget(
        title: "🔗 ${entry.key}",
        url: entry.value,
        description: "Cek profil $username di ${entry.key}",
        category: 'Social Media',
        icon: '🔗',
      ));
    }

    // Multi-engine search
    for (var engine in selectedEngines) {
      targets.add(OsintTarget(
        title: "🔍 Search (${engines[engine]!.name})",
        url: buildSearchUrl(engine, '"$username"'),
        description: "Pencarian username",
        category: 'General',
        engine: engine,
        icon: engines[engine]!.icon,
      ));
    }

    return targets;
  }

  /// Generate dorks for domain/website
  static List<OsintTarget> generateDomainDorks(String input, {
    List<SearchEngine> selectedEngines = const [SearchEngine.google],
  }) {
    List<OsintTarget> targets = [];
    String domain = input.trim().replaceAll(RegExp(r'^https?://'), '').replaceAll(RegExp(r'/$'), '');

    // Subdomains
    targets.add(OsintTarget(
      title: "🌐 Subdomain Finder",
      url: buildSearchUrl(SearchEngine.google, 'site:*.$domain'),
      description: "Cari subdomain",
      category: 'Reconnaissance',
      icon: '🌐',
    ));

    // Directory listing
    targets.add(OsintTarget(
      title: "📂 Directory Listing",
      url: buildSearchUrl(SearchEngine.google, 'site:$domain intitle:"index of"'),
      description: "Cari direktori terbuka",
      category: 'Vulnerability',
      icon: '📂',
    ));

    // Exposed files
    targets.add(OsintTarget(
      title: "📄 Exposed Files",
      url: buildSearchUrl(SearchEngine.google, 
        'site:$domain filetype:pdf | filetype:doc | filetype:xls | filetype:sql | filetype:log'),
      description: "Cari file yang terekspos",
      category: 'Document',
      icon: '📄',
    ));

    // Config files
    targets.add(OsintTarget(
      title: "⚙️ Config Files",
      url: buildSearchUrl(SearchEngine.google, 
        'site:$domain filetype:env | filetype:cfg | filetype:conf | filetype:ini | filetype:yml | filetype:xml'),
      description: "Cari file konfigurasi",
      category: 'Vulnerability',
      icon: '⚙️',
    ));

    // Login pages
    targets.add(OsintTarget(
      title: "🔐 Login Pages",
      url: buildSearchUrl(SearchEngine.google, 
        'site:$domain inurl:login | inurl:admin | inurl:signin | inurl:auth'),
      description: "Cari halaman login/admin",
      category: 'Authentication',
      icon: '🔐',
    ));

    // Error pages
    targets.add(OsintTarget(
      title: "❌ Error Messages",
      url: buildSearchUrl(SearchEngine.google, 
        'site:$domain intext:"error" | intext:"warning" | intext:"exception"'),
      description: "Cari pesan error yang informatif",
      category: 'Debug',
      icon: '❌',
    ));

    // SQL errors
    targets.add(OsintTarget(
      title: "💉 SQL Errors",
      url: buildSearchUrl(SearchEngine.google, 
        'site:$domain intext:"sql syntax" | intext:"mysql" | intext:"syntax error"'),
      description: "Cari indikasi SQL vulnerability",
      category: 'Vulnerability',
      icon: '💉',
    ));

    // Backup files
    targets.add(OsintTarget(
      title: "💾 Backup Files",
      url: buildSearchUrl(SearchEngine.google, 
        'site:$domain filetype:bak | filetype:old | filetype:backup | filetype:sql | filetype:zip'),
      description: "Cari file backup",
      category: 'Backup',
      icon: '💾',
    ));

    // External tools
    targets.add(OsintTarget(
      title: "🔬 Shodan",
      url: 'https://www.shodan.io/search?query=hostname:$domain',
      description: "Cek di Shodan",
      category: 'External',
      icon: '🔬',
    ));

    targets.add(OsintTarget(
      title: "📜 Wayback Machine",
      url: 'https://web.archive.org/web/*/$domain',
      description: "Lihat arsip historis",
      category: 'External',
      icon: '📜',
    ));

    targets.add(OsintTarget(
      title: "🔗 VirusTotal",
      url: 'https://www.virustotal.com/gui/domain/$domain',
      description: "Analisis keamanan domain",
      category: 'External',
      icon: '🔗',
    ));

    targets.add(OsintTarget(
      title: "📊 BuiltWith",
      url: 'https://builtwith.com/$domain',
      description: "Lihat teknologi yang digunakan",
      category: 'External',
      icon: '📊',
    ));

    targets.add(OsintTarget(
      title: "🌍 DNSDumpster",
      url: 'https://dnsdumpster.com/',
      description: "DNS reconnaissance",
      category: 'External',
      icon: '🌍',
    ));

    return targets;
  }

  /// Generate dorks for IP address
  static List<OsintTarget> generateIpDorks(String input, {
    List<SearchEngine> selectedEngines = const [SearchEngine.google],
  }) {
    List<OsintTarget> targets = [];
    String ip = input.trim();

    // Basic search
    for (var engine in selectedEngines) {
      targets.add(OsintTarget(
        title: "🔍 IP Search (${engines[engine]!.name})",
        url: buildSearchUrl(engine, '"$ip"'),
        description: "Cari referensi IP",
        category: 'General',
        engine: engine,
        icon: engines[engine]!.icon,
      ));
    }

    // Shodan
    targets.add(OsintTarget(
      title: "🔬 Shodan",
      url: 'https://www.shodan.io/host/$ip',
      description: "Informasi lengkap dari Shodan",
      category: 'External',
      icon: '🔬',
    ));

    // Censys
    targets.add(OsintTarget(
      title: "🔎 Censys",
      url: 'https://search.censys.io/hosts/$ip',
      description: "Analisis dari Censys",
      category: 'External',
      icon: '🔎',
    ));

    // VirusTotal
    targets.add(OsintTarget(
      title: "🦠 VirusTotal",
      url: 'https://www.virustotal.com/gui/ip-address/$ip',
      description: "Analisis keamanan IP",
      category: 'Security',
      icon: '🦠',
    ));

    // AbuseIPDB
    targets.add(OsintTarget(
      title: "⚠️ AbuseIPDB",
      url: 'https://www.abuseipdb.com/check/$ip',
      description: "Cek laporan abuse",
      category: 'Security',
      icon: '⚠️',
    ));

    // IPInfo
    targets.add(OsintTarget(
      title: "📍 IPInfo",
      url: 'https://ipinfo.io/$ip',
      description: "Geolokasi dan info ISP",
      category: 'Geolocation',
      icon: '📍',
    ));

    // GreyNoise
    targets.add(OsintTarget(
      title: "🔊 GreyNoise",
      url: 'https://viz.greynoise.io/ip/$ip',
      description: "Analisis noise internet",
      category: 'Security',
      icon: '🔊',
    ));

    return targets;
  }

  /// Generate dorks for person name
  static List<OsintTarget> generateNameDorks(String input, {
    String? customDomain,
    List<SearchEngine> selectedEngines = const [SearchEngine.google],
  }) {
    List<OsintTarget> targets = [];
    String name = input.trim();

    // Custom domain
    if (customDomain != null && customDomain.isNotEmpty) {
      for (var engine in selectedEngines) {
        targets.add(OsintTarget(
          title: "🎯 Custom: $customDomain (${engines[engine]!.name})",
          url: buildSearchUrl(engine, 'site:$customDomain "$name"'),
          description: "Mencari nama di $customDomain",
          category: 'Custom',
          engine: engine,
          icon: engines[engine]!.icon,
        ));
      }
    }

    // Multi-engine exact match
    for (var engine in selectedEngines) {
      targets.add(OsintTarget(
        title: "🔍 Exact Match (${engines[engine]!.name})",
        url: buildSearchUrl(engine, '"$name"'),
        description: "Pencarian nama tepat",
        category: 'General',
        engine: engine,
        icon: engines[engine]!.icon,
      ));
    }

    // Social media
    targets.add(OsintTarget(
      title: "📱 Social Media",
      url: buildSearchUrl(SearchEngine.google, 
        'site:facebook.com | site:instagram.com | site:twitter.com | site:linkedin.com | site:tiktok.com "$name"'),
      description: "Cari di social media",
      category: 'Social Media',
      icon: '📱',
    ));

    // LinkedIn specific
    targets.add(OsintTarget(
      title: "💼 LinkedIn",
      url: buildSearchUrl(SearchEngine.google, 'site:linkedin.com/in "$name"'),
      description: "Cari profil profesional",
      category: 'Professional',
      icon: '💼',
    ));

    // Images
    targets.add(OsintTarget(
      title: "🖼️ Image Search",
      url: 'https://www.google.com/search?q="$name"&tbm=isch',
      description: "Cari foto/gambar",
      category: 'Images',
      icon: '🖼️',
    ));

    // News
    targets.add(OsintTarget(
      title: "📰 News Search",
      url: 'https://www.google.com/search?q="$name"&tbm=nws',
      description: "Cari di berita",
      category: 'News',
      icon: '📰',
    ));

    // Indonesian context
    targets.add(OsintTarget(
      title: "🇮🇩 Indonesia Context",
      url: buildSearchUrl(SearchEngine.google, 
        '"$name" site:detik.com | site:kompas.com | site:tribunnews.com | site:tempo.co'),
      description: "Cari di media Indonesia",
      category: 'News ID',
      icon: '🇮🇩',
    ));

    // Documents
    targets.add(OsintTarget(
      title: "📄 Documents",
      url: buildSearchUrl(SearchEngine.google, 
        '"$name" filetype:pdf | filetype:doc | filetype:xls'),
      description: "Cari di dokumen publik",
      category: 'Document',
      icon: '📄',
    ));

    return targets;
  }

  /// Main generator with type selection
  static List<OsintTarget> generateDorks(String input, OsintType type, {
    String? customDomain,
    List<SearchEngine> selectedEngines = const [SearchEngine.google],
    bool useAdvancedDorks = true,
  }) {
    switch (type) {
      case OsintType.phone:
        return generatePhoneDorks(input, 
          customDomain: customDomain, 
          selectedEngines: selectedEngines,
          useAdvancedDorks: useAdvancedDorks);
      case OsintType.email:
        return generateEmailDorks(input, 
          customDomain: customDomain, 
          selectedEngines: selectedEngines,
          useAdvancedDorks: useAdvancedDorks);
      case OsintType.username:
        return generateUsernameDorks(input, 
          selectedEngines: selectedEngines);
      case OsintType.domain:
        return generateDomainDorks(input, 
          selectedEngines: selectedEngines);
      case OsintType.ip:
        return generateIpDorks(input, 
          selectedEngines: selectedEngines);
      case OsintType.name:
        return generateNameDorks(input, 
          customDomain: customDomain,
          selectedEngines: selectedEngines);
    }
  }

  /// Get all available dork templates
  static List<DorkTemplate> getDorkTemplates() {
    return dorkTemplates;
  }

  /// Apply a dork template with target
  static String applyDorkTemplate(DorkTemplate template, String target) {
    return '${template.template} "$target"';
  }
}