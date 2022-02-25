// import 'package:awesome_select/awesome_select.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart' as dialogFlow;

import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:sumed/customfunctionality/conversation.dart';
import 'package:sumed/customfunctionality/drop_down_list_model.dart';
import 'package:sumed/customfunctionality/generate_chip.dart';

import 'package:sumed/models/custom_payload.dart';
import 'package:sumed/models/message_model.dart' as appMessage;
import 'package:sumed/models/message_model.dart';
import 'package:sumed/models/value_holder.dart';

import '../app_theme.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../customfunctionality/generate_chip.dart';

/*
Layout type
0 -> Single select chip
1 -> Multi selected chip
2 -> List selection chip

options (when there is list)
1 - > First option and it increase its value for rest of option
 */
class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key, required this.user}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
  final User user;
}

class _ChatRoomState extends State<ChatRoom> /*with RestorationMixin*/ {
  late dialogFlow.DialogFlowtter dialogFlowtter;
  var msgController = Get.put(MessageController());

  // var isBottomSheetShow = false.obs;
  var bottomSheetTitle = "".obs;
  final RxList<String> _bottomSheetValueSelection = RxList();
  final RxList<String> _multipleValueQueue = RxList();

  final RxList<S2Choice> _choiceValues = RxList();
  bool _isSingleSelection = false;
  int _layoutType = 0;
  bool _isForName = false;

  final RxBool _isWaitForAnotherMessage = false.obs;
  final RxString _timeUnitSelected = ''.obs;
  final RxString _timeValueSelected = ''.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dialogFlow.DialogFlowtter.fromFile().then((instance) {
      dialogFlowtter = instance;
      Future.delayed(const Duration(seconds: 1), () {
        _checkForMessage("Hello");
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (allUserList.isNotEmpty) {
          for (var element in allUserList) {
            _choiceValues.add(S2Choice(label: element.name));
          }
          _isSingleSelection = true;
          _isForName = true;
          // isBottomSheetShow.value = true;
          bottomSheetTitle.value = "Select patient name";
          _showSingleSelectionChipsWithBottomSheet(true);
        }
      });
    });
  }

  List<String> determineMessageType(dialogFlow.Message message) {
    List<String> values = [];
    switch (message.type) {
      case dialogFlow.MessageType.payload:
        if (message.payload != null) {
          values.add("1");
          var parsedValue = _parsePayload(message.payload!);
          int type = parsedValue['op'];
          values.addAll(parsedValue['values']);

          _isSingleSelection = type < 2;
          print("**********is Single selection $_isSingleSelection");

          // String caption = values.removeAt(0);

          /*onExtraMessage.call(values);

          return chipList(values, onSelection, caption);*/
        }
        return values;
      /*case dialogFlow.MessageType.card:
      // return _CardContainer(card: message.card!);
        break;*/
      case dialogFlow.MessageType.text:
      default:
        values.add("0");
        values.add(message.text?.text?[0] ?? '');
        return values;
    }
  }

  final Map<String, Options> options = {};

  Map<String, dynamic> _parsePayload(Map<String, dynamic> payload) {
    final Map<String, dynamic> map = {};
    final List<String> values = [];

    CustomPayload receivedPayload = CustomPayload.fromJson(payload);
    /*if (!_isCalled) {
      onExtraMessage.call(receivedPayload.contentTitle!);
      _isCalled = true;
    }*/
    int type = receivedPayload.outputValue!;
    _layoutType = receivedPayload.layoutType!;
    map["op"] = type;
    values.add(receivedPayload.contentTitle!);
    for (var element in receivedPayload.richContent!) {
      for (var innerElement in element) {
        if (innerElement.type! == "list") values.add(innerElement.title!);
        if (innerElement.options != null) {
          options[innerElement.title!] = innerElement.options!;
        }
      }
    }

    map["values"] = values;
    if (options.isNotEmpty && _layoutType == 2) map["options"] = options;

    return map;
  }

  // final RxBool _isSend = false.obs;
  _initQueueSendingMessage() {
    _isWaitForAnotherMessage.listen((p0) {
      if (p0) {
        bool hasValue = _multipleValueQueue.value.isNotEmpty;
        if (hasValue /* && _isSend.value*/) {
          var valueToSend = _multipleValueQueue.value.removeAt(0);
          print("SENDING MESSAGE TO DF $valueToSend");
          _checkForMessage(valueToSend);
        }
      }
    });
  }

  Future<void> _checkForMessage(text, [bool isUserMessage = false]) async {
    dialogFlow.DetectIntentResponse response =
        await dialogFlowtter.detectIntent(
      queryInput: dialogFlow.QueryInput(text: dialogFlow.TextInput(text: text)),
    );

    // print("RECEIVED TEXT = ${response.props.toString()}");
    if (response.message == null) return;

    // msgController.messages
    _addMessage(response.message!, isUserMessage);

    if (_isWaitForAnotherMessage.value) {
      _isWaitForAnotherMessage.value = false;
      // _isWaitForAnotherMessage.value = true;
      if (_multipleValueQueue.isEmpty) {
        // _isWaitForAnotherMessage.value = false;
        _multipleValueQueue.close();
      }
    }
    _botStatus.value = _online;
  }

  Future<void> _addMessage(dialogFlow.Message message,
      [bool isUserMessage = false]) async {
    // print("********** ${message.toString()}");
    String textToDisplay = "";
    if (!isUserMessage) {
      List<String> values = determineMessageType(message);
      String typeOfMessage = values.removeAt(0);
      textToDisplay = values.removeAt(0);
      if (values.isNotEmpty) {
        for (var element in values) {
          _choiceValues.add(S2Choice(
              label: element,
              meta: _layoutType == 2 && options.isNotEmpty
                  ? options[element]
                  : ""));
        }
        // isBottomSheetShow.value = true;
        bottomSheetTitle.value = textToDisplay;
        _determineInputLayout();
      }
    } else {
      textToDisplay = message.text!.text![0].toString();
    }

    _addMessageToConversation(isUserMessage, textToDisplay);
  }

  String _getTimeValue() {
    final df = DateFormat('hh:mm a');
    return df.format(DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    _botStatus.value = _typing;
    await Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        dialogFlow.Message(text: dialogFlow.DialogText(text: [text])),
        true,
      );
      _checkForMessage(text);
    });
  }

  String _getTodayValue() {
    // final df = DateFormat('dd-MM-yyyy hh:mm a');
    final df = DateFormat('dd-MM-yyyy');
    return df.format(DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch));
  }

  final String _online = 'Online';
  final String _typing = 'Typing...';
  final RxString _botStatus = ''.obs;

  @override
  Widget build(BuildContext context) {
    _botStatus.value = _typing;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.kAppbarColor,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
                radius: 24,
                backgroundColor: MyTheme.kAppbarColor,
                child: Image.asset(
                    widget.user.avatar) /*,
              backgroundImage: ,*/
                ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.user.name,
                  style: MyTheme.chatSenderName,
                ),
                Obx(() {
                  return Text(
                    _botStatus.value,
                    style: MyTheme.chatTime,
                  );
                }),
              ],
            ),
          ],
        ),
        elevation: 4,
      ),
      backgroundColor: MyTheme.kBgColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Container(
                color: MyTheme.kBgColor,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Conversation(user: widget.user),
              ),
            ),
            /*Obx(() => Visibility(
                visible: !(isBottomSheetShow.value),
                child:*/
            buildChatComposer() /*))*/,
            /*Obx(() => Visibility(
                  visible: isBottomSheetShow.value,
                  child: _determineInputLayout(),
                ))*/
          ],
        ),
      ),
    );
  }

/*
  formedAForm() {
    String valueForSecondComponent = '';
    String valueForThirdComponent = '';
    String valueForFirstComponent = '';
    RxInt initialValueForNumeric = 0.obs;
    var initialValueForString;
    return SmartSelect<String>.multiple(
      title: bottomSheetTitle.value,
      selectedValue: _bottomSheetValueSelection,
      onChange: (selected) {
        // _user = selected?.value;
      },
      modalFilter: false,
      choiceItems: _choiceValues,
      choiceGrouped: false,
      choiceLayout: S2ChoiceLayout.list,
      choiceBuilder: (context, state, choice) {
        RxList<bool> isSelectedForSecondOption =
            RxList(List.generate(3, (index) => false));
        RxList<bool> isSelectedForThirdOption =
            RxList(List.generate(2, (index) => false));

        return SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Column(
            children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: _choiceValues.length,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 1:
                            {
                              var title = _choiceValues[index].title;

                              Options options =
                                  _choiceValues[index].meta as Options;
                              isSelectedForSecondOption = RxList(List.generate(
                                  options.temperature!.length,
                                  (index) => false));

                              return Card(
                                  // color: choice.selected ? theme.primaryColor : theme.cardColor,
                                  child: Container(
                                      padding: const EdgeInsets.all(7),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            title ?? '',
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                            style: MyTheme.heading2.copyWith(
                                              color: MyTheme.kWhite,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Obx(() => ToggleButtons(
                                                selectedColor: MyTheme.kRedish,
                                                // fillColor: Colors.white,
                                                children: options.temperature!
                                                    .map<Widget>((s) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Text(
                                                          s,
                                                          style: MyTheme
                                                              .heading2
                                                              .copyWith(
                                                            color:
                                                                MyTheme.kWhite,
                                                          ),
                                                        )))
                                                    .toList(),
                                                onPressed: (int index) {
                                                  valueForSecondComponent =
                                                      "$title - ${options.temperature![index]}";
                                                  for (int buttonIndex = 0;
                                                      buttonIndex <
                                                          isSelectedForSecondOption
                                                              .length;
                                                      buttonIndex++) {
                                                    if (buttonIndex == index) {
                                                      isSelectedForSecondOption[
                                                              buttonIndex] =
                                                          !isSelectedForSecondOption[
                                                              buttonIndex];
                                                    } else {
                                                      isSelectedForSecondOption[
                                                          buttonIndex] = false;
                                                    }
                                                  }
                                                },
                                                isSelected:
                                                    isSelectedForSecondOption,
                                              )),
                                        ],
                                      )));
                            }
                          case 2:
                            {
                              var title = _choiceValues[index].title;

                              Options options =
                                  _choiceValues[index].meta as Options;
                              isSelectedForThirdOption = RxList(List.generate(
                                  options.temperature!.length,
                                  (index) => false));
                              return Card(
                                  // color: choice.selected ? theme.primaryColor : theme.cardColor,
                                  child: Container(
                                      padding: const EdgeInsets.all(7),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              title ?? '',
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.visible,
                                              style: MyTheme.heading2.copyWith(
                                                color: MyTheme.kWhite,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Obx(() => ToggleButtons(
                                                  selectedColor:
                                                      MyTheme.kRedish,
                                                  // fillColor: Colors.white,
                                                  children: options.temperature!
                                                      .map<Widget>((s) =>
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Text(
                                                                s,
                                                                style: MyTheme
                                                                    .heading2
                                                                    .copyWith(
                                                                  color: MyTheme
                                                                      .kWhite,
                                                                ),
                                                              )))
                                                      .toList(),
                                                  onPressed: (int index) {
                                                    valueForThirdComponent =
                                                        "$title - ${options.temperature![index]}";
                                                    for (int buttonIndex = 0;
                                                        buttonIndex <
                                                            isSelectedForThirdOption
                                                                .length;
                                                        buttonIndex++) {
                                                      if (buttonIndex ==
                                                          index) {
                                                        isSelectedForThirdOption[
                                                                buttonIndex] =
                                                            !isSelectedForThirdOption[
                                                                buttonIndex];
                                                      } else {
                                                        isSelectedForThirdOption[
                                                                buttonIndex] =
                                                            false;
                                                      }
                                                    }
                                                  },
                                                  isSelected:
                                                      isSelectedForThirdOption,
                                                ))
                                          ])));
                            }
                          default:
                            {
                              final RxList<int> numericalValues = RxList(
                                  _determineDropDownValueForTimeUnit(
                                      "Days", _choiceValues[index].meta));
                              initialValueForNumeric.value = numericalValues[0];
                              var dataSetForString =
                                  getTimeUnit(_choiceValues[index].meta);
                              initialValueForString =
                                  dataSetForString.keys.elementAt(0);
                              var title = _choiceValues[index].title;

                              return Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      title ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.visible,
                                      style: MyTheme.heading2.copyWith(
                                        color: MyTheme.kWhite,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Obx(() {
                                          return Flexible(
                                              fit: FlexFit.loose,
                                              flex: 1,
                                              child: NumberValueSelector(
                                                data: numericalValues,
                                                initialValue:
                                                    initialValueForNumeric
                                                        .value,
                                                label: title ?? '',
                                                onSelectedValue:
                                                    (selectedValue) {
                                                  _timeValueSelected.value =
                                                      selectedValue;
                                                  initialValueForNumeric.value =
                                                      int.parse(selectedValue);
                                                },
                                              ));
                                        }),
                                        */
/*Obx(() => */ /*

                                        Flexible(
                                            fit: FlexFit.loose,
                                            flex: 1,
                                            child: StringValueSelector(
                                              data: dataSetForString,
                                              initialValue:
                                                  initialValueForString,
                                              label: title ?? '',
                                              onSelectedValue: (selectedValue) {
                                                initialValueForString =
                                                    selectedValue;
                                                _timeUnitSelected.value =
                                                    selectedValue;
                                                valueForFirstComponent =
                                                    "$title details \n";
                                                numericalValues.value =
                                                    _determineDropDownValueForTimeUnit(
                                                        _timeUnitSelected.value,
                                                        _choiceValues[index]
                                                            .meta);
                                                initialValueForNumeric.value =
                                                    numericalValues[0];
                                              },
                                            )) */
/*)*/ /*

                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                        }
                      }))
            ],
          ),
        );
      },
      modalFooterBuilder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(25, 5, 25, 15),
          child: ButtonTheme(
            minWidth: double.infinity,
            child: FlatButton(
              child: Text('Submit (${state.selection?.length})'),
              color: MyTheme.createMaterialColor(MyTheme.kWhite),
              textColor: MyTheme.kRedish,
              onPressed: () async {
                ValueHolderForBot holderForBot = ValueHolderForBot();

                valueForFirstComponent = initialValueForString +
                    " " +
                    initialValueForNumeric.toString();
                holderForBot.firstValue = valueForFirstComponent;
                holderForBot.secondValue = valueForSecondComponent;
                holderForBot.thirdValue = valueForThirdComponent;
                holderForBot.valueTag = bottomSheetTitle.value;
                String valueToSend = "Details \n" +
                    valueForFirstComponent +
                    "\n" +
                    valueForSecondComponent +
                    "\n" +
                    valueForThirdComponent;

                _bottomSheetValueSelection.clear();
                isBottomSheetShow.value = false;
                _choiceValues.clear();
                state.closeModal();

                await _sendMessage(valueToSend);

                Future.delayed(const Duration(milliseconds: 250), () {
                  if (_multipleValueQueue.isNotEmpty) {
                    _isWaitForAnotherMessage.value = true;
                  }
                });
              },
            ),
          ),
        );
      },
      modalType: S2ModalType.fullPage,
    );
  }

  SmartSelect _smartSelect(bool isForProblems) {
    SmartSelect sele = SmartSelect<String>.multiple(
      choiceType: S2ChoiceType.chips,
      title: bottomSheetTitle.value,
      // selectedResolver: ,
      selectedValue: _bottomSheetValueSelection.value,
      onChange: (selected) {
        _bottomSheetValueSelection.clear();
        _bottomSheetValueSelection.addAll(selected!.value!.toList());
        if (isForProblems) {
          _multipleValueQueue.clear();
          _multipleValueQueue.addAll(_bottomSheetValueSelection);
          isForProblems = false;
          _initQueueSendingMessage();
          _isWaitForAnotherMessage.value = true;

          // multipleValueQueue.listen((values) { values.forEach((element) { })});
        }
        var valueToSend = "";
        for (var element in selected.value!) {
          if (selected.value!.length == 1) {
            valueToSend = element;
          } else {
            valueToSend += element + ",";
          }
        }

        bool containsExtraComma = valueToSend.endsWith(",");
        if (containsExtraComma) {
          valueToSend = valueToSend.substring(0, valueToSend.length - 1);
          */
/*valueToSend = valueToSend.replaceRange(
              valueToSend.length - 1, valueToSend.length - 1, '');*/ /*

        }

        print(
            "SELECTED VALUES = ${_bottomSheetValueSelection.value.toString()}");

        // sendMessage(valueToSend);
        _addMessageToConversation(true, valueToSend);
        _bottomSheetValueSelection.clear();
        isBottomSheetShow.value = false;
        _choiceValues.clear();
      },
      choiceItems: _choiceValues,
      choiceActiveStyle: S2ChoiceStyle(highlightColor: MyTheme.kRedish),
      choiceConfig: S2ChoiceConfig(
        type: S2ChoiceType.chips,
        activeStyle: S2ChoiceStyle(
            control: S2ChoiceControl.leading,
            highlightColor: MyTheme.kRedish,
            accentColor: MyTheme.kRedish,
            raised: true),
        layout: S2ChoiceLayout.grid,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 3.5,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          crossAxisCount: 2,
        ),
      ),
      modalConfirm: false,

      modalType: S2ModalType.bottomSheet,
      modalValidation: (value) {
        return value.length > 0 ? '' : 'Select at least one';
      },

      modalHeaderBuilder: (context, state) {
        // state.showModal();
        return Container(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
          child: state.modalTitle,
        );
      },
      modalFooterBuilder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(25, 5, 25, 15),
          child: ButtonTheme(
            minWidth: double.infinity,
            child: FlatButton(
              child: Text('Submit (${state.selection?.length})'),
              color: MyTheme.createMaterialColor(MyTheme.kWhite),
              textColor: MyTheme.kRedish,
              onPressed: (state.selection?.isValid ?? true)
                  ? () => state.closeModal(confirmed: true)
                  : null,
            ),
          ),
        );
      },
    );

    return sele;
  }

  SmartSelect _smartChipSelectForSingle(bool isForName) {
    SmartSelect sele = SmartSelect<String>.single(
      choiceType: S2ChoiceType.chips,
      title: bottomSheetTitle.value,
      selectedValue: "",
      onChange: (selected) {
        _bottomSheetValueSelection.clear();
        // bottomSheetValueSelection.addAll(selected!.value!.toList());
        _sendMessage(selected.value!);
        if (_isForName) {
          currentUser = allUserList
              .firstWhere((element) => element.name == selected.value);
          _isForName = false;
        }
        isBottomSheetShow.value = false;
        _choiceValues.clear();
        _isSingleSelection = false;
      },
      choiceItems: _choiceValues,
      choiceActiveStyle: S2ChoiceStyle(highlightColor: MyTheme.kRedish),
      choiceConfig: S2ChoiceConfig(
        type: S2ChoiceType.chips,
        activeStyle: S2ChoiceStyle(
            control: S2ChoiceControl.leading,
            highlightColor: MyTheme.kRedish,
            accentColor: MyTheme.kRedish,
            raised: true),
        layout: S2ChoiceLayout.grid,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 3.5,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          crossAxisCount: 2,
        ),
      ),
      modalConfirm: false,
      modalType: S2ModalType.bottomSheet,
      modalValidation: (selected) {
        if (selected == null) return 'Select at least one';
        return '';
      },
    );

    return sele;
  }
*/

  Widget buildChatComposer() {
    final TextEditingController chatController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(4),
      color: MyTheme.kWhite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 60,
              // color:MyTheme.kWhite,
              decoration: BoxDecoration(
                color: MyTheme.kWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  /*Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(
                    width: 10,
                  ),*/
                  Expanded(
                    child: TextField(
                      controller: chatController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type your message ...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.attach_file,
                    color: Colors.grey[500],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Container(
            color: MyTheme.kRedish,
            height: 40,
            child: /* ClipRRect(

                borderRadius: const BorderRadius.all(Radius.circular(30)),
                child:*/
                IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: () {
                _sendMessage(chatController.text);
                chatController.clear();
              },

              /*style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(MyTheme.kAccentColor),
            )*/
              // backgroundColor: MyTheme.kAccentColor,
            ) /*)*/,
          )
        ],
      ),
    );
  }

  // final Map<String, List<appMessage.Message>> _allMessages = {};
  // final List<appMessage.Message> _userMessage = [];
  // final List<appMessage.Message> _botMessage = [];

  void _addMessageToConversation(bool isUserMessage, String textToDisplay) {
    var appMsgs = appMessage.Message(
        sender: isUserMessage ? currentUser : botSuMed,
        avatar: isUserMessage ? currentUser.avatar : botSuMed.avatar,
        text: textToDisplay,
        time: _getTimeValue(),
        isRead: true,
        unreadCount: 0);

    /*   if (isUserMessage) {
      _userMessage.add(appMsgs);

      _allMessages['user'] = _userMessage;
    } else {
      _botMessage.add(appMsgs);
      _allMessages['bot'] = _botMessage;
    }*/

    /*msgController.chatMessageHolder.listen((p0) {

      p0.value;
    });*/
    // msgController.messages.add(appMsgs);

    msgController.chatMessageHolder /*.value .value*/ .add(appMsgs);
  }

  _determineInputLayout() {
    switch (_layoutType) {
      case 1:
        //patch to overcome value assign of selection
        _showMultiSelectionChipsWithBottomSheet(true);
        break;
      case 2:
        _showDynamicUiBottomSheet();
        break;
      case 0:
      default:
        _showSingleSelectionChipsWithBottomSheet(_isForName);
        break;
    }
  }

  List<int> _determineDropDownValueForTimeUnit(String value, meta) {
    if (value.toLowerCase() == "month") {
      return getMonthValue(meta);
    } else if (value.toLowerCase() == "weeks") {
      return getWeeksValue(meta);
    } else {
      return getDaysValue(meta);
    }
  }

  _getDslDecoration() {
    return const BoxDecoration(
      border: BorderDirectional(
        bottom: BorderSide(width: 1, color: Colors.black12),
        top: BorderSide(width: 1, color: Colors.black12),
      ),
    );
  }

  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        itemHeight: 102,
        value: value,
        itemBuilder: (context, value) {
          return Text(value);
        });
  }

  _showSingleSelectionChipsWithBottomSheet(bool isForName) {
    showMaterialModalBottomSheet(
      expand: false,
      isDismissible: false,
      enableDrag: false,
      context: context,
      backgroundColor: MyTheme.kBgColor,
      builder: (context) => Material(
        child: SafeArea(
            top: false,
            child: ChipsFilter(
              filters: _choiceValues,
              title: bottomSheetTitle.value,
              isSingleSelection: true,
              selectedValueCallback: (selectedValueList) {
                var selectedValue = selectedValueList[0];
                _sendMessage(selectedValue);
                if (_isForName) {
                  currentUser = allUserList
                      .firstWhere((element) => element.name == selectedValue);
                  _isForName = false;
                }
                _bottomSheetValueSelection.clear();
                // isBottomSheetShow.value = false;
                _choiceValues.clear();
              },
            )),
      ),
    );
  }

  _showMultiSelectionChipsWithBottomSheet(isForProblems) {
    showModalBottomSheet(
      // expand: false,
      isDismissible: false,
      enableDrag: false,
      context: context,
      // backgroundColor: Colors.transparent,
      builder: (context) => Material(
        child: SafeArea(
            top: false,
            child: ChipsFilter(
              filters: _choiceValues,
              title: bottomSheetTitle.value,
              isSingleSelection: false,
              selectedValueCallback: (selectedValueList) {
                _bottomSheetValueSelection.value = selectedValueList;
                if (isForProblems) {
                  _multipleValueQueue.clear();
                  _multipleValueQueue.addAll(_bottomSheetValueSelection);
                  isForProblems = false;
                  _initQueueSendingMessage();
                  _isWaitForAnotherMessage.value = true;

                  // multipleValueQueue.listen((values) { values.forEach((element) { })});
                }
                var valueToSend = "";
                for (var element in selectedValueList) {
                  if (selectedValueList.length == 1) {
                    valueToSend = element;
                  } else {
                    valueToSend += element + ",";
                  }
                }

                bool containsExtraComma = valueToSend.endsWith(",");
                if (containsExtraComma) {
                  valueToSend =
                      valueToSend.substring(0, valueToSend.length - 1);
                }

                print(
                    "SELECTED VALUES = ${_bottomSheetValueSelection.value.toString()}");

                // sendMessage(valueToSend);
                _addMessageToConversation(true, valueToSend);
                _bottomSheetValueSelection.clear();
                // isBottomSheetShow.value = false;
                _choiceValues.clear();
              },
            )),
      ),
    );
  }

  _showDynamicUiBottomSheet() {
    String valueForSecondComponent = '';
    String valueForThirdComponent = '';
    String valueForFirstComponent = '';
    RxInt initialValueForNumeric = 0.obs;
    var initialValueForString;
    RxList<bool> isSelectedForSecondOption =
        RxList(List.generate(3, (index) => false));
    RxList<bool> isSelectedForThirdOption =
        RxList(List.generate(2, (index) => false));
    showModalBottomSheet(
      isScrollControlled: false,
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder: (context) => Column(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(bottomSheetTitle.value,
                      style: MyTheme.chatSenderName))),
          ListView.builder(
              shrinkWrap: true,
              itemCount: _choiceValues.length,
              itemBuilder: (context, index) {
                switch (index) {
                  case 1:
                    {
                      var title = _choiceValues[index].label;

                      Options options = _choiceValues[index].meta as Options;
                      isSelectedForSecondOption = RxList(List.generate(
                          options.temperature!.length, (index) => false));

                      return Container(
                          padding: const EdgeInsets.all(7),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [

                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.visible,
                                        style: MyTheme.chatConversation,)),
                              const SizedBox(height: 5),
                              LayoutBuilder(builder: (context, constraints) {
                                return Obx(() => ToggleButtons(
                                      constraints: BoxConstraints.expand(
                                          width: (constraints.maxWidth / 4) -
                                              (5 / 4),
                                          height: 45),
                                      borderColor: MyTheme.kDarkGrey,
                                      children:
                                          options.temperature!.map<Widget>((s) {
                                        return getTabWidget(
                                            s,
                                            isSelectedForSecondOption[options
                                                .temperature!
                                                .indexOf(s)]);
                                      }).toList(),
                                      onPressed: (int index) {
                                        valueForSecondComponent =
                                            "$title - ${options.temperature![index]}";
                                        for (int buttonIndex = 0;
                                            buttonIndex <
                                                isSelectedForSecondOption
                                                    .length;
                                            buttonIndex++) {
                                          if (buttonIndex == index) {
                                            isSelectedForSecondOption[
                                                    buttonIndex] =
                                                !isSelectedForSecondOption[
                                                    buttonIndex];
                                          } else {
                                            isSelectedForSecondOption[
                                                buttonIndex] = false;
                                          }
                                        }
                                      },
                                      isSelected: isSelectedForSecondOption,
                                    ));
                              }),
                            ],
                          ));
                    }
                  case 2:
                    {
                      var title = _choiceValues[index].label;

                      Options options = _choiceValues[index].meta as Options;
                      isSelectedForThirdOption = RxList(List.generate(
                          options.temperature!.length, (index) => false));
                      return Container(
                          padding: const EdgeInsets.all(7),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                               /* Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                  style: MyTheme.chatConversation,
                                ),*/
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(title,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.visible,
                                          style: MyTheme.chatConversation,)),
                                const SizedBox(height: 5),
                                LayoutBuilder(builder: (context, constraints) {
                                  return Obx(() => ToggleButtons(
                                        constraints: BoxConstraints.expand(
                                            width: (constraints.maxWidth / 4) -
                                                (5 / 4),
                                            height: 45),
                                        borderColor: MyTheme.kDarkGrey,
                                        children: options.temperature!
                                            .map<Widget>((s) {
                                          return getTabWidget(
                                              s,
                                              isSelectedForThirdOption[options
                                                  .temperature!
                                                  .indexOf(s)]);
                                        }).toList(),
                                        onPressed: (int index) {
                                          valueForThirdComponent =
                                              "$title - ${options.temperature![index]}";
                                          for (int buttonIndex = 0;
                                              buttonIndex <
                                                  isSelectedForThirdOption
                                                      .length;
                                              buttonIndex++) {
                                            if (buttonIndex == index) {
                                              isSelectedForThirdOption[
                                                      buttonIndex] =
                                                  !isSelectedForThirdOption[
                                                      buttonIndex];
                                            } else {
                                              isSelectedForThirdOption[
                                                  buttonIndex] = false;
                                            }
                                          }
                                        },
                                        isSelected: isSelectedForThirdOption,
                                      ));
                                }),
                                // LayoutBuilder(builder:
                                //     (context, constraints) {
                                //   return Obx(() => ToggleButtons(
                                //         children: options
                                //             .temperature!
                                //             .map<Widget>((s) => getTabWidget(
                                //                 s,
                                //                 isSelectedForSecondOption[
                                //                     options
                                //                         .temperature!
                                //                         .indexOf(
                                //                             s)]))
                                //             .toList(),
                                //         onPressed: (int index) {
                                //           valueForThirdComponent =
                                //               "$title - ${options.temperature![index]}";
                                //           for (int buttonIndex = 0;
                                //               buttonIndex <
                                //                   isSelectedForThirdOption
                                //                       .length;
                                //               buttonIndex++) {
                                //             if (buttonIndex ==
                                //                 index) {
                                //               isSelectedForThirdOption[
                                //                       buttonIndex] =
                                //                   !isSelectedForThirdOption[
                                //                       buttonIndex];
                                //             } else {
                                //               isSelectedForThirdOption[
                                //                       buttonIndex] =
                                //                   false;
                                //             }
                                //           }
                                //         },
                                //         isSelected:
                                //             isSelectedForThirdOption,
                                //       ));
                                // })
                              ]));
                    }
                  default:
                    {
                      final RxList<int> numericalValues = RxList(
                          _determineDropDownValueForTimeUnit(
                              "Days", _choiceValues[index].meta));
                      initialValueForNumeric.value = numericalValues[0];
                      var dataSetForString =
                          getTimeUnit(_choiceValues[index].meta);
                      initialValueForString =
                          dataSetForString.keys.elementAt(0);
                      var title = _choiceValues[index].label;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(title,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                    style: MyTheme.chatConversation,)),
                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Obx(() {
                                return Flexible(
                                    fit: FlexFit.loose,
                                    flex: 1,
                                    child: NumberValueSelector(
                                      data: numericalValues,
                                      initialValue:
                                          initialValueForNumeric.value,
                                      label: title,
                                      onSelectedValue: (selectedValue) {
                                        _timeValueSelected.value =
                                            selectedValue;
                                        initialValueForNumeric.value =
                                            int.parse(selectedValue);
                                      },
                                    ));
                              }),
                              Flexible(
                                  fit: FlexFit.loose,
                                  flex: 1,
                                  child: StringValueSelector(
                                    data: dataSetForString,
                                    initialValue: initialValueForString,
                                    label: title,
                                    onSelectedValue: (selectedValue) {
                                      initialValueForString = selectedValue;
                                      _timeUnitSelected.value = selectedValue;
                                      valueForFirstComponent =
                                          "$title details \n";
                                      numericalValues.value =
                                          _determineDropDownValueForTimeUnit(
                                              _timeUnitSelected.value,
                                              _choiceValues[index].meta);
                                      initialValueForNumeric.value =
                                          numericalValues[0];
                                    },
                                  ))
                            ],
                          ),
                        ],
                      );
                    }
                }
              }),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(2),
            child: ElevatedButton(
              child: Text('Submit',
                  style:
                      MyTheme.chatSenderName.copyWith(color: MyTheme.kWhite)),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(MyTheme.kRedish)),
              onPressed: () async {
                ValueHolderForBot holderForBot = ValueHolderForBot();

                valueForFirstComponent = initialValueForString +
                    " " +
                    initialValueForNumeric.toString();
                holderForBot.firstValue = valueForFirstComponent;
                holderForBot.secondValue = valueForSecondComponent;
                holderForBot.thirdValue = valueForThirdComponent;
                holderForBot.valueTag = bottomSheetTitle.value;
                String valueToSend = "Details \n" +
                    valueForFirstComponent +
                    "\n" +
                    valueForSecondComponent +
                    "\n" +
                    valueForThirdComponent;

                _bottomSheetValueSelection.clear();

                _choiceValues.clear();

                await _sendMessage(valueToSend);
                Get.back();

                Future.delayed(const Duration(milliseconds: 250), () {
                  if (_multipleValueQueue.isNotEmpty) {
                    _isWaitForAnotherMessage.value = true;
                  }
                });
              },
            ),
          )
        ],
      ),
    );
  }

/*@override
  String? get restorationId => 'chat_room';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(msgController.chatMessageHolder.value, 'chat_conversation');
  }*/
}

class StringValueSelector extends StatelessWidget {
  final buttonPadding = const EdgeInsets.fromLTRB(0, 0, 0, 0);

  // final List<int> data;
  final Map<String, int> data;
  final String label;
  final Function(String) onSelectedValue;
  final initialValue;

  final _currentHorizontalIntValue = 0.obs;

  StringValueSelector(
      {Key? key,
      required this.data,
      required this.initialValue,
      required this.label,
      required this.onSelectedValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _currentHorizontalIntValue.value = data[initialValue]!;
    return Column(
      children: [
        /*  Container(
            alignment: AlignmentDirectional.centerStart,
            margin: const EdgeInsets.only(left: 4),
            child: Text(label)),*/
        Padding(
          padding: buttonPadding,
          child: Container(
            decoration: _getShadowDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Padding(
                        child: Obx(() => NumberPicker(
                              value: _currentHorizontalIntValue.value,
                              minValue: data.values.elementAt(0),
                              maxValue: data.values.elementAt(data.length - 1),
                              step: 1,
                              textMapper: (s) {
                                return data.keys.elementAt(
                                    data.values.toList().indexOf(int.parse(s)));
                              },
                              axis: Axis.vertical,
                              onChanged: (value) {
                                _currentHorizontalIntValue.value = value;

                                onSelectedValue
                                    .call(data.keys.elementAt(value - 1));
                              },
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black26),
                              ),
                            )),
                        padding: const EdgeInsets.only(left: 12))),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _getDropdownIcon(),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        itemHeight: 56,
        value: value,
        itemBuilder: (context, value) {
          return Text(value);
        });
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.white.withOpacity(0.06),
          spreadRadius: 4,
          offset: const Offset(0.0, 0.0),
          blurRadius: 15.0,
        ),
      ],
    );
  }

  Widget _getDropdownIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            color: MyTheme.kRedish,
            child: IconButton(
              focusColor: MyTheme.kRedish,
              onPressed: () {
                if ((_currentHorizontalIntValue.value - 1) > 0) {
                  _currentHorizontalIntValue.value =
                      _currentHorizontalIntValue.value - 1;
                  onSelectedValue.call(data.keys
                      .elementAt(_currentHorizontalIntValue.value - 1));
                }
              },
              icon: Icon(
                Icons.keyboard_arrow_up_sharp,
                color: MyTheme.kWhite,
              ),
            )),
        const SizedBox(
          height: 10,
        ),
        Container(
            color: MyTheme.kRedish,
            child: IconButton(
              onPressed: () {
                if (_currentHorizontalIntValue.value != (data.length)) {
                  _currentHorizontalIntValue.value =
                      _currentHorizontalIntValue.value + 1;
                  onSelectedValue.call(data.keys
                      .elementAt(_currentHorizontalIntValue.value - 1));
                }
              },
              icon: Icon(
                Icons.keyboard_arrow_down_sharp,
                color: MyTheme.kWhite,
              ),
            ))
      ],
    );
    /*return const Icon(
      Icons.unfold_more,
      color: Colors.blueAccent,
    );*/
  }
}

class NumberValueSelector extends StatelessWidget {
  final buttonPadding = const EdgeInsets.fromLTRB(0, 0, 0, 0);

  final List<int> data;

  // final Map<String, int> data;
  final String label;
  final Function(String) onSelectedValue;
  final int initialValue;
  final _currentHorizontalIntValue = 0.obs;

  NumberValueSelector(
      {Key? key,
      required this.data,
      required this.initialValue,
      required this.label,
      required this.onSelectedValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _currentHorizontalIntValue.value = initialValue;
    return Column(
      children: [
        // Container(
        //   alignment: AlignmentDirectional.centerStart,
        //   margin: const EdgeInsets.only(left: 4),
        //   child: Text(label)),
        Padding(
          padding: buttonPadding,
          child: Container(
            decoration: _getShadowDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Padding(
                        child: Obx(() {
                          var currentValue = _currentHorizontalIntValue.value;

                          return NumberPicker(
                            value: currentValue,
                            minValue: data[0],
                            maxValue: data[data.length - 1],
                            step: 1,
                            axis: Axis.vertical,
                            onChanged: (value) {
                              _currentHorizontalIntValue.value = value;
                              onSelectedValue.call(value.toString());
                            },
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                          );
                        }),
                        padding: const EdgeInsets.only(left: 12))),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _getDropdownIcon(),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.white.withOpacity(0.06),
          spreadRadius: 4,
          offset: const Offset(0.0, 0.0),
          blurRadius: 15.0,
        ),
      ],
    );
  }

  Widget _getDropdownIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            color: MyTheme.kRedish,
            child: IconButton(
              focusColor: MyTheme.kRedish,
              onPressed: () {
                if (_currentHorizontalIntValue.value != (data.length)) {
                  _currentHorizontalIntValue.value =
                      _currentHorizontalIntValue.value + 1;
                }
              },
              icon: Icon(
                Icons.add,
                color: MyTheme.kWhite,
              ),
            )),
        const SizedBox(
          height: 10,
        ),
        Container(
            color: MyTheme.kRedish,
            child: IconButton(
              onPressed: () {
                if ((_currentHorizontalIntValue.value - 1) > 0) {
                  _currentHorizontalIntValue.value =
                      _currentHorizontalIntValue.value - 1;
                }
              },
              icon: Icon(
                Icons.remove,
                color: MyTheme.kWhite,
              ),
            ))
      ],
    );
    /*return const Icon(
      Icons.unfold_more,
      color: Colors.blueAccent,
    );*/
  }
}
