import 'package:fyp_app/pages/auth/login_page.dart';
import 'package:fyp_app/pages/home_page.dart';
import 'package:fyp_app/pages/profile_page.dart';
import 'package:fyp_app/service/auth_service.dart';
import 'package:fyp_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fyp_app/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SymptomsPage extends StatefulWidget {
  String userName;
  String email;
  SymptomsPage({Key? key, required this.email, required this.userName})
      : super(key: key);

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  final formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  Map<String, dynamic>? medicalHistory;
  bool medicalHistoryExists = true;

  @override
  void initState() {
    super.initState();
    fetchMedicalHistory();
  }

  Future<void> fetchMedicalHistory() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          var data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('medicalHistory')) {
            medicalHistory = data['medicalHistory'] as Map<String, dynamic>;
          } else {
            medicalHistoryExists = false;
          }
        });
      }
    } catch (e) {
      print("Error fetching medical history: $e");
      setState(() {
        medicalHistoryExists = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, HomePage());
              },
              icon: const Icon(
                Icons.home,
              ))
        ],
        backgroundColor: Constants.primaryColorr,
        elevation: 0,
        title: const Text(
          "Medical Info",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: <Widget>[
          Icon(
            Icons.account_circle,
            size: 150,
            color: Colors.grey[700],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          const Divider(
            height: 2,
          ),
          ListTile(
            onTap: () {
              nextScreen(context, const HomePage());
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.home),
            title: const Text(
              "Home",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () {},
            selected: true,
            selectedColor: Theme.of(context).primaryColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.medical_information),
            title: const Text(
              "Medical Info",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () {
              nextScreen(
                  context,
                  ProfilePage(
                    userName: widget.userName,
                    email: widget.email,
                  ));
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Edit Profile",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  });
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      )),
      body: medicalHistory == null && medicalHistoryExists
          ? Center(child: CircularProgressIndicator())
          : !medicalHistoryExists
              ? Center(
                  child: Text(
                    "Please visit the profile page",
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildInfoCard("Full Name", widget.userName),
                      buildInfoCard("Patient Age", medicalHistory!['age']),
                      buildInfoCard("Patient Sex", medicalHistory!['gender']),
                      buildInfoCard("Level of Education",
                          medicalHistory!['educationLevel']),
                      buildInfoCard("Current Treatment (MABs)",
                          medicalHistory!['treatmentTaken']),
                      buildInfoCard("Previous Treatment Before MABs",
                          medicalHistory!['treatmentTakenBefore']),
                      buildInfoCard("Start Date of MAB Treatment",
                          medicalHistory!['startDateofMAB']),
                      buildInfoCard(
                          "Duration of Disease", medicalHistory!['duration']),
                      buildInfoCard("Waiting Time Before Diagnosis",
                          medicalHistory!['waitingtime']),
                      buildInfoCard("Tests Taken Before Diagnosis",
                          medicalHistory!['testBefore']),
                      buildInfoCard(
                          "Extent of Disease", medicalHistory!['extentOf']),
                      buildInfoCard("Previous Surgery",
                          medicalHistory!['previousSergery']),
                    ],
                  ),
                ),
    );
  }

  Widget buildInfoCard(String label, String value) {
    return Card(
      color: Color.fromARGB(255, 134, 198, 217), // Custom background color
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          label,
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
