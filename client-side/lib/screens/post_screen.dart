import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:intl/date_symbol_data_local.dart'; // Initialize locale data
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // For polyline decoding

import '../services/posts_service.dart';
import '../services/requests_service.dart';
import 'chat_screen.dart';
import '../widgets/custom_appbar.dart';
import '../services/auth_service.dart';

class PostScreen extends StatefulWidget {
  final int journeyId;

  const PostScreen({Key? key, required this.journeyId}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Map<String, dynamic>? _journey;
  bool _isLoading = true;
  String? _existingRequestStatus = null;

  int userId = AuthService().userId ?? -1;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchJourney();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null); // Initialize Turkish locale
  }

  Future<void> _fetchJourney() async {
    try {
      final journey = await PostsService.getJourneyById(widget.journeyId);
      setState(() {
        _journey = journey;
        _isLoading = false;
      });
      _checkExistingRequest();
    } catch (e) {
      print('Error fetching journey: $e');
      setState(() {
        _isLoading = false;
      });
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yolculuk bilgisi alınamadı: $e')),
      );
    }
  }

  void _checkExistingRequest() {
    var existingRequest = _journey?['requests']
        ?.firstWhere((req) => req['senderId'] == userId, orElse: () => null);

    if (existingRequest != null) {
      setState(() {
        _existingRequestStatus = existingRequest['status']['statusName'];
        print(_existingRequestStatus);
      });
    }
  }

  Future<void> _createRequest() async {
    Map<String, dynamic> request = {
      "requestId": 0,
      "journeyId": widget.journeyId,
      "senderId": userId,
      "receiverId": _journey?['userId'],
      "time":
          DateTime.now().toIso8601String(), // Current time as the request time
      "statusId": 1, // Assuming '1' might mean 'pending'
      "receiverIsDeleted": false,
      "senderIsDeleted": false
    };

    try {
      bool success = await RequestsService.createRequest(request);
      if (success) {
        // Show confirmation message or update UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İstek başarıyla gönderildi!')),
        );
        _fetchJourney(); // Refresh the journey to reflect the new request
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İstek gönderilemedi!')),
        );
      }
    } catch (e) {
      print('Error creating request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(title: 'İlan Detayları'),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color.fromARGB(255, 54, 69, 74), // Background color
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJourneyCard(),
                        ],
                      ),
                    ),
                    _buildChatButton(), // Chat button at the bottom left
                    _buildApplyButton(),
                  ],
                ),
        ));
  }

  Widget _buildJourneyCard() {
    // Format the time in Turkish locale
    String formattedTime = 'N/A';
    if (_journey?['time'] != null) {
      final DateTime dateTime = DateTime.parse(_journey!['time']);
      final DateFormat formatter = DateFormat('dd MMMM yyyy HH:mm', 'tr');
      formattedTime = formatter.format(dateTime);
    }

    // Extract coordinates
    final departureLatitude = _journey?['map']?['departureLatitude'] != null
        ? double.tryParse(_journey!['map']?['departureLatitude'])
        : null;
    final departureLongitude = _journey?['map']?['departureLongitude'] != null
        ? double.tryParse(_journey!['map']?['departureLongitude'])
        : null;
    final destinationLatitude = _journey?['map']?['destinationLatitude'] != null
        ? double.tryParse(_journey!['map']?['destinationLatitude'])
        : null;
    final destinationLongitude =
        _journey?['map']?['destinationLongitude'] != null
            ? double.tryParse(_journey!['map']?['destinationLongitude'])
            : null;

    // Extract the encoded route
    final encodedRoute = _journey?['map']?['mapRoute'] ?? '';

    // Decode the polyline into a list of LatLng
    List<LatLng> polylineCoordinates = [];
    if (encodedRoute.isNotEmpty) {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPoints =
          polylinePoints.decodePolyline(encodedRoute);

      polylineCoordinates = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person,
                    size: 28, color: Color.fromARGB(255, 6, 30, 69)),
                const SizedBox(width: 8),
                Text(
                  _journey?['user']?['username'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              'Başlangıç:',
              '${_journey?['map']?['currentDistrict'] ?? 'Unknown'}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.flag,
              'Hedef:',
              '${_journey?['map']?['destinationDistrict'] ?? 'Unknown'}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Tarih:', formattedTime),
            const SizedBox(height: 16),
            // Add the map widget here
            if (departureLatitude != null &&
                departureLongitude != null &&
                destinationLatitude != null &&
                destinationLongitude != null)
              SizedBox(
                height: 200, // Adjust height as needed
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GoogleMap(
                    initialCameraPosition: _getInitialCameraPosition(
                        departureLatitude,
                        departureLongitude,
                        destinationLatitude,
                        destinationLongitude),
                    markers: {
                      Marker(
                        markerId: const MarkerId('departure'),
                        position: LatLng(departureLatitude, departureLongitude),
                        infoWindow: const InfoWindow(title: 'Başlangıç'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                      ),
                      Marker(
                        markerId: const MarkerId('destination'),
                        position:
                            LatLng(destinationLatitude, destinationLongitude),
                        infoWindow: const InfoWindow(title: 'Hedef'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                    },
                    polylines: polylineCoordinates.isNotEmpty
                        ? {
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: polylineCoordinates,
                              color: Colors.blue,
                              width: 5,
                            ),
                          }
                        : {},
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: (GoogleMapController controller) {
                      _adjustCameraBounds(polylineCoordinates, controller);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Determines the initial camera position based on origin and destination
  CameraPosition _getInitialCameraPosition(double originLat, double originLng,
      double destinationLat, double destinationLng) {
    // Calculate the midpoint between origin and destination
    double midLat = (originLat + destinationLat) / 2;
    double midLng = (originLng + destinationLng) / 2;

    return CameraPosition(
      target: LatLng(midLat, midLng),
      zoom: 10, // Adjust zoom level as needed
    );
  }

  // Adjusts the camera to fit the entire polyline
  Future<void> _adjustCameraBounds(
      List<LatLng> polylineCoordinates, GoogleMapController controller) async {
    if (polylineCoordinates.isEmpty) return;

    double minLat = polylineCoordinates.first.latitude;
    double maxLat = polylineCoordinates.first.latitude;
    double minLng = polylineCoordinates.first.longitude;
    double maxLng = polylineCoordinates.first.longitude;

    for (var coord in polylineCoordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // Animate the camera to fit the bounds with padding
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: const Color.fromARGB(255, 6, 30, 69)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton() {
    // Check if the user is the owner of the journey
    if (userId == _journey?['userId']) {
      return const SizedBox.shrink(); // Return an empty widget
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  postOwnerName: _journey?['user']?['username'] ?? 'Unknown',
                  receiverId: _journey?['userId'] ?? 0,
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.chat,
            color: Colors.white,
          ),
          label: const Text(
            'Chat',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 6, 30, 69),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    // Check if the user is the owner of the journey
    if (userId == _journey?['userId']) {
      return const SizedBox.shrink(); // Return an empty widget
    }

    if (_existingRequestStatus == null) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _createRequest(),
            icon: const Icon(Icons.check, color: Colors.white),
            label:
                const Text('İstek At', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 6, 30, 69),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      );
    } else {
      // Display status
      Color buttonColor = Colors.blue; // default for pending
      String displayText = "Bekliyor";
      if (_existingRequestStatus == 'reject') {
        buttonColor = Colors.red;
        displayText = "Reddedildi";
      } else if (_existingRequestStatus == 'acceptance') {
        buttonColor = Colors.green;
        displayText = "Kabul edildi";
      }

      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {}, // Optionally perform some action on tap
            icon: Icon(Icons.info, color: Colors.white),
            label: Text(displayText, style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      );
    }
  }
}
