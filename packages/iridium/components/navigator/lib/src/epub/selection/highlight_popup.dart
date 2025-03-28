import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/selection/selection_popup.dart';

class HighlightPopup extends SelectionPopup {
  static const List<Color> highlightTints = [
    Color.fromARGB(255, 255, 192, 203), // pink
    Color.fromARGB(255, 187, 173, 255), // purple
    Color.fromARGB(255, 135, 206, 250), // blue
    Color.fromARGB(255, 144, 238, 144), // green
    Color.fromARGB(255, 255, 218, 185), // peach
  ];

  HighlightPopup(super.selectionListener);

  @override
  double get optionsWidth => 320.0;

  @override
  double get optionsHeight => 48.0;

  void showHighlightPopup(
    BuildContext context,
    Selection selection,
    HighlightStyle style,
    Color tint,
    String? highlightId,
  ) {
    displayPopup(context, selection,
        child: Material(
          color: Color(0xFF3B3B3B),
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          elevation: 8.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...highlightTints
                    .map((color) => buildColorOption(color, () {
                          if (highlightId != null) {
                            selectionListener.updateHighlight(
                                selection, style, color, highlightId);
                          } else {
                            selectionListener.createHighlight(
                                selection, style, color);
                          }
                          close();
                        }))
                    .toList(),
                buildNoteOption(context, selection, highlightId),
                if (highlightId != null) buildDeleteOption(context, highlightId),
              ],
            ),
          ),
        ));
  }

  Widget buildColorOption(Color color, VoidCallback action) => IconButton(
        padding: EdgeInsets.all(4.0),
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        onPressed: action,
        icon: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
        ),
      );

  Widget buildNoteOption(
          BuildContext context, Selection selection, String? highlightId) =>
      IconButton(
        padding: EdgeInsets.all(4.0),
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        onPressed: () {
          selectionListener.showAnnotationPopup(selection,
              highlightId: highlightId);
          close();
        },
        icon: Icon(
          Icons.edit,
          color: Colors.white,
          size: 24,
        ),
      );

  Widget buildDeleteOption(BuildContext context, String highlightId) =>
      IconButton(
        padding: EdgeInsets.all(4.0),
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        onPressed: () {
          selectionListener.deleteHighlight(highlightId);
          close();
        },
        icon: Icon(
          Icons.close,
          color: Colors.white,
          size: 24,
        ),
      );
}
