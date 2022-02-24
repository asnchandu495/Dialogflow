import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sumed/app_theme.dart';

class S2Choice {
  ///
  /// Displayed label
  ///
  final String label;

  ///
  /// The displayed icon when selected
  ///
  final dynamic meta;

  const S2Choice({required this.label, this.meta});
}

class ChipsFilter extends StatelessWidget {
  ///
  /// The list of the filters
  ///
  final List<S2Choice> filters;
  final List<String> selectedValues = [];

  ///
  /// The default selected index starting with 0
  ///
  ///
  final String title;
  final bool isSingleSelection;
  final Function(List<String>) selectedValueCallback;

  ChipsFilter(
      {Key? key,
        required this.title,
      required this.filters,
      required this.isSingleSelection,
      required this.selectedValueCallback})
      : super(key: key);

  var selectedIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /*SizedBox(
            height: 300,
            width: double.maxFinite,
            child: Wrap(
              children: filters.map((e) => chipBuilder(context,selectedIndex.value)).toList(),
              direction: Axis.horizontal,
              */ /*itemBuilder:chipBuilder ,
              itemCount: filters.length,
              scrollDirection: Axis.horizontal,*/ /*
            ),
          ),*/
          Text(title,style: MyTheme.chatSenderName),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            children: filters
                .map((e) =>
                    buildChip(e.label, isSingleSelection, (selectedValue) {
                      if (!selectedValues.contains(selectedValue)) {
                        selectedValues.add(selectedValue);
                      }

                      if (isSingleSelection) {
                        _fireAndExistScreen();
                      }
                    }))
                .toList(),

            /*itemBuilder:chipBuilder ,
              itemCount: filters.length,
              scrollDirection: Axis.horizontal,*/
          ),
          Visibility(
              visible: !isSingleSelection,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedValues.isNotEmpty) {
                      _fireAndExistScreen();
                    } else {
                      return;
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(MyTheme.kRedish)
                  ),
                  child: Text(
                    'Submit',
                    style:
                        MyTheme.chatSenderName.copyWith(color: MyTheme.kWhite),
                  ),
                ),
              ))
        ]);
  }

  _fireAndExistScreen(){
    selectedValueCallback.call(selectedValues);
    Get.back();
  }

  ///
  /// Build a single chip
  ///
  Widget chipBuilder(context, filter, currentIndex) {
    // S2Choice filter = filters[currentIndex];
    RxBool isActive = (selectedIndex == currentIndex).obs;

    return GestureDetector(
      onTap: () {
        selectedIndex = currentIndex;
        isActive.value = selectedIndex == currentIndex;
      },
      child: Obx(() {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: isActive.value ? Colors.blueAccent : Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isActive.value)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: const Icon(Icons.check),
                ),
              Text(
                filter.label,
                style: MyTheme.chatConversation,
              ),
            ],
          ),
        );
      }),
    );
  }
}

/*class _ChipsFilterState extends StatelessWidget {
  ///
  /// Currently selected index
  ///


  @override
  void initState() {
    // When [widget.selected] is defined, check the value and set it as
    // [selectedIndex]
    if (widget.selected >= 0 && widget.selected < widget.filters.length) {
      selectedIndex.value = widget.selected;
    }

    super.initState();
  }


}*/

Widget buildChip(
    String label, bool isSingleSelection, Function(String) onSelection) {
  var _isSelected = false.obs;
  return Obx(() => FilterChip(
        padding: const EdgeInsets.all(4.0),

        /*avatar: CircleAvatar(
      backgroundColor: Colors.pink.shade600,
      child: const Text('FD'),
    ),*/
        label: Text(
          label,
          style: MyTheme.chatConversation.copyWith(
              color:
                  _isSelected.value ? MyTheme.kWhite : MyTheme.kChatTimeColor),
        ),
        selected: _isSelected.value,
        elevation: 5,
        showCheckmark: true,
        checkmarkColor: MyTheme.kWhite,
        backgroundColor: MyTheme.kWhite,
        selectedColor: MyTheme.kBlueShade,
        onSelected: (bool selected) {
          _isSelected.value = selected;
          onSelection.call(label);
          // Navigator.pop(context);
          /* if(selected) {
        onSelection.call(label);
        Get.back();
      }*/
        },
        /*onDeleted: () {
    },*/
      ));

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
