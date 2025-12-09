import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/face_shape_provider.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key}) : super(key: key);

  List<String> _stylingDo(String shape) {
    final key = shape.toUpperCase();
    switch (key) {
      case 'OVAL':
        return [
          'Layer lembut untuk menambah dimensi di sisi wajah.',
          'Poni samping tipis untuk menonjolkan struktur tulang pipi.',
          'Panjang medium hingga bawah bahu cocok untuk variasi styling.',
        ];
      case 'ROUND':
        return [
          'Layer memanjang di bawah dagu agar wajah tampak lebih tegas.',
          'Belah samping (side part) untuk menciptakan ilusi garis vertikal.',
          'Volume di atas (crown) untuk menambah tinggi wajah.',
        ];
      case 'SQUARE':
        return [
          'Soft layer di ujung rambut agar garis rahang lebih lembut.',
          'Wave atau curl loose untuk mengurangi kesan kaku.',
          'Side-swept bangs untuk menyeimbangkan dahi dan rahang.',
        ];
      case 'HEART':
        return [
          'Layer dari pipi ke bawah untuk menambah fullness di rahang.',
          'Curtain bangs tipis agar dahi tampak seimbang.',
          'Textured lob atau bob di bawah dagu untuk memberi berat di bawah.',
        ];
      case 'DIAMOND':
        return [
          'Layer lembut di area pipi untuk menyeimbangkan tulang pipi tinggi.',
          'Poni tirai atau samping untuk melembutkan dahi.',
          'Wave medium di bawah telinga memberi volume merata.',
        ];
      default:
        return [
          'Layer yang proporsional untuk menyeimbangkan bentuk wajah.',
          'Hindari volume berlebih di area yang sudah dominan.',
          'Coba tekstur natural (wave/curl) untuk tampilan lebih dinamis.',
        ];
    }
  }

  List<String> _stylingDont(String shape) {
    final key = shape.toUpperCase();
    switch (key) {
      case 'OVAL':
        return [
          'Poni terlalu tebal yang menutupi seluruh dahi.',
          'Volume berlebihan di seluruh kepala tanpa definisi.',
        ];
      case 'ROUND':
        return [
          'Poni penuh/tebal lurus yang memperpendek wajah.',
          'Bob tumpul di dagu yang menambah lebar wajah.',
        ];
      case 'SQUARE':
        return [
          'Belah tengah dengan rambut lurus kaku tanpa layer.',
          'Bob tumpul di rahang yang menonjolkan garis kotak.',
        ];
      case 'HEART':
        return [
          'Volume besar di atas kepala yang mempertegas dahi lebar.',
          'Potongan terlalu pendek di pelipis yang menonjolkan dahi.',
        ];
      case 'DIAMOND':
        return [
          'Layer berlebih di puncak kepala yang menambah panjang wajah.',
          'Poni terlalu pendek yang membuat dahi tampak lebih lebar.',
        ];
      default:
        return [
          'Volume berlebih di area dominan wajah.',
          'Potongan tumpul tanpa layer pada fitur yang sudah tegas.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FaceShapeProvider>(context);
    final result = provider.result;

    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Analisis',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(provider.imagePath!),
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              result.shape,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB24AE5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'Yang Cocok untuk ${result.shape}',
              items: _stylingDo(result.shape),
              icon: Icons.check_circle,
              iconColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Yang Sebaiknya Dihindari',
              items: _stylingDont(result.shape),
              icon: Icons.block,
              iconColor: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rekomendasi Hairstyle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            ...result.recommendations.map(
              (rec) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        rec.imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rec.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              _Tag(label: 'Layer'),
                              _Tag(label: 'Low maintenance'),
                              _Tag(label: 'Salon friendly'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'Perawatan Cepat',
              items: const [
                'Gunakan heat protectant sebelum styling panas.',
                'Sisirlah rambut ketika setengah kering untuk mencegah patah.',
                'Trim rutin 6-8 minggu untuk menjaga bentuk potongan.',
              ],
              icon: Icons.favorite,
              iconColor: const Color(0xFFEC4899),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.items,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: iconColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF7C3AED),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
