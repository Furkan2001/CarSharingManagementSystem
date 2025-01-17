import 'package:signalr_netcore/signalr_client.dart';
import '../utils/main_link.dart';

class SignalRService {
  late HubConnection hubConnection;
  static final String link = MainLink().url;

  DateTime eventStart = DateTime.now();
  DateTime eventEnd = DateTime.now();

  Future<void> startConnection(String userId) async {
    // Base URL for the SignalR hub
    final url = 'http://$link:3000/messageHub?user_id=$userId';

    hubConnection = HubConnectionBuilder().withUrl(url).build();

    try {
      await hubConnection.start();
      print("SignalR connection established.");
    } catch (e) {
      print("SignalR connection failed: $e");
    }
  }

  Future<void> stopConnection() async {
    await hubConnection.stop();
    print("SignalR bağlantısı durduruldu.");
  }

  Future<void> sendMessage(int senderId, int receiverId, String message) async {
    eventStart = DateTime.now();
    try {
      await hubConnection
          .invoke('SendMessage', args: [senderId, receiverId, message]);
      print("Mesaj gönderildi: $message");
    } catch (e) {
      print("Mesaj gönderim hatası: $e");
    }
    eventEnd = DateTime.now();
    Duration difference = eventEnd.difference(eventStart);
    print("Send button clicked at $eventStart\n"
        "Messaged send at $eventEnd\n"
        "Miliseconds sending message: ${difference.inMilliseconds}");
  }

  void onReceiveMessage(
      Function(int senderId, String message) onMessageReceived) {
    print("service page");
    hubConnection.on('ReceiveMessage', (arguments) {
      int senderId = arguments![0] as int;
      String message = arguments[1] as String;
      onMessageReceived(senderId, message);
    });
  }
}
