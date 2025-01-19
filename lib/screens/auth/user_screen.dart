import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: user != null
            ? [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ]
            : null,
        backgroundColor: isDarkMode ? Colors.brown[900] : Colors.brown[200],
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No user is currently logged in.',
                    style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.brown[800]),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/auth/login');
                    },
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.brown[700] : Colors.brown[300],
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.brown[900],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/auth/register');
                    },
                    child: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.brown[700] : Colors.brown[300],
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.brown[900],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Text(
                      user.email?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.brown[800]),
                  ),
                  Text(user.email ?? 'Unknown',
                      style: TextStyle(
                          color:
                              isDarkMode ? Colors.white : Colors.brown[600])),
                  SizedBox(height: 20),
                  Text(
                    'UID:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.brown[800]),
                  ),
                  Text(user.uid,
                      style: TextStyle(
                          color:
                              isDarkMode ? Colors.white : Colors.brown[600])),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.brown[700] : Colors.brown[300],
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.brown[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
