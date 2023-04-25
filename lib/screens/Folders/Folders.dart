import 'package:files_webdav/screens/Folders/components/FoldersBody.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Folders extends StatelessWidget {
  static String route = 'folders';
  const Folders({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoldersBody();
  }
}
