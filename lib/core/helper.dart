import 'package:piawai/core/constants.dart';

String imageUrl(String path) =>
    path.startsWith('https://') ? path : '$baseUrl/$path';
