import 'package:dialog_flowtter/dialog_flowtter.dart' as dialogFlow;
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dialogFlow.DialogFlowtter.fromFile().then((instance) {
      dialogFlowtter = instance;
      Future.delayed(const Duration(seconds: 1), () {
        _checkForMessage("Hello");
      });
    });
  }

  List<String> determineMessageType(dialogFlow.Message message) {
    List<String> values = [];
    switch (message.type) {
      case dialogFlow.MessageType.payload:
        if (message.payload != null) {
          values.add("1");
          values.addAll(_parsePayload(message.payload!));

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

  List<String> _parsePayload(Map<String, dynamic> payload) {
    List<String> values = [];
    CustomPayload receivedPayload = CustomPayload.fromJson(payload);
    /*if (!_isCalled) {
      onExtraMessage.call(receivedPayload.contentTitle!);
      _isCalled = true;
    }*/
    values.add(receivedPayload.contentTitle!);
    for (var element in receivedPayload.richContent!) {
      for (var innerElement in element) {
        if (innerElement.type! == "list") values.add(innerElement.title!);
      }
    }
    return values;
  }

  Future<void> _checkForMessage(text, [bool isUserMessage = false]) async {
    dialogFlow.DetectIntentResponse response =
        await dialogFlowtter.detectIntent(
      queryInput: dialogFlow.QueryInput(text: dialogFlow.TextInput(text: text)),
    );

    if (response.message == null) return;

    // msgController.messages
    addMessage(response.message!, isUserMessage);
  }

  Future<void> addMessage(dialogFlow.Message message,
      [bool isUserMessage = false]) async {
    print("********** ${message.toString()}");
    String textToDisplay = "";
    if (!isUserMessage) {
      List<String> values = determineMessageType(message);
      String typeOfMessage = values.removeAt(0);
      textToDisplay = values[0];
    } else {
      textToDisplay = message.text!.text![0].toString();
    }

    var appMsgs = appMessage.Message(
        sender: isUserMessage ? currentUser : botSuMed,
        avatar: isUserMessage ? currentUser.avatar : botSuMed.avatar,
        text: textToDisplay,
        time: DateTime.now().hour.toString() +
            " " +
            DateTime.now().minute.toString(),
        isRead: true,
        unreadCount: 0);
    msgController.messages.add(appMsgs);
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
                  style: MyTheme.chatSenderName.copyWith(color: Colors.grey),
                ),
                Text(
                  'online',
                  style: MyTheme.bodyText1
                      .copyWith(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      backgroundColor: MyTheme.kPrimaryColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
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
            buildChatComposer()
          ],
        ),
      ),
    );
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
          ElevatedButton.icon(
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              sendMessage(chatController.text);
              /* msgController.messages.add(appMessage.Message(
                  sender: currentUser,
                  avatar: '',
                  text: chatController.text,
                  time: DateTime.now().hour.toString() +
                      " " +
                      DateTime.now().minute.toString(),
                  isRead: true,
                  unreadCount: 0));*/

              /*  msgController.messages.add(appMessage.Message(
                  sender: botSuMed,
                  avatar: '',
                  text: "SuMed Text",
                  time: DateTime.now().hour.toString() +
                      " " +
                      DateTime.now().minute.toString(),
                  isRead: true,
                  unreadCount: 0));*/
              // setState(() {
              chatController.clear();
              // });
            },
            label: const Text("Send"),
          )
        ],
      ),
    );
  }
}
