import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';
import '../widgets/custom_appbar.dart';
import '../screens/post_screen.dart';
import '../services/auth_service.dart';
import '../utils/journey_utils.dart';

class VehicleRequestsScreen extends StatefulWidget {
  const VehicleRequestsScreen({Key? key}) : super(key: key);

  @override
  _VehicleRequestsScreenState createState() => _VehicleRequestsScreenState();
}

class _VehicleRequestsScreenState extends State<VehicleRequestsScreen> {
  List<dynamic> _journeys = [];
  List<dynamic> _filteredJourneys = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Tarih filtresi için kullanacağımız değişkenler
  DateTime? _filterStartTime;
  DateTime? _filterEndTime;

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  int userId = AuthService().userId ?? -1;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchJourneys();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null);
  }

  /// Sayfa açıldığında veri çekme
  Future<void> _fetchJourneys() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final journeys = await PostsService.getAllJourneys();

      // mapId == null olanları ve hasVehicle == true olanları
      // ekranda istemiyoruz. Ayrıca userId eşleşen kayıtlar da listede olmayacak.
      setState(() {
        _journeys = journeys
            .where((journey) =>
                journey['hasVehicle'] == false &&
                journey['userId'] != userId &&
                journey['mapId'] != null)
            .toList();
        _filteredJourneys = _journeys;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching journeys: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sunucuya filtre POST isteği
  Future<void> _applyFilter() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Bu örnekte hasVehicle değerini null gönderiyoruz (yok kabul ediyoruz).
      // İsterseniz 'false' olarak gönderebilirsiniz (server logic’inize bağlı).
      final filteredResult = await PostsService.filterJourneys(
        startTime: _filterStartTime,
        endTime: _filterEndTime,
        hasVehicle: null, // Sadece tarih bazlı filtre
      );

      // Gelen sonuçları da ayrıca hasVehicle == false, mapId != null, userId != me
      // koşullarına göre filtreliyoruz.
      setState(() {
        _journeys = filteredResult
            .where((journey) =>
                journey['hasVehicle'] == false &&
                journey['userId'] != userId &&
                journey['mapId'] != null)
            .toList();

        _filteredJourneys = _journeys;
        _isLoading = false;
      });
    } catch (e) {
      print('Error filtering journeys: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Client-side arama
  void _filterJourneys(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredJourneys = _journeys.where((journey) {
        final departure =
            (journey['map']?['currentDistrict'] ?? '').toLowerCase();
        final destination =
            (journey['map']?['destinationDistrict'] ?? '').toLowerCase();
        return departure.contains(_searchQuery) ||
            destination.contains(_searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Araç Talebi Paylaşımları'),
      drawer: const Menu(),
      body: Container(
        color: const Color.fromARGB(255, 54, 69, 74),
        child: Column(
          children: [
            _buildSearchAndFilterRow(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredJourneys.length,
                      itemBuilder: (context, index) {
                        final journey = _filteredJourneys[index];
                        final currentDistrict =
                            journey['map']?['currentDistrict'] ?? 'Unknown';
                        final destinationDistrict =
                            journey['map']?['destinationDistrict'] ?? 'Unknown';

                        // Tarih hesaplama (tek seferlik veya düzenli)
                        final DateTime dateToShow = journey['isOneTime']
                            ? DateTime.parse(journey['time'])
                            : JourneyUtils.calculateDateForRecurringJourney(
                                journey);

                        final DateFormat formatter =
                            DateFormat('dd MMMM yyyy HH:mm', 'tr');
                        final String formattedTime =
                            formatter.format(dateToShow);

                        final id = journey['journeyId'] ?? -1;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Card(
                            elevation: 4,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Color.fromARGB(255, 6, 30, 69),
                                          size: 30),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Başlangıç: ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: currentDistrict,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Hedef: ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: destinationDistrict,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: Color.fromARGB(255, 6, 30, 69),
                                          size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PostScreen(journeyId: id),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          backgroundColor: const Color.fromARGB(
                                              255, 6, 30, 69),
                                        ),
                                        child: const Text(
                                          'Detaylar',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Arama çubuğu + Filtre butonu aynı satırda
  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Arama Kutusu
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              onChanged: _filterJourneys,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Başlangıç veya Hedef Ara',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filtre Butonu
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
        ],
      ),
    );
  }

  /// Tarih filtresi diyaloğu
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Dialog içindeki setState'i yönetmek için StatefulBuilder kullanıyoruz
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Filtre Uygula'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlangıç Tarihi
                    ListTile(
                      title: const Text('Başlangıç Tarihi'),
                      subtitle: Text(
                        _filterStartTime != null
                            ? DateFormat('dd MMM yyyy')
                                .format(_filterStartTime!)
                            : 'Seçilmedi',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _filterStartTime ?? now,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              _filterStartTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                    // Bitiş Tarihi
                    ListTile(
                      title: const Text('Bitiş Tarihi'),
                      subtitle: Text(
                        _filterEndTime != null
                            ? DateFormat('dd MMM yyyy').format(_filterEndTime!)
                            : 'Seçilmedi',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _filterEndTime ?? now,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              _filterEndTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Vazgeç'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Uygula'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Filtre POST isteği
                    _applyFilter();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
