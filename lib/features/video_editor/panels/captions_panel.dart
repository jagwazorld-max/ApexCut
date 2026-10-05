import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CaptionsPanel extends StatefulWidget {
  final String script;
  final ValueChanged<String> onScriptChanged;
  final VoidCallback onBurnCaptions;
  final int captionCount;

  const CaptionsPanel({
    super.key,
    required this.script,
    required this.onScriptChanged,
    required this.onBurnCaptions,
    required this.captionCount,
  });

  @override
  State<CaptionsPanel> createState() => _CaptionsPanelState();
}

class _CaptionsPanelState extends State<CaptionsPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.script);
  }

  @override
  void dispose() {
    _controller.dispose();
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
          const Text('Auto Captions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            widget.captionCount == 0
                ? 'Split the voiceover script onto timed lower-thirds'
                : '${widget.captionCount} caption cards on the timeline',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              onChanged: widget.onScriptChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Type or paste the spoken lines…',
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onBurnCaptions,
              icon: const Icon(Icons.subtitles_rounded, size: 18),
              label: const Text('Lay captions on picture'),
            ),
          ),
        ],
      ),
    );
  }
}
