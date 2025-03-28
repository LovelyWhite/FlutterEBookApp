// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_commons/extensions/strings.dart';
import 'package:mno_commons/utils/href.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/src/epub/constants.dart';
import 'package:xml/xml.dart';

/// Parser for NCX files that describes the table of content and page list.
class NcxParser {
  /// Parse the Xml document for table of content and page list.
  static Map<String, List<Link>> parse(XmlElement document, String filePath) {
    MapEntry<String, List<Link>>? toc = document
        .getElement("navMap", namespace: Namespaces.ncx)
        ?.let((it) => _parseNavMapElement(it, filePath))
        .let((it) => MapEntry("toc", it));
    MapEntry<String, List<Link>>? pageList = document
        .getElement("pageList", namespace: Namespaces.ncx)
        ?.let((it) => _parsePageListElement(it, filePath))
        .let((it) => MapEntry("page-list", it));
    return Map.fromEntries([toc, pageList].whereNotNull());
  }

  static List<Link> _parseNavMapElement(XmlElement element, String filePath) =>
      element
          .findElements("navPoint", namespace: Namespaces.ncx)
          .mapNotNull((it) => _parseNavPointElement(it, filePath))
          .toList();

  static List<Link> _parsePageListElement(
          XmlElement element, String filePath) =>
      element
          .findElements("pageTarget", namespace: Namespaces.ncx)
          .mapNotNull((it) {
        String? href = _extractHref(it, filePath);
        String? title = _extractTitle(it);
        return (href.isNullOrBlank || title.isNullOrBlank)
            ? null
            : Link(title: title, href: href!);
      }).toList();

  static Link? _parseNavPointElement(XmlElement element, String filePath) {
    String? title = _extractTitle(element);
    String? href = _extractHref(element, filePath);
    
    // 增强子元素查找，有时候嵌套的navPoint可能有不同的结构
    List<Link> children = [];
    
    // 直接子元素中的navPoint
    var directChildren = element
        .findElements("navPoint", namespace: Namespaces.ncx)
        .mapNotNull((it) => _parseNavPointElement(it, filePath))
        .toList();
    
    if (directChildren.isNotEmpty) {
      children.addAll(directChildren);
    }
    
    // 有些EPUB会在navMap下使用navList来组织子菜单
    var navList = element.getElement("navList", namespace: Namespaces.ncx);
    if (navList != null) {
      var navTargets = navList
          .findElements("navTarget", namespace: Namespaces.ncx)
          .mapNotNull((it) {
            String? targetTitle = _extractTitle(it);
            String? targetHref = _extractHref(it, filePath);
            if (targetHref.isNullOrBlank || targetTitle.isNullOrBlank) {
              return null;
            }
            return Link(title: targetTitle, href: targetHref!);
          }).toList();
      
      if (navTargets.isNotEmpty) {
        children.addAll(navTargets);
      }
    }
    
    // 针对只有标题没有href的情况，比如目录分组
    if (href == null && title != null && children.isNotEmpty) {
      return Link(title: title, href: "#", children: children);
    }
    
    // 正常情况
    return (children.isEmpty && (href == null || title == null))
        ? null
        : Link(title: title, href: href ?? "#", children: children);
  }

  static String? _extractTitle(XmlElement element) => element
      .getElement("navLabel", namespace: Namespaces.ncx)
      ?.getElement("text", namespace: Namespaces.ncx)
      ?.text
      .replaceAll(RegExp("\\s+"), " ")
      .trim()
      .ifBlank(() => null);

  static String? _extractHref(XmlElement element, String filePath) => element
      .getElement("content", namespace: Namespaces.ncx)
      ?.getAttribute("src")
      ?.ifBlank(() => null)
      ?.let((it) => Href(it, baseHref: filePath).string.removePrefix('/'));
}
