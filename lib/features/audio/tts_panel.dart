import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_theme.dart';

class TtsPanel extends StatefulWidget {
  final ValueChanged<String>? onAudioGenerated;

  const TtsPanel({super.key, this.onAudioGenerated});

  @override
  State<TtsPanel> createState() => _TtsPanelState();
}

class _TtsPanelState extends State<TtsPanel> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _controller = TextEditingController();
  bool _isSpeaking = false;
  String _selectedVoice = 'Default';
  String _language = 'en-US';

  final List<Map<String, String>> _voices = [
    {'id': 'Default', 'lang': 'en-US', 'pitch': '1.0', 'rate': '0.5'},
    {'id': 'Male Deep', 'lang': 'en-US', 'pitch': '0.65', 'rate': '0.42'},
    {'id': 'Male Narrator', 'lang': 'en-US', 'pitch': '0.8', 'rate': '0.4'},
    {'id': 'Female Soft', 'lang': 'en-US', 'pitch': '1.25', 'rate': '0.45'},
    {'id': 'Female Energetic', 'lang': 'en-US', 'pitch': '1.4', 'rate': '0.58'},
    {'id': 'Child', 'lang': 'en-US', 'pitch': '1.7', 'rate': '0.5'},
    {'id': 'Robot', 'lang': 'en-US', 'pitch': '0.45', 'rate': '0.32'},
    {'id': 'British', 'lang': 'en-GB', 'pitch': '1.0', 'rate': '0.48'},
    {'id': 'Australian', 'lang': 'en-AU', 'pitch': '1.05', 'rate': '0.5'},
    {'id': 'Indian English', 'lang': 'en-IN', 'pitch': '1.1', 'rate': '0.48'},
    {'id': 'Spanish', 'lang': 'es-ES', 'pitch': '1.0', 'rate': '0.5'},
    {'id': 'French', 'lang': 'fr-FR', 'pitch': '1.0', 'rate': '0.5'},
    {'id': 'German', 'lang': 'de-DE', 'pitch': '0.95', 'rate': '0.48'},
    {'id': 'Portuguese', 'lang': 'pt-BR', 'pitch': '1.05', 'rate': '0.5'},
    {'id': 'Italian', 'lang': 'it-IT', 'pitch': '1.0', 'rate': '0.5'},
    {'id': 'Korean', 'lang': 'ko-KR', 'pitch': '1.05', 'rate': '0.5'},
    {'id': 'Arabic', 'lang': 'ar-SA', 'pitch': '0.95', 'rate': '0.48'},
    {'id': 'Whisper', 'lang': 'en-US', 'pitch': '0.9', 'rate': '0.28'},
    {'id': 'News Anchor', 'lang': 'en-US', 'pitch': '0.88', 'rate': '0.46'},
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(_language);
    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _tts.setCancelHandler(() => setState(() => _isSpeaking = false));
  }

  Future<void> _speak() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final voice = _voices.firstWhere((v) => v['id'] == _selectedVoice, orElse: () => _voices.first);
    await _tts.setLanguage(voice['lang']!);
    await _tts.setPitch(double.parse(voice['pitch']!));
    await _tts.setSpeechRate(double.parse(voice['rate']!));
    await _tts.speak(text);
    widget.onAudioGenerated?.call(text);
  }

  Future<void> _stop() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Text-to-Speech', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(hintText: 'Type script for voiceover...', isDense: true),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _voices.map((v) {
                final selected = _selectedVoice == v['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(v['id']!, style: const TextStyle(fontSize: 11)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedVoice = v['id']!),
                    selectedColor: AppTheme.primary.withOpacity(0.25),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSpeaking ? null : _speak,
                  icon: Icon(_isSpeaking ? Icons.volume_up : Icons.play_arrow, size: 18),
                  label: Text(_isSpeaking ? 'Speaking...' : 'Speak'),
                ),
              ),
              if (_isSpeaking)
                IconButton(onPressed: _stop, icon: const Icon(Icons.stop_circle, color: AppTheme.secondary)),
            ],
          ),
        ],
      ),
    );
  }
}
