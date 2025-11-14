import 'package:flutter/material.dart';

import 'custom_widgets/markdown_config.dart';
import 'markdown_component.dart';
import 'md_widget.dart';

class GptMarkdown extends StatelessWidget {
  final TextDirection textDirection;
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextScaler? textScaler;
  final void Function(String url, String title)? onLinkTap;
  final void Function(String code)? onCodeReplaceTap;
  final String Function(String tex)? latexWorkaround;
  final int? maxLines;

  final TextOverflow? overflow;
  final bool followLinkColor;
  final bool useDollarSignsForLatex;
  final List<MarkdownComponent>? components;
  final List<MarkdownComponent>? inlineComponents;

  const GptMarkdown(
    this.data, {
    super.key,
    this.style,
    this.followLinkColor = false,
    this.textDirection = TextDirection.ltr,
    this.onCodeReplaceTap,
    this.latexWorkaround,
    this.textAlign,
    this.textScaler,
    this.onLinkTap,
    this.maxLines,
    this.overflow,
    this.components,
    this.inlineComponents,
    this.useDollarSignsForLatex = false,
  });

  @override
  Widget build(BuildContext context) {
    String tex = data.trim();
    if (useDollarSignsForLatex) {
      tex = tex.replaceAllMapped(
        RegExp(r"(?<!\\)\$\$(.*?)(?<!\\)\$\$", dotAll: true),
        (match) => "\\[${match[1] ?? ""}\\]",
      );
      if (!tex.contains(r"\(")) {
        tex = tex.replaceAllMapped(
          RegExp(r"(?<!\\)\$(.*?)(?<!\\)\$"),
          (match) => "\\(${match[1] ?? ""}\\)",
        );
        tex = tex.splitMapJoin(
          RegExp(r"\[.*?\]|\(.*?\)"),
          onNonMatch: (p0) {
            return p0.replaceAll("\\\$", "\$");
          },
        );
      }
    }
    return ClipRRect(
      child: MdWidget(
        context,
        tex,
        true,
        config: GptMarkdownConfig(
          textDirection: textDirection,
          style: style,
          onLinkTap: onLinkTap,
          onCodeReplaceTap: onCodeReplaceTap,
          textAlign: textAlign,
          textScaler: textScaler,
          followLinkColor: followLinkColor,
          latexWorkaround: latexWorkaround,
          maxLines: maxLines,
          overflow: overflow,
          components: components,
          inlineComponents: inlineComponents,
        ),
      ),
    );
  }
}
