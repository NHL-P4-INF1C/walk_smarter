import "package:flutter/material.dart";
import "package:walk_smarter/leaderboard.dart";
import "dart:convert";
import "pocketbase.dart";

var pb = PocketBaseSingleton().instance;

class FriendProfilePage extends StatefulWidget 
{
  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> 
{
  String _username = "Loading...";
  String _profilePicture = "";
  String _userID = 'kyw332amt7ct21r';
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final jsonString =
          await pb.collection("users").getFirstListItem("id=\"$_userID\"");
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
                onPressed: () 
                {
                  Navigator.pushNamed(context, "/profilepage");
                },
              ),
              SizedBox(width: 8),
              Row( 
                children: [
                  Text(
                    "Go Back",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF096A2E))
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                  radius: 23,
                  backgroundImage: _profilePicture.startsWith("http")
                      ? NetworkImage(_profilePicture)
                      : AssetImage("assets/standardProfilePicture.png")
                          as ImageProvider),
            ),
          ],
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
              alignment: Alignment.topLeft,
              children: [
                Positioned(
                  left: 10,
                  top: 50,
                  child: SizedBox(
                      width: 130,
                      height: 130,
                      child: CircleAvatar(
                          radius: 0,
                          backgroundImage: _profilePicture.startsWith("http")
                              ? NetworkImage(_profilePicture)
                              : AssetImage("assets/standardProfilePicture.png")
                                  as ImageProvider)),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Text(
                    _username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  left: 150,
                  top: 50,
                  child: Text(
                    "Last Trophy",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                    left: 150,
                    top: 80,
                    child: SizedBox(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/award.png',
                              width: 40,
                              height: 40,
                            ),
                            Text(
                              'April 2024',
                              style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.bold),
                            )
                          ]),
                    )),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 200,
                  child: Container(
                    height: 1,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  left: 30,
                  top: 220,
                  child: Text(
                    "Trophies",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  left: 200,
                  top: 220,
                  child: SizedBox(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LeaderboardPage(),
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 9, 106, 46),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 7, horizontal: 30),
                        child: Text(
                          "View more",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 280,
                  child: Container(
                    width: 355,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF096A2E), // Green color
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/award.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Champion",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Earned in April 2024",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 380,
                  child: Container(
                    width: 355,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF096A2E), // Green color
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/award.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "2nd place",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Earned in April 2024",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 480,
                  child: Container(
                    width: 355,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF096A2E), // Green color
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/award.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "3rd place",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Earned in April 2024",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                      Navigator.pushNamed(context, '/homepage');
                    case 1:
                      Navigator.pushNamed(context, '/leaderboard');
                    case 2:
                      Navigator.pushNamed(context, '/friendspage');
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