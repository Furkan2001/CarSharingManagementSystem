import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../services/messages_service.dart'; // Import the MessageService
import '../services/signal_r_service.dart';
import '../services/auth_service.dart';

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
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController
  final List<dynamic> _messages = [];
  int userId = AuthService().userId ?? -1;

  DateTime eventStart = DateTime.now();
  DateTime eventEnd = DateTime.now();

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

          setState(() {
            _messages.add(newMessage);
          });

          _scrollToBottom(); // Scroll to bottom when a new message is received
        }
      });
    } catch (e) {
      print("SignalR initialization failed: $e");
    }
  }

  Future<void> _loadMessages() async {
    try {
      final serverMessages =
          await MessageService.getMessageHistory(userId, widget.receiverId);

      setState(() {
        _messages.clear();
        _messages.addAll(serverMessages);
      });

      // Scroll to the bottom after loading messages
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final messageText = _messageController.text.trim();
      final timestamp = DateTime.now().toIso8601String();

      try {
        await _signalRService.sendMessage(
            userId, widget.receiverId, messageText);

        final newMessage = {
          'senderId': userId,
          'receiverId': widget.receiverId,
          'messageText': messageText,
          'timestamp': timestamp,
        };

        setState(() {
          _messages.add(newMessage);
        });

        _messageController.clear(); // Clear the input field
        _scrollToBottom(); // Scroll to bottom after sending the message

        print("Message sent at ${DateTime.now()}");
      } catch (e) {
        print('Failed to send message: $e');
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose of the ScrollController
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
                controller: _scrollController, // Attach ScrollController
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
