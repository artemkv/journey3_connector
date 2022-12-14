extension DateFunctions on DateTime {
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameHour(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day &&
        hour == other.hour;
  }
}

class Timeline {
  DateTime nowUtc() {
    return DateTime.now().toUtc();
  }
}
