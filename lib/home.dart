import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'add_category.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controller = TextEditingController();
  final EncryptedSharedPreferences _encryptedData =
      EncryptedSharedPreferences();

  void update(bool success) {
    if (success) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AddCategory()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('failed to set key')));
    }
  }

  checkLogin() async {
    if (_controller.text.toString().trim() == '') {
      update(false);
    } else {
      _encryptedData
          .setString('myKey', _controller.text.toString())
          .then((bool success) {
        if (success) {
          update(true);
        } else {
          update(false);
        }
      });
    }
  }

  void checkSavedData() async {
    _encryptedData.getString('myKey').then((String myKey) {
      if (myKey.isNotEmpty) {
        Navigator.of(context)
            .push(MaterialPageRoute(
            builder: (context) => const AddCategory()));
      }
    });
  }


  @override
  void initState() {
    super.initState();
    checkSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(children: [
        const SizedBox(height: 10),
        SizedBox(
            width: 200,
            child: TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: _controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Enter Key'),
            )),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: checkLogin, child: const Text('Save'))
      ])),
    );
  }
}
