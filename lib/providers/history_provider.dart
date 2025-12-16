import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/face_history.dart';
import '../services/history_database.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryDatabase _database = HistoryDatabase.instance;

  List<FaceHistory> _histories = [];
  bool _isLoading = false;

  List<FaceHistory> get histories => _histories;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _histories = await _database.getHistories();
    } catch (e) {
      debugPrint('Failed to load history: $e');
      _histories = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHistory({
    required String imagePath,
    required String shape,
  }) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('History save aborted: image not found');
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'history_${DateTime.now().millisecondsSinceEpoch}${p.extension(imagePath)}';
      final savedPath = p.join(directory.path, fileName);

      await imageFile.copy(savedPath);

      final history = FaceHistory(
        shape: shape.toUpperCase(),
        imagePath: savedPath,
        createdAt: DateTime.now(),
      );

      final id = await _database.insertHistory(history);
      _histories = [
        history.copyWith(id: id),
        ..._histories,
      ];
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save history: $e');
    }
  }

  Future<void> deleteHistory(int id) async {
    FaceHistory? target;
    for (final item in _histories) {
      if (item.id == id) {
        target = item;
        break;
      }
    }

    await _database.deleteHistory(id);
    if (target != null) {
      final file = File(target.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _histories = _histories.where((item) => item.id != id).toList();
    notifyListeners();
  }
}
