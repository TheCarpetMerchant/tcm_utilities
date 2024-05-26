import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:tcm_utilities/src/tcm_theme.dart';
import 'package:tcm_utilities/src/tcm_utils.dart';


/// General containing class for diverse widgets allowing a choice.
class TCMOption {

  const TCMOption({
    this.icon,
    this.title = '',
    this.confirmationMessage = '',
    this.value = -1,
  });

  final IconData? icon;

  /// Name of the option.
  final String title;

  /// Used only in [TCMOptionsBottomSheet] and [TCMPopupMenu].
  final String confirmationMessage;

  /// Unique value of this option, returned by the callback.
  final int value;
}

/// A FloatingActionButton with the + icon.
class FloatingAddButton extends StatelessWidget {

  const FloatingAddButton({
    required this.onTap,
    this.label = '',
    this.icon = Icons.add_rounded,
    super.key,
  });

  final void Function() onTap;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if(label.isNotEmpty) return FloatingActionButton.extended(
      onPressed: onTap,
      label: Text(label),
      icon: Icon(icon),
    );

    return FloatingActionButton(
      onPressed: onTap,
      child: Icon(icon),
    );
  }
}

/// A regular Snackbar.
class TCMSnackbar {

  const TCMSnackbar({
    required this.label,
    this.buttonLabel,
    this.buttonCallback,
    this.context,
  });

  final BuildContext? context;

  /// The message displayed by the snackbar.
  final String label;

  /// The text of the Snackbar's button. If null, no button will be shown.
  final String? buttonLabel;

  /// The callback of the Snackbar's button. If null, no button will be shown.
  final void Function()? buttonCallback;

  /// Shows the Snackbar.
  void show([BuildContext? currentContext]) {
    ScaffoldMessenger.of(context ?? currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(context ?? currentContext!).showSnackBar(
      SnackBar(
        content: Text(label),
        action: buttonLabel != null && buttonCallback != null ? SnackBarAction(
          label: buttonLabel!,
          onPressed: buttonCallback!,
        ) : null,
      ),
    );
  }
}

/// An IconButton with the icon check_rounded.
class ValidationIconButton extends StatelessWidget {

  const ValidationIconButton({
    required this.onTap,
    super.key,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.check_rounded,),
    );
  }
}

/// A Slider between two int values.
class IntSlider extends StatelessWidget {

  const IntSlider({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.label = '',
    this.unit = '',
    this.padding = const EdgeInsets.all(8),
    this.showTitle = true,
    super.key,
  });

  /// Title of the Slider.
  final String label;

  /// Minimum range of the Slider.
  final int min;

  /// Maximum range of the Slider.
  final int max;

  /// Current value of the Slider.
  final int value;

  final EdgeInsets padding;

  /// Callback triggered whenever the Slider changes position by user input.
  final void Function(int) onChanged;

  final String unit;

  final bool showTitle;

  String get title => unit.isNotEmpty ? '$label ($value $unit)' : '$label ($value)';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(showTitle) Text(title),
          Row(
            children: [
              Text('$min'),
              Expanded(
                child: Slider(
                  onChanged: (newValue) { if(value != newValue.toInt()) onChanged(newValue.toInt()); },
                  value: value.toDouble(),
                  label: '$value',
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: (max-min)+1,
                ),
              ),
              Text('$max'),
            ],
          ),
        ],
      ),
    );
  }
}

/// A builder Function returning a SizedBox of height 8.
Widget separatorSizedBoxBuilder(_,__) => const SizedBox(height: 8,);

extension MapToDropdown<K> on Map<K,String> {

  /// Creates a list of DropdownMenuItem from this Map with the key as the value.
  List<DropdownMenuItem<K>> get toDropDownItems => entries.toDropDownItems;
}

extension MapEntryToDropdown<K> on Iterable<MapEntry<K,String>> {

  /// Creates a list of DropdownMenuItem from this list of MapEntries with the key as the value.
  List<DropdownMenuItem<K>> get toDropDownItems {
    return map<DropdownMenuItem<K>>((entry) {
      return DropdownMenuItem<K>(
        value: entry.key,
        child: Text(entry.value),
      );
    }).toList();
  }
}

/// A padding widget that positions its child above the device's keyboard.
class AboveKeyboard extends StatelessWidget {

  const AboveKeyboard({
    required this.child,
    this.padding = 8,
    super.key,
  });

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: padding,
        top: padding,
        right: padding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
        ],
      ),
    );
  }
}

/// A DropdownButtonFormField that makes use of the Map.toDropdownItems function.
class SimpleDropDown<K> extends StatelessWidget {

  const SimpleDropDown({
    required this.onChanged,
    required this.value,
    required this.content,
    this.defaultValue,
    this.title = '',
    this.expanded = false,
    this.padding = const EdgeInsets.all(8),
    this.dropdownButtonFormFieldKey,
    super.key,
  });

  /// [value] = text of the item
  final Map<K,String> content;

  /// Title of the dropdown
  final String title;

  /// Value to show in the dropdown. If not present in the [content], defaults to [defaultValue].
  final K? value;

  /// Value to show when [value] isn't present in [content] (usually before loading data)
  final K? defaultValue;

  final EdgeInsets padding;
  final void Function(K) onChanged;
  final bool expanded;
  final GlobalKey<State>? dropdownButtonFormFieldKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: DropdownButtonFormField<K>(
        key: dropdownButtonFormFieldKey,
        decoration: title.isNotEmpty ? InputDecoration(labelText: title) : null,
        isExpanded: expanded,
        value: content.keys.contains(value) ? value : defaultValue,
        onChanged: (val) {
          if(val == null) return;
          onChanged(val);
        },
        items: content.toDropDownItems,
      ),
    );
  }
}

/// A Column with a bunch of added options to simplify code and prevent nesting.
class ScrollableColumn extends StatelessWidget {

  const ScrollableColumn({
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.isLoading = false,
    this.expanded = false,
    this.scrollbar = false,
    this.safeArea = true,
    this.loadingWidget,
    this.emptyWidget,
    this.divider,
    this.scrollable = true,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool isLoading;

  /// Wraps the final widget in a SafeArea.
  final bool safeArea;

  /// Wraps the SingleChildScrollView in a Expanded.
  final bool expanded;

  /// Wrap the SingleChildScrollView in a Scrollbar.
  final bool scrollbar;

  /// Shown if [isLoading] is true.
  final Widget? loadingWidget;

  /// Will be shown if not null, [isLoading] is false and [children] is empty.
  final Widget? emptyWidget;

  /// If not null, this widget will be inserted in between each child.
  final Widget? divider;

  /// If true, the widget is wrapped in a SingleChildScrollView.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {

    final List<Widget> childs = [];
    childs.addAll(children);
    if(divider != null) childs.insertEveryOther(divider!);

    late Widget widget;
    if(isLoading) {
      widget = loadingWidget ??
          loadingWidgetBuilder?.call(context) ??
          const SizedBox.shrink();
    } else {
      if(children.isEmpty && emptyWidget != null) {
        widget = emptyWidget!;
      } else {
        widget = Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: childs,
          ),
        );
        widget = scrollable ? SingleChildScrollView(child: widget,) : widget;
        widget = scrollbar && scrollable ? Scrollbar(child: widget,) : widget;
      }
    }
    widget = expanded ? Expanded(child: widget,) : widget;
    return safeArea ? SafeArea(child: widget,) : widget;
  }

  /// A function that returns a widget shown when isLoading is true.
  /// It will be ignored if [loadingWidget] is provided.
  /// If null and loadingWidget is null, [StandardListView] will return a 0-sized SizedBox when [isLoading] is true.
  static Widget Function(BuildContext)? loadingWidgetBuilder = (_) => const LoadingWidget();
}

/// Useful functions for Stateful Widget, such as loading state handling.
abstract class TCMState<T extends StatefulWidget> extends State<T> {

  /// Stores the state of loading.
  /// The goal is to prevent actions while another is taking place by checking this, notably in [startLoading].
  bool isLoading = false;
  bool get isNotLoading => !isLoading;
  BuildContext? get safeContext => mounted ? context : null;

  /// setState(() {}). If Flutter is currently building, called post-frame.
  void refresh([void Function() fn = _fn]) {
    if(mounted) {
      if(isBuilding) {
        doNextFrame(() {
          if(mounted) {
            setState(fn);
          }
        });
      } else {
        setState(fn);
      }
    }
  }

  void unfocusAndRefresh([void Function() fn = _fn]) {
    unfocus();
    refresh(fn);
  }

  /// Calls [refresh] if [value] is not null or false.
  void refreshIf([dynamic value]) {
    if(value != null && value != false) refresh();
  }

  /// Switches the loading state, or sets its value if [newValue] is not null.
  /// [beforeRefresh] will be called after switching [isLoading], but before calling [refresh]
  /// Refreshes to the new state.
  bool switchLoading([bool? newValue, void Function()? beforeRefresh]) {
    if(newValue != null) isLoading = newValue;
    else isLoading = !isLoading;
    beforeRefresh?.call();
    refresh();
    return isLoading;
  }

  /// Sets [isLoading] to true. Returns false if isLoading was already true (something was already taking place).
  /// Refreshes to the new state.
  bool startLoading([void Function()? beforeSwitch]) {
    if(isLoading) return false;
    switchLoading(true, beforeSwitch);
    return true;
  }

  /// Same as [startLoading], but doesn't call [refresh].
  bool startLoadingSilently() {
    if(isLoading) return false;
    isLoading = true;
    return true;
  }

  /// Sets [isLoading] to false.
  /// Refreshes to the new state.
  void endLoading() => switchLoading(false);

  /// Same as [endLoading], but doesn't call [refresh].
  void endLoadingSilently() {
    isLoading = false;
  }

  /// Calls [endLoading] and toasts [toast].
  void endLoadingAndToast(String toast, {bool cancel = false, bool long = false}) {
    endLoading();
    toastThis(toast, cancel: cancel, long: long);
  }

  /// Requests to unfocus the context. This is to prevent returning to typing in a TextFormField on every setState.
  void unfocus() => FocusScope.of(context).unfocus();

  /// Unfocus the primary focus.
  void unfocusPrimary() => FocusManager.instance.primaryFocus?.unfocus();

  void unfocusAnd(void Function() fn) {
    unfocus();
    fn();
  }

  /// SchedulerBinding.instance.addPostFrameCallback((_) => func());
  void doNextFrame(void Function() fn) => onNextFrame(fn);

  /// Pops the page only if the widget is still mounted.
  void safePop([dynamic value]) => mounted ? Navigator.pop(context, value) : null;

  static void _fn() {}
  static void onNextFrame(void Function() fn) => SchedulerBinding.instance.addPostFrameCallback((_) => fn());
  static void onNextFrameIfBuilding(void Function() fn) {
    if(isBuilding) SchedulerBinding.instance.addPostFrameCallback((_) => fn());
    else fn();
  }

  /// Returns true if Flutter is currently building a frame, or if the first frame hasn't been rendered yet.
  /// In that case, the scheduler phase is still 'idle' despite Flutter running the first build.
  static bool get isBuilding => [
    SchedulerPhase.transientCallbacks,
    SchedulerPhase.midFrameMicrotasks,
    SchedulerPhase.persistentCallbacks,
  ].contains(WidgetsBinding.instance.schedulerPhase)
      || WidgetsBinding.instance.rootElement == null;
}

class LoadIfWidget extends StatelessWidget {

  const LoadIfWidget({
    required this.child,
    required this.isLoading,
    this.loadingWidget,
    super.key,
  });

  final Widget child;
  final Widget? loadingWidget;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if(isLoading) return loadingWidget ?? loadingWidgetBuilder?.call(context) ?? const SizedBox.shrink();
    return child;
  }

  /// A function that returns a widget shown when isLoading is true.
  /// It will be ignored if [loadingWidget] is provided.
  /// If null and loadingWidget is null, [StandardListView] will return a 0-sized SizedBox when [isLoading] is true.
  static Widget Function(BuildContext)? loadingWidgetBuilder = (_) => const LoadingWidget();
}

/// This class allows getting the correct divider color in [children],
/// while keeping the ExpansionTile divider-less by making it transparent.
/// Use this only if Flutter has not yet allowed ExpansionTile to not have those fucking Dividers.
class NotFuckExpansionTile extends StatelessWidget {

  const NotFuckExpansionTile({
    required this.children,
    required this.title,
    this.padding = EdgeInsets.zero,
    this.showDivider = true,
    this.initiallyExpanded = false,
    this.dividerHeight = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  });

  final List<Widget> children;
  final Widget title;
  final EdgeInsets padding;
  final bool showDivider;
  final bool initiallyExpanded;
  final double dividerHeight;

  /// If null, no border will be show around the ExpansionTile.
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = Theme.of(context).dividerColor;
    return Padding(
      padding: padding,
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: borderRadius != null ? RoundedRectangleBorder(
          borderRadius: borderRadius!,
          side: BorderSide(color: dividerColor),
        ) : null,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent,),
          child: ExpansionTile(
            title: title,
            initiallyExpanded: initiallyExpanded,
            children: [
              if(showDivider) Divider(color: dividerColor, height: dividerHeight,),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class StandardListView extends StatelessWidget {

  const StandardListView({
    required this.itemCount,
    required this.itemBuilder,
    this.nothingToShowText,
    this.loadingWidget,
    this.bottomListPadding = 0,
    this.shrinkWrap = true,
    this.isLoading = false,
    this.safeArea = false,
    this.expanded = false,
    this.scrollable = true,
    this.showFloatingActionButtonBottomPadding = false,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  /// Text shown when the list is empty.
  /// If empty, the list is shown.
  /// If null, will default to [defaultNothingToShowText].
  final String? nothingToShowText;
  final int itemCount;
  final bool expanded;
  final bool isLoading;
  final bool shrinkWrap;
  final bool safeArea;
  final bool scrollable;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? loadingWidget;
  final double bottomListPadding;
  final EdgeInsets padding;
  final bool showFloatingActionButtonBottomPadding;

  int get totalItemCount => actualBottomPadding > 0 ? itemCount+1 : itemCount;

  double get actualBottomPadding => showFloatingActionButtonBottomPadding
      ? bottomPaddingForFloatingActionButton+bottomListPadding
      : bottomListPadding;

  @override
  Widget build(BuildContext context) {
    late Widget widget;
    if(isLoading) {
      widget = loadingWidget ??
          loadingWidgetBuilder?.call(context) ??
          const SizedBox.shrink();
    } else {
      widget = Center(child: Text(nothingToShowText ?? defaultNothingToShowText, textAlign: TextAlign.center,),);
      if(itemCount > 0 || (nothingToShowText ?? defaultNothingToShowText).isEmpty)
        widget = ListView.separated(
          shrinkWrap: shrinkWrap,
          physics: scrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
          padding: padding,
          itemCount: totalItemCount,
          itemBuilder: checkBottomPaddingItemBuilder,
          separatorBuilder: separatorSizedBoxBuilder,
        );
    }
    widget = expanded ? Expanded(child: widget,) : widget;
    return safeArea ? SafeArea(child: widget,) : widget;
  }

  Widget checkBottomPaddingItemBuilder(BuildContext context, int index) {
    // Check on [itemCount] because it has 3 for a list of 3 items, but we're going to get 0..2.
    if(actualBottomPadding > 0 && index == itemCount) return SizedBox(height: actualBottomPadding,);
    return itemBuilder(context, index);
  }

  static String defaultNothingToShowText = 'Nothing to show !';

  /// A function that returns a widget shown when isLoading is true.
  /// It will be ignored if [loadingWidget] is provided.
  /// If null and loadingWidget is null, [StandardListView] will return a 0-sized SizedBox when [isLoading] is true.
  static Widget Function(BuildContext)? loadingWidgetBuilder = (_) => const LoadingWidget();

  /// Shorthand for [bottomListPadding] when a [FloatingActionButton] is used and we don't want
  /// the content of the ListView to be obscured by it.
  static const double bottomPaddingForFloatingActionButton = 70;
}

class CenteredText extends StatelessWidget {

  const CenteredText(this.text, {
    this.style,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final TextStyle? style;
  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// List of rich texts, used to useless prevent nesting.
class RichTextList extends StatelessWidget {

  const RichTextList({
    required this.texts,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final List<TextSpan> texts;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: texts,),
      textAlign: textAlign,
    );
  }
}

/// A TextField with a clear_rounded suffix icon to clear the field.
class SearchTextField extends StatelessWidget {

  const SearchTextField({
    required this.controller,
    required this.title,
    this.titleAlwaysFloating = true,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  final TextEditingController controller;
  final String title;
  final EdgeInsets padding;
  final bool titleAlwaysFloating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          floatingLabelBehavior: titleAlwaysFloating ? FloatingLabelBehavior.always : null,
          suffixIcon: IconButton(
            onPressed: () => controller.text = '',
            icon: const Icon(Icons.clear_rounded,),
          ),
        ),
      ),
    );
  }
}

class EasyCheckboxListTile extends StatelessWidget {

  const EasyCheckboxListTile({
    required this.value,
    required this.title,
    required this.onChanged,
    this.controlAffinity = ListTileControlAffinity.leading,
    super.key,
  });

  final bool value;
  final String title;
  final ListTileControlAffinity controlAffinity;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
      controlAffinity: controlAffinity,
      title: Text(title),
    );
  }
}

/// A simple CircularProgressIndicator that can easily be positionned in [ScrollableColumn].
class LoadingWidget extends StatelessWidget {

  const LoadingWidget({
    this.expanded = false,
    super.key,
  });

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    Widget res = const Center(
      child: CircularProgressIndicator(),
    );
    if(expanded) res = Expanded(child: res);
    return res;
  }
}

class TCMAppBar extends StatelessWidget implements PreferredSizeWidget {

  const TCMAppBar({
    this.title = '',
    this.actions = const [],
    this.options = const [],
    this.onOptionSelected,
    this.onValidate,
    this.leading,
    this.bottom,
    Key? key,
  }) : super(key: key);

  /// Title of the AppBar.
  final String title;

  /// Icons to show on the right side of the AppBar.
  final List<Widget> actions;

  /// Options available in the Dropdown menu of the AppBar (three white dots).
  /// If empty, no menu icon will be shown.
  final List<TCMOption> options;

  /// Callback when one of the [options] are selected.
  /// If empty, no menu icon will be shown.
  final void Function(int)? onOptionSelected;

  /// If provided, a check_rounded Icon will be added to the [actions].
  final void Function()? onValidate;

  /// Appbar.bottom.
  final PreferredSizeWidget? bottom;

  /// Appbar.leading.
  final Widget? leading;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(title),
      bottom: bottom,
      actions: [

        // Bouton de validation standard
        if(onValidate != null) ValidationIconButton(onTap: onValidate!),

        // Actions bonus passées
        ...actions,

        // More options ...
        if(onOptionSelected != null && options.isNotEmpty) TCMPopupMenu(
          options: options,
          onTap: (option) => onOptionSelected?.call(option),
        ),
      ],
    );
  }
}

class TCMPopupMenu extends StatelessWidget {

  const TCMPopupMenu({
    required this.options,
    required this.onTap,
    super.key,
  });

  final List<TCMOption> options;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (option) async {
        final tcmOption = options.firstWhereOrNull((e) => e.value == option);
        if(tcmOption == null) return;
        if(tcmOption.confirmationMessage.isEmpty || await TCMDialog.showConfirmation(context,tcmOption.confirmationMessage)) {
          onTap(tcmOption.value);
        }
      },
      itemBuilder: (_) => [
        for(final option in options)
          PopupMenuItem<int>(
            value: option.value,
            child: Row(
              children: [
                if(option.icon != null) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(option.icon),
                ),
                Expanded(
                  child: Text(option.title),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class TCMOptionsBottomSheet {

  const TCMOptionsBottomSheet({
    required this.options,
    this.context,
    this.title,
    this.barrierColor,
  });

  final BuildContext? context;
  final Color? barrierColor;
  final List<TCMOption> options;
  final Widget? title;

  Future<int?> show([BuildContext? currentContext]) {
    currentContext ??= context;
    return showCustomBottomSheet<int>(
      context: currentContext!,
      barrierColor: barrierColor ?? TCMThemeProvider.currentThemeDataStatic.barrierColor,
      child: ScrollableColumn(
        padding: EdgeInsets.zero,
        children: [
          if(title != null) title!,
          for(final option in options)
            ListTile(
              leading: option.icon != null ? Icon(option.icon) : null,
              title: Text(option.title),
              onTap: () async {
                if(option.confirmationMessage.isEmpty || await TCMDialog.showConfirmation(currentContext!,option.confirmationMessage)) {
                  Navigator.pop(currentContext!, option.value);
                }
              },
            ),
        ],
      ),
    );
  }
}

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  double maxWidthConstraintsPadding = 8,
  double radius = 8,
  bool isScrollControlled = false,
  bool aboveKeyboard = false,
  Color? barrierColor,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    scrollControlDisabledMaxHeightRatio: 1,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width-(maxWidthConstraintsPadding*2), // Padding of 8 on both sides
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(radius),
      ),
    ),
    barrierColor: barrierColor,
    builder: (context) => aboveKeyboard ? AboveKeyboard(child: child) : child,
  );
}

class TCMDialog {

  const TCMDialog({
    required this.child,
    this.context,
    this.barrierColor,
    this.barrierDismissible = true,
  });

  final BuildContext? context;
  final Widget child;
  final bool barrierDismissible;
  final Color? barrierColor;

  Future<T?> show<T>([BuildContext? currentContext]) async {
    return showDialog<T>(
      context: context ?? currentContext!,
      builder: (_) => child,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? TCMThemeProvider.currentThemeDataStatic.barrierColor,
    );
  }

  static Future<void> showInfoBox(BuildContext context, String message) async => TCMDialog(
    context: context,
    child: AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 24),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  ).show();

  static Future<bool> showConfirmation(BuildContext context, String message) async {
    return await TCMDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Confirmation'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ).show<bool?>() ?? false;
  }

  static Future<bool> showRefusal(BuildContext context, String message,) async => !(await showConfirmation(context, message));
}

class TextInputBottomSheet {

  TextInputBottomSheet({
    this.context,
    this.title = '',
    this.initialValue = '',
  });

  final BuildContext? context;
  final String title;
  final String initialValue;

  Future<String> show([BuildContext? currentContext]) async {
    TextEditingController controller = TextEditingController();
    controller.text = initialValue;
    bool? res = await showCustomBottomSheet<bool>(
      context: context ?? currentContext!,
      aboveKeyboard: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 8, left: 8, right: 8),
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: title),
          onSubmitted: (_) => Navigator.pop(context ?? currentContext!, true),
        ),
      ),
    );
    if(!(res ?? false)) return '';
    return controller.text;
  }
}

class NumbersTextField extends StatelessWidget {

  const NumbersTextField({
    required this.controller,
    this.title = '',
    this.intrinsicWidth = false,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  final TextEditingController controller;
  final String title;
  final bool intrinsicWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Widget widget = Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: title),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
    return intrinsicWidth ? IntrinsicWidth(child: widget,) : widget;
  }
}

/// OutlinedButton.icon but it respects IconTheme.
class OutlinedIconButton extends StatelessWidget {

  const OutlinedIconButton({
    required this.icon,
    required this.onTap,
    this.label = '',
    this.buttonStyle,
    this.iconColor,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color? iconColor;
  final ButtonStyle? buttonStyle;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: iconColor ?? IconTheme.of(context).color,
      ),
      style: buttonStyle,
      label: Text(label,),
    );
  }
}

class RadioList<T> extends StatelessWidget {

  const RadioList({
    required this.onChanged,
    required this.value,
    required this.options,
    this.wrapper = RadioWrapper.Column,
    super.key,
  });

  /// Called
  final void Function(T?)? onChanged;

  /// Current value to show.
  final T value;

  final Map<T, String> options;

  /// If false, will be a row.
  final RadioWrapper wrapper;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      for(final option in options.entries)
        RadioListTile<T>(
          value: option.key,
          groupValue: value,
          onChanged: onChanged,
          title: Text(option.value),
        ),
    ];

    // Wrap the tiles to their content size
    if(wrapper.needsWrapping) {
      for(int i = 0; i < children.length; i++) {
        children[i] = IntrinsicWidth(child: children[i],);
      }
    }

    switch(wrapper) {
      case RadioWrapper.Wrap: return Wrap(children: children,);
      case RadioWrapper.Column: return Column(children: children,);
      case RadioWrapper.Row: return Row(children: children,);
    }
  }
}

enum RadioWrapper {
  Wrap,
  Column,
  Row;

  const RadioWrapper();

  bool get needsWrapping => this == Row || this == Wrap;
}

class TCMImage extends StatelessWidget {
  const TCMImage({
    required this.url,
    this.obfuscateErrors = true,
    this.width,
    this.height,
    super.key,
  });

  final bool obfuscateErrors;
  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      errorBuilder: obfuscateErrors
          ? (_,__,___) => const Icon(Icons.image_not_supported_rounded)
          : null,
    );
  }
}

class DateTextField extends StatelessWidget {

  const DateTextField({
    required this.date,
    required this.title,
    required this.onTap,
    this.onTapClear,
    super.key,
  });

  final DateTime? date;
  final String title;
  final void Function() onTap;
  final void Function()? onTapClear;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          controller: TextEditingController(text: date?.formatDate ?? 'No Date'),
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            labelText: title,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: onTapClear != null ? IconButton(
              onPressed: onTapClear,
              icon: const Icon(Icons.clear,),
            ) : null,
          ),
        ),
      ),
    );
  }
}

class TCMScaffold extends StatefulWidget {

  const TCMScaffold({
    this.appBar,
    this.body,
    this.drawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.doubleTapExit = false,
    this.onWillPop,
    this.onAdd,
    super.key,
  });

  final Widget? floatingActionButton;
  final Widget? body;
  final Widget? drawer;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool doubleTapExit;
  final Future<bool> Function()? onWillPop;
  final void Function()? onAdd;

  @override
  State<TCMScaffold> createState() => _TCMScaffoldState();
}

class _TCMScaffoldState extends State<TCMScaffold> {
  DateTime backButtonPressTime = DateTime.now();
  bool tapedOnce = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget scaffold = Scaffold(
      key: _scaffoldKey,
      appBar: widget.appBar,
      body: widget.body,
      drawer: widget.drawer,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.onAdd != null ? FloatingActionButton(
        onPressed: widget.onAdd,
        child: const Icon(Icons.add_rounded),
      ) : widget.floatingActionButton,
    );
    if(widget.onWillPop != null) return WillPopScope(onWillPop: widget.onWillPop, child: scaffold,);
    if(widget.doubleTapExit) return WillPopScope(
      onWillPop: () async {

        // Allow closing the drawer
        if((_scaffoldKey.currentState?.isDrawerOpen ?? false) || (_scaffoldKey.currentState?.isEndDrawerOpen ?? false)) return true;

        // User might tap directely after having opened the page because he fumbled.
        // Otherwise and if 2 seconds have elapsed, we can close.
        if(tapedOnce && backButtonPressTime.difference(DateTime.now()).inSeconds.abs() < 2) return true;

        toastThis('Tap twice to close the app');
        backButtonPressTime = DateTime.now();
        tapedOnce = true;
        return false;

      },
      child: scaffold,
    );
    return scaffold;
  }
}

class TextWithLink extends StatelessWidget {

  const TextWithLink({
    required this.text,
    this.onClick,
    this.onUrlClick,
    this.style,
    this.centered = false,
    super.key,
  });

  final String text;
  final void Function(String)? onClick;
  final void Function(String)? onUrlClick;
  final bool centered;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final normalStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final underlinedStyle = normalStyle?.copyWith(decoration: TextDecoration.underline, color: Colors.blue);
    final texts = splittedText();
    return RichText(
      textAlign: centered ? TextAlign.center : TextAlign.start,
      text: TextSpan(
        children: <InlineSpan>[
          for (final portion in texts)
            TextSpan(
              text: portion.$1,
              style: portion.$3 ? underlinedStyle : normalStyle,
              recognizer: portion.$3 ? (TapGestureRecognizer()..onTap = () => onTap(portion)) : null,
            ),
        ],
      ),
    );
  }

  void onTap((String, String, bool) portion) {
    if(portion.$2.isNotEmpty) {
      if(onUrlClick != null) onUrlClick?.call(portion.$2);
      else onClick?.call(portion.$2);
    } else {
      onClick?.call(portion.$1);
    }
  }

  List<(String, String, bool)> splittedText() {
    List<(String, String, bool)> res = [];
    int currentTextIndex = 0;
    int startIndex = text.indexOf('{{');
    while(startIndex >= 0) {
      // Add the normal until then text
      res.add((text.substring(currentTextIndex, startIndex), '', false));

      // Find out if our special text has an url attached
      int endIndex = text.indexOf('}}', startIndex);
      int restartAt = endIndex;
      if(text.length > endIndex+2 && text[endIndex+2] == '[') {
        restartAt = text.indexOf(']', endIndex+3);
        final url = text.substring(endIndex+3, restartAt);
        res.add((text.substring(startIndex+2, endIndex), url, true));
        currentTextIndex = restartAt+1;
      } else {
        res.add((text.substring(startIndex+2, endIndex), '', true));
        currentTextIndex = restartAt+2;
      }

      if(currentTextIndex > text.length) break;
      startIndex = text.indexOf('{{', currentTextIndex);
    }

    // Add last bit of text if needed
    if(currentTextIndex < text.length) res.add((text.substring(currentTextIndex), '', false));
    return res;
  }
}

class DateRangeWithEdit extends StatelessWidget {
  const DateRangeWithEdit({
    required this.onDateChanged,
    this.start,
    this.end,
    this.maxRangeInDays,
    this.minDate,
    this.maxDate,
    super.key,
  });

  final DateTime? start;
  final DateTime? end;
  final void Function(DateTime?, DateTime?) onDateChanged;
  final DateTime? minDate;
  final DateTime? maxDate;
  final int? maxRangeInDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DateTextField(
          date: start,
          title: 'Start',
          onTap: () => editDateOfRange(context, true),
        ),
        DateTextField(
          date: end,
          title: 'End',
          onTap: () => editDateOfRange(context, false),
        ),
      ],
    );
  }

  void editDateOfRange(BuildContext context, bool isStart) {
    TCMDialog(
      context: context,
      child: Dialog(
        child: SizedBox(
          height: MediaQuery.of(context).size.width*0.6,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (value) => onDateTimeChanged(isStart, value),
            initialDateTime: isStart ? start : end,
            minimumDate: minDate,
            maximumDate: maxDate,
          ),
        ),
      ),
    ).show<void>();
  }

  // Change the date and adapt the other end of the range accordingly
  void onDateTimeChanged(bool isStart, DateTime value) {
    DateTime? startEdit = start;
    DateTime? endEdit = end;
    if(isStart) {
      startEdit = value;
      if(endEdit != null) {
        if(startEdit.isAfter(end!)) {
          endEdit = startEdit;
        }
        if(maxRangeInDays != null) {
          if(startEdit.difference(endEdit).inDays.abs() > maxRangeInDays!) {
            endEdit = startEdit.add(Duration(days: maxRangeInDays!-1));
          }
        }
      }
    } else {
      endEdit = value;
      if(startEdit != null) {
        if(endEdit.isBefore(startEdit)) {
          startEdit = endEdit;
        }
        if(maxRangeInDays != null) {
          if(startEdit.difference(endEdit).inDays.abs() > maxRangeInDays!) {
            startEdit = endEdit.subtract(Duration(days: maxRangeInDays!-1));
          }
        }
      }
    }
    onDateChanged(startEdit, endEdit);
  }
}

class UnretardedGridView extends StatelessWidget {
  const UnretardedGridView({
    required this.children,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.crossAxisCount,
    super.key,
  });

  final List<Widget> children;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for(int i = 0; i < (children.length/crossAxisCount); i++)
          Padding(
            padding: (i+1 >= (children.length/crossAxisCount)) ? EdgeInsets.zero : EdgeInsets.only(bottom: mainAxisSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                for(int j = 0; j < crossAxisCount; j++)
                  Padding(
                    padding: (j+1 >= crossAxisCount) ? EdgeInsets.zero : EdgeInsets.only(right: crossAxisSpacing),
                    child: children[i*crossAxisCount + j],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}


void toastThis(String value, {bool cancel = false, bool long = false}) {
  if(cancel) cancelToast();
  Fluttertoast.showToast(
    msg: value,
    toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: const Color(0xDD555555),
    textColor: Colors.white,
    fontSize: 14,
  );
}

void cancelToast() => Fluttertoast.cancel();

extension NavigatorEnum on BuildContext {
  /// [routeName] gets cast to a string. So you can use an enum and cast it back on the other side.
  Future<T?> goTo<T extends Object?>(dynamic routeName, [Object? argument]) {
    return Navigator.of(this).pushNamed<T>(routeName.toString(), arguments: argument);
  }
  /// See [goTo].
  Future<T?> goToReplacement<T extends Object?, TO extends Object?>(dynamic routeName, [Object? argument]) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(routeName.toString(), arguments: argument);
  }
}

class SliverPersistentFloatingHeader extends SliverPersistentHeaderDelegate {

  SliverPersistentFloatingHeader({
    required this.child,
    required this.size,
  });

  final Widget child;
  final double size;

  @override
  double get minExtent => size;

  @override
  double get maxExtent => size;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(SliverPersistentFloatingHeader oldDelegate) {
    return true;
  }
}
