import 'package:cowtrain/constants.dart';
import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
class AddCattleFormScreen extends StatefulWidget {
  @override
  _AddCattleFormScreenState createState() => _AddCattleFormScreenState();
}

class _AddCattleFormScreenState extends State<AddCattleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _foodsController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _teethController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedGender;

  Future<void> _submitForm(BuildContext context) async {
    // Access the provider safely with listen: false
    final user = Provider.of<UserProvider>(context, listen: false).user;
    String _userId = user.userid;

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.post(
          Uri.parse('$uri/cattle/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "userid": _userId,
            "color": _colorController.text,
            "name": _nameController.text,
            "age": int.parse(_ageController.text),
            "teeth_number": int.parse(_teethController.text),
            "foods": _foodsController.text,
            "price": double.parse(_priceController.text),
            "gender": _selectedGender,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cattle added successfully!')),
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  DashboardScreen())
          ); // Navigate back after successful submission
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add cattle. Try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Cattle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: 'Color',
                  hintText: 'Enter cattle color',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the color' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter cattle name',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the name' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) => value == null ? 'Please select gender' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter cattle age',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the age' : null,
              ),
              TextFormField(
                controller: _teethController,
                decoration: InputDecoration(
                  labelText: 'Teeth Number',
                  hintText: 'Enter number of teeth',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter teeth number' : null,
              ),
              TextFormField(
                controller: _foodsController,
                decoration: InputDecoration(
                  labelText: 'Foods',
                  hintText: 'Enter foods separated by commas',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the foods' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter cattle price',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the price' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  _submitForm(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
