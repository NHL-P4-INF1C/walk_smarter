import "package:flutter/material.dart";
import "package:pocketbase/pocketbase.dart";
import "dart:convert";

import "profileappsettings.dart";
import "profileusersettings.dart";

final pb = PocketBase("https://inf1c-p4-pocketbase.bramsuurd.nl");

class ProfilePageSettings extends StatefulWidget 
{
  @override
  State<ProfilePageSettings> createState() => _ProfilePageSettingsState();
}

class _ProfilePageSettingsState extends State<ProfilePageSettings> 
{
  String _username = "Loading...";
  String _profilePicture = "";
  String _userID = "5iwzvti4kqaf2zb";
  int currentIndex = 0;

  @override
  void initState() 
  {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async 
  {
    try
    {
      final jsonString = await pb.collection("users").getFirstListItem(
        "id=\"$_userID\"" 
      );
      final record = jsonDecode(jsonString.toString());
      setState(() 
      {
        _username = record["username"];
        if(record["avatar"] != null)
        {
          _profilePicture = pb.files.getUrl(jsonString, record["avatar"]).toString();          
        }
        else
        {
          _profilePicture = "";
        }
      });
    } 
    catch (e) 
    {
      print("Error fetching user data: $e");
      setState(() 
      {
        _username = "Error loading username";
        _profilePicture = "";
      });
    }
  }

  @override
  void didChangeDependencies() 
  {
    super.didChangeDependencies();
    _fetchUserData();
  }
  
  @override
  Widget build(BuildContext context) 
  {
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
                  child: SizedBox(
                    width: 130,
                    height: 130,
                    child: CircleAvatar(
                      radius: 0,
                      backgroundImage: _profilePicture.startsWith("http")
                          ? NetworkImage(_profilePicture)
                          : AssetImage("assets/standardProfilePicture.png") as ImageProvider,
                    ),
                  ),
                ),
                Positioned(
                  top: 200,
                  child: Text(
                    _username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  top: 245,
                  child: GestureDetector(
                    onTap: () 
                    {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfileUserSettings(),
                      ));
                    },
                    child: Container(
                      width: 355,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                            "User settings",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 310,
                  child: GestureDetector(
                    onTap: () 
                    {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfileAppSettings(),
                      ));
                    },
                    child: Container(
                      width: 355,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.settings_outlined,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "App settings",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 375,
                  child: GestureDetector(
                    onTap: () 
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) 
                        {
                          return AlertDialog(
                            title: Text("Log out?"),
                            content: Text("Are you sure you want to log out?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () 
                                {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () 
                                {
                                  Navigator.pushNamed (context, "/");
                                },
                                child: Text("Log out"),
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
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.logout_outlined,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Log out",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
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
              onTap: (index) 
              {
                setState(() 
                {
                  currentIndex = index;
                  switch (index) 
                  {
                    case 0:
                      Navigator.pushNamed(context, "/homepage");
                      break;
                    case 1:
                      Navigator.pushNamed(context, "/leaderboard");
                      break;
                    case 2:
                      Navigator.pushNamed(context, "/friendspage");
                      break;
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