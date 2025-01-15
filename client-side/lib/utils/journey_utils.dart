class JourneyUtils {
  // Get the closest date in the future for a given day of the week
  static DateTime getClosestDateForDay(int dayOfWeek) {
    final now = DateTime.now();
    final int daysToAdd = (dayOfWeek - now.weekday + 7) % 7;

    // Reset the time to midnight before returning
    final DateTime closestDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: daysToAdd));

    return closestDate;
  }

  // Calculate the date to show for recurring journeys
  static DateTime calculateDateForRecurringJourney(
      Map<String, dynamic> journey) {
    final String timeString = journey['time'];
    final List<dynamic> journeyDays = journey['journeyDays'] ?? [];

    // Parse time from the journey's `time` field
    final DateTime journeyTime = DateTime.parse(timeString);

    // Calculate possible dates based on journey days
    List<DateTime> possibleDates = journeyDays.map((day) {
      final int dayId = day['day']['dayId']; // 1: Monday, 2: Tuesday, etc.

      // Get the closest day and set the journey time explicitly
      final DateTime closestDay = getClosestDateForDay(dayId);
      final DateTime closestDayWithTime = DateTime(
        closestDay.year,
        closestDay.month,
        closestDay.day,
        journeyTime.hour,
        journeyTime.minute,
      );

      return closestDayWithTime;
    }).toList();

    // Sort the possible dates and return the earliest one in the future
    possibleDates.sort();

    final DateTime result = possibleDates.firstWhere(
      (date) => date.isAfter(DateTime.now()),
      orElse: () {
        print('No future dates found. Returning original journey time.');
        return journeyTime;
      },
    );

    return result;
  }
}
