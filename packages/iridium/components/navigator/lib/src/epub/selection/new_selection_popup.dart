import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/selection/highlight_popup.dart';
import 'package:mno_navigator/src/epub/selection/selection_popup.dart';

class NewSelectionPopup extends SelectionPopup {
  NewSelectionPopup(super.selectionListener);

  @override
  double get optionsWidth => 300.0;

  @override
  double get optionsHeight => 64.0;

  void displaySelectionPopup(BuildContext context, Selection selection) {
    displayPopup(context, selection,
        child: Material(
          color: const Color(0xFF3B3B3B),
          borderRadius: BorderRadius.circular(8.0),
          elevation: 8.0,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  "Copy",
                  Icons.copy_outlined,
                  () {
                    // TODO: 实现复制功能
                  },
                ),
                _buildDivider(),
                _buildOption(
                  "Underline",
                  Icons.format_underlined,
                  () {
                    selectionListener.showHighlightPopup(selection,
                        HighlightStyle.underline, HighlightPopup.highlightTints[0]);
                  },
                ),
                _buildDivider(),
                _buildOption(
                  "Highlight",
                  Icons.brush_outlined,
                  () {
                    selectionListener.showHighlightPopup(selection,
                        HighlightStyle.highlight, HighlightPopup.highlightTints[0]);
                  },
                ),
                _buildDivider(),
                _buildOption(
                  "Note",
                  Icons.mode_comment_outlined,
                  () {
                    selectionListener.showAnnotationPopup(selection,
                        style: HighlightStyle.highlight,
                        tint: HighlightPopup.highlightTints[0]);
                  },
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildOption(String text, IconData icon, VoidCallback action) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
