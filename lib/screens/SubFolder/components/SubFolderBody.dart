import 'dart:convert';

import 'package:files_webdav/Settings/Settings.dart';
import 'package:files_webdav/models/user.dart';
import 'package:files_webdav/screens/SubFolder/Subfolder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import '../../../constants.dart';

class SubFolderBody extends StatefulWidget {
  final String folder;
  const SubFolderBody({Key? key, required this.folder}) : super(key: key);

  @override
  State<SubFolderBody> createState() => _SubFolderBodyState();
}

class _SubFolderBodyState extends State<SubFolderBody> {
  // webdav
  late webdav.Client client;

  // TODO need change your test url && user && pwd
  // if you use browser and received 'XMLHttpRequest error'  you need check cors!!!
  // https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code
  // final url = 'https://bungevirtual.com/remote.php/dav/files/Dixon/';
  var url = '';
  var user = '';
  var password = '';
  var dirPath = '/';
  var longPressed = false;
  TextEditingController folderNameController = TextEditingController();
  String? folderName;
  final _formKey = GlobalKey<FormState>();
  bool error = false;
  final List<String> errors = [];

  @override
  void initState() {
    super.initState();

    dirPath = widget.folder;

    getUser();

    Future.delayed(const Duration(seconds: 4), () async {
      var userUrl = 'https://$url/remote.php/dav/files/$user';
      client = webdav.newClient(
        userUrl,
        user: user,
        password: password,
        debug: true,
      );
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

  Widget _buildListView(BuildContext context, List<webdav.File> list) {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final file = list[index];
          return GestureDetector(
            onLongPress: () => {longPressed = true},
            child: ListTile(
              leading: Icon(file.isDir == true
                  ? Icons.folder
                  : Icons.file_present_rounded),
              title: Text(file.name ?? ''),
              subtitle: Text(file.mTime.toString()),
              // subtitle: Text(widget.folder),
              onTap: () async {
                if (file.isDir == true) {
                  final subFolderPath = '$dirPath/${file.name}';
                  Navigator.pushNamed(context, SubFolder.route,
                      arguments: {'folder': subFolderPath});
                  print('${subFolderPath}');
                }
              },
            ),
          );
        });
  }

  void addError({required String error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({required String error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, Settings.route);
            },
            radius: 24,
            child: const Icon(Icons.more_vert),
          )
        ],
        title: const Text('Folders'),
      ),
      body: FutureBuilder(
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
        onPressed: () {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: const Text('Create Folder'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: folderNameController,
                            onSaved: (newValue) => folderName = newValue,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                removeError(error: kNullError);
                              }
                              return;
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                addError(error: kNullError);

                                return "";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Folder Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                              onPressed: () async {
                                await client.mkdir('$folderName');
                              },
                              child: const Text('Create'))
                        ],
                      ),
                    ),
                  ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
