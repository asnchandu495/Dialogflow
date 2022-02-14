import 'package:flutter/material.dart';
import 'package:sumed/models/custom_payload.dart';

class DropListModel {
  DropListModel(this.listOptionItems);

  final List<OptionItem> listOptionItems;
}

/*DropListModel getTimeUnit(dynamic values) {
  Options options = values as Options;
  List<OptionItem> timeUnit = [];
  if (options.days != null) {
    timeUnit.add(OptionItem(id: "1", title: 'Days'));
  }
  if (options.weeks != null) {
    timeUnit.add(OptionItem(id: "2", title: 'Weeks'));
  }

  if (options.months != null) {
    timeUnit.add(OptionItem(id: "3", title: 'Month'));
  }
  return DropListModel(timeUnit);
}*/

/*
List<String> getTimeUnit(dynamic values) {
  Options options = values as Options;
  List<String> timeUnit = [];
  if (options.days != null) {
    timeUnit.add('Days');
  }
  if (options.weeks != null) {
    timeUnit.add('Weeks');
  }

  if (options.months != null) {
    timeUnit.add('Month');
  }
  return timeUnit;
}
*/

Map<String,int> getTimeUnit(dynamic values) {
  Options options = values as Options;
  Map<String,int> timeUnit = {};
  if (options.days != null) {
    timeUnit["Days"] = 1;
  }
  if (options.weeks != null) {
    timeUnit["Weeks"] = 2;
    // timeUnit.add(2);
  }

  if (options.months != null) {
    timeUnit["Month"] = 3;
    // timeUnit.add(3);
  }
  return timeUnit;
}


/*DropListModel getDaysValue(dynamic values) {
  Options options = values as Options;
  List<OptionItem> dayValues = [];
  if (options.days != null) {
    for (var element in options.days!) {
      dayValues
          .add(OptionItem(id: element.toString(), title: element.toString()));
    }
  }
  return DropListModel(dayValues);
}*/

List<int> getDaysValue(dynamic values) {
  Options options = values as Options;
  List<int> dayValues = [];
  if (options.days != null) {
    for (var element in options.days!) {
      dayValues.add(element);
    }
  }
  return dayValues;
}

/*DropListModel getWeeksValue(dynamic values) {
  Options options = values as Options;
  List<OptionItem> weekValues = [];
  if (options.weeks != null) {
    for (var element in options.weeks!) {
      weekValues
          .add(OptionItem(id: element.toString(), title: element.toString()));
    }
  }
  return DropListModel(weekValues);
}*/

List<int> getWeeksValue(dynamic values) {
  Options options = values as Options;
  List<int> weekValues = [];
  if (options.weeks != null) {
    for (var element in options.weeks!) {
      weekValues.add(element);
    }
  }
  return weekValues;
}

/*DropListModel getMonthValue(dynamic values) {
  Options options = values as Options;
  List<OptionItem> monthValues = [];
  if (options.months != null) {
    for (var element in options.months!) {
      monthValues
          .add(OptionItem(id: element.toString(), title: element.toString()));
    }
  }
  return DropListModel(monthValues);
}*/

List<int> getMonthValue(dynamic values) {
  Options options = values as Options;
  List<int> monthValues = [];
  if (options.months != null) {
    for (var element in options.months!) {
      monthValues.add(element);
    }
  }
  return monthValues;
}

class OptionItem {
  final String id;
  final String title;

  OptionItem({required this.id, required this.title});
}
