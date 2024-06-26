import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:image_picker/image_picker.dart";
import "utils/pocketbase.dart";
import "dart:convert";
import "package:http/http.dart" as http;

import "changeusername.dart";

var pb = PocketBaseSingleton().instance;

class ProfileUserSettings extends StatefulWidget {
  @override
  State<ProfileUserSettings> createState() => _ProfileUserSettingsState();
}

class _ProfileUserSettingsState extends State<ProfileUserSettings> {
  String _username = "Loading...";
  String _profilePicture = "";
  String _userID = pb.authStore.model['id'];
  int currentIndex = 0;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final jsonString = await pb.collection("users").getFirstListItem(
            'id="$_userID"',
          );
      final record = jsonDecode(jsonString.toString());
      setState(() {
        _username = record["username"];
        if (record["avatar"] != null) {
          _profilePicture =
              pb.files.getUrl(jsonString, record["avatar"]).toString();
        } else {
          _profilePicture = "";
        }
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _username = "Error loading username";
        _profilePicture = "";
      });
    }
  }

  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        BuildContext context = this.context;

        var request = http.MultipartRequest(
          "PATCH",
          Uri.parse(
              '${dotenv.env["POCKETBASE_URL"]}api/collections/users/records/$_userID'),
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            "avatar",
            image.path,
          ),
        );
        request.headers.addAll({
          "Authorization": "Bearer ${pb.authStore.token}",
        });

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await http.Response.fromStream(response);
          var responseData = jsonDecode(responseBody.body);
          setState(() {
            _profilePicture = responseData["avatar"];
          });
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile picture changed successfully!"),
            ),
          );

          await _fetchUserData();
        } else {
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to change profile picture"),
            ),
          );
        }
      } catch (e) {
        print("Error uploading image: $e");
        if (!mounted) return;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error changing profile picture"),
          ),
        );
      }
    }
  }

  Future<void> _deleteProfilePicture() async {
    try {
      await pb.collection("users").update(_userID, body: {
        "avatar": null,
      });
      setState(() {
        _profilePicture = "";
      });
      if (!mounted) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile picture deleted successfully!"),
        ),
      );
    } catch (e) {
      print("Error deleting profile picture: $e");
      if (!mounted) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete profile picture"),
        ),
      );
    }
  }

  Future<bool> _verifyPassword(String username, String password) async {
    try {
      await pb.collection('users').authWithPassword(
            username,
            password,
          );
      return pb.authStore.isValid;
    } catch (e) {
      print("Error verifying password: $e");
      return false;
    }
  }

  Future<void> _deleteAccount(String username, String password) async {
    if (await _verifyPassword(username, password)) {
      try {
        await pb.collection("users").delete(_userID);
        BuildContext context = this.context;
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      } catch (e) {
        print("Error deleting account: $e");
        if (!mounted) return;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete account. Please try again."),
          ),
        );
      }
    } else {
      if (!mounted) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Incorrect username or password. Please try again."),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 243, 243),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF096A2E)),
                onPressed: () {
                  Navigator.pushNamed(context, "/profilepagesettings");
                },
              ),
              SizedBox(width: 8),
              Row(
                children: [
                  Text(
                    "Go Back",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF096A2E)),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Walk Smarter",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Image(
                      image: AssetImage("assets/walksmarterlogo.png"),
                      height: 40,
                      width: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 600,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 245, 243, 243),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 50,
                  left: 30,
                  child: GestureDetector(
                    onTap: _changeProfilePicture,
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: Stack(
                        children: [
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.5),
                              BlendMode.modulate,
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundImage: _profilePicture
                                      .startsWith("http")
                                  ? NetworkImage(_profilePicture)
                                  : AssetImage(
                                          "assets/standardProfilePicture.png")
                                      as ImageProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 43,
                            right: 43,
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: Image.asset(
                                "assets/pencil.png",
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 150,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Profile Picture?"),
                            content: Text(
                                "Are you sure you want to delete your profile picture?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteProfilePicture();
                                  Navigator.of(context).pop();
                                },
                                child: Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Text(
                        "Delete profile picture",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 200,
                  child: Text(
                    _username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  top: 245,
                  child: GestureDetector(
                    onTap: () async {
                      bool? result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChangeUsernamePage(),
                        ),
                      );
                      if (result == true) {
                        _fetchUserData();
                      }
                    },
                    child: Container(
                      width: 355,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        ),
                      ],
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.person_outline,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Change username",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 310,
                  child: GestureDetector(
                    onTap: () async {
                      await pb
                          .collection('users')
                          .requestPasswordReset(pb.authStore.model['email']);
                      showDialog(
                        // ignore: use_build_context_synchronously
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Email Sent"),
                            content: Text(
                                "An email has been sent to reset your password."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 355,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        ),
                      ],
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.key,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Change password",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 410,
                  left: 20,
                  child: Text(
                    "Danger Zone",
                    style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 148, 147, 147)),
                  ),
                ),
                Positioned(
                  top: 435,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Account?"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    "Enter your username and password to delete your account:"),
                                SizedBox(height: 10),
                                TextField(
                                  controller: _usernameController,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    hintText: "Username",
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  String username =
                                      _usernameController.text.trim();
                                  String password =
                                      _passwordController.text.trim();
                                  if (username.isNotEmpty &&
                                      password.isNotEmpty) {
                                    _deleteAccount(username, password);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Please enter both username and password."),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Color.fromARGB(255, 255, 0, 0),
                                      width: 2,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 15,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.delete_outline,
                                        size: 30,
                                        color: Color.fromARGB(255, 255, 0, 0),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Delete account",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 255, 0, 0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 355,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Color.fromARGB(255, 255, 0, 0),
                          width: 2,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.delete_outline,
                            size: 30,
                            color: Color.fromARGB(255, 255, 0, 0),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Delete account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              color: Color(0xFF096A2E),
              width: 2.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: "Map",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard),
                  label: "Leaderboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: "Friends",
                ),
              ],
              selectedItemColor: Color.fromARGB(255, 119, 120, 119),
              currentIndex: 1,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                  switch (index) {
                    case 0:
                      Navigator.pushNamed(context, "/homepage");
                    case 1:
                      Navigator.pushNamed(context, "/leaderboard");
                    case 2:
                      Navigator.pushNamed(context, "/friendspage");
                    default:
                      break;
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
