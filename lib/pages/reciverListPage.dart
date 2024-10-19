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
  List<Map<String, dynamic>> filteredList = []; // Filtered list to display
  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchUsers(); // Fetch the users when the widget is initialized
    _searchController.addListener(_filterUsers); // Add listener for search input
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
        usersList = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        filteredList = usersList; // Initialize filtered list to all users
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  // Filter the usersList based on search query
  void _filterUsers() {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        filteredList = usersList; // Show all users when query is empty
      });
    } else {
      setState(() {
        filteredList = usersList.where((user) {
          return user['phonenumber'] != null &&
              user['phonenumber'].toString().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receiver List'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by phone number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: filteredList.isEmpty
          ? Center(child: Text('ไม่เจอผู้ใช้เบอร์นี้')) // Display message when no users are found
          : ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> user = filteredList[index];
                if (user['phonenumber'] != phonenumber) {
                  return ListTile(
                    title: Text(user['username'] ?? 'No Name'), // Display user's name
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['phonenumber'] ?? 'phonenumber'), // Display user's phone number
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
