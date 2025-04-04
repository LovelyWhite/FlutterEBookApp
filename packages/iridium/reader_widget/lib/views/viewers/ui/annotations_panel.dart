import 'package:flutter/material.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';
import 'dart:convert';
class AnnotationsPanel extends StatefulWidget {
  final ReaderContext readerContext;
  final AnnotationType annotationType;

  const AnnotationsPanel({
    super.key,
    required this.readerContext,
    required this.annotationType,
  });

  @override
  State<StatefulWidget> createState() => AnnotationsPanelState();
}

class AnnotationsPanelState extends State<AnnotationsPanel> {
  final TextEditingController _searchController = TextEditingController();
  List<ReaderAnnotation> _allAnnotations = [];
  List<ReaderAnnotation> _filteredAnnotations = [];

  @override
  void initState() {
    super.initState();
    _loadAnnotations();
    _searchController.addListener(_filterAnnotations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnotations() async {
    _allAnnotations =
        await widget.readerContext.readerAnnotationRepository.allWhere();
    _filterAnnotations();
  }

  void _filterAnnotations() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredAnnotations = List.from(_allAnnotations);
      } else {
        _filteredAnnotations = _allAnnotations.where((annotation) {
          final locator = Locator.fromJsonString(annotation.location);
          final title = locator?.title ?? '';
          final text = locator?.text.highlight ?? '';
          return title
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              text.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();
      }
    });
  }

  void _exportNotes() {
    // TODO: 实现导出功能
  }

  @override
  Widget build(BuildContext context) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Container(
          color: const Color(0xFFF7F7F7),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Record',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'G.O.A.T Tradie',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Color(0xFF666666),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total: ${_filteredAnnotations.length} notes',
                                    style: const TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.trending_up,
                                    size: 16,
                                    color: Color(0xFF666666),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Duration: 1 hour',
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/splash.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFEEEEEE),
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search notes',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Color(0xFF999999),
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: _exportNotes,
                            child: Container(
                              height: 44,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.upload_outlined,
                                    color: Color(0xFF666666),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Export notes',
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _filteredAnnotations.length,
                  itemBuilder: (context, index) =>
                      _buildAnnotationItem(_filteredAnnotations[index]),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildAnnotationItem(ReaderAnnotation annotation) {
    final locator = Locator.fromJsonString(annotation.location);
    final title = locator?.title ?? '';
    final text = locator?.text.highlight ?? '';
    print(jsonEncode(annotation));
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: _getAnnotationIcon(annotation.annotationType),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getAnnotationTypeText(annotation),
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty) ...[

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (annotation?.annotationType == AnnotationType.bookmark) ...[
                    Text(
                      'Bookmark  ${locator?.locations.progression?.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                  if (annotation?.annotation?.isNotEmpty ?? false) ...[
                    Text(
                      annotation?.annotation ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAnnotationIcon(AnnotationType type) {
    IconData iconData;
    switch (type) {
      case AnnotationType.bookmark:
        iconData = Icons.bookmark_border;
        break;
      case AnnotationType.highlight:
        iconData = Icons.format_underline;
        break;
      default:
        iconData = Icons.note_outlined;
    }
    return Icon(
      iconData,
      color: const Color(0xFF666666),
      size: 24,
    );
  }

  String _getAnnotationTypeText(ReaderAnnotation annotation) {
    if (annotation?.annotation?.isNotEmpty ?? false) {
      return 'Note';
    }
    switch (annotation.annotationType) {
      case AnnotationType.bookmark:
        return 'Bookmark';
      case AnnotationType.highlight:
        return 'Remark';
      default:
        return 'Note';
    }
  }

  void _onTap(ReaderAnnotation readerAnnotation) {
    Navigator.pop(context);
    widget.readerContext
        .execute(GoToLocationCommand(readerAnnotation.location));
  }
}
