import 'package:flutter/material.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class ContentPanel extends StatefulWidget {
  final ReaderContext readerContext;

  const ContentPanel({super.key, required this.readerContext});

  @override
  State<StatefulWidget> createState() => ContentPanelState();
}

class ContentPanelState extends State<ContentPanel> {
  // 记录每个链接的展开状态，默认所有链接都是展开的
  final Map<String, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
    // 初始化每个链接的展开状态
    _initExpandedState(widget.readerContext.tableOfContents);
  }

  // 初始化展开状态，默认为展开的
  void _initExpandedState(List<Link> links) {
    for (var link in links) {
      // 使用href作为唯一标识
      _expandedState[link.href] = true;
      if (link.children.isNotEmpty) {
        _initExpandedState(link.children);
      }
    }
  }

  // 切换指定链接的展开状态
  void _toggleExpanded(String href) {
    setState(() {
      _expandedState[href] = !(_expandedState[href] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF8F8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF717171),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'search for chapters',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF717171),
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF717171),
                      ),
                    ),
                  ),
                  Container(
                    height: 31,
                    width: MediaQuery.of(context).size.width * 0.45,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'table of contents',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF717171),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: widget.readerContext.tableOfContents
                  .map((link) => _buildTocItem(context, link, 0))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTocItem(BuildContext context, Link link, int level) {
    bool hasChildren = link.children.isNotEmpty;
    bool isExpanded = _expandedState[link.href] ?? false;
    bool isClickable = !link.href.startsWith('#') || hasChildren;

    String pageNumber = _getPageNumber(link);

    return Column(
      children: [
        InkWell(
          onTap: isClickable
              ? () {
                  if (hasChildren) {
                    _toggleExpanded(link.href);
                  } else if (!link.href.startsWith('#')) {
                    _onTap(link);
                  }
                }
              : null,
          child: Container(
            padding: EdgeInsets.only(
              left: 20.0 + level * 10.0,
              right: 20.0,
              top: 16.0,
              bottom: 16.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F8),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFEDEDED),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  link.title ?? "无标题",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: const Color(0xFF717171),
                    fontWeight:
                        level == 0 ? FontWeight.w500 : FontWeight.normal,
                    letterSpacing: -0.2,
                  ),
                ),
                if (hasChildren) ...[
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 18,
                    color: const Color(0xFF717171),
                  ),
                ],
                const Expanded(child: SizedBox()),
                Text(
                  pageNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC0C2C4),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          Column(
            children: link.children
                .map((child) => _buildTocItem(context, child, level + 1))
                .toList(),
          ),
      ],
    );
  }

  String _getPageNumber(Link link) {
    // 从 tableOfContentsToSpineItemIndex 获取 spine item 索引
    int spineIndex =
        widget.readerContext.tableOfContentsToSpineItemIndex[link] ?? -1;

    if (spineIndex >= 0) {
      // 获取对应的 spine item
      Link? spineItem =
          widget.readerContext.publication?.readingOrder[spineIndex];

      if (spineItem != null) {
        // 从 paginationInfo 获取页码信息
        LinkPagination? pagination =
            widget.readerContext.publication?.paginationInfo[spineItem];

        if (pagination != null) {
          return pagination.firstPageNumber.toString();
        }
      }
    }
    return "";
  }

  void _onTap(Link link) {
    Navigator.pop(context);
    widget.readerContext
        .execute(GoToHrefCommand(link.hrefPart, link.elementId));
  }
}
