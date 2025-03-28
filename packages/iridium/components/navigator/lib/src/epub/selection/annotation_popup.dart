import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class AnnotationPopup extends StatefulWidget {
  final SelectionListener selectionListener;
  final Selection selection;
  final HighlightStyle style;
  final Color tint;
  final String? annotation;
  final String? highlightId;

  AnnotationPopup(
    this.selectionListener,
    this.selection,
    this.style,
    this.tint,
    this.annotation,
    this.highlightId,
  );

  static void showAnnotationPopup(
    BuildContext context,
    SelectionListener selectionListener,
    Selection selection,
    HighlightStyle style,
    Color tint,
    String? annotation,
    String? highlightId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AnnotationPopup(
          selectionListener,
          selection,
          style,
          tint,
          annotation,
          highlightId,
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => AnnotationPopupState();
}

class AnnotationPopupState extends State<AnnotationPopup> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  SelectionListener get selectionListener => widget.selectionListener;
  Selection get selection => widget.selection;
  HighlightStyle get style => widget.style;
  Color get tint => widget.tint;
  String? get annotation => widget.annotation;
  String? get highlightId => widget.highlightId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: annotation);
    // 自动获取焦点
    Future.delayed(Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/icons/note-left.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Add annotations with explanations...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        saveHighlight(value);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/note-send.png',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      saveHighlight(_controller.text);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  void saveHighlight(String text) {
    String? id = highlightId;
    if (id == null) {
      selectionListener.createHighlight(selection, style, tint,
          annotation: text);
    } else {
      selectionListener.updateHighlight(selection, style, tint, id,
          annotation: text);
    }
  }
}
