import 'package:flutter/material.dart';
import '../widgets/menu_widget.dart'; 

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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      
      print('Name: ${_nameController.text}');
      print('Departure Place: ${_departurePlaceController.text}');
      print('Destination: ${_destinationController.text}');
      print('Departure Time: ${_departureTimeController.text}');

      // TODO: Connect to backend to save the post

      _nameController.clear();
      _departurePlaceController.clear();
      _destinationController.clear();
      _departureTimeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşım başarıyla oluşturuldu!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaşım Oluştur'),
      ),
      drawer: const Menu(), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'İsim',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen isim girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _departurePlaceController,
                decoration: const InputDecoration(
                  labelText: 'Kalkış Yeri',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kalkış yerini girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Hedef',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen hedefi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _departureTimeController,
                decoration: const InputDecoration(
                  labelText: 'Kalkış Saati',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kalkış saati girin';
                  }
                  return null;
                },
              ),
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
}
