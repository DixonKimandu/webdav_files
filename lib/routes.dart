import 'package:files_webdav/Settings/Settings.dart';
import 'package:files_webdav/screens/Files/Files.dart';
import 'package:files_webdav/screens/Folders/Folders.dart';
import 'package:files_webdav/screens/SubFolder/Subfolder.dart';
import 'package:files_webdav/screens/auth/Login.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  Login.route: (context) => const Login(),
  Folders.route: (context) => const Folders(),
  Files.route: (context) => const Files(),
  SubFolder.route: (context) => const SubFolder(),
  Settings.route: (context) => const Settings(),
};
