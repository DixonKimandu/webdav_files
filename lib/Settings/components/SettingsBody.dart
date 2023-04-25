import 'dart:convert';

import 'package:files_webdav/screens/auth/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            ListTile(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('creds');
                await prefs.setString(
                    'creds', jsonEncode({'username': '', 'password': ''}));
                Navigator.pushNamed(context, Login.route);
              },
              leading: const Icon(Icons.door_back_door),
              title: const Text('Logout'),
            ),
          ]),
        ),
      )),
    );
  }
}
