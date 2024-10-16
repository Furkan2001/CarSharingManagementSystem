import 'package:flutter/material.dart';

class MyPostScreen extends StatefulWidget {
  final Map<String, String> post;
  final int index;
  final Function(int, Map<String, String>) updatePost;

  const MyPostScreen({
    Key? key,
    required this.post,
    required this.index,
    required this.updatePost,
  }) : super(key: key);

  @override
  _MyPostScreenState createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  late TextEditingController _departurePlaceController;
  late TextEditingController _destinationController;
  late TextEditingController _departureTimeController;

  @override
  void initState() {
    super.initState();
    _departurePlaceController = TextEditingController(text: widget.post['departure place']);
    _destinationController = TextEditingController(text: widget.post['destination']);
    _departureTimeController = TextEditingController(text: widget.post['departure']);
  }

  @override
  void dispose() {
    _departurePlaceController.dispose();
    _destinationController.dispose();
    _departureTimeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedPost = {
      'name': widget.post['name']!,
      'departure place': _departurePlaceController.text,
      'destination': _destinationController.text,
      'departure': _departureTimeController.text,
    };

    widget.updatePost(widget.index, updatedPost);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşım başarıyla güncellendi!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaşımı düzenleyin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _departurePlaceController,
              decoration: const InputDecoration(
                labelText: 'Kalkış Yeri',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Hedef',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _departureTimeController,
              decoration: const InputDecoration(
                labelText: 'Kalkış Saati',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Değişiklikleri kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
