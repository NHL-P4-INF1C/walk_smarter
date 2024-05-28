import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:walk_smarter/loginpage.dart';
import 'package:walk_smarter/mappage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:convert';

import 'profileusersettings.dart';

final pb = PocketBase('https://inf1c-p4-pocketbase.bramsuurd.nl');

class ProfilePageSettings extends StatefulWidget {
  @override
  State<ProfilePageSettings> createState() => _ProfilePageSettingsState();
}

class _ProfilePageSettingsState extends State<ProfilePageSettings> {
  String _username = 'Loading...';
  String _profilePicture = '';
  String _userID = "08ars3msi5hgi5o";

  @override
  void initState() 
  {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try
    {
      final jsonString = await pb.collection('users').getFirstListItem(
        'id="$_userID"' 
      );
      final record = jsonDecode(jsonString.toString());
      setState(() 
      {
        _username = record["username"];
        if(record['avatar'] != null)
        {
          _profilePicture = pb.files.getUrl(jsonString, record['avatar']).toString();          
        }
        else
        {
          _profilePicture = '';
        }
      });
    } 
    catch (e) 
    {
      print('Error fetching user data: $e');
      setState(() 
      {
        _username = 'Error loading username';
        _profilePicture = '';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/walksmarterlogo.png'),
              height: 40,
              width: 40,
            ),
            SizedBox(width: 8),
            Text(
              'Walk Smarter',
              style: TextStyle(fontSize: 14),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Text(
                    '1000 Points',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: 40,
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profilepage');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 665,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 245, 243, 243),
            border: Border(
              top: BorderSide(
                color: Colors.black,
                width: 1,
              ),
              bottom: BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
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
                      backgroundImage: _profilePicture.startsWith('http')
                          ? NetworkImage(_profilePicture)
                          : AssetImage('assets/standardProfilePicture.png') as ImageProvider,
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
                    onTap: () {
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
                            'User settings',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 310,
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
                          'App settings',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 375,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginDemo(),
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
                            Icons.logout_outlined,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Log out',
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Friends',
          ),
        ],
        selectedItemColor: Color(int.parse('0xFF096A2E')),
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ));
          }
        },
      ),
    );
  }
}