import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../services/messages_service.dart'; // Import the MessageService
import '../services/signal_r_service.dart';

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
  final SignalRService _signalRService = SignalRService();
  final TextEditingController _messageController = TextEditingController();
  final List<dynamic> _messages = [];
  int userId = 1;

  @override
  void initState() {
    super.initState();
    _initializeSignalR();
    _loadMessages();
  }

  Future<void> _initializeSignalR() async {
    try {
      await _signalRService.startConnection(userId.toString());

      _signalRService.onReceiveMessage((senderId, messageText) async {
        if (senderId == widget.receiverId) {
          final timestamp = DateTime.now().toIso8601String();
          final newMessage = {
            'senderId': senderId,
            'receiverId': userId,
            'messageText': messageText,
            'timestamp': timestamp,
          };

          // Update the UI
          setState(() {
            _messages.add(newMessage);
          });
        }
      });
    } catch (e) {
      print("SignalR initialization failed: $e");
    }
  }

  /// Load messages from local database and server
  Future<void> _loadMessages() async {
    try {
      // Fetch server messages
      final serverMessages =
          await MessageService.getMessageHistory(userId, widget.receiverId);

      setState(() {
        _messages.clear();
        _messages.addAll(serverMessages);
      });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  /// Send a message using SignalR
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final messageText = _messageController.text.trim();
      final timestamp = DateTime.now().toIso8601String();

      try {
        // Send message via SignalR
        await _signalRService.sendMessage(
            userId, widget.receiverId, messageText);

        final newMessage = {
          'senderId': userId,
          'receiverId': widget.receiverId,
          'messageText': messageText,
          'timestamp': timestamp,
        };

        // Update the chat UI
        setState(() {
          _messages.add(newMessage);
        });

        _messageController.clear(); // Clear the message input field
      } catch (e) {
        print('Failed to send message: $e');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _signalRService.stopConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '${widget.postOwnerName} ile Mesajlaşma'),
      body: Container(
        color: const Color(0xFF363C3E),
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
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF2196F3),
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
