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
      return Stack(
        children: [
          tileWidget, // tile asli OSM tetap utuh
          Container(
            color: Colors.black.withOpacity(0.2), // overlay gelap
          ),
        ],
      );
    },
  );
}
