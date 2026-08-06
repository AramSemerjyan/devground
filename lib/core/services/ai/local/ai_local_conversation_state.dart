class ConversationState {
  final int maxMessages; // Maximum number of messages to keep
  List<Map<String, String>> messages;

  ConversationState(this.maxMessages) : messages = [];

  void addUserMessage(String text) {
    if (messages.length >= maxMessages) {
      messages.removeAt(0); // Remove the oldest message
    }
    messages.add({"role": "user", "content": text});
  }

  void addBotResponse(String response) {
    if (messages.length >= maxMessages) {
      messages.removeAt(0); // Remove the oldest message
    }
    messages.add({"role": "bot", "content": response});
  }
}
