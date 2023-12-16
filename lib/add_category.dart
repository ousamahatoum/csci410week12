import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const String _baseURL = 'https://csci410fall2023.000webhostapp.com';
EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controllerID = TextEditingController();
  TextEditingController _controllerName = TextEditingController();
  bool _loading = false;


  @override
  void dispose() {
    _controllerID.dispose();
    _controllerName.dispose();
    super.dispose();
  }

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          IconButton(onPressed: () {
            _encryptedData.remove('myKey').then((success) =>
            Navigator.of(context).pop());
          }, icon: const Icon(Icons.logout))
        ],
          title: const Text('Add Category'),
          centerTitle: true,
          automaticallyImplyLeading: false,
    ),
        body: Center(child: Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          SizedBox(width: 200, child: TextFormField(controller: _controllerID,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter ID',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter id';
              }
              return null;
            },
          )),
          const SizedBox(height: 10),
          SizedBox(width: 200, child: TextFormField(controller: _controllerName,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter Name',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
          )),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _loading = true;
                  });
                  saveCategory(update, int.parse(_controllerID.text.toString()), _controllerName.text.toString());
                }
              },
              child: const Text('Submit'),
            ),
          const SizedBox(height: 10),
          Visibility(visible: _loading, child: const CircularProgressIndicator())
        ],
      ),
    )));
  }
}

void saveCategory(Function(String text) update, int cid, String name) async {
  try {
    String myKey = await _encryptedData.getString('myKey');
      final response = await http.post(
          Uri.parse('$_baseURL/save.php'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: convert.jsonEncode(<String, String>{
            'cid': '$cid', 'name': name, 'key': myKey
          })).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        update(response.body);
      }
  }
  catch(e) {
    update("connection error");
  }
}

