import 'package:cowtrain/constants.dart';
import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/Dashboard.dart';
import 'package:cowtrain/constants/theme_constants.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Add Cattle', style: AppTheme.headingLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header Section
              Text(
                'Enter Cattle Details',
                style: AppTheme.headingMedium,
              ),
              SizedBox(height: AppTheme.spacingL),

              // Form Fields
              TextFormField(
                controller: _nameController,
                decoration: AppTheme.inputDecoration('Name').copyWith(
                  prefixIcon: Icon(Icons.pets_outlined, color: AppTheme.primaryBrown),
                ),
                style: AppTheme.bodyLarge,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the name' : null,
              ),
              SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _colorController,
                decoration: AppTheme.inputDecoration('Color').copyWith(
                  prefixIcon: Icon(Icons.palette_outlined, color: AppTheme.primaryBrown),
                ),
                style: AppTheme.bodyLarge,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the color' : null,
              ),
              SizedBox(height: AppTheme.spacingM),

              DropdownButtonFormField<String>(
                decoration: AppTheme.inputDecoration('Gender').copyWith(
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryBrown),
                ),
                style: AppTheme.bodyLarge,
                items: ['Male', 'Female']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender, style: AppTheme.bodyLarge),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) => value == null ? 'Please select gender' : null,
              ),
              SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _ageController,
                decoration: AppTheme.inputDecoration('Age').copyWith(
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.primaryBrown),
                  suffixText: 'years',
                ),
                style: AppTheme.bodyLarge,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the age' : null,
              ),
              SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _teethController,
                decoration: AppTheme.inputDecoration('Teeth Number').copyWith(
                  prefixIcon: Icon(Icons.medical_services_outlined, color: AppTheme.primaryBrown),
                ),
                style: AppTheme.bodyLarge,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter teeth number' : null,
              ),
              SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _foodsController,
                decoration: AppTheme.inputDecoration('Foods').copyWith(
                  prefixIcon: Icon(Icons.grass_outlined, color: AppTheme.primaryBrown),
                  hintText: 'Enter foods separated by commas',
                ),
                style: AppTheme.bodyLarge,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the foods' : null,
              ),
              SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _priceController,
                decoration: AppTheme.inputDecoration('Price').copyWith(
                  prefixIcon: Icon(Icons.attach_money_outlined, color: AppTheme.primaryBrown),
                  prefixText: '\$ ',
                ),
                style: AppTheme.bodyLarge,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the price' : null,
              ),
              SizedBox(height: AppTheme.spacingXL),

              // Submit Button
              ElevatedButton(
                style: AppTheme.primaryButton,
                onPressed: () {
                  _submitForm(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  child: Text(
                    'Add Cattle',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }
}
