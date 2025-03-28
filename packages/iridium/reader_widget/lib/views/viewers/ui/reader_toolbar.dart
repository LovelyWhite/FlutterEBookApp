import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:iridium_reader_widget/views/viewers/ui/reader_navigation_screen.dart';
import 'package:iridium_reader_widget/views/viewers/ui/toolbar_button.dart';
import 'package:iridium_reader_widget/views/viewers/ui/toolbar_page_number.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:iridium_reader_widget/util/router.dart';

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
                  _buildSettingsButton(context),
                  _buildFontButton(context),
                  _buildSearchButton(context),
                  _buildBrightnessButton(context),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildChaptersButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      color: Colors.black54,
      onPressed: () {
        // 显示章节目录
        MyRouter.pushPage(
            context, ReaderNavigationScreen(readerContext: readerContext));
      },
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      color: Colors.black54,
      onPressed: () {},
    );
  }

  Widget _buildFontButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.text_fields),
      color: Colors.black54,
      onPressed: () {},
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      color: Colors.black54,
      onPressed: () {},
    );
  }

  Widget _buildBrightnessButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.brightness_6),
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

  Widget _builderCurrentPage() => StreamBuilder<int>(
        initialData: 1,
        stream: pageNumberController.stream,
        builder: (context, snapshot) => ToolbarPageNumber(
          pageNumber: snapshot.data ?? 1,
        ),
      );

  Widget _buildNbPages(BuildContext context) => ToolbarPageNumber(
        pageNumber: readerContext.publication?.nbPages ?? 1,
      );

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
                      size: 24,
                    ),
                  ));
            }),
      );
}
