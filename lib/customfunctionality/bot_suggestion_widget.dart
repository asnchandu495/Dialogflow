class BotSuggestions {
  List<String> suggestions = [];

  BotSuggestions(List<dynamic> messages) {
    for (var message in messages) {
      if (message['payload'] != null) {
        List<dynamic> suggestionList = message['payload']['suggestions'];
        suggestionList.forEach((suggestion) => suggestions.add(suggestion));
      }
    }
  }
}