import 'package:flutter_tts/flutter_tts.dart';

/// TTS (Text-to-Speech) servis sınıfı
/// flutter_tts paketini kullanarak metin okuma işlemlerini yönetir
class TtsService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  /// TTS motorunu başlatır ve temel ayarları yapar
  Future<void> initialize() async {
    _flutterTts = FlutterTts();

    // Temel ayarları yapılandır
    await _flutterTts.setLanguage('tr-TR'); // Türkçe dil desteği
    await _flutterTts.setSpeechRate(0.5); // Konuşma hızı (0.0 - 1.0)
    await _flutterTts.setVolume(1.0); // Ses seviyesi (0.0 - 1.0)
    await _flutterTts.setPitch(1.0); // Ses tonu (0.5 - 2.0)

    _isInitialized = true;
  }

  /// Verilen metni sesli olarak okur
  /// 
  /// [text] parametresi okunacak metni içerir
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      throw Exception('TtsService başlatılmamış. Önce initialize() metodunu çağırın.');
    }

    if (text.isEmpty) {
      return;
    }

    await _flutterTts.speak(text);
  }

  /// Devam eden okuma işlemini durdurur
  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }

  /// TTS kaynaklarını temizler
  void dispose() {
    if (_isInitialized) {
      _flutterTts.stop();
      _isInitialized = false;
    }
  }
}
