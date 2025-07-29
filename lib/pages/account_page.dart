import 'package:flutter/material.dart';
import 'package:trenpal/custom%20widgets/editable_textfield.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EditableGrayTextField(
            prompt: 'Username',
            controller: _usernameController,
            initiallyEditable: false,
            initialText: "hello",
          ),
        ],
      ),
    );
  }
}
