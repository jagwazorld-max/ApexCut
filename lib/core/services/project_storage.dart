import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../shared/models/project.dart';

class ProjectStorage {
  static final ProjectStorage _instance = ProjectStorage._internal();
  factory ProjectStorage() => _instance;
  ProjectStorage._internal();

  Future<Directory> get _dir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/apexcut_projects');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> _projectPath(String id) async {
    final dir = await _dir;
    return '${dir.path}/$id.json';
  }

  Future<void> saveProject(dynamic project) async {
    if (project is Project) {
      final path = await _projectPath(project.id);
      final map = {
        'id': project.id,
        'name': project.name,
        'type': project.type.name,
        'aspectRatio': project.aspectRatio.name,
        'createdAt': project.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'durationMs': project.duration.inMilliseconds,
        'musicPath': project.musicPath,
        'musicVolume': project.musicVolume,
        'colorGrade': project.colorGrade,
        'clipCount': project.tracks.fold<int>(0, (sum, t) => sum + t.clips.length),
      };
      await File(path).writeAsString(jsonEncode(map));
      return;
    }
    if (project is Map<String, dynamic>) {
      final id = project['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final path = await _projectPath(id);
      final map = Map<String, dynamic>.from(project);
      map['id'] = id;
      map['updatedAt'] = DateTime.now().toIso8601String();
      await File(path).writeAsString(jsonEncode(map));
      return;
    }
    throw ArgumentError('saveProject expects Project or Map');
  }

  Future<List<Map<String, dynamic>>> listProjects() async {
    final dir = await _dir;
    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));
    final list = <Map<String, dynamic>>[];
    for (final f in files) {
      try {
        final content = await f.readAsString();
        list.add(jsonDecode(content) as Map<String, dynamic>);
      } catch (_) {}
    }
    list.sort((a, b) {
      final ba = (b['updatedAt'] ?? '').toString();
      final aa = (a['updatedAt'] ?? '').toString();
      return ba.compareTo(aa);
    });
    return list;
  }

  Future<void> deleteProject(String id) async {
    final path = await _projectPath(id);
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<Project> createAndSave({
    required String name,
    required ProjectType type,
  }) async {
    final project = Project.create(name: name, type: type);
    await saveProject(project);
    return project;
  }
}
