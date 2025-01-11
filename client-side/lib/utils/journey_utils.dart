import 'package:intl/intl.dart';

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

    // Debugging output
    print('Current Date: $now');
    print('Day of the Week: $dayOfWeek');
    print('Days to Add: $daysToAdd');
    print('Closest Date for Day $dayOfWeek: $closestDate');

    return closestDate;
  }

  // Calculate the date to show for recurring journeys
  static DateTime calculateDateForRecurringJourney(
      Map<String, dynamic> journey) {
    final String timeString = journey['time'];
    final List<dynamic> journeyDays = journey['journeyDays'] ?? [];

    // Debugging output
    print('Journey Time String: $timeString');
    print('Journey Days: $journeyDays');

    // Parse time from the journey's `time` field
    final DateTime journeyTime = DateTime.parse(timeString);

    // Debugging output
    print('Parsed Journey Time: $journeyTime');

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

      // Debugging output for each journey day
      print('Day ID: $dayId');
      print('Closest Day: $closestDay');
      print('Closest Day with Time: $closestDayWithTime');

      return closestDayWithTime;
    }).toList();

    // Sort the possible dates and return the earliest one in the future
    possibleDates.sort();

    // Debugging output
    print('Sorted Possible Dates: $possibleDates');

    final DateTime result = possibleDates.firstWhere(
      (date) => date.isAfter(DateTime.now()),
      orElse: () {
        print('No future dates found. Returning original journey time.');
        return journeyTime;
      },
    );

    // Debugging output
    print('Selected Date to Show: $result');

    return result;
  }
}
