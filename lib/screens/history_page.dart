import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../utils/face_shape_helper.dart';
import '../models/face_history.dart';
import 'detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Riwayat Deteksi',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.histories.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat deteksi',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.histories.length,
            itemBuilder: (context, index) {
              final history = provider.histories[index];
              return _HistoryTile(
                history: history,
                onTap: () {
                  final result = FaceShapeHelper.buildResult(history.shape);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        result: result,
                        imagePath: history.imagePath,
                        createdAt: history.createdAt,
                      ),
                    ),
                  );
                },
                onDelete: history.id == null
                    ? null
                    : () => provider.deleteHistory(history.id!),
                dateLabel: _formatDate(history.createdAt),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.history,
    required this.onTap,
    required this.dateLabel,
    this.onDelete,
  });

  final FaceHistory history;
  final VoidCallback onTap;
  final String dateLabel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 58,
            height: 58,
            child: File(history.imagePath).existsSync()
                ? Image.file(
                    File(history.imagePath),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
          ),
        ),
        title: Text(
          history.shape,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          dateLabel,
          style: const TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                color: const Color(0xFFEF4444),
                onPressed: onDelete,
              ),
      ),
    );
  }
}
