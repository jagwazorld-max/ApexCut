import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import '../../core/services/project_storage.dart';
import '../gallery/gallery_screen.dart';
import '../templates/templates_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Map<String, dynamic>> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final list = await ProjectStorage().listProjects();
    if (mounted) {
      setState(() {
        _recent = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Branding.appName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Branding.byLine,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                'Create New',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 14),

              _CreateCard(
                title: 'New Video Project',
                subtitle: 'Multi-track • Premiere tools',
                icon: Icons.movie_creation_rounded,
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GalleryScreen(isVideoMode: true)),
                ),
              ),
              const SizedBox(height: 10),
              _CreateCard(
                title: 'Edit Photo',
                subtitle: 'Color • Filters • Text • Effects',
                icon: Icons.photo_camera_rounded,
                color: AppTheme.secondary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GalleryScreen(isVideoMode: false)),
                ),
              ),
              const SizedBox(height: 10),
              _CreateCard(
                title: 'Templates',
                subtitle: 'Reels • Shorts • Stories • Ads',
                icon: Icons.auto_awesome_rounded,
                color: AppTheme.accent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                ),
              ),

              const SizedBox(height: 28),
              Text(
                'Recent Projects',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : _recent.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Center(
                              child: Text(
                                'No projects yet\nStart creating above',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _recent.length,
                            itemBuilder: (context, index) {
                              final p = _recent[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.movie_outlined, color: AppTheme.primary),
                                ),
                                title: Text(p['name'] ?? 'Untitled'),
                                subtitle: Text(
                                  p['updatedAt']?.toString().substring(0, 16) ?? '',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  onPressed: () async {
                                    await ProjectStorage().deleteProject(p['id']);
                                    _loadRecent();
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CreateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
