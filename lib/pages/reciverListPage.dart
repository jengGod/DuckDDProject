import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reciverlistpage extends StatefulWidget {
  const Reciverlistpage({super.key});

  @override
  State<Reciverlistpage> createState() => _ReciverlistState();
}

class _ReciverlistState extends State<Reciverlistpage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> usersList = [];
  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchUsers(); // Fetch the users when the widget is initialized
  }
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      phonenumber = prefs.getString('phonenumber');
      profilePicture = prefs.getString('profile_picture');
    });
  }

  // Fetch users from Firestore
  Future<void> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('Users').get();

      // Loop through documents and add to the usersList
      setState(() {
        usersList = querySnapshot.docs.map((doc) {
          return doc.data()
              as Map<String, dynamic>; // Cast to Map<String, dynamic>
        }).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receiver List'),
      ),
      body: usersList.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader while data is loading
          : ListView.builder(
              itemCount: usersList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> user = usersList[index];
                if (user['phonenumber'] != phonenumber) {
                  return ListTile(
                    title: Text(
                        user['username'] ?? 'No Name'), // Display user's name
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['phonenumber'] ??
                            'phonenumber'), // Display user's phone number
                        Text(user['email'] ?? 'email'), // Display user's email
                      ],
                    ),
                    onTap: () {
                      // Pop back to SendPage with the selected data
                      Navigator.pop(context, {
                        'username': user['username'],
                        'phonenumber': user['phonenumber'],
                      });
                    },
                  );
                }
                // Return an empty widget if condition is not met
                return const SizedBox.shrink();
              },
            ),
    );
  }
}
