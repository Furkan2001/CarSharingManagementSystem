import 'package:signalr_netcore/signalr_client.dart';
import 'package:signalr_netcore/ihub_protocol.dart';

class SignalRService {
  late HubConnection hubConnection;

  Future<void> startConnection(String userId, String apiKey) async {
    // Base URL for the SignalR hub
    final url = 'http://localhost:3000/messageHub';

    final defaultHeaders = MessageHeaders();
    defaultHeaders.setHeaderValue("user_id", userId);
    defaultHeaders.setHeaderValue("x-api-key", apiKey);

    final httpConnectionOptions =
        new HttpConnectionOptions(headers: defaultHeaders);

    // Build the connection with a custom HTTP client
    hubConnection = HubConnectionBuilder()
        .withUrl(
          url,
          options: httpConnectionOptions,
        )
        .build();

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
    try {
      await hubConnection
          .invoke('SendMessage', args: [senderId, receiverId, message]);
      print("Mesaj gönderildi: $message");
    } catch (e) {
      print("Mesaj gönderim hatası: $e");
    }
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
