import 'package:flutter/material.dart';

class GptMarkdownThemeData extends ThemeExtension<GptMarkdownThemeData> {
  GptMarkdownThemeData._({
    required this.highlightColor,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.h6,
    required this.hrLineThickness,
    required this.hrLineColor,
    required this.linkColor,
    required this.linkHoverColor,
  });

  factory GptMarkdownThemeData({
    required Brightness brightness,
    Color? highlightColor,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? h5,
    TextStyle? h6,
    double? hrLineThickness,
    Color? hrLineColor,
    Color? linkColor,
    Color? linkHoverColor,
  }) {
    ThemeData themeData = switch (brightness) {
      Brightness.light => ThemeData.light(),
      Brightness.dark => ThemeData.dark(),
    };
    final typography = Typography.tall2021.copyWith(
      displayLarge: Typography.tall2021.displayLarge?.copyWith(inherit: true),
      displayMedium: Typography.tall2021.displayMedium?.copyWith(inherit: true),
      displaySmall: Typography.tall2021.displaySmall?.copyWith(inherit: true),
      headlineLarge: Typography.tall2021.headlineLarge?.copyWith(inherit: true),
      headlineMedium: Typography.tall2021.headlineMedium?.copyWith(
        inherit: true,
      ),
      headlineSmall: Typography.tall2021.headlineSmall?.copyWith(inherit: true),
      titleLarge: Typography.tall2021.titleLarge?.copyWith(inherit: true),
      titleMedium: Typography.tall2021.titleMedium?.copyWith(inherit: true),
      titleSmall: Typography.tall2021.titleSmall?.copyWith(inherit: true),
      bodyLarge: Typography.tall2021.bodyLarge?.copyWith(inherit: true),
      bodyMedium: Typography.tall2021.bodyMedium?.copyWith(inherit: true),
      bodySmall: Typography.tall2021.bodySmall?.copyWith(inherit: true),
      labelLarge: Typography.tall2021.labelLarge?.copyWith(inherit: true),
      labelMedium: Typography.tall2021.labelMedium?.copyWith(inherit: true),
      labelSmall: Typography.tall2021.labelSmall?.copyWith(inherit: true),
    );
    themeData = themeData.copyWith(textTheme: typography);
    TextTheme textTheme = themeData.textTheme;
    return GptMarkdownThemeData._fromTheme(themeData, textTheme).copyWith(
      highlightColor: highlightColor,
      h1: h1,
      h2: h2,
      h3: h3,
      h4: h4,
      h5: h5,
      h6: h6,
      hrLineThickness: hrLineThickness,
      hrLineColor: hrLineColor,
      linkColor: linkColor,
      linkHoverColor: linkHoverColor,
    );
  }

  factory GptMarkdownThemeData._fromTheme(
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return GptMarkdownThemeData._(
      highlightColor: theme.colorScheme.onSurfaceVariant.withAlpha(50),
      h1: textTheme.headlineLarge,
      h2: textTheme.headlineMedium,
      h3: textTheme.headlineSmall,
      h4: textTheme.titleLarge,
      h5: textTheme.titleMedium,
      h6: textTheme.titleSmall,
      hrLineThickness: 1,
      hrLineColor: theme.colorScheme.outline,
      linkColor: Colors.blue,
      linkHoverColor: Colors.red,
    );
  }

  Color highlightColor;

  TextStyle? h1;
  TextStyle? h2;
  TextStyle? h3;
  TextStyle? h4;
  TextStyle? h5;
  TextStyle? h6;

  double hrLineThickness;

  Color hrLineColor;
  Color linkColor;
  Color linkHoverColor;

  @override
  GptMarkdownThemeData copyWith({
    Color? highlightColor,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? h5,
    TextStyle? h6,
    double? hrLineThickness,
    Color? hrLineColor,
    Color? linkColor,
    Color? linkHoverColor,
  }) {
    return GptMarkdownThemeData._(
      highlightColor: highlightColor ?? this.highlightColor,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      h5: h5 ?? this.h5,
      h6: h6 ?? this.h6,
      hrLineThickness: hrLineThickness ?? this.hrLineThickness,
      hrLineColor: hrLineColor ?? this.hrLineColor,
      linkColor: linkColor ?? this.linkColor,
      linkHoverColor: linkHoverColor ?? this.linkHoverColor,
    );
  }

  @override
  GptMarkdownThemeData lerp(GptMarkdownThemeData? other, double t) {
    if (other == null) {
      return this;
    }
    return GptMarkdownThemeData._(
      highlightColor:
          Color.lerp(highlightColor, other.highlightColor, t) ?? highlightColor,
      h1: TextStyle.lerp(h1, other.h1, t) ?? h1,
      h2: TextStyle.lerp(h2, other.h2, t) ?? h2,
      h3: TextStyle.lerp(h3, other.h3, t) ?? h3,
      h4: TextStyle.lerp(h4, other.h4, t) ?? h4,
      h5: TextStyle.lerp(h5, other.h5, t) ?? h5,
      h6: TextStyle.lerp(h6, other.h6, t) ?? h6,
      hrLineThickness: Tween(
        begin: hrLineThickness,
        end: other.hrLineThickness,
      ).transform(t),
      hrLineColor: Color.lerp(hrLineColor, other.hrLineColor, t) ?? hrLineColor,
      linkColor: Color.lerp(linkColor, other.linkColor, t) ?? linkColor,
      linkHoverColor:
          Color.lerp(linkHoverColor, other.linkHoverColor, t) ?? linkHoverColor,
    );
  }
}

class GptMarkdownTheme extends InheritedWidget {
  const GptMarkdownTheme({
    super.key,
    required this.gptThemeData,
    required super.child,
  });
  final GptMarkdownThemeData gptThemeData;

  static GptMarkdownThemeData of(BuildContext context) {
    var theme = Theme.of(context);
    final provider = context
        .dependOnInheritedWidgetOfExactType<GptMarkdownTheme>();
    if (provider != null) {
      return provider.gptThemeData;
    }
    final themeData = theme.extension<GptMarkdownThemeData>();
    if (themeData != null) {
      return themeData;
    }
    return GptMarkdownThemeData._fromTheme(theme, theme.textTheme);
  }

  @override
  bool updateShouldNotify(GptMarkdownTheme oldWidget) {
    return gptThemeData != oldWidget.gptThemeData;
  }
}
