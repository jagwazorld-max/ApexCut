import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_theme.dart';

/// Text-to-Speech panel – write text and generate voiceover in different voices
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
  double _rate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _selectedVoice = 'Default';

  final List<String> _voices = [
    'Default',
    'Male (Deep)',
    'Female (Soft)',
    'Female (Energetic)',
    'Male (Narrator)',
    'Child',
    'Robot',
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
    await _tts.setVolume(_volume);

    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _tts.setCancelHandler(() => setState(() => _isSpeaking = false));
  }

  Future<void> _speak() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Simple voice simulation via pitch/rate
    switch (_selectedVoice) {
      case 'Male (Deep)':
        await _tts.setPitch(0.7);
        await _tts.setSpeechRate(0.4);
        break;
      case 'Female (Soft)':
        await _tts.setPitch(1.3);
        await _tts.setSpeechRate(0.45);
        break;
      case 'Female (Energetic)':
        await _tts.setPitch(1.4);
        await _tts.setSpeechRate(0.6);
        break;
      case 'Male (Narrator)':
        await _tts.setPitch(0.85);
        await _tts.setSpeechRate(0.42);
        break;
      case 'Child':
        await _tts.setPitch(1.6);
        await _tts.setSpeechRate(0.5);
        break;
      case 'Robot':
        await _tts.setPitch(0.5);
        await _tts.setSpeechRate(0.35);
        break;
      default:
        await _tts.setPitch(_pitch);
        await _tts.setSpeechRate(_rate);
    }

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
          const Text('Text-to-Speech Voiceover', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          const Text(
            'Write text → choose voice → generate natural speech',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Type what you want the voice to say...',
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _voices.map((v) {
                final selected = _selectedVoice == v;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(v, style: const TextStyle(fontSize: 11)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedVoice = v),
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
                  label: Text(_isSpeaking ? 'Speaking...' : 'Generate & Play'),
                ),
              ),
              const SizedBox(width: 8),
              if (_isSpeaking)
                IconButton(
                  onPressed: _stop,
                  icon: const Icon(Icons.stop_circle, color: AppTheme.secondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
