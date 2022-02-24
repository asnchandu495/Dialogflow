import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:sumed/models/message_model.dart';

/*
class ChatMessageHolder extends RestorableValue<Map<String, List<Message>>> {
  @override
  Map<String, List<Message>> createDefaultValue() => {};

  @override
  void didUpdateValue(Map<String, List<Message>>? oldValue) {
    List<bool> compareValue =
        List.generate(oldValue!.keys.length, (index) => false);
    int countI = 0;
    for (var element in oldValue.keys) {
      compareValue[countI] =
          oldValue[element]!.length != value[element]!.length;
      countI++;
    }
    for (var element in compareValue) {
      if (element) {
        notifyListeners();
      }
    }
  }

  @override
  Object? toPrimitives() {
    // TODO: implement toPrimitives
    throw UnimplementedError();
  }

  @override
  Map<String, List<Message>> fromPrimitives(Object? data) {
    // TODO: implement fromPrimitives
    throw UnimplementedError();
  }
}
*/

class ChatMessageHolder extends RestorableValue<RxList<Message>> {
  @override
  RxList<Message> createDefaultValue() =>
      value.isEmpty ? RxList<Message>() : value;

  @override
  void didUpdateValue(RxList<Message>? oldValue) {
    /* List<bool> compareValue =
    List.generate(oldValue!.keys.length, (index) => false);
    int countI = 0;
    for (var element in oldValue.keys) {
      compareValue[countI] =
          oldValue[element]!.length != value[element]!.length;
      countI++;
    }
    for (var element in compareValue) {
      if (element) {
        notifyListeners();
      }
    }*/

    if (oldValue!.length != value.length) {
      notifyListeners();
    }
  }

  @override
  Object? toPrimitives() {
    // TODO: implement toPrimitives
    throw UnimplementedError();
  }

  @override
  RxList<Message> fromPrimitives(Object? data) {
    // TODO: implement fromPrimitives
    throw UnimplementedError();
  }
}
