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
    return ListView(
      children: widget.readerContext.tableOfContents
          .map((link) => _buildTocItem(context, link, 0))
          .toList(),
    );
  }

  Widget _buildTocItem(BuildContext context, Link link, int level) {
    bool hasChildren = link.children.isNotEmpty;
    bool isExpanded = _expandedState[link.href] ?? false;
    bool isClickable = !link.href.startsWith('#') || hasChildren;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当前目录项
        InkWell(
          onTap: isClickable ? () {
            if (hasChildren) {
              _toggleExpanded(link.href);
            } else if (!link.href.startsWith('#')) {
              _onTap(link);
            }
          } : null,
          child: Container(
            decoration: BoxDecoration(
              color: level == 0 ? Colors.grey.withOpacity(0.1) : null,
              border: level == 0 
                  ? Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 0.5))
                  : null,
            ),
            padding: EdgeInsets.only(
              left: 16.0 + level * 16.0, // 根据层级缩进
              right: 16.0,
              top: 12.0,
              bottom: 12.0,
            ),
            child: Row(
              children: [
                if (hasChildren) 
                  Icon(
                    isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                    size: 20, 
                    color: Colors.grey,
                  ),
                if (!hasChildren)
                  SizedBox(width: 20), // 保持缩进一致
                Expanded(
                  child: Text(
                    link.title ?? "无标题",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: level == 0 ? FontWeight.bold : FontWeight.normal,
                      color: isClickable 
                        ? (hasChildren ? Colors.black87 : Colors.blue)
                        : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 子目录项，仅在展开状态显示
        if (hasChildren && isExpanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            child: Column(
              children: link.children
                  .map((child) => _buildTocItem(context, child, level + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _onTap(Link link) {
    Navigator.pop(context);
    widget.readerContext
        .execute(GoToHrefCommand(link.hrefPart, link.elementId));
  }
}
