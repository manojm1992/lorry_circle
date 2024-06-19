import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PatternGenerator(),
    );
  }
}

class PatternGenerator extends StatefulWidget {
  @override
  _PatternGeneratorState createState() => _PatternGeneratorState();
}

class _PatternGeneratorState extends State<PatternGenerator> {
  final TextEditingController _controller = TextEditingController();
  String _pattern = '';



  void _generatePattern() {
    final input = int.tryParse(_controller.text);
    if (input == null || input <= 0) {
      setState(() {
        _pattern = 'Please enter a positive integer';
      });
      return;
    }

    int num = 1;
    StringBuffer buffer = StringBuffer();

    // Upper part of the pattern
    for (int i = 1; i <= input; i++) {
      for (int j = 1; j <= i; j++) {
        buffer.write('$num ');
        num++;
      }
      buffer.write('\n');
    }

    // Lower part of the pattern
    num -= input;
    for (int i = input - 1; i >= 1; i--) {
      for (int j = 1; j <= i; j++) {
        buffer.write('$num ');
        num++;
      }
      num -= (i * 2);
      buffer.write('\n');
    }

    setState(() {
      _pattern = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration:  InputDecoration(
          
                  border: OutlineInputBorder(
                    borderSide:  const BorderSide(
                      color: Colors.black, // Outline color
                    ),
                    borderRadius:
                    BorderRadius.circular(8.0), // Rounded corners
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black45, // Outline color when focused
                    ),
                    borderRadius:
                    BorderRadius.circular(8.0), // Rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color:Colors.black45, // Outline color when not focused
                    ),
                    borderRadius:
                    BorderRadius.circular(8.0), // Rounded corners
                  ),
                  labelText: 'Enter a positive integer',
                ),
              ),
               SizedBox(height: MediaQuery.of(context).size.height*0.016),
              ElevatedButton(
                onPressed: _generatePattern,
                child: const Text('Generate Pattern'),
              ),
              const SizedBox(height: 16),
              Text(
                _pattern,
                style: const TextStyle(fontSize: 20),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.020),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const ProfileScreen()));
                },
                child: const Text('Tap For Next Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key});

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/?results=2000'));

    if (response.statusCode == 200) {
      List<dynamic> usersJson = jsonDecode(response.body)['results'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:   const Color(0xFFF2FAF3),
      appBar: AppBar(
        title: const Text('Profile'),

      ),
      body: FutureBuilder<List<User>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            List<User> users = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                User user = users[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to details screen on row tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(user: user,imageUrl: user.imageUrl,),
                      ),
                    );
                  },
                  child: ProfileCard(
                    name: "${user.title} ${user.firstName} ${user.lastName}",
                    gender: user.gender,
                    age: user.age,
                    birthDate: user.birthDate,
                    address: "${user.street}, ${user.city}, ${user.state}, ${user.country}",
                    email: user.email,
                    phone: user.phone,
                    imageUrl: user.imageUrl,
                    onTapImage: () {
                      // Navigate to full-screen image view on image tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageView(imageUrl: user.imageUrl),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}


// Details Screen Widget
class UserDetailsScreen extends StatelessWidget {
  final String imageUrl;
  final User user;

  UserDetailsScreen({required this.user,required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Color genderColor = gender == 'male' ? Color(0xFF00BBD3) : Color(0xFFFF41B1);
    return Scaffold(
      appBar: AppBar(
        actions: [ IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {

            Navigator.pop(context);
          },
        ),],
        title: const Text('User Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              child:Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Text("Name: ${user.title} ${user.firstName} ${user.lastName}",style: const TextStyle(color:  Color(0xFF252926)),),
            Text("Username: ${user.firstName}",style: const TextStyle(color: Color(0xFFA3ACA5)),),
            Text("Gender: ${user.gender}",style: const TextStyle(color: Color(0xFFA3ACA5)),),
            Text("Email: ${user.email}",style: const TextStyle(color: Color(0xFFA3ACA5)),),
            Text("Address: ${user.street}, ${user.city}, ${user.state}, ${user.country}",style: const TextStyle(color: Color(0xFFA3ACA5)),),
            Text("Phone: ${user.phone}",style: const TextStyle(color: Color(0xFFA3ACA5)),),
            ElevatedButton(
              onPressed: () {

                Navigator.push(context, MaterialPageRoute(builder: (context)=>  ProfileScreen()));
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// Full Screen Image View Widget
class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  FullScreenImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close full-screen image view on tap
        },
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String gender;
  final int age;
  final String birthDate;
  final String address;
  final String email;
  final String phone;
  final String imageUrl;
  final VoidCallback onTapImage; // Named parameter for onTapImage

  ProfileCard({
    required this.name,
    required this.gender,
    required this.age,
    required this.birthDate,
    required this.address,
    required this.email,
    required this.phone,
    required this.imageUrl,
    required this.onTapImage, // Initialize the named parameter
  });

  @override
  Widget build(BuildContext context) {
    Color genderColor = gender == 'male' ? const Color(0xFF00BBD3) : const Color(0xFFFF41B1);
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF252926),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8.0, // Space between items
                      runSpacing: 4.0, // Space between lines
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              gender == 'male' ? Icons.male : Icons.female,
                              color: genderColor,
                            ),
                            const SizedBox(width: 8.0),
                            Text(gender, style: const TextStyle(color: Color(0xFFA3ACA5)),),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cake,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4.0),
                            Text('$age Years Old',style: const TextStyle(color: Color(0xFFA3ACA5)),),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(birthDate,style: const TextStyle(color: Color(0xFFA3ACA5)),),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.grey,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(address,style: const TextStyle(color: Color(0xFFA3ACA5)),),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(
                Icons.email,
                color: Colors.grey,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(email,style: const TextStyle(color: Color(0xFFA3ACA5)),),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(phone,style: const TextStyle(color: Color(0xFFA3ACA5)),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class User {
  final String title;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final String birthDate;
  final String street;
  final String city;
  final String state;
  final String country;
  final String email;
  final String phone;
  final String imageUrl;


  User({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.birthDate,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      title: json['name']['title'],
      firstName: json['name']['first'],
      lastName: json['name']['last'],
      gender: json['gender'],
      age: json['dob']['age'],
      birthDate: json['dob']['date'].split('T')[0],
      street: json['location']['street']['name'],
      city: json['location']['city'],
      state: json['location']['state'],
      country: json['location']['country'],
      email: json['email'],
      phone: json['phone'],
      imageUrl: json['picture']['large'],
    );
  }
}

