import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:iridium_reader_widget/views/viewers/ui/reader_navigation_screen.dart';
import 'package:iridium_reader_widget/views/viewers/ui/toolbar_button.dart';
import 'package:iridium_reader_widget/views/viewers/ui/toolbar_page_number.dart';
import 'package:iridium_reader_widget/views/viewers/ui/content_panel.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:iridium_reader_widget/util/router.dart';
import 'package:iridium_reader_widget/views/viewers/ui/annotations_panel.dart';
import 'dart:ui' as ui;

class ReaderToolbar extends StatefulWidget {
  final ReaderContext readerContext;
  final VoidCallback onSkipLeft;
  final VoidCallback onSkipRight;

  const ReaderToolbar(
      {super.key,
      required this.readerContext,
      required this.onSkipLeft,
      required this.onSkipRight});

  @override
  State<StatefulWidget> createState() => ReaderToolbarState();
}

class ReaderToolbarState extends State<ReaderToolbar> {
  static const double height = kToolbarHeight;
  late StreamSubscription<bool> _toolbarStreamSubscription;
  late StreamSubscription<PaginationInfo> _currentLocationStreamSubscription;
  late StreamController<int> pageNumberController;
  double opacity = 0.0;

  ReaderContext get readerContext => widget.readerContext;

  Function() get onSkipLeft => widget.onSkipLeft;

  Function() get onSkipRight => widget.onSkipRight;

  @override
  void initState() {
    super.initState();
    readerContext.checkPaginationInitialization();

    _toolbarStreamSubscription = readerContext.toolbarStream.listen((visible) {
      setState(() {
        opacity = (visible) ? 1.0 : 0.0;
      });
    });
    pageNumberController = StreamController.broadcast();
    _currentLocationStreamSubscription =
        readerContext.currentLocationStream.listen((event) {
      pageNumberController.add(event.page);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _toolbarStreamSubscription.cancel();
    _currentLocationStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: IgnorePointer(
          ignoring: opacity < 1.0,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 300),
            child: Container(
              height: height,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChaptersButton(context),
                  _buildBookmarkButton(context),
                  _buildProgressButton(context),
                  _buildBrightnessButton(context),
                  _buildFontButton(context),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildChaptersButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/icons/chapters.png',
        width: 18,
        height: 18,
      ),
      color: Colors.black54,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFFFAF8F8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.95,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 32),
                        child: Center(
                          child: Container(
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFFC0C2C4),
                        ),
                        label: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            "Return to\nthe current",
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: Color(0xFFC0C2C4),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ContentPanel(readerContext: readerContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarkButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/icons/bookmark.png',
        width: 18,
        height: 18,
      ),
      color: Colors.black54,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFFFAF8F8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.95,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 15),
                        child: Center(
                          child: Container(
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: AnnotationsPanel(
                    readerContext: readerContext,
                    annotationType: AnnotationType.bookmark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/icons/fonts.png',
        width: 18,
        height: 18,
      ),
      color: Colors.black54,
      onPressed: () {},
    );
  }

  Widget _buildProgressButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/icons/progress.png',
        width: 18,
        height: 18,
      ),
      color: Colors.black54,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFFFAF8F8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => StreamBuilder<int>(
            initialData: 1,
            stream: pageNumberController.stream,
            builder: (context, snapshot) {
              final totalPages = readerContext.publication?.nbPages ?? 1;
              final currentPage = snapshot.data ?? 1;
              final percentComplete = ((currentPage / totalPages) * 100).toInt();
              final remainingHours = ((totalPages - currentPage) / 20).round(); // Average reading speed of 20 pages per hour
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProgressStat(
                          '$percentComplete%',
                          'Finish reading\nin about $remainingHours hours',
                        ),
                        Container(width: 1, height: 50, color: Colors.grey[300]),
                        _buildProgressStat(
                          '20min',
                          'Reading time',
                        ),
                        Container(width: 1, height: 50, color: Colors.grey[300]),
                        _buildProgressStat(
                          '3',
                          'Notes',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Interactive progress bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate position for the handle
                          final handlePosition = (constraints.maxWidth - 44) * 
                              math.min(1.0, math.max(0.0, (currentPage - 1) / (totalPages - 1)));
                          
                          // Track current drag position for handle
                          int draggedPage = currentPage;
                          
                          return GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              final RenderBox box = context.findRenderObject() as RenderBox;
                              final Offset localPosition = box.globalToLocal(details.globalPosition);
                              final double progress = math.max(0, math.min(1, localPosition.dx / constraints.maxWidth));
                              draggedPage = math.max(1, math.min(
                                totalPages, 
                                (progress * totalPages).round()
                              ));
                              pageNumberController.add(draggedPage);
                            },
                            onHorizontalDragEnd: (details) {
                              // Use the current page from the stream builder
                              readerContext.execute(GoToPageCommand(currentPage));
                            },
                            onTapDown: (details) {
                              final RenderBox box = context.findRenderObject() as RenderBox;
                              final Offset localPosition = box.globalToLocal(details.globalPosition);
                              final double progress = math.max(0, math.min(1, localPosition.dx / constraints.maxWidth));
                              final int newPage = math.max(1, math.min(
                                totalPages, 
                                (progress * totalPages).round()
                              ));
                              pageNumberController.add(newPage);
                              readerContext.execute(GoToPageCommand(newPage));
                            },
                            child: Stack(
                              children: [
                                // Background progress bar
                                Container(
                                  width: constraints.maxWidth,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                // Progress fill (already read portion)
                                Container(
                                  width: handlePosition + 22, // Add half of handle width
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC0C2C4),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(22),
                                      bottomLeft: Radius.circular(22),
                                      // No radius on the right side
                                    ),
                                  ),
                                ),
                                // Draggable handle (circle)
                                Positioned(
                                  left: handlePosition,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                // Left arrow
                                Positioned(
                                  left: 10,
                                  child: SizedBox(
                                    height: 44,
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        size: 16,
                                        color: const Color(0xFF717171),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrightnessButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/icons/lightness.png',
        width: 18,
        height: 18,
      ),
      color: Colors.black54,
      onPressed: () {},
    );
  }

  Widget _firstRow(BuildContext context) {
    var isReversed =
        readerContext.readingProgression?.isReverseOrder() ?? false;
    return Row(
      children: <Widget>[
        ToolbarButton(
          asset:
              'packages/iridium_reader_widget/assets/images/ic_skip_left_white_24dp.png',
          onPressed: onSkipLeft,
        ),
        const SizedBox(width: 8.0),
        (isReversed ? _buildNbPages(context) : _builderCurrentPage()),
        _buildSlider(context),
        (isReversed ? _builderCurrentPage() : _buildNbPages(context)),
        const SizedBox(width: 8.0),
        ToolbarButton(
          asset:
              'packages/iridium_reader_widget/assets/images/ic_skip_right_white_24dp.png',
          onPressed: onSkipRight,
        ),
      ],
    );
  }

  Widget _builderCurrentPage() {
    return StreamBuilder<int>(
      initialData: 1,
      stream: pageNumberController.stream,
      builder: (context, snapshot) {
        return ToolbarPageNumber(
          pageNumber: snapshot.data ?? 1,
        );
      },
    );
  }

  Widget _buildNbPages(BuildContext context) {
    return ToolbarPageNumber(
      pageNumber: readerContext.publication?.nbPages ?? 1,
    );
  }

  Widget _buildSlider(BuildContext context) => Expanded(
        child: StreamBuilder<int>(
            initialData: 1,
            stream: pageNumberController.stream,
            builder: (context, snapshot) {
              var isReversed =
                  readerContext.readingProgression?.isReverseOrder() ?? false;
              var maxPageNumber =
                  readerContext.publication?.nbPages.toDouble() ?? 1;
              var curPageNum = snapshot.data?.toDouble() ?? 1;
              return FlutterSlider(
                  rtl: isReversed,
                  onDragging: (handlerIndex, lowerValue, upperValue) =>
                      pageNumberController.add(lowerValue.toInt()),
                  onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                    readerContext.execute(GoToPageCommand(lowerValue.toInt()));
                  },
                  min: 1.0,
                  max: maxPageNumber,
                  values: [curPageNum],
                  trackBar: FlutterSliderTrackBar(
                    inactiveTrackBarHeight: 4,
                    activeTrackBarHeight: 6,
                    inactiveTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    activeTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  handler: FlutterSliderHandler(
                    child: Icon(
                      Icons.adjust,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 18,
                    ),
                  ));
            }),
      );
}
