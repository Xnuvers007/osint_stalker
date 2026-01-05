/// QRIS Static to Dynamic Converter
/// Original PHP Code by: GidhanB.A
/// Converted to Dart by: Xnuvers007

class QrisConverter {
  /// Default QRIS static code
  static const String defaultQris = 
    "00020101021126610014COM.GO-JEK.WWW01189360091433654410040210G3654410040303UMI"
    "51440014ID.CO.QRIS.WWW0215ID10253776897120303UMI5204504553033605802ID5919Sora Store, PD AREN6007TANGSEL61051522362070703A016304F029";

  /// Convert static QRIS to dynamic QRIS with nominal
  static String convert({
    String? qrisCode,
    required int nominal,
    double? serviceFeePercent,
    int? serviceFeeRupiah,
  }) {
    String qris = qrisCode ?? defaultQris;
    
    // Remove last 4 characters (CRC)
    qris = qris.substring(0, qris.length - 4);
    
    // Change from static (010211) to dynamic (010212)
    String step1 = qris.replaceAll("010211", "010212");
    
    // Split by "5802ID"
    List<String> step2 = step1.split("5802ID");
    
    if (step2.length < 2) {
      throw Exception("Invalid QRIS format");
    }
    
    // Build nominal string
    String nominalStr = nominal.toString();
    String uang = "54${nominalStr.length.toString().padLeft(2, '0')}$nominalStr";
    
    // Add service fee if provided
    String tax = "";
    if (serviceFeeRupiah != null && serviceFeeRupiah > 0) {
      String feeStr = serviceFeeRupiah.toString();
      tax = "55020256${feeStr.length.toString().padLeft(2, '0')}$feeStr";
    } else if (serviceFeePercent != null && serviceFeePercent > 0) {
      String feeStr = serviceFeePercent.toString();
      tax = "55020357${feeStr.length.toString().padLeft(2, '0')}$feeStr";
    }
    
    if (tax.isEmpty) {
      uang += "5802ID";
    } else {
      uang += "${tax}5802ID";
    }
    
    // Combine
    String fix = "${step2[0].trim()}$uang${step2[1].trim()}";
    
    // Add CRC
    fix += _calculateCRC16(fix);
    
    return fix;
  }

  /// Calculate CRC16 checksum
  static String _calculateCRC16(String str) {
    int crc = 0xFFFF;
    
    for (int c = 0; c < str.length; c++) {
      crc ^= str.codeUnitAt(c) << 8;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ 0x1021;
        } else {
          crc = crc << 1;
        }
      }
    }
    
    int hex = crc & 0xFFFF;
    String hexStr = hex.toRadixString(16).toUpperCase();
    
    // Pad to 4 characters
    while (hexStr.length < 4) {
      hexStr = "0$hexStr";
    }
    
    return hexStr;
  }

  /// Validate QRIS format
  static bool isValidQris(String qris) {
    // Basic validation
    if (qris.length < 50) return false;
    if (!qris.startsWith("000201")) return false;
    return true;
  }

  /// Parse QRIS to get merchant info
  static Map<String, String> parseQris(String qris) {
    Map<String, String> info = {};
    
    try {
      // Extract merchant name (tag 59)
      RegExp merchantNameRegex = RegExp(r'59(\d{2})(.+?)(?=60|61|62|63|$)');
      Match? merchantMatch = merchantNameRegex.firstMatch(qris);
      if (merchantMatch != null) {
        int length = int.parse(merchantMatch.group(1)!);
        String fullMatch = merchantMatch.group(2)!;
        info['merchantName'] = fullMatch.substring(0, length);
      }
      
      // Extract city (tag 60)
      RegExp cityRegex = RegExp(r'60(\d{2})(.+?)(?=61|62|63|$)');
      Match? cityMatch = cityRegex.firstMatch(qris);
      if (cityMatch != null) {
        int length = int.parse(cityMatch.group(1)!);
        String fullMatch = cityMatch.group(2)!;
        info['city'] = fullMatch.substring(0, length);
      }
      
      // Extract postal code (tag 61)
      RegExp postalRegex = RegExp(r'61(\d{2})(\d+)');
      Match? postalMatch = postalRegex.firstMatch(qris);
      if (postalMatch != null) {
        int length = int.parse(postalMatch.group(1)!);
        String fullMatch = postalMatch.group(2)!;
        info['postalCode'] = fullMatch.substring(0, length);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    
    return info;
  }
}
