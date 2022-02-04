import 'package:awesome_select/awesome_select.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildChip(String label, Color color, Function(String) onSelection) {

  bool _isSelected = false;
  return InputChip(
    padding: const EdgeInsets.all(2.0),

    /*avatar: CircleAvatar(
      backgroundColor: Colors.pink.shade600,
      child: const Text('FD'),
    ),*/
    label: Text(
      label,
      style: const TextStyle(color: Colors.white),
    ),
    selected: _isSelected,
    elevation: 5,
    showCheckmark: true,
    backgroundColor: Colors.blueGrey,
    selectedColor: Colors.blue.shade600,
    onSelected: (bool selected) {
      // Navigator.pop(context);
      onSelection.call(label);
      Get.back();
    },
    /*onDeleted: () {
    },*/
  );

  /* return Chip(
    labelPadding: EdgeInsets.all(2.0),
    avatar: CircleAvatar(
      backgroundColor: Colors.white70,
      child: Text(label[0].toUpperCase()),
    ),
    label: Text(
      label,
      style: TextStyle(
        color: Colors.white,
      ),
    ),

    backgroundColor: color,
    elevation: 6.0,
    shadowColor: Colors.grey[60],
    padding: EdgeInsets.all(8.0),
  );*/
}
