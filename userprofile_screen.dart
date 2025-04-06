// userprofile_screen.dart or wherever your screen is

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:women_safety_application/screens/home_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key})
    : super(key: key); // No userData required now

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,MaterialPageRoute(builder:(context)=>HomeScreen()),
              );
            },
            child: Text('LogOut'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.warning),
              title: Text('Emergency'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.share_location),
              title: Text('Share Location'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Center(
        child: Text("Welcome to your profile!", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
