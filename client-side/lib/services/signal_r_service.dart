import 'package:signalr_netcore/signalr_client.dart';
import 'package:signalr_netcore/ihub_protocol.dart';

class SignalRService {
  late HubConnection hubConnection;

  Future<void> startConnection(String userId, String apiKey) async {
    // Base URL for the SignalR hub
    final url = 'http://localhost:3000/messageHub?user_id=$userId';

    final httpConnectionOptions = HttpConnectionOptions(
      transport: HttpTransportType.WebSockets, // Transport türünü WebSocket olarak belirleyin
      skipNegotiation: true, // Negotiate aşamasını atla (eğer sunucu bunu gerektiriyorsa)
    );

    // Build the connection with a custom HTTP client
    hubConnection = HubConnectionBuilder()
        .withUrl(
          url,
          options: httpConnectionOptions,
        )
        .build();

    hubConnection.onclose(({Exception? error}) {
      if (error != null) {
        print("[ERROR] Bağlantı kapandı. Hata: ${error.toString()}");
      } else {
        print("[INFO] Bağlantı kapandı.");
      }
    });

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
