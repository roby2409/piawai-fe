import 'package:flutter_map/flutter_map.dart';

TileLayer buildTileLayer() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.rigofficial.piawai',
  tileProvider: NetworkTileProvider(),
  errorTileCallback: (tile, error, stackTrace) {},
);
