import 'package:files_webdav/screens/auth/components/LoginBody.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Login extends StatelessWidget {
  static String route = 'Login';

  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginBody();
  }
}
