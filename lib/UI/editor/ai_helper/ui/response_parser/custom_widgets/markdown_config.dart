import 'package:flutter/material.dart';

import '../markdown_component.dart';

class GptMarkdownConfig {
  final TextDirection textDirection;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextScaler? textScaler;
  final void Function(String url, String title)? onLinkTap;
  final void Function(String code)? onCodeReplaceTap;
  final String Function(String tex)? latexWorkaround;
  final bool followLinkColor;
  final int? maxLines;
  final TextOverflow? overflow;
  final List<MarkdownComponent>? components;
  final List<MarkdownComponent>? inlineComponents;

  const GptMarkdownConfig({
    this.style,
    this.textDirection = TextDirection.ltr,
    this.onLinkTap,
    this.onCodeReplaceTap,
    this.textAlign,
    this.textScaler,
    this.latexWorkaround,
    this.followLinkColor = false,
    this.maxLines,
    this.overflow,
    this.components,
    this.inlineComponents,
  });

  GptMarkdownConfig copyWith({
    TextStyle? style,
    TextDirection? textDirection,
    final void Function(String url, String title)? onLinkTap,
    final void Function(String code)? onCodeReplaceTap,
    final TextAlign? textAlign,
    final TextScaler? textScaler,
    final String Function(String tex)? latexWorkaround,
    final bool? followLinkColor,
    final int? maxLines,
    final TextOverflow? overflow,
    final List<MarkdownComponent>? components,
    final List<MarkdownComponent>? inlineComponents,
  }) {
    return GptMarkdownConfig(
      style: style ?? this.style,
      textDirection: textDirection ?? this.textDirection,
      onLinkTap: onLinkTap ?? this.onLinkTap,
      onCodeReplaceTap: onCodeReplaceTap ?? this.onCodeReplaceTap,
      textAlign: textAlign ?? this.textAlign,
      textScaler: textScaler ?? this.textScaler,
      latexWorkaround: latexWorkaround ?? this.latexWorkaround,
      followLinkColor: followLinkColor ?? this.followLinkColor,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      components: components ?? this.components,
      inlineComponents: inlineComponents ?? this.inlineComponents,
    );
  }

  SelectableText getRich(TextSpan span) {
    return SelectableText.rich(
      span,
      textDirection: textDirection,
      textScaler: textScaler,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  bool isSame(GptMarkdownConfig other) {
    return style == other.style &&
        textAlign == other.textAlign &&
        textScaler == other.textScaler &&
        maxLines == other.maxLines &&
        overflow == other.overflow &&
        followLinkColor == other.followLinkColor &&
        textDirection == other.textDirection;
  }
}
