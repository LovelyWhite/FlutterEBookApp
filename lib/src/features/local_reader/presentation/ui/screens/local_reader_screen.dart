import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:iridium_reader_widget/iridium_reader_widget.dart';
import 'package:iridium_reader_widget/views/viewers/epub_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_ebook_app/src/common/common.dart';

@RoutePage()
class LocalReaderScreen extends StatefulWidget {
  const LocalReaderScreen({super.key});

  @override
  State<LocalReaderScreen> createState() => _LocalReaderScreenState();
}

class _LocalReaderScreenState extends State<LocalReaderScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    try {
      // EPUB asset path
      const assetPath = 'assets/G.O.A.T Tradie - BusinessSight.epub';
      
      // Convert asset to temp file
      final filePath = await AssetLoader.loadAssetToTempFile(assetPath);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _filePath = filePath;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading EPUB: $e';
        });
      }
      print('EPUB loading error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while preparing the file
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('eBook Reader'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show error message if there was an error
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('eBook Reader'),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    // Display the EpubScreen with SQLite storage
    if (_filePath != null) {
      return FutureBuilder<EpubScreen>(
        future: EpubScreen.fromPathWithSqliteStorage(filePath: _filePath!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('加载错误: ${snapshot.error}'),
              ),
            );
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return const Scaffold(
              body: Center(
                child: Text('无法加载电子书文件'),
              ),
            );
          }
        },
      );
    } else {
      return const Scaffold(
        body: Center(
          child: Text('无法加载电子书文件'),
        ),
      );
    }
  }
}
