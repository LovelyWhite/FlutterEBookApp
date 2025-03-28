import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AssetLoader {
  /// 从资产加载文件并返回临时文件路径
  static Future<String> loadAssetToTempFile(String assetPath) async {
    try {
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final tempFile = File('${tempDir.path}/$fileName');
      
      // 如果文件已存在，直接返回
      if (await tempFile.exists()) {
        return tempFile.path;
      }
      
      // 从资产加载数据
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      
      // 写入临时文件
      await tempFile.writeAsBytes(bytes);
      
      return tempFile.path;
    } catch (e) {
      print('Error loading asset: $e');
      rethrow;
    }
  }
} 
