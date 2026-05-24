import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

TileLayer buildTileLayer(BuildContext context) {
  // 1. Deteksi apakah aplikasi sedang dalam Dark Mode
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.rigofficial.piawai',
    tileProvider: NetworkTileProvider(),
    errorTileCallback: (tile, error, stackTrace) {},

    // 2. Gunakan tileBuilder untuk memanipulasi warna jika isDarkMode bernilai true
    tileBuilder: (context, tileWidget, tile) {
      if (!isDarkMode) {
        return tileWidget; // Tampilan normal untuk Light Mode
      }

      // Filter matrix untuk mengubah gaya terang OSM menjadi estetika gelap (Dark Sci-Fi/Minimalis)
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -0.9, 0.0, 0.0, 0.0, 230.0, // Invert & sedikit kurangi kontras merah
          0.0, -0.9, 0.0, 0.0, 230.0, // Invert & sedikit kurangi kontras hijau
          0.0, 0.0, -0.8, 0.0, 240.0, // Invert biru dengan tone sedikit berbeda
          0.0, 0.0, 0.0, 1.0, 0.0, // Alpha tetap normal
        ]),
        child: tileWidget,
      );
    },
  );
}
