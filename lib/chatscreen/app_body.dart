import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sumed/customfunctionality/generate_chip.dart';
import 'package:sumed/models/custom_payload.dart';

class AppBody extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  // final RxList<RxMap<String, dynamic>> messages;
  final Function(String) onSelection;
  final Function(List<String> extraMessage) onExtraMessage;

  const AppBody(
      {Key? key,
      required this.messages,
      required this.onSelection,
      required this.onExtraMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, i) {
        var obj = messages.toList()[messages.toList().length - 1 - i];
        Message message = obj['message'] ?? Message();
        bool isUserMessage = obj['isUserMessage'] ?? false;
        return Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MessageContainer(
              message: message,
              isUserMessage: isUserMessage,
              onSelection: onSelection,
              onExtraMessage: onExtraMessage,
            ),
          ],
        );
      },
      separatorBuilder: (_, i) => Container(height: 10),
      itemCount: messages.toList().length,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
    );
  }
}

class _MessageContainer extends StatelessWidget {
  final Message message;
  final bool isUserMessage;
  final Function(String) onSelection;
  final Function(List<String> extraMessage) onExtraMessage;

  _MessageContainer(
      {Key? key,
      required this.message,
      this.isUserMessage = false,
      required this.onSelection,
      required this.onExtraMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: LayoutBuilder(
        builder: (context, constrains) {
          if (kDebugMode) {
            print("Message type is ${message.type}");
            print("Message type is ${message.text.toString()}");
          }
          switch (message.type) {
            case MessageType.payload:
              if (message.payload != null) {
                List<String> values = _parsePayload(message.payload!);
                // _isCalled = false;

                String caption = values.removeAt(0);
                // return const SizedBox();

                onExtraMessage.call(values);

                return chipList(values, onSelection, caption);
              } else {
                return SizedBox();
              }
            case MessageType.card:
              return _CardContainer(card: message.card!);
            case MessageType.text:
            default:
              return Container(
                decoration: BoxDecoration(
                  color: isUserMessage ? Colors.teal : Colors.brown,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Text(
                  message.text?.text?[0] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  chipList(
      List<String> values, Function(String) onSelection, String extraMessage) {
    return Column(
      children: [
        /*Text(extraMessage),*/
        Container(
          decoration: BoxDecoration(
            color: isUserMessage ? Colors.teal : Colors.brown,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(10),
          child: Text(
            extraMessage,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        _formGroupOfChips(values)
      ],
    );
  }

  _formGroupOfChips(List<String> values) {
    return Wrap(
        spacing: 6.0,
        runSpacing: 6.0,
        children: values.map((value) {
          return buildChip(value, false, onSelection);
        }).toList());
  }

  // bool _isCalled = false;

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
}

class _CardContainer extends StatelessWidget {
  final DialogCard card;

  const _CardContainer({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lime,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.imageUri != null)
            Container(
              constraints: const BoxConstraints.expand(height: 150),
              child: Image.network(
                card.imageUri!,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.title ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (card.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      card.subtitle!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                if (card.buttons?.isNotEmpty ?? false)
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 40,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      // padding: const EdgeInsets.symmetric(vertical: 5),
                      itemBuilder: (context, i) {
                        CardButton button = card.buttons![i];
                        return TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(button.text ?? ''),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(button.postback ?? ''),
                            ));
                          },
                        );
                      },
                      separatorBuilder: (_, i) => Container(width: 10),
                      itemCount: card.buttons!.length,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
