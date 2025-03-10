// import 'package:calendarro/calendarro.dart';
// import 'package:calendarro/date_utils.dart' as dt;
// // import 'package:calendarro/default_day_tile.dart';
// import 'package:flutter/material.dart';

// class CalendarroDayItem extends StatelessWidget {
//   final DateTime date;
//   CalendarroState calendarroState;
//   final DateTimeCallback onTap;

//   CalendarroDayItem({required this.date, required this.calendarroState, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     bool isToday = dt.DateUtils.isToday(date);
//     calendarroState = Calendarro.of(context);
//     bool daySelected = calendarroState.isDateSelected(date);
//     var textColor = daySelected ? Colors.white : Colors.grey;

//     BoxDecoration boxDecoration;
//     if (daySelected) {
//       boxDecoration =
//           BoxDecoration(color: Colors.green[200], shape: BoxShape.circle);
//     } else if (isToday) {
//       boxDecoration =
//           BoxDecoration(color: Constants.greyColor, shape: BoxShape.circle);
//     }

//     return Expanded(
//         child: GestureDetector(
//       child: Container(
//           height: 40.0,
//           decoration: boxDecoration,
//           child: Center(
//               child: Text(
//             "${date.day}",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.black),
//           ))),
//       onTap: handleTap,
//       behavior: HitTestBehavior.translucent,
//     ));
//   }

//   void handleTap() {
//     if (onTap != null) {
//       onTap(date);
//     }
//   }
// }

// class CustomDayTileBuilder extends DayTileBuilder {
//   CustomDayTileBuilder();

//   @override
//   Widget build(BuildContext context, DateTime date, DateTimeCallback onTap) {
//     return CalendarroDayItem(
//       date: date,
//       calendarroState: Calendarro.of(context),
//       onTap: onTap,
//     );
//   }
// }



