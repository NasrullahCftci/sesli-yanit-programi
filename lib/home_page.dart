import 'package:flutter/material.dart';
import 'tts_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final TtsService _ttsService = TtsService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      await _ttsService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TTS başlatma hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _onSpeakButtonPressed() async {
    final text = _textController.text.trim();
    
    // Metin boşsa kullanıcıya bilgi ver
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen okunacak bir metin girin'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    try {
      // TTS ile metni sesli oku
      await _ttsService.speak(text);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sesli okuma hatası: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery ile ekran boyutunu al
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Ekran boyutuna göre padding ayarla
    double horizontalPadding;
    double verticalPadding;
    
    if (screenWidth < 600) {
      // Mobil cihazlar
      horizontalPadding = 16.0;
      verticalPadding = 16.0;
    } else if (screenWidth < 1024) {
      // Tablet cihazlar
      horizontalPadding = 32.0;
      verticalPadding = 24.0;
    } else {
      // Desktop cihazlar
      horizontalPadding = 48.0;
      verticalPadding = 32.0;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesli Yanıt Programı'),
        centerTitle: true, // Başlığı ortala
        backgroundColor: const Color(0xFF2E7D32), // Koyu yeşil arka plan
        foregroundColor: Colors.white, // Beyaz yazı rengi
      ),
      body: Stack(
        children: [
          Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Metin girin...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onSpeakButtonPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sesli Oku',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
          // Geliştirici bilgisi - sağ alt köşe
          Positioned(
            right: 16,
            bottom: 16,
            child: Text(
              'Geliştirici: Nasrullah Çiftci',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
