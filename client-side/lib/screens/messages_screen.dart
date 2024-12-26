import 'package:flutter/material.dart';
import '../services/messages_service.dart';  // Import the MessageService
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
  int _currentUserId = 2;  // Your logged-in user's ID, set this dynamically as needed

  @override
  void initState() {
    super.initState();
    _loadEndMessages();
  }

  Future<void> _loadEndMessages() async {
    try {
      var endMessages = await MessageService.getEndUnreadedMessagesForAPerson(_currentUserId);
      setState(() {
        _endMessages = endMessages;
      });
    } catch (e) {
      print('Error loading end messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Messages'),
      drawer: const Menu(),
      body: Container(
        color: const Color(0xFF363C3E),  // Keeping theme consistent
        child: ListView.separated(
          itemCount: _endMessages.length,
          itemBuilder: (context, index) {
            final message = _endMessages[index];
            final isCurrentUserSender = message['senderId'] == _currentUserId;
            final chatPartner = isCurrentUserSender ? message['receiver'] : message['sender'];
            final messageText = message['messageText'];
            final time = message['time'];
            DateTime dateTime = DateTime.parse(time);  // Parse the time string
            String formattedTime = DateFormat('HH:mm').format(dateTime);  // Format the time to only include hours and minutes


            return ListTile(
              title: Text(chatPartner['name'] + ' ' + chatPartner['surname'], style: TextStyle(color: Colors.white)),
              subtitle: Text(messageText, style: TextStyle(color: Colors.grey)),
              trailing: Text(formattedTime, style: TextStyle(color: Colors.grey[400])),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                  postOwnerName: chatPartner['username'], 
                  receiverId: chatPartner['userId'],
                )));
              },
            );
          },
          separatorBuilder: (context, index) => Divider(color: Colors.white),  // Customizing the divider color
          padding: EdgeInsets.zero,  // Optional: Adjust padding if necessary
        ),
      ),
    );
  }
}
