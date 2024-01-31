import 'package:flutter/material.dart';


class TCMTheme {

  const TCMTheme({
    required this.id,
    this.themeDataGetter,
    this.themeData,
  });

  /// Unique id used to the set with [TCMThemeProvider.setTheme].
  final int id;

  /// Function returning the [ThemeData].
  /// This is a function so hot reloading updates the theme.
  final TCMThemeData Function()? themeDataGetter;

  /// ThemeData of this theme. To use only if [themeDataGetter] causes performance issues.
  final TCMThemeData? themeData;

  TCMThemeData get theme => themeData ?? themeDataGetter!();
}

class TCMThemeProvider extends ChangeNotifier {

  static final instance = TCMThemeProvider();
  static final List<TCMTheme> _themes = [];
  static late int _currentThemeId;

  /// Returns the currently selected theme's ThemeData.
  static TCMThemeData get currentThemeDataStatic => getThemeById(_currentThemeId)!.theme;
  static int get currentThemeId => _currentThemeId;
  TCMThemeData get currentThemeData => currentThemeDataStatic;

  /// Sets the current theme according to the provided [id] and notifies listeners.
  static void setTheme(int id) {
    if(getThemeById(id) == null) throw Exception('A theme of id $id does not exist !');
    _currentThemeId = id;
    instance.notifyListeners();
  }

  /// Iterates to the next theme in the list and notifies listeners.
  /// Returns the current theme's id.
  static int toggleTheme() {
    int index = _themes.indexOf(getThemeById(_currentThemeId)!);
    if(index < _themes.length-1) setTheme(_themes[index+1].id);
    else setTheme(_themes.first.id);
    return _currentThemeId;
  }

  /// Adds [theme] to the list of available themes.
  static void registerTheme(TCMTheme theme) {
    _themes.removeWhere((t) => t.id == theme.id);
    _themes.add(theme);
  }

  /// Return the TCMTheme of id [id].
  /// Returns null if the [id] in not in themes list.
  static TCMTheme? getThemeById(int id) {
    try {
      return _themes.firstWhere((t) => t.id == id,);
    } catch (e) {
      return null;
    }
  }

  /// Act like the theme was changed even if it wasn't.
  static void refresh() => instance.notifyListeners();

}

extension TextThemeUtilities on TextTheme {
  static const TextStyle bold = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle italic = TextStyle(fontStyle: FontStyle.italic);
  static const TextStyle green = TextStyle(color: Colors.green);
  static const TextStyle red = TextStyle(color: Colors.red);
  static const TextStyle orange = TextStyle(color: Colors.orange);
  static const TextStyle white = TextStyle(color: Colors.white);
  static const TextStyle blue = TextStyle(color: Colors.blue);
  static const TextStyle grey = TextStyle(color: Colors.grey);
}

extension TextStyleUtilities on TextStyle {

  /// Allows chaining styles like bodyText1.copyWithStyle(theme.bold).copyWithStyle(theme.italic)
  TextStyle copyWithStyle(TextStyle style) {
    return copyWith(
      inherit: style.inherit,
      color: style.color,
      backgroundColor: style.backgroundColor,
      fontFamily: style.fontFamily,
      fontFamilyFallback: style.fontFamilyFallback,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      letterSpacing: style.letterSpacing,
      wordSpacing: style.wordSpacing,
      textBaseline: style.textBaseline,
      height: style.height,
      leadingDistribution: style.leadingDistribution,
      locale: style.locale,
      foreground: style.foreground,
      background: style.background,
      shadows: style.shadows,
      fontFeatures: style.fontFeatures,
      decoration: style.decoration,
      decorationColor: style.decorationColor,
      decorationStyle: style.decorationStyle,
      decorationThickness: style.decorationThickness,
      debugLabel: style.debugLabel,
      overflow: style.overflow,
    );
  }

  TextStyle get normal => copyWith(fontWeight: FontWeight.normal);
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get green => copyWith(color: Colors.green);
  TextStyle get red => copyWith(color: Colors.red);
  TextStyle get orange => copyWith(color: Colors.orange);
  TextStyle get white => copyWith(color: Colors.white);
  TextStyle get black => copyWith(color: Colors.black);
  TextStyle get blue => copyWith(color: Colors.blue);
  TextStyle get grey => copyWith(color: Colors.grey);
}

class TCMThemeData {

  TCMThemeData({
    required this.themeData,
    this.barrierColor,
  });

  final ThemeData themeData;
  final Color? barrierColor;

  static MaterialColor getMaterialColor(Color color) => MaterialColor(color.value, {
    50: color.withOpacity(.1),
    100: color.withOpacity(.2),
    200: color.withOpacity(.3),
    300: color.withOpacity(.4),
    400: color.withOpacity(.5),
    500: color.withOpacity(.6),
    600: color.withOpacity(.7),
    700: color.withOpacity(.8),
    800: color.withOpacity(.9),
    900: color.withOpacity(1),
  });
}
