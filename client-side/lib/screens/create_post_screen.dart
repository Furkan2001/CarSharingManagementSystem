import 'package:flutter/material.dart';
import '../widgets/menu_widget.dart';
import '../services/posts_service.dart'; // Import the service

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departurePlaceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _departureTimeController = TextEditingController();

  // Submit handler connected to backend
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Collect form data into a journey object
      final newJourney = {
        'userName': _nameController.text,
        'beginning': _departurePlaceController.text,
        'destination': _destinationController.text,
        'time': _departureTimeController.text,
      };

      try {
        final success = await PostsService.createJourney(newJourney);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paylaşım başarıyla oluşturuldu!')),
          );

          // Clear the form fields after success
          _nameController.clear();
          _departurePlaceController.clear();
          _destinationController.clear();
          _departureTimeController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paylaşım oluşturulamadı!')),
          );
        }
      } catch (e) {
        print('Error creating journey: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bir hata oluştu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaşım Oluştur'),
      ),
      drawer: const Menu(), // Navigation menu widget
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextField(_nameController, 'İsim', 'Lütfen isim girin'),
              const SizedBox(height: 16.0),
              _buildTextField(_departurePlaceController, 'Kalkış Yeri', 'Lütfen kalkış yerini girin'),
              const SizedBox(height: 16.0),
              _buildTextField(_destinationController, 'Hedef', 'Lütfen hedefi girin'),
              const SizedBox(height: 16.0),
              _buildTextField(_departureTimeController, 'Kalkış Saati', 'Lütfen kalkış saati girin'),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Paylaşım Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields with validation
  Widget _buildTextField(
      TextEditingController controller, String label, String errorMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }
}
