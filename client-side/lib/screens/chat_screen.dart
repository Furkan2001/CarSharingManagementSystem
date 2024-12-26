import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../services/messages_service.dart'; // Import the MessageService

class ChatScreen extends StatefulWidget {
  final String postOwnerName;
  final int receiverId; // Receiver's ID

  const ChatScreen(
      {Key? key, required this.postOwnerName, required this.receiverId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<dynamic> _messages = [];
  int userId =
      1; // Assuming the current user's ID is 2. You can replace this with dynamic user ID if needed.

  @override
  void initState() {
    super.initState();
    _loadMessageHistory(); // Load message history between current user and receiver
  }

  Future<void> _loadMessageHistory() async {
    try {
      ;

      // Load messages from the server
      var messageHistory =
          await MessageService.getMessageHistory(userId, widget.receiverId);

      // Combine the messages from the local database and the server

      // Remove duplicates based on 'messageId' and sort by 'time'
      // var uniqueMessages = {};
      // for (var message in allMessages) {
      //   uniqueMessages[message['messageId']] = message;  // Use messageId as the key to ensure uniqueness
      // }

      // Sort messages by time (ascending order)
      //sortedMessages.sort((a, b) => DateTime.parse(a['time']).compareTo(DateTime.parse(b['time'])));

      setState(() {
        _messages.clear(); // Clear existing messages
        _messages.addAll(
            messageHistory); // Add the sorted, unique messages to the list
      });
    } catch (e) {
      print('Error loading message history: $e');
    }
  }

  // Send a message
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final messageText = _messageController.text.trim();

      // Send the message via the MessageService
      bool success = await MessageService.sendMessage(
          userId, widget.receiverId, messageText);

      if (success) {
        setState(() {
          // Add the sent message to the local message list
          _messages.add({'sender': userId, 'message': messageText});
        });
        _messageController.clear(); // Clear the message input field
      } else {
        // Show an error message if sending fails
        print('Failed to send message');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '${widget.postOwnerName} ile Mesajlaşma'),
      body: Container(
        color: const Color(0xFF363C3E), // Background color for the chat screen
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isSender = message['senderId'] == userId;
                  return Align(
                    alignment:
                        isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isSender
                            ? const Color(0xFF4CAF50) // Green for sender
                            : const Color(0xFF2196F3), // Blue for receiver
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12.0),
                          topRight: const Radius.circular(12.0),
                          bottomLeft: isSender
                              ? const Radius.circular(12.0)
                              : Radius.zero,
                          bottomRight: isSender
                              ? Radius.zero
                              : const Radius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        '${message['messageText']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Mesaj girin',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF424242),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
