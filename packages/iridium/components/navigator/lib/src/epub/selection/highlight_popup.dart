import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/selection/selection_popup.dart';

class HighlightPopup extends SelectionPopup {
  static const List<Color> highlightTints = [
    Color.fromARGB(255, 249, 239, 125),
    Color.fromARGB(255, 173, 247, 123),
    Color.fromARGB(255, 124, 198, 247),
    Color.fromARGB(255, 247, 124, 124),
    Color.fromARGB(255, 182, 153, 255),
  ];

  HighlightPopup(super.selectionListener);

  @override
  double get optionsWidth => 360.0;

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
          type: MaterialType.canvas,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          elevation: 8.0,
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
        ));
  }

  Widget buildColorOption(Color color, VoidCallback action) => IconButton(
        padding: EdgeInsets.all(4.0),
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        onPressed: action,
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
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
          color: Colors.blue.shade800,
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
          color: Colors.red.shade700,
          size: 24,
        ),
      );
}
