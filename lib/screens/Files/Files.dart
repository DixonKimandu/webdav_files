import 'package:files_webdav/screens/Files/components/FilesBody.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Files extends StatelessWidget {
  static String route = 'files';
  const Files({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final folder = args['folder'] as String;
    return FilesBody(
      folder: folder,
    );
  }
}
