# Design Document

## Overview

Voice Reader App, Flutter framework kullanarak geliştirilecek basit ve etkili bir text-to-speech uygulamasıdır. Uygulama, sade bir mimari yapı ile tüm platformlarda (web, mobil, desktop) çalışacak şekilde tasarlanmıştır. MVVM gibi karmaşık mimari patternler kullanılmayacak, bunun yerine Flutter'ın StatefulWidget yapısı ile basit bir state yönetimi uygulanacaktır.

## Architecture

### Project Structure

```
voice_reader_app/
├── lib/
│   ├── main.dart                 # Uygulama giriş noktası
│   ├── home_page.dart            # Ana sayfa widget'ı
│   └── tts_service.dart          # Text-to-speech servis sınıfı
├── android/                      # Android platform konfigürasyonu
├── ios/                          # iOS platform konfigürasyonu
├── web/                          # Web platform konfigürasyonu
├── windows/                      # Windows platform konfigürasyonu
├── linux/                        # Linux platform konfigürasyonu
├── macos/                        # MacOS platform konfigürasyonu
└── pubspec.yaml                  # Proje bağımlılıkları
```

### Architecture Pattern

Basit bir yapı kullanılacak:
- **main.dart**: MaterialApp ve tema konfigürasyonu
- **home_page.dart**: UI ve state yönetimi (StatefulWidget)
- **tts_service.dart**: flutter_tts paketini sarmalayan basit bir servis sınıfı

## Components and Interfaces

### 1. Main Application (main.dart)

**Sorumluluklar:**
- Uygulamayı başlatmak
- MaterialApp konfigürasyonu
- Tema ayarları

**Arayüz:**
```dart
void main() {
  runApp(const VoiceReaderApp());
}

class VoiceReaderApp extends StatelessWidget {
  // MaterialApp widget'ı döndürür
}
```

### 2. Home Page (home_page.dart)

**Sorumluluklar:**
- Kullanıcı arayüzünü oluşturmak
- Metin girişini yönetmek
- TTS servisini çağırmak
- Buton durumunu yönetmek

**State Yönetimi:**
- TextEditingController: Metin girişini yönetir
- Loading state: Sesli okuma sırasında buton durumunu kontrol eder

**UI Bileşenleri:**
- AppBar: Başlık
- TextField: Metin girişi (multiline, responsive)
- ElevatedButton: "Sesli Oku" butonu
- Padding ve Center widget'ları: Responsive layout

### 3. TTS Service (tts_service.dart)

**Sorumluluklar:**
- flutter_tts paketini başlatmak
- Metin okuma işlemini gerçekleştirmek
- Platform-specific ayarları yapmak

**Arayüz:**
```dart
class TtsService {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  void dispose();
}
```

## Data Models

Bu basit uygulama için karmaşık data modellere ihtiyaç yoktur. Sadece String tipinde metin verisi kullanılacaktır.

**Veri Akışı:**
1. Kullanıcı TextField'a metin girer
2. TextEditingController metni tutar
3. Buton tıklandığında metin TtsService'e gönderilir
4. TtsService metni sesli olarak okur

## Platform-Specific Configuration

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

flutter_tts paketi Android'de ek izin gerektirmez, ancak internet izni genel kullanım için eklenecektir.

### iOS (ios/Runner/Info.plist)

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Bu uygulama metni sesli okumak için konuşma özelliğini kullanır.</string>
```

### Web

Web platformu için flutter_tts paketi Web Speech API kullanır. Ek konfigürasyon gerekmez.

### Desktop (Windows, Linux, MacOS)

Desktop platformlar için flutter_tts paketi native TTS motorlarını kullanır. Ek konfigürasyon gerekmez.

## UI Design

### Layout Structure

```
┌─────────────────────────────────────┐
│         Voice Reader App            │  <- AppBar
├─────────────────────────────────────┤
│                                     │
│                                     │
│  ┌───────────────────────────────┐ │
│  │                               │ │
│  │   Metin girin...              │ │  <- TextField (multiline)
│  │                               │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│       ┌─────────────────┐          │
│       │   Sesli Oku     │          │  <- ElevatedButton
│       └─────────────────┘          │
│                                     │
└─────────────────────────────────────┘
```

### Responsive Design

- **Mobil**: Padding 16px, TextField yüksekliği 200px
- **Tablet/Desktop**: Maksimum genişlik 600px, merkeze hizalı
- **Web**: Tüm ekran genişliğinde çalışır, maksimum genişlik sınırı ile

## Error Handling

### Hata Senaryoları

1. **Boş Metin**: Kullanıcı boş metin ile butona tıklarsa
   - Çözüm: Buton tıklanmadan önce kontrol, boşsa işlem yapılmaz

2. **TTS Başlatma Hatası**: flutter_tts başlatılamazsa
   - Çözüm: try-catch bloğu ile hata yakalanır, kullanıcıya SnackBar ile bilgi verilir

3. **Platform Desteği**: Bazı platformlarda TTS çalışmazsa
   - Çözüm: flutter_tts paketi tüm platformları destekler, ancak hata durumunda kullanıcıya bilgi verilir

### Hata Yönetimi Stratejisi

```dart
try {
  await ttsService.speak(text);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Hata: $e')),
  );
}
```

## Testing Strategy

### Manuel Test Senaryoları

1. **Temel Fonksiyonellik**
   - Metin girişi yapılabilir mi?
   - "Sesli Oku" butonu çalışıyor mu?
   - Metin sesli olarak okunuyor mu?

2. **Platform Testleri**
   - Her platformda (web, Android, iOS, Windows, Linux, MacOS) uygulama çalışıyor mu?
   - TTS her platformda düzgün çalışıyor mu?

3. **UI Testleri**
   - Farklı ekran boyutlarında UI düzgün görünüyor mu?
   - Responsive tasarım çalışıyor mu?

4. **Edge Case Testleri**
   - Boş metin ile buton tıklanırsa ne olur?
   - Çok uzun metin girilirse ne olur?
   - Özel karakterler ve emoji'ler okunabiliyor mu?

### Test Yaklaşımı

Bu basit proje için otomatik test yazılmayacak. Manuel testler yeterli olacaktır. Geliştirme sırasında her platformda uygulama çalıştırılarak test edilecektir.

## Dependencies

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_tts: ^4.0.2  # Text-to-speech paketi

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Implementation Notes

1. **Basitlik**: Kod mümkün olduğunca basit ve anlaşılır olacak
2. **Platform Desteği**: Tüm platformlar için tek kod tabanı kullanılacak
3. **State Yönetimi**: StatefulWidget ile basit state yönetimi
4. **Servis Katmanı**: TtsService sınıfı ile flutter_tts paketi soyutlanacak
5. **UI/UX**: Material Design prensipleri takip edilecek
6. **Performans**: Minimal bağımlılık, hızlı başlatma
