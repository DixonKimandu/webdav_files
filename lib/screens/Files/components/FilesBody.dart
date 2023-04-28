import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:files_webdav/models/user.dart';
import 'package:files_webdav/screens/Files/Files.dart';
import 'package:files_webdav/screens/SubFolder/Subfolder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path/path.dart';
import '../../../Settings/Settings.dart';

class FilesBody extends StatefulWidget {
  final String folder;
  const FilesBody({Key? key, required this.folder}) : super(key: key);

  @override
  State<FilesBody> createState() => _FilesBodyState();
}

class _FilesBodyState extends State<FilesBody> {
  // webdav
  late webdav.Client client;

  // TODO need change your test url && user && pwd
  // if you use browser and received 'XMLHttpRequest error'  you need check cors!!!
  // https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code
  final serverFilesUrl = 'apps/files/?dir=';
  var url = '';
  var user = '';
  var password = '';
  var dirPath = '/';
  var longPressed = false;
  late final WebViewController controller;
  var loadingPercentage = 0;
  bool docOpened = false;
  var userUrl = '';

  @override
  void initState() {
    super.initState();

    dirPath = widget.folder;

    getUser();

    Future.delayed(const Duration(seconds: 4), () async {
      userUrl = 'https://$url/remote.php/dav/files/$user';
      client = webdav.newClient(
        userUrl,
        user: user,
        password: password,
        debug: true,
      );

      // controller = WebViewController()
      //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //   ..loadRequest(
      //     Uri.parse('$userUrl/$dirPath'),
      //     method: LoadRequestMethod.get,
      //     headers: <String, String>{
      //       'authorization':
      //           'Basic ${base64.encode(utf8.encode('$user:$password'))}'
      //     },
      //   );
    });
  }

  getUser() async {
    final prefs = await SharedPreferences.getInstance();
    User authUser = User.fromJson(jsonDecode(prefs.getString('creds')!));
    url = authUser.url!;
    user = authUser.username!;
    password = authUser.password!;
  }

  Future<List<webdav.File>> _getData() async {
    await Future.delayed(const Duration(seconds: 4));
    return client.readDir(dirPath);
    // var list = client.readDir(dirPath);
    // return list.forEach((f) {
    //     print('${f.name} ${f.path}');
    //   });
  }

  downloadDoc(String file) {
    final doc = file;
    print('Doc $doc');
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
      ))
      ..loadRequest(
        // Uri.parse('$userUrl/$dirPath/$doc'),
        // Uri.parse('https://flutter.dev')
        Uri.parse('https://$url/$serverFilesUrl$dirPath'),
        method: LoadRequestMethod.get,
        headers: <String, String>{
          'authorization':
              'Basic ${base64.encode(utf8.encode('$user:$password'))}'
        },
      );
  }

  Widget _buildListView(BuildContext context, List<webdav.File> list) {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final file = list[index];
          return ListTile(
            leading: Icon(
                file.isDir == true ? Icons.folder : Icons.file_present_rounded),
            title: Text(file.name ?? ''),
            subtitle: Text(file.mTime.toString()),
            onLongPress: () {
              showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(0, 1000, 0, 0),
                  items: [
                    PopupMenuItem(
                        onTap: () async {
                          await client.remove('/$dirPath/${file.name}/');
                        },
                        value: 'delete',
                        child: const Text('Delete'))
                  ]);
            },
            onTap: () async {
              if (file.isDir == true) {
                final subFolderPath = '$dirPath/${file.name}';
                Navigator.pushNamed(context, SubFolder.route,
                    arguments: {'folder': subFolderPath});
                print('${subFolderPath}');
              } else {
                final doc = file.eTag;
                downloadDoc(doc!);
                setState(() {
                  docOpened = true;
                });
              }

              // Navigator.pushNamed(context, Files.route);
              // client.read('$dirPath/${file.name}', onProgress: (c, t) {
              //   print(c / t);
              // });
              // final bytes = await client.read('$dirPath/${file.name}',
              //     onProgress: (c, t) {
              //   print(c / t);
              // });

              // String filePath;

              // if (!kIsWeb && Platform.isAndroid) {
              //   final externalDir = await getExternalStorageDirectory();
              //   final downloadDir =
              //       Directory('${externalDir!.path}/Download');
              //   if (!downloadDir.existsSync()) {
              //     downloadDir.createSync();
              //   }
              //   filePath = '${externalDir.path}/Downloads/${file.name}';
              // } else {
              //   final appDocDir = await getApplicationDocumentsDirectory();
              //   filePath = '${appDocDir.path}/${file.name}';
              // }

              // final appDocDir = await getApplicationDocumentsDirectory();
              // filePath = '${appDocDir.path}/${file.name}';

              // final fileObj = File(filePath);
              // await fileObj.writeAsBytes(bytes);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('File downloaded to $filePath'),
              //     duration: Duration(seconds: 5),
              //   ),
              // );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          docOpened
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      docOpened = false;
                    });
                    Navigator.pushNamed(context, Files.route,
                        arguments: {'folder': dirPath});
                  },
                  icon: const Icon(Icons.close))
              : const SizedBox(),
          longPressed
              ? Row(
                  children: [
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.download)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.copy)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.delete))
                  ],
                )
              : const SizedBox(),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, Settings.route);
            },
            radius: 24,
            child: const Icon(Icons.more_vert),
          )
        ],
        title: const Text('Files'),
      ),
      body: docOpened
          ? Stack(children: [
              WebViewWidget(
                controller: controller,
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 1000,
                  height: 100,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 100.0, top: 40),
                    child: Text(dirPath),
                  ),
                ),
              ),
              if (loadingPercentage < 100)
                LinearProgressIndicator(
                  value: loadingPercentage / 100.0,
                ),
            ])
          : FutureBuilder(
              future: _getData(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<webdav.File>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    return _buildListView(context, snapshot.data ?? []);
                }
              }),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();

            if (result != null) {
              PlatformFile file =
                  // result.files.first;
                  result.files.single;
              String path = result.files.single.path!;

              File doc = File(file.path!);

              // CancelToken c = CancelToken();
              await client.writeFromFile(
                '${file.path}',
                '${widget.folder}/${basename(path)}',
                onProgress: (c, t) {
                  print(c / t);
                }, /*cancelToken: c*/
              ).then((value) => Navigator.pushNamed(context, Files.route,
                  arguments: {'folder': dirPath}));
            }
          },
          child: const Icon(Icons.add)),
    );
  }
}
