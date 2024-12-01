import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgAssetLoader {
  final String assetPath;

  SvgAssetLoader(this.assetPath);

  String cacheKey() => assetPath;

  Future<ByteData> loadBytes() async {
    // Simply return the ByteData obtained from the rootBundle
    return await rootBundle.load(assetPath);
  }
}

void loadSvgList(List<String> svgPaths) {
  for (String path in svgPaths) {
    final loader = SvgAssetLoader(path);
    // Assuming svg.cache is some form of cache that stores ByteData for SVGs
    svg.cache.putIfAbsent(loader.cacheKey(), () => loader.loadBytes());
  }
}