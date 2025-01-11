import 'package:flutter/material.dart';
import '../services/messages_service.dart'; // Import the MessageService
import '../widgets/custom_appbar.dart';
import '../widgets/menu_widget.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> _endMessages = [];
  int _currentUserId =
      1; // Your logged-in user's ID, set this dynamically as needed
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEndMessages(); // Initial load
  }

  Future<void> _loadEndMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var endMessages =
          await MessageService.getEndMessagesForAPerson(_currentUserId);
      setState(() {
        _endMessages = endMessages;
      });
    } catch (e) {
      print('Error loading end messages: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToChatScreen(
      BuildContext context, String postOwnerName, int receiverId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          postOwnerName: postOwnerName,
          receiverId: receiverId,
        ),
      ),
    ).then((_) {
      // Refresh messages when coming back
      _loadEndMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Messages'),
      drawer: const Menu(),
      body: Container(
        color: const Color(0xFF363C3E), // Keeping theme consistent
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(), // Show a loading spinner
              )
            : ListView.separated(
                itemCount: _endMessages.length,
                itemBuilder: (context, index) {
                  final message = _endMessages[index];
                  final isCurrentUserSender =
                      message['senderId'] == _currentUserId;
                  final chatPartner = isCurrentUserSender
                      ? message['receiver']
                      : message['sender'];
                  final messageText = message['messageText'];
                  final time = message['time'];
                  DateTime dateTime =
                      DateTime.parse(time); // Parse the time string
                  String formattedTime = DateFormat('HH:mm').format(
                      dateTime); // Format the time to only include hours and minutes

                  // Check if the message is unread
                  final bool isUnread =
                      message['receiverId'] == _currentUserId &&
                          message['isRead'] == false;

                  return ListTile(
                    leading: isUnread
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[800],
                                child: Text(
                                  chatPartner['name'][0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ],
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: Text(
                              chatPartner['name'][0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                    title: Text(
                      '${chatPartner['name']} ${chatPartner['surname']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      messageText,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      formattedTime,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    onTap: () {
                      _navigateToChatScreen(
                        context,
                        chatPartner['username'],
                        chatPartner['userId'],
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                    color: Colors.white), // Customizing the divider color
                padding:
                    EdgeInsets.zero, // Optional: Adjust padding if necessary
              ),
      ),
    );
  }
}
