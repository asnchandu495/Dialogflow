import 'package:get/get.dart';

import 'package:sumed/models/message_model.dart';

import '../models/user_model.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';

class Conversation extends StatelessWidget {
  Conversation({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;
  final ScrollController _controller = ScrollController();


  void moveToEndOfList() {
    Future.delayed(const Duration(milliseconds: 250), () {
      try {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    moveToEndOfList();
    final msgController = Get.put(MessageController());
    msgController.chatMessageHolder.listen((val) {
      moveToEndOfList();
    });

    return GetBuilder<MessageController>(
        init: MessageController(),
        builder: (context) {
          return Obx(() => ListView.builder(
              // reverse: true,
              controller: _controller,
              itemCount: msgController.chatMessageHolder.value.value.length,
              itemBuilder: (context, int index) {
                final message = msgController.chatMessageHolder.value.value[index];
                bool isMe = message.sender.id == currentUser.id;
                final String userName =
                    msgController.chatMessageHolder.value.value[index].sender.name + "\n";
                String text = msgController.chatMessageHolder.value.value[index].text;
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              radius: 15,
                              backgroundImage: AssetImage(user.avatar),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                              padding: const EdgeInsets.all(10),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6),
                              decoration: BoxDecoration(
                                  color: isMe
                                      ? MyTheme.kAccentColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 12 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 12),
                                  )),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: userName,
                                        style: MyTheme.bodyTextMessage.copyWith(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.grey[800],
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: text,
                                        style: MyTheme.bodyTextMessage.copyWith(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.grey[800],
                                        )),
                                  ],
                                ),
                              )),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isMe)
                              const SizedBox(
                                width: 40,
                              ),
                            Icon(
                              Icons.done_all,
                              size: 20,
                              color: MyTheme.bodyTextTime.color,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              message.time,
                              style: MyTheme.bodyTextTime,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }));
        });
    /*return Obx(() => ListView.builder(
        // reverse: true,
        controller: _controller,
        itemCount: messages.length,
        itemBuilder: (context, int index) {
          final message = messages[index];
          bool isMe = message.sender.id == currentUser.id;
          final String userName = messages[index].sender.name + "\n";
          String text = messages[index].text;
          return Container(
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isMe)
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage(user.avatar),
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        decoration: BoxDecoration(
                            color:
                                isMe ? MyTheme.kAccentColor : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            )),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: userName,
                                  style: MyTheme.bodyTextMessage.copyWith(
                                      color: isMe
                                          ? Colors.white
                                          : Colors.grey[800],
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: text,
                                  style: MyTheme.bodyTextMessage.copyWith(
                                    color:
                                        isMe ? Colors.white : Colors.grey[800],
                                  )),
                            ],
                          ),
                        ) */ /*Text(
                        messages[index].sender.name +
                            "\n" +
                            messages[index].text,
                        style: MyTheme.bodyTextMessage.copyWith(
                            color: isMe ? Colors.white : Colors.grey[800]),
                      ),*/ /*
                        ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isMe)
                        const SizedBox(
                          width: 40,
                        ),
                      Icon(
                        Icons.done_all,
                        size: 20,
                        color: MyTheme.bodyTextTime.color,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        message.time,
                        style: MyTheme.bodyTextTime,
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }));*/
  }
}
