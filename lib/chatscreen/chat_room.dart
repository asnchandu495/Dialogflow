import 'package:awesome_select/awesome_select.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart' as dialogFlow;
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import 'package:sumed/customfunctionality/chat_composer.dart';
import 'package:sumed/customfunctionality/conversation.dart';
import 'package:sumed/models/custom_payload.dart';
import 'package:sumed/models/message_model.dart' as appMessage;
import 'package:sumed/models/message_model.dart';

import '../app_theme.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key, required this.user}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
  final User user;
}

class _ChatRoomState extends State<ChatRoom> {
  late dialogFlow.DialogFlowtter dialogFlowtter;
  var msgController = Get.put(MessageController());
  var isBottomSheetShow = false.obs;
  var bottomSheetTitle = "".obs;
  RxList<String> bottomSheetValueSelection = RxList();
  RxList<String> multipleValueQueue = RxList();

  RxList<S2Choice<String>> choiceValues = RxList();
  bool _isSingleSelection = false;
  int _layoutType = 0;
  bool _isForName = false;

  RxBool isWaitForAnotherMessage = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dialogFlow.DialogFlowtter.fromFile().then((instance) {
      dialogFlowtter = instance;
      Future.delayed(const Duration(seconds: 1), () {
        _checkForMessage("Hello");

        if (allUserList.isNotEmpty) {
          for (var element in allUserList) {
            choiceValues
                .add(S2Choice(title: element.name, value: element.name));
          }
          _isSingleSelection = true;
          _isForName = true;
          isBottomSheetShow.value = true;
          bottomSheetTitle.value = "Select patient name";
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
          ;

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

  Map<String, dynamic> _parsePayload(Map<String, dynamic> payload) {
    final Map<String, dynamic> map = {};
    List<String> values = [];
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
      }
    }
    map["values"] = values;
    return map;
  }

  _initQueueSendingMessage() {
    isWaitForAnotherMessage.listen((p0) {
      if (p0) {
        bool hasValue = multipleValueQueue.value.isNotEmpty;
        if (hasValue) {
          var valueToSend = multipleValueQueue.value.removeAt(0);
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
    addMessage(response.message!, isUserMessage);

    if (isWaitForAnotherMessage.value) {
      isWaitForAnotherMessage.value = false;
      isWaitForAnotherMessage.value = true;
      if (multipleValueQueue.isEmpty) {
        isWaitForAnotherMessage.value = false;
        multipleValueQueue.close();
      }
    }
  }

  Future<void> addMessage(dialogFlow.Message message,
      [bool isUserMessage = false]) async {
    // print("********** ${message.toString()}");
    String textToDisplay = "";
    if (!isUserMessage) {
      List<String> values = determineMessageType(message);
      String typeOfMessage = values.removeAt(0);
      textToDisplay = values.removeAt(0);
      if (values.isNotEmpty) {
        for (var element in values) {
          choiceValues.add(S2Choice(title: element, value: element));
        }
        isBottomSheetShow.value = true;
        bottomSheetTitle.value = textToDisplay;
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

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      addMessage(
        dialogFlow.Message(text: dialogFlow.DialogText(text: [text])),
        true,
      );

      _checkForMessage(text);

      /*  var appMsgs = appMessage.Message(
          sender: currentUser,
          avatar: currentUser.avatar,
          text: text,
          time: DateTime.now().hour.toString() +
              " " +
              DateTime.now().minute.toString(),
          isRead: true,
          unreadCount: 0);
      msgController.messages.add(appMsgs);*/
    });
  }

  String _getTodayValue() {
    // final df = DateFormat('dd-MM-yyyy hh:mm a');
    final df = DateFormat('dd-MM-yyyy');
    return df.format(DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(
                widget.user.avatar,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  widget.user.name,
                  style: MyTheme.chatSenderName.copyWith(color: Colors.white),
                ),
                Text(
                  'online',
                  style: MyTheme.bodyText1
                      .copyWith(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        elevation: 4,
      ),
      // backgroundColor: MyTheme.kPrimaryColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                    color: MyTheme.kPrimaryColorVariant,
                    borderRadius: const BorderRadius.all(Radius.circular(12))),
                child: Text(_getTodayValue(),
                    style: MyTheme.bodyTextTime.copyWith(
                      color: Colors.white,
                    ))),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Conversation(user: widget.user),
                ),
              ),
            ),
            Obx(() => Visibility(
                visible: !(isBottomSheetShow.value),
                child: buildChatComposer())),
            Obx(() => Visibility(
                  visible: isBottomSheetShow.value,
                  child: _getInputLayout(),
                  /*child: _isSingleSelection
                      ? _smartChipSelectForSingle(_isForName)
                      : _smartSelect(),*/
                ))
          ],
        ),
      ),
    );
  }

  SmartSelect _smartSelect(bool isForProblems) {
    SmartSelect sele = SmartSelect<String>.multiple(
      choiceType: S2ChoiceType.chips,
      title: bottomSheetTitle.value,
      // selectedResolver: ,
      selectedValue: bottomSheetValueSelection.value,
      onChange: (selected) {
        bottomSheetValueSelection.clear();
        bottomSheetValueSelection.addAll(selected!.value!.toList());
        if (isForProblems) {
          multipleValueQueue.clear();
          multipleValueQueue.addAll(bottomSheetValueSelection);
          isForProblems = false;
          _initQueueSendingMessage();
          isWaitForAnotherMessage.value = true;

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
          /*valueToSend = valueToSend.replaceRange(
              valueToSend.length - 1, valueToSend.length - 1, '');*/
        }

        print(
            "SELECTED VALUES = ${bottomSheetValueSelection.value.toString()}");

        // sendMessage(valueToSend);
        _addMessageToConversation(true, valueToSend);
        isBottomSheetShow.value = false;
        choiceValues.clear();
      },
      choiceItems: choiceValues,
      choiceActiveStyle: S2ChoiceStyle(highlightColor: MyTheme.kAccentColor),
      choiceConfig: S2ChoiceConfig(
        type: S2ChoiceType.chips,
        activeStyle: S2ChoiceStyle(
            control: S2ChoiceControl.leading,
            highlightColor: MyTheme.kAccentColor,
            accentColor: MyTheme.kAccentColor,
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
              color: MyTheme.createMaterialColor(MyTheme.kPrimaryColor),
              textColor: MyTheme.kAccentColor,
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
        bottomSheetValueSelection.clear();
        // bottomSheetValueSelection.addAll(selected!.value!.toList());
        sendMessage(selected.value!);
        if (_isForName) {
          currentUser = allUserList
              .firstWhere((element) => element.name == selected.value);
          _isForName = false;
        }
        isBottomSheetShow.value = false;
        choiceValues.clear();
        _isSingleSelection = false;
      },
      choiceItems: choiceValues,
      choiceActiveStyle: S2ChoiceStyle(highlightColor: MyTheme.kAccentColor),
      choiceConfig: S2ChoiceConfig(
        type: S2ChoiceType.chips,
        activeStyle: S2ChoiceStyle(
            control: S2ChoiceControl.leading,
            highlightColor: MyTheme.kAccentColor,
            accentColor: MyTheme.kAccentColor,
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

  Container buildChatComposer() {
    final TextEditingController chatController = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
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
            width: 16,
          ),
          FloatingActionButton(
            onPressed: () {
              sendMessage(chatController.text);
              chatController.clear();
            },
            backgroundColor: MyTheme.kAccentColor,
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _addMessageToConversation(bool isUserMessage, String textToDisplay) {
    var appMsgs = appMessage.Message(
        sender: isUserMessage ? currentUser : botSuMed,
        avatar: isUserMessage ? currentUser.avatar : botSuMed.avatar,
        text: textToDisplay,
        time: _getTimeValue(),
        isRead: true,
        unreadCount: 0);
    msgController.messages.add(appMsgs);
  }

  Widget _getInputLayout() {
    switch (_layoutType) {
      case 1:
        //patch to overcome value assign of selection
        return _smartSelect(true);
      case 0:
      default:
        return _smartChipSelectForSingle(_isForName);
    }
  }
}
