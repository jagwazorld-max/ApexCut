import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'tts_panel.dart';

class AudioPanel extends StatefulWidget {
  const AudioPanel({super.key});

  @override
  State<AudioPanel> createState() => _AudioPanelState();
}

class _AudioPanelState extends State<AudioPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: const [
              Tab(text: 'Voiceover'),
              Tab(text: 'Music'),
              Tab(text: 'SFX'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const TtsPanel(),
                _MusicLibrary(),
                _SfxLibrary(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicLibrary extends StatelessWidget {
  final tracks = [
    'Upbeat Pop',
    'Cinematic Epic',
    'Lo-fi Chill',
    'Corporate',
    'Trap Beat',
    'Acoustic',
    'Electronic',
    'Sad Piano',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tracks.length,
      itemBuilder: (context, i) {
        return ListTile(
          leading: const Icon(Icons.music_note, color: AppTheme.primary),
          title: Text(tracks[i]),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added: ${tracks[i]}')),
              );
            },
          ),
        );
      },
    );
  }
}

class _SfxLibrary extends StatelessWidget {
  final effects = [
    'Whoosh',
    'Pop',
    'Click',
    'Notification',
    'Transition',
    'Impact',
    'Riser',
    'Glitch',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: effects.length,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('SFX: ${effects[i]}')),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(effects[i], style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ),
          ),
        );
      },
    );
  }
}
