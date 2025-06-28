import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Form',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DynamicFormPage(),
    );
  }
}

class DynamicFormPage extends StatefulWidget {
  const DynamicFormPage({super.key});

  @override
  State<DynamicFormPage> createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  List<dynamic> _formFields = [];

  @override
  void initState() {
    super.initState();
    loadForm();
  }

  Future<void> loadForm() async {
    final jsonString = await rootBundle.loadString('assets/form.json');
    final decoded = json.decode(jsonString);
    setState(() {
      _formFields = decoded;
    });
  }

  Widget buildFormField(Map<String, dynamic> field) {
    final key = field['key'];
    final label = field['label'];
    final type = field['type'];
    final required = field['required'] ?? false;

    InputDecoration decoration = InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );

    switch (type) {
      case 'text':
      case 'email':
      case 'number':
        return TextFormField(
          keyboardType:
              type == 'number' ? TextInputType.number : TextInputType.text,
          decoration: decoration,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (required && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            if (type == 'email' && value!.isNotEmpty && !value.contains('@')) {
              return 'Invalid email';
            }
            return null;
          },
          onSaved: (value) => _formData[key] = value,
        );
      case 'dropdown':
        return DropdownButtonFormField<String>(
          decoration: decoration,
          value: null,
          items:
              (field['options'] as List<dynamic>)
                  .map(
                    (opt) => DropdownMenuItem(
                      value: opt.toString(),
                      child: Text(opt.toString()),
                    ),
                  )
                  .toList(),
          onChanged: (val) => _formData[key] = val,
          validator: (value) {
            if (required && (value == null || value.isEmpty)) {
              return 'Please select an option';
            }
            return null;
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void submitForm() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Submitted Data'),
              content: Text(jsonEncode(_formData)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_formFields.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Form')),
      body: dynamicbody(),
    );
  }

  Widget dynamicbody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView.separated(
          itemCount: _formFields.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == _formFields.length) {
              return Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              );
            }
            return buildFormField(_formFields[index]);
          },
        ),
      ),
    );
  }
}
