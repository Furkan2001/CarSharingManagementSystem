import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import '../services/requests_service.dart';
import '../widgets/menu_widget.dart';
import '../widgets/custom_appbar.dart';
import 'package:intl/intl.dart';

import 'chat_screen.dart';

class RequestPage extends StatefulWidget {
  final int journeyId;

  const RequestPage({Key? key, required this.journeyId}) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  bool _isLoading = true;
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  // Fetch requests for the journey
  Future<void> _fetchRequests() async {
    try {
      final journey = await PostsService.getMyJourneyById(widget.journeyId);
      setState(() {
        _requests = journey['requests'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching journey: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRequest(int requestId, int statusId) async {
    int status;

    if (statusId == 1) {
      status = 3;
    } else {
      status = statusId;
    }

    try {
      // Find the request from the local list using the requestId
      var request = _requests.firstWhere((r) => r['requestId'] == requestId);

      // Prepare the request data with updated status and receiverIsDeleted set to 1
      Map<String, dynamic> updatedData = {
        "requestId": request['requestId'],
        "journeyId": request['journeyId'],
        "senderId": request['sender']['userId'],
        "receiverId": request['receiver']['userId'],
        "time": request['time'],
        "statusId": status,
        "receiverIsDeleted": true,
        "senderIsDeleted": request['senderIsDeleted'],
        "sender": request['sender'],
        "receiver": request['receiver'],
      };

      bool success =
          await RequestsService.updateRequest(requestId, updatedData);

      if (success) {
        setState(() {
          _requests.removeWhere((r) => r['requestId'] == requestId);
        });
      }
    } catch (e) {
      print('Error deleting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete request.')),
      );
    }
  }

  // Update the request status
  Future<void> _updateRequestStatus(int requestId, int statusId) async {
    try {
      // Find the request from the local list using the requestId
      var request = _requests.firstWhere((r) => r['requestId'] == requestId);

      // Prepare the request data to be sent to the API
      Map<String, dynamic> updatedData = {
        "requestId": request['requestId'],
        "journeyId": request['journeyId'],
        "senderId": request['sender']['userId'],
        "receiverId": request['receiver']['userId'],
        "time": request['time'],
        "statusId": statusId,
        "receiverIsDeleted": request['receiverIsDeleted'],
        "senderIsDeleted": request['senderIsDeleted'],
        "sender": request['sender'],
        "receiver": request['receiver'],
      };
      bool success =
          await RequestsService.updateRequest(requestId, updatedData);
      if (success) {
        // If the update is successful, find the request and update its status locally
        setState(() {
          var index = _requests.indexWhere((r) => r['requestId'] == requestId);
          if (index != -1) {
            _requests[index]['statusId'] = statusId;
          }
        });
      }
    } catch (e) {
      print('Error updating request: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update request.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'İstekler'),
      drawer: const Menu(),
      body: Container(
        color: const Color.fromARGB(255, 54, 69, 74),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty
                ? const Center(child: Text('Bu paylaşım için istek yok.'))
                : ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      final senderName = request['sender']['name'] +
                          " " +
                          request['sender']['surname'];
                      var status = "beklemede";

                      if (request['statusId'] == 2) {
                        status = "Onaylandı";
                      } else if (request['statusId'] == 3) {
                        status = "Reddedildi";
                      }

                      final timeString = request['time'] ?? 'N/A';

                      String formattedTime;
                      if (timeString != 'N/A') {
                        final DateTime dateTime = DateTime.parse(timeString);
                        final DateFormat formatter =
                            DateFormat('dd MMMM yyyy HH:mm', 'tr');
                        formattedTime = formatter.format(dateTime);
                      } else {
                        formattedTime = 'N/A';
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text('$senderName - $status'),
                            subtitle: Text(formattedTime),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  onPressed: () => _updateRequestStatus(
                                      request['requestId'], 2),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () => _updateRequestStatus(
                                      request['requestId'], 3),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            postOwnerName: request?['sender']
                                                    ?['username'] ??
                                                'Unknown',
                                            receiverId: request?['sender']
                                                    ?['userId'] ??
                                                0),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.grey),
                                  onPressed: () => _deleteRequest(
                                      request['requestId'],
                                      request['statusId']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
