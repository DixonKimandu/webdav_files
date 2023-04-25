import 'package:files_webdav/screens/SubFolder/components/SubFolderBody.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SubFolder extends StatelessWidget {
  static String route = 'subFolder';
  const SubFolder({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final folder = args['folder'] as String;
    return SubFolderBody(
      folder: folder,
    );
  }
}
