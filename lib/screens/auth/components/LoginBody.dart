import 'dart:convert';

import 'package:files_webdav/components/FormErrors.dart';
import 'package:files_webdav/models/user.dart';
import 'package:files_webdav/screens/Folders/Folders.dart';
import 'package:files_webdav/utils/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  TextEditingController urlController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? url;
  String? userName;
  String? password;
  final _formKey = GlobalKey<FormState>();
  bool visibility = true;
  bool remember = false;
  bool busy = false;
  bool error = false;
  final List<String> errors = [];
  var user = '';
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    getUser();
  }

  getUser() async {
    final prefs = await SharedPreferences.getInstance();
    User authUser = User.fromJson(jsonDecode(prefs.getString('creds')!));
    user = authUser.username!;

    if (user != '') {
      // isLoggedIn = true;
      setState(() {
        isLoggedIn = true;
      });
    }
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
        body: SafeArea(
      child: isLoggedIn
          ? const Folders()
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .25,
                      ),
                      const Text('WEBDAV Files'),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: urlController,
                          onSaved: (newValue) => url = newValue,
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
                            hintText: 'example.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: nameController,
                          onSaved: (newValue) => userName = newValue,
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
                            hintText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        margin: const EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(
                          onSaved: (newValue) => password = newValue,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              removeError(error: kPassNullError);
                            }
                            return;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              addError(error: kPassNullError);

                              return "";
                            }
                            return null;
                          },
                          obscureText: visibility,
                          controller: passwordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    visibility = !visibility;
                                  });
                                },
                                icon: Icon(!visibility
                                    ? Icons.visibility
                                    : Icons.visibility_off)),
                            hintText: 'Password',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(20),
                      ),
                      FormError(errors: errors),
                      SizedBox(
                        height: getProportionateScreenHeight(20),
                      ),
                      Container(
                          margin: const EdgeInsets.only(
                            top: 20,
                          ),
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 50,
                          child: busy
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

                                      // logger.d('validated $password $userName');

                                      // authProvider
                                      //     .login(password: password, username: userName)
                                      //     .then((value) {
                                      //   // * successfull response
                                      //   // context
                                      //   //     .read<RoomProvider>()
                                      //   //     .roomsModel = value;
                                      //   //*assign to get rooms
                                      //   setState(() {
                                      //     busy = false;
                                      //   });

                                      //   Navigator.pushReplacementNamed(
                                      //       context, Folders.route);
                                      // }).catchError((onError) {
                                      //   //! invalid response ERROR HANDLING
                                      //   setState(() {
                                      //     busy = false;
                                      //   });

                                      //   addError(error: kInvalidCredentials);
                                      // });

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.remove('creds');
                                      await prefs.setString(
                                          'creds',
                                          jsonEncode({
                                            'url': url,
                                            'username': userName,
                                            'password': password
                                          }));

                                      Navigator.pushReplacementNamed(
                                          context, Folders.route);
                                    }
                                  },
                                  child: const Text('Login'))),
                    ],
                  ),
                ),
              )),
    ));
  }
}
