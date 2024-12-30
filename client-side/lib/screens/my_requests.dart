import 'package:flutter/material.dart';
import '../services/requests_service.dart';
import '../widgets/menu_widget.dart';
import '../widgets/custom_appbar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'chat_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  final int userId;

  const MyRequestsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _myRequestsToOthers = [];
  List<dynamic> _othersRequestsToMe = [];

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchMyRequests();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null); // Initialize Turkish locale
  }

  Future<void> _fetchMyRequests() async {
    try {
      final requests = await RequestsService.getMyRequests(widget.userId);
      if (requests != null) {
        setState(() {
          _myRequestsToOthers =
              requests.where((r) => r['senderId'] == widget.userId).toList();
          _othersRequestsToMe =
              requests.where((r) => r['receiverId'] == widget.userId).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update the request status
  Future<void> _updateRequestStatus(int requestId, int statusId) async {
    try {
      // Find the request in both lists (_myRequestsToOthers and _othersRequestsToMe)
      var request = _myRequestsToOthers.firstWhere(
              (r) => r['requestId'] == requestId,
              orElse: () => null) ??
          _othersRequestsToMe.firstWhere((r) => r['requestId'] == requestId,
              orElse: () => null);

      if (request == null) {
        // If the request wasn't found in either list
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Request not found!')));
        return;
      }

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
          // Update the status in the correct list (_myRequestsToOthers or _othersRequestsToMe)
          if (_myRequestsToOthers.contains(request)) {
            var index = _myRequestsToOthers
                .indexWhere((r) => r['requestId'] == requestId);
            if (index != -1) {
              _myRequestsToOthers[index]['statusId'] = statusId;
            }
          } else if (_othersRequestsToMe.contains(request)) {
            var index = _othersRequestsToMe
                .indexWhere((r) => r['requestId'] == requestId);
            if (index != -1) {
              _othersRequestsToMe[index]['statusId'] = statusId;
            }
          }
        });
      }
    } catch (e) {
      print('Error updating request: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update request.')));
    }
  }

  // Add delete request function
  Future<void> _deleteRequest(int requestId, bool isOutgoing) async {
    try {
      // Find the request in the correct list (outgoing or incoming)
      var request = isOutgoing
          ? _myRequestsToOthers.firstWhere((r) => r['requestId'] == requestId,
              orElse: () => null)
          : _othersRequestsToMe.firstWhere((r) => r['requestId'] == requestId,
              orElse: () => null);

      if (request == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request not found!')),
        );
        return;
      }

      // Prepare the updated data with correct field set for deletion
      Map<String, dynamic> updatedData = {
        "requestId": request['requestId'],
        "journeyId": request['journeyId'],
        "senderId": request['sender']['userId'],
        "receiverId": request['receiver']['userId'],
        "time": request['time'],
        "statusId": 3, // Mark as "rejected" for deletion
        "receiverIsDeleted": isOutgoing ? request['receiverIsDeleted'] : true,
        "senderIsDeleted": isOutgoing ? true : request['senderIsDeleted'],
        "sender": request['sender'],
        "receiver": request['receiver'],
      };

      // Call the API to update the request
      bool success =
          await RequestsService.updateRequest(requestId, updatedData);

      if (success) {
        setState(() {
          // Remove the deleted request from the appropriate list
          if (isOutgoing) {
            _myRequestsToOthers.removeWhere((r) => r['requestId'] == requestId);
          } else {
            _othersRequestsToMe.removeWhere((r) => r['requestId'] == requestId);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete request.')),
        );
      }
    } catch (e) {
      print('Error deleting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while deleting the request.')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'acceptance':
        return Colors.green;
      case 'reject':
        return Colors.red;
      default:
        return Colors.blue; // Assuming 'wait' or any other status
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
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    // "My Requests to Others" Section
                    if (_myRequestsToOthers.isNotEmpty) ...[
                      const Text(
                        'İsteklerim',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      ..._myRequestsToOthers.map((request) {
                        final timeString = request['time'] ?? 'N/A';
                        final formattedTime = timeString != 'N/A'
                            ? DateFormat('dd MMMM yyyy HH:mm', 'tr')
                                .format(DateTime.parse(timeString))
                            : 'N/A';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                  '${request['receiver']['name']} ${request['receiver']['surname']}'),
                              subtitle: Text(formattedTime),
                              trailing: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Ensure the Row fits its children
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        () {}, // Status button does not perform any action here
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getStatusColor(
                                          request['status']['statusName']),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                    child: Text(
                                      request['status']['statusName'] ==
                                              'acceptance'
                                          ? 'Kabul Edildi'
                                          : request['status']['statusName'] ==
                                                  'reject'
                                              ? 'Reddedildi'
                                              : 'Bekliyor',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 8), // Space between buttons
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.grey),
                                    onPressed: () => _deleteRequest(
                                        request['requestId'],
                                        true), // Outgoing request
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],

                    // "Other People's Requests to Me" Section
                    if (_othersRequestsToMe.isNotEmpty) ...[
                      const Text(
                        'Gelen İstekler',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      ..._othersRequestsToMe.map((request) {
                        final timeString = request['time'] ?? 'N/A';
                        final formattedTime = timeString != 'N/A'
                            ? DateFormat('dd MMMM yyyy HH:mm', 'tr')
                                .format(DateTime.parse(timeString))
                            : 'N/A';

                        var status = "beklemede";

                        if (request['statusId'] == 2) {
                          status = "Onaylandı";
                        } else if (request['statusId'] == 3) {
                          status = "Reddedildi";
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                  '${request['sender']['name']} ${request['sender']['surname']} ($status)'),
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
                                                0,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.grey),
                                    onPressed: () => _deleteRequest(
                                        request['requestId'],
                                        false), // Incoming request
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
