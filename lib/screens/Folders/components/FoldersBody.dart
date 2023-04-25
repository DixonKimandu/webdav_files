import 'dart:convert';

import 'package:files_webdav/Settings/Settings.dart';
import 'package:files_webdav/models/user.dart';
import 'package:files_webdav/screens/Files/Files.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import '../../../constants.dart';

class FoldersBody extends StatefulWidget {
  const FoldersBody({super.key});

  @override
  State<FoldersBody> createState() => _FoldersBodyState();
}

class _FoldersBodyState extends State<FoldersBody> {
  // webdav
  late webdav.Client client;

  // TODO need change your test url && user && pwd
  // if you use browser and received 'XMLHttpRequest error'  you need check cors!!!
  // https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code
  // final url = 'https://bungevirtual.com/remote.php/dav/files/';
  var url = '';
  var user = '';
  var password = '';
  final dirPath = '/';
  TextEditingController folderNameController = TextEditingController();
  String? folderName;
  final _formKey = GlobalKey<FormState>();
  bool error = false;
  final List<String> errors = [];
  bool busy = false;

  @override
  void initState() {
    super.initState();

    getUser();

    // client = webdav.newClient(
    //   url,
    //   user: user,
    //   password: password,
    //   debug: true,
    // );

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
    // setState(() {
    //   user = authUser.username!;
    //   password = authUser.password!;
    // });
    url = authUser.url!;
    user = authUser.username!;
    password = authUser.password!;

    // print('User $user');
    // print('Pass $password');
    // initWebdav();
  }

  initWebdav() {
    client = webdav.newClient(
      url,
      user: user,
      password: password,
      debug: true,
    );
    _getData();
  }

  Future<List<webdav.File>> _getData() async {
    // return client.readDir(dirPath);
    await Future.delayed(const Duration(seconds: 4));
    print('Url $url');
    print('User $user');
    print('Pass $password');
    return client.readDir(dirPath);
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
            onTap: () {
              Navigator.pushNamed(context, Files.route,
                  arguments: {'folder': file.name});
              print('Remote path ${file.path}');
            },
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
                          busy
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : TextButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      setState(() {
                                        busy = true;
                                      });
                                      await client.mkdir('$folderName').then(
                                          (value) => Navigator.pop(context));
                                    }
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
