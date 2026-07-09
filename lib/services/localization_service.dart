import 'package:flutter/material.dart';

class LocalizationService {
  LocalizationService._();
  static final LocalizationService instance = LocalizationService._();

  final ValueNotifier<String> currentLocale = ValueNotifier<String>('en');

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'dashboard': 'Dashboard',
      'report_crime': 'Report Crime',
      'threat_scanner': 'Threat Scanner',
      'cyber_news': 'Cyber News',
      'rewards': 'Rewards',
      'contact_us': 'Contact Us',
      'sessions': '1:1 Session',
      'scan_system': 'Scan System',
      'welcome': 'Welcome Back',
      'hacked_btn': 'I AM HACKED',
      'hacked_title': 'EMERGENCY: Account Breach Detected',
      'hacked_desc': 'Initiating bank freeze, securing personal data, and notifying authorities...',
      'freeze_bank': 'Freeze My Bank',
      'connect_bank': 'Connect Bank',
      'total_reports': 'Total Reports',
      'threats_blocked': 'Threats Blocked',
      'hero_title': 'The digital war begins where fraud targets ordinary people.',
    },
    'hi': {
      'dashboard': 'डैशबोर्ड',
      'report_crime': 'अपराध रिपोर्ट करें',
      'threat_scanner': 'खतरा स्कैनर',
      'cyber_news': 'साइबर समाचार',
      'rewards': 'पुरस्कार',
      'contact_us': 'संपर्क करें',
      'sessions': '1:1 सत्र',
      'scan_system': 'सिस्टम स्कैन करें',
      'welcome': 'वापसी पर स्वागत है',
      'hacked_btn': 'मैं हैक हो गया हूँ',
      'hacked_title': 'आपातकाल: खाता उल्लंघन का पता चला',
      'hacked_desc': 'बैंक फ्रीज शुरू करना, व्यक्तिगत डेटा सुरक्षित करना और अधिकारियों को सूचित करना...',
      'freeze_bank': 'मेरा बैंक फ्रीज करें',
      'connect_bank': 'बैंक कनेक्ट करें',
      'total_reports': 'कुल रिपोर्ट',
      'threats_blocked': 'खतरे रोके गए',
      'hero_title': 'डिजिटल युद्ध वहां शुरू होता है जहां धोखाधड़ी आम लोगों को निशाना बनाती है।',
    },
    'mr': {
      'dashboard': 'डॅशबोर्ड',
      'report_crime': 'गुन्हा नोंदवा',
      'threat_scanner': 'धोका स्कॅनर',
      'cyber_news': 'सायबर बातम्या',
      'rewards': 'बक्षीस',
      'contact_us': 'संपर्क साधा',
      'sessions': '1:1 सत्र',
      'scan_system': 'सिस्टम स्कॅन करा',
      'welcome': 'तुमचे स्वागत आहे',
      'hacked_btn': 'मी हॅक झालो आहे',
      'hacked_title': 'आणीबाणी: खाते उल्लंघन आढळले',
      'hacked_desc': 'बँक गोठवणे सुरू करणे, वैयक्तिक डेटा सुरक्षित करणे आणि अधिकाऱ्यांना सूचित करणे...',
      'freeze_bank': 'माझी बँक गोठवा',
      'connect_bank': 'बँक कनेक्ट करा',
      'total_reports': 'एकूण अहवाल',
      'threats_blocked': 'धोके रोखले',
      'hero_title': 'जेव्हा सामान्य लोकांना फसवणुकीचे लक्ष्य केले जाते तेव्हा डिजिटल युद्ध सुरू होते.',
    },
  };

  String translate(String key) {
    return _localizedValues[currentLocale.value]?[key] ?? key;
  }

  void setLocale(String locale) {
    currentLocale.value = locale;
  }
}
