class User {
  String? url;
  String? username;
  String? password;

  User({this.url, this.username, this.password});

  User.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    username = json['username'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['username'] = this.username;
    data['password'] = this.password;
    return data;
  }
}
