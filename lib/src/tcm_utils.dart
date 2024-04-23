import 'dart:convert';

import 'package:intl/intl.dart';


T deepCopy<T>(T value, T Function(Map<String, dynamic> json) fromJson) =>
    fromJson(json.decode(json.encode(value)) as Map<String, dynamic>);

// UNTESTED WITH TYPE ANNOTATIONS
List<T> deepCopyList<T>(List<T> values, T Function(Map<String, dynamic> jsonObj) fromJson) =>
    List<T>.from((json.decode(json.encode(values)) as List<dynamic>).map<T>((model)=> fromJson(model as Map<String, dynamic>)));

List<T> deserializeList<T>(String? jsonString, T Function(Map<String, dynamic> json) fromJson) {
  if ((jsonString ?? '').isEmpty) return [];
  try {
    return List<T>.from((json.decode(jsonString!) as List<dynamic>)
        .map<T>((model) => fromJson(model as Map<String, dynamic>)),);
  } catch(_) {}
  return [];
}

T? deserialize<T>(String? jsonString, T Function(Map<String, dynamic> json) fromJson) {
  if ((jsonString ?? '').isEmpty) return null;
  try {
    return fromJson(json.decode(jsonString!) as Map<String, dynamic>);
  } catch(_) {}
  return null;
}

Future<void> wait(int milliseconds) async => Future<void>.delayed(Duration(milliseconds: milliseconds));

/// Simple class to share a value to children widgets who might modify it.
class SimpleController<T> {
  SimpleController(this.value);
  T value;
}

extension DateTimeUtilities on DateTime {

  static String dateFormat = 'dd/MM/yyyy';

  int get week {
    // Get the first day of this week, and the first day of the first week of the year. The number of times I can fit 7 in between is our week number.
    DateTime thisDt = DateTime(year, month, day);
    DateTime yearStart = DateTime(year);
    while(thisDt.weekday > 1) thisDt = thisDt.subtract(const Duration(days: 1));
    while(yearStart.weekday > 1) yearStart = yearStart.subtract(const Duration(days: 1));
    Duration dur = thisDt.difference(yearStart);
    if(dur.inHours == 0) return 1;
    return ((dur.inHours/24).round()/7).floor();
  }

  DateTime copyWith({int? newYear, int? newMonth, int? newDay, int? newHour, int? newMinute, int? newSecond, int? newMillisecond, int? newMicrosecond}) {
    return DateTime(newYear ?? year, newMonth ?? month, newDay ?? day, newHour ?? hour, newMinute ?? minute, newSecond ?? second, newMillisecond ?? millisecond, newMicrosecond ?? microsecond);
  }

  DateTime copyWithDate(DateTime date) => copyWith(newYear: date.year, newMonth: date.month, newDay: date.day);
  DateTime copyWithHour(DateTime date) => copyWith(newHour: date.hour, newMinute: date.minute, newSecond: date.second, newMillisecond: date.millisecond, newMicrosecond: date.microsecond);

  String format({String? pattern}) => isValid ? DateFormat(pattern ?? dateFormat).format(this) : '';

  bool get isValid => year > 0;
  bool get isNotValid => !isValid;
  bool get isToday => isSameDateAs(DateTime.now());
  bool get isTodayOrBefore => isToday || isBefore(DateTime.now());
  bool get isTodayOrAfter => isToday || isAfter(DateTime.now());
  String get formatHour => isValid ? '$hourPadded:$minutePadded' : '';
  String get formatDate => format();
  String get formatDateHour => isValid ? '$formatDate $formatHour' : '';
  String get hourPadded => hour > 9 ? '$hour' : '0$hour';
  String get minutePadded => minute > 9 ? '$minute' : '0$minute';
  String get secondPadded => second > 9 ? '$second' : '0$second';

  DateTime get firstDayOfWeek => subtract(Duration(days: weekday - 1));
  DateTime get lastDayOfWeek => add(Duration(days: DateTime.daysPerWeek - weekday));
  DateTime get firstDayOfMonth => DateTime(year, month);
  DateTime get lastDayOfMonth => addMonth().subtract(const Duration(days: 1));
  DateTime get firstDayOfYear => DateTime(year);
  DateTime get lastDayOfYear => DateTime(year,12,31);

  DateTime get onlyDate => copyWith(newHour: 0, newMinute: 0, newSecond: 0, newMillisecond: 0, newMicrosecond: 0);
  DateTime get onlyHour => copyWith(newDay: 1, newMonth: 1, newYear: 0);

  int get secondsSinceEpoch => millisecondsSinceEpoch~/1000;

  DateTime get toClosestQuarter => copyWith(newMinute: roundToClosestQuarter(minute), newSecond: 0, newMillisecond: 0, newMicrosecond: 0);
  DateTime get toAboveQuarter => copyWith(newMinute: roundToAboveQuarter(minute), newSecond: 0, newMillisecond: 0, newMicrosecond: 0);
  DateTime get toBelowQuarter => copyWith(newMinute: roundToBelowQuarter(minute), newSecond: 0, newMillisecond: 0, newMicrosecond: 0);
  DateTime get toLastMicrosecondOfDay => copyWith(newHour: 23, newMinute: 59, newSecond: 59, newMillisecond: 999, newMicrosecond: 999);

  bool isDateBefore(DateTime other) => onlyDate.isBefore(other.onlyDate);
  bool isDateAfter(DateTime other) => onlyDate.isAfter(other.onlyDate);
  bool isHourBefore(DateTime other) => onlyHour.isBefore(other.onlyHour);
  bool isHourAfter(DateTime other) => onlyHour.isAfter(other.onlyHour);

  bool isSameDateOrBefore(DateTime other) => isSameDateAs(other) || onlyDate.isBefore(other.onlyDate);
  bool isSameDateOrAfter(DateTime other) => isSameDateAs(other) || onlyDate.isAfter(other.onlyDate);
  bool isSameMomentOrBefore(DateTime other) => isAtSameMomentAs(other) || isBefore(other);
  bool isSameMomentOrAfter(DateTime other) => isAtSameMomentAs(other) || isAfter(other);
  bool isSameDateAs(DateTime other) => day == other.day && month == other.month && year == other.year;
  bool isBetween(DateTime before, DateTime after) => isSameMomentOrAfter(before) && isSameMomentOrBefore(after);
  DateTime addDay([int days = 1]) => add(Duration(days: days));
  DateTime addWeek([int weeks = 1]) => add(Duration(days: 7*weeks));
  DateTime addMonth([int months = 1]) => months >= 1
      ? copyWith(newYear: year+((month+months)~/12), newMonth: (month+months)%12)
      : copyWith(
    newYear: year-(month > (months*-1) ? 0 : (((month+months)~/12)*-1)+1),
    newMonth: month > ((months*-1)%12) ? month-((months*-1)%12) : (month-((months*-1)%12))+12,
  );
  DateTime addYear([int years = 1]) => copyWith(newYear: year+years);

  DateTime downToWeekday(int weekday) {
    DateTime other = copyWith();
    while(other.weekday != weekday) other = other.subtract(const Duration(days: 1));
    return other;
  }

  DateTime upToWeekday(int weekday) {
    return downToWeekday(weekday).add(const Duration(days: 6));
  }

  Iterable<DateTime> iterateDayTo(DateTime other) sync* {
    DateTime currentDate = copyWith();
    while(currentDate.isSameDateOrBefore(other)) {
      yield currentDate;
      currentDate = currentDate.addDay();
    }
  }
  Iterable<DateTime> iterateWeekTo(DateTime other) sync* {
    DateTime currentDate = downToWeekday(1);
    other = other.downToWeekday(1);
    while(currentDate.isSameDateOrBefore(other)) {
      yield currentDate;
      currentDate = currentDate.addWeek();
    }
  }
  Iterable<DateTime> iterateMonthTo(DateTime other) sync* {
    DateTime currentDate = firstDayOfMonth;
    while(currentDate.isSameDateOrBefore(other.firstDayOfMonth)) {
      yield currentDate;
      currentDate = currentDate.addMonth();
    }
  }
  Iterable<DateTime> iterateYearTo(DateTime other) sync* {
    DateTime currentDate = firstDayOfYear;
    while(currentDate.isSameDateOrBefore(other.firstDayOfYear)) {
      yield currentDate;
      currentDate = currentDate.addYear();
    }
  }

  static int roundToClosestQuarter(int minute) => minute - (minute % 15) + ((minute % 15) > 7 ? 15 : 0);
  static int roundToAboveQuarter(int minute) => (minute % 15) > 0 ? minute + (15-(minute % 15)) : minute;
  static int roundToBelowQuarter(int minute) => minute - (minute % 15);

  static DateTime nowWith({int? year, int? month, int? day, int? hour, int? minute, int? second, int? millisecond, int? microsecond}) {
    DateTime leNow = DateTime.now();
    return DateTime(year ?? leNow.year, month ?? leNow.month, day ?? leNow.day, hour ?? leNow.hour, minute ?? leNow.minute, second ?? leNow.second, millisecond ?? leNow.millisecond, microsecond ?? leNow.microsecond);
  }

  static DateTime parseZero(String? value) => DateTime.tryParse(value ?? '') ?? DateTime(0);

  static bool periodInConflict(DateTime debut1, DateTime fin1, DateTime debut2, DateTime fin2) => debut1.isBefore(fin2) && debut2.isBefore(fin1);

  static List<DateTime> periodToList(DateTime a, DateTime b) {
    List<DateTime> dates = [];
    if(a.isAfter(b)) return [];
    if(a.isSameDateAs(b)) return [a];
    DateTime parcours = a;
    while(parcours.isSameDateOrBefore(b)) {
      dates.add(parcours);
      parcours = parcours.add(const Duration(days: 1));
    }
    return dates;
  }
}

extension DurationUtilities on Duration {

  bool get isZero => inMicroseconds == 0;
  int get second => inSeconds.abs() % 60;
  int get minute => inMinutes.abs() % 60;
  int get hour => inHours.abs() % 24;
  int get inDaysRounded => (inHours/24).round();
  double get inHoursAndMinutes => inHours.abs() + (minute/60)*100;
  bool get isNegativeOrZero => inMicroseconds <= 0;
  bool get isPositive => inMicroseconds > 0;

  // Si inHours > 0, il montrera le '-' lui-même.
  // ignore: prefer_interpolation_to_compose_strings
  String get formatHour => (isNegative && inHours == 0 ? '-' : '') + '$inHoursPadded:$minutesPadded';
  String get formatHourAndSeconds => '$formatHour:$secondsPadded';
  String get secondsPadded => '$second'.padLeft(2,'0');
  String get minutesPadded => '$minute'.padLeft(2,'0');
  String get inHoursPadded => '$inHours'.padLeft(2,'0');
  String get hoursPadded => '$hour'.padLeft(2,'0');
  // ignore: prefer_interpolation_to_compose_strings
  String get formatHourAndDays => (isNegative && inHours == 0 ? '-' : '') + (inDays > 0 ? '$inDays:' : '') + '$inHoursPadded:$minutesPadded';

  Duration get toClosestQuarter => Duration(hours: inHours) + Duration(minutes: DateTimeUtilities.roundToClosestQuarter(minute));
  Duration get toAboveQuarter => Duration(hours: inHours) + Duration(minutes: DateTimeUtilities.roundToAboveQuarter(minute));
  Duration get toBelowQuarter => Duration(hours: inHours) + Duration(minutes: DateTimeUtilities.roundToBelowQuarter(minute));
  bool get isValidHour => !(isNegative || inMinutes > (23*60)+45);
}

extension IterableDurationUtilities on Iterable<Duration> {
  Duration get total => fold(Duration.zero, (previousValue, element) => previousValue + element);
}

extension NumUtilities on num {
  String get compactString => NumberFormat.compact().format(this);
}

extension IntUtilities on int {
  static int parseZero(String? value) => int.tryParse(value ?? '') ?? 0;
}

extension IterableIntUtilities on Iterable<int> {
  int get highest => isNotEmpty ? reduce((a, b) => a < b ? b : a) : 0;
  int get total => fold(0, (previousValue, element) => previousValue + element);
}

extension DoubleUtilities on double {
  static double parseZero(String? value) => double.tryParse(value ?? '') ?? 0;
}

extension ListUtilities<T> on List<T> {

  /// Inserts [object] in-between each element of the List : [1,object,2].
  void insertEveryOther(T object) {
    for(int i = length-1; i > 0; i--) insert(i, object);
  }

  /// Calls addAll then returns the List.
  List<T> addAllWith(Iterable<T> objects) {
    addAll(objects);
    return this;
  }

  /// Shorthand for [addAllIfNotThere] with 1 item.
  void addIfNotThere(T object, [bool Function(T,T)? same]) => addAllIfNotThere([object], same);

  /// Checks if the element exists in the List before adding it.
  void addAllIfNotThere(Iterable<T> objects, [bool Function(T,T)? same]) {
    for(T object in objects) {
      if(same != null && none((e) => same(object,e))) add(object);
      else if(same == null && !contains(object)) add(object);
    }
  }

  /// Calls addAllIfNotThere then returns the List.
  List<T> addAllIfNotThereWith(Iterable<T> objects, [bool Function(T,T)? same]) {
    addAllIfNotThere(objects,same);
    return this;
  }

  /// Return the element after [index] or the first element of the list.
  T nextOrFirst(int index) {
    if(index + 1 >= length) return first;
    else return this[index + 1];
  }

  /// Swappes the places of the items at the specified indexes (in-place).
  void swap(int index1, int index2) {
    T value = this[index1];
    this[index1] = this[index2];
    this[index2] = value;
  }

  void swapIfIndexValid(int index1, int index2) {
    if(indexValid(index1) && indexValid(index2)) {
      swap(index1, index2);
    }
  }

  /// Returns the object at the index if the index is valid.
  T? getSafe(int index) => indexValid(index) ? this[index] : null;

  /// If the value is in the list, removes it. If not, adds it.
  bool invertPresence(T value) {
    if(contains(value)) {
      remove(value);
      return false;
    } else {
      add(value);
      return true;
    }
  }

  /// Replaces the [previousValue] by [newValue] at the same place (index) in the list.
  /// Adds to the end if [previousValue] is not found.
  void replace(T previousValue, T newValue) {
    int index = indexOf(previousValue);
    if(index == -1) {
      add(newValue);
    } else {
      remove(previousValue);
      insert(index, newValue);
    }
  }

  List<T> copy(T Function(Map<String, dynamic> jsonObj) fromJson) => deepCopyList(this, fromJson);

  void retainDistinct(dynamic Function(T e) getId) {
    final ids = map(getId).toSet();
    retainWhere((e) => ids.remove(getId(e)));
  }

  List<T> removeAndGiveWhere(bool Function(T element) test) {
    List<T> vals = where(test).toList();
    vals.forEach(remove);
    return vals;
  }

  List<T> safeSublist(int start, [int? end]) {
    if(isEmpty || start > length) return [];
    if(end != null && end > length) end = length;
    return sublist(start, end);
  }
}

extension IterableUtilities<T> on Iterable<T> {

  bool get onlyOne => length == 1;
  bool get moreThenOne => length > 1;
  bool get onlyTwo => length == 2;

  /// true if [index] is a valid index to access.
  bool indexValid(int index) => index > -1 && index < length;

  /// The inverse of [any].
  bool none(bool Function(T e) test) => !any(test);

  /// Returns true if any element of [list] is present in this list too.
  bool containsAny(Iterable<T> list) => any((e) => list.contains(e));

  /// The inverse of [containsAny].
  bool containsNone(Iterable<T> list) => !containsAny(list);

  /// Returns the first item of the List or null if no item is found.
  T? firstWhereOrNull(bool Function(T e) test) {
    for (T e in this) if (test(e)) return e;
    return null;
  }

  List<T> distinct(dynamic Function(T e) getId) {
    final ids = map(getId).toSet();
    final objs = toList();
    objs.retainWhere((e) => ids.remove(getId(e)));
    return objs;
  }
}

extension StringUtilities on String {

  int get parseNums => replaceAll(StringUtilities.regexNotNums, '').parseZero;
  int get parseZero => int.tryParse(onlyNums) ?? 0;
  DateTime get parseDateTime => DateTimeUtilities.parseZero(this);
  String get onlyNums => replaceAll(regexNotNums, '');
  bool get isNumeric => double.tryParse(this) != null;

  List<String> splitMore(List<String> spliters) {
    List<String> res = split(spliters.first);
    List<String> temp = [];
    for(int i = 1; i < spliters.length; i++) {
      temp = [];
      for(String s in res) temp.addAll(s.split(spliters[i]));
      res.clear();
      res.addAll(temp);
    }
    return res;
  }
  bool lowercaseContains(String comp) => toLowerCase().contains(comp.toLowerCase());

  static final regexNotNums = RegExp('[^0-9]');
}

extension MapUtilities<K, V> on Map<K, V> {

  /// Returns a Map of the same types with [entries] and [additionalEntries].
  Map<K, V> copyWith(Map<K, V> additionalEntries) {
    Map<K, V> res = {};
    res.addAll(this);
    res.addAll(additionalEntries);
    return res;
  }

  /// Returns a copy of this Map where the keys are the values, and the values are the keys.
  Map<V, K> get inverted => {
    for(MapEntry<K, V> entry in entries)
      entry.value: entry.key,
  };

}

extension BoolUtilities on bool {
  /// Returns -1 if this is false and [other] is true,
  /// 1 if other < this, and 0 if they're the same.
  int compareTo(bool other) {
    if(this == other) return 0;
    // [this] is ordered before other
    if(this == false && other == true) return -1;
    return 1;
  }

  String get toIntString => this ? '1' : '0';
}
