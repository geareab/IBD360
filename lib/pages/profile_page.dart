import 'package:flutter/material.dart';
import 'package:fyp_app/pages/auth/login_page.dart';
import 'package:fyp_app/pages/home_page.dart';
import 'package:fyp_app/pages/symptoms_update.dart';
import 'package:fyp_app/service/auth_service.dart';
import 'package:fyp_app/widgets/widgets.dart';
import 'package:fyp_app/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String email;

  ProfilePage({Key? key, required this.email, required this.userName})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();

  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController startDateofMABController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController waitingtimeController = TextEditingController();
  TextEditingController previousSergeryController = TextEditingController();

  String? educationLevel;
  String? selectedDoctor;
  String? treatmentTaken;
  String? treatmentTakenBefore;
  String? testBefore;
  String? extentOf;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('medicalHistory')) {
          Map<String, dynamic> medicalHistory =
              data['medicalHistory'] as Map<String, dynamic>;
          setState(() {
            ageController.text = medicalHistory['age'] ?? '';
            genderController.text = medicalHistory['gender'] ?? '';
            educationLevel = medicalHistory['educationLevel'];
            selectedDoctor = medicalHistory['selectedDoctor'];
            treatmentTaken = medicalHistory['treatmentTaken'];
            treatmentTakenBefore = medicalHistory['treatmentTakenBefore'];
            startDateofMABController.text =
                medicalHistory['startDateofMAB'] ?? '';
            durationController.text = medicalHistory['duration'] ?? '';
            waitingtimeController.text = medicalHistory['waitingtime'] ?? '';
            testBefore = medicalHistory['testBefore'];
            extentOf = medicalHistory['extentOf'];
            previousSergeryController.text =
                medicalHistory['previousSergery'] ?? '';
          });
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load data: $error')));
    }
  }

  // Function to save form data to Firestore as JSON
  Future<void> saveFormData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a JSON object from the form data
      Map<String, dynamic> medicalHistory = {
        'userName': widget.userName,
        'gender': genderController.text,
        'age': ageController.text,
        'educationLevel': educationLevel,
        'selectedDoctor': selectedDoctor,
        'treatmentTaken': treatmentTaken,
        'treatmentTakenBefore': treatmentTakenBefore,
        'startDateofMAB': startDateofMABController.text,
        'duration': durationController.text,
        'waitingtime': waitingtimeController.text,
        'testBefore': testBefore,
        'extentOf': extentOf,
        'previousSergery': previousSergeryController.text,
      };

      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: widget.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          String uid = documentSnapshot.id;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'medicalHistory': medicalHistory});

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data saved successfully!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No user found with this email')));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save data: $error')));
      }
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
          "Profile",
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
              onTap: () {
                nextScreen(
                    context,
                    SymptomsPage(
                      userName: widget.userName,
                      email: widget.email,
                    ));
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.medical_information),
              title: const Text(
                "Medical Info",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {},
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
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
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: ageController,
                decoration: textInputDecoration.copyWith(
                    labelText: "Age",
                    prefixIcon: Icon(
                      Icons.person_2,
                      color: Theme.of(context).primaryColor,
                    )),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: genderController,
                decoration: textInputDecoration.copyWith(
                  labelText: "Gender",
                  prefixIcon: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                  ),
                  hintText: "Enter your gender",
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: textInputDecoration.copyWith(
                    labelText: "Education Level",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    )),
                value: educationLevel,
                hint: const Text("Education Level"),
                items: <String>[
                  'None',
                  'Primary School',
                  'Secondary School',
                  'Bachelor',
                  'Master',
                  'PhD'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    educationLevel = newValue;
                  });
                },
                validator: (val) {
                  if (val == null) {
                    return "Please select an education level";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: textInputDecoration.copyWith(
                    labelText: "Treatment Taken",
                    prefixIcon: Icon(
                      Icons.medication,
                      color: Theme.of(context).primaryColor,
                    )),
                value: treatmentTaken,
                hint: const Text("Treatment Taken"),
                items: <String>[
                  'None',
                  "Adalimumab",
                  "Infliximab",
                  "Ustekinumab",
                  "Vedolizumab"
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    treatmentTaken = newValue;
                  });
                },
                validator: (val) {
                  if (val == null) {
                    return "Please select a treatment";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: textInputDecoration.copyWith(
                    labelText: "Treatment Taken Before",
                    prefixIcon: Icon(
                      Icons.medication,
                      color: Theme.of(context).primaryColor,
                    )),
                value: treatmentTakenBefore,
                hint: const Text("Treatment Taken Before"),
                items: <String>[
                  'None',
                  'Azathioprine',
                  'Methotrexate',
                  'Corticosteroids',
                  'Others'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    treatmentTakenBefore = newValue;
                  });
                },
                validator: (val) {
                  if (val == null) {
                    return "Please select a previous treatment";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: startDateofMABController,
                decoration: textInputDecoration.copyWith(
                  labelText: "Start Date of Treatment",
                  prefixIcon: Icon(
                    Icons.date_range,
                    color: Theme.of(context).primaryColor,
                  ),
                  hintText: "Start Date of MAB Treatment",
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter start date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: durationController,
                decoration: textInputDecoration.copyWith(
                  labelText: "Duration of Disease",
                  prefixIcon: Icon(
                    Icons.date_range,
                    color: Theme.of(context).primaryColor,
                  ),
                  hintText: "Duration of Disease in days",
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: waitingtimeController,
                decoration: textInputDecoration.copyWith(
                  labelText: "Waiting time before Diagnose",
                  prefixIcon: Icon(
                    Icons.date_range,
                    color: Theme.of(context).primaryColor,
                  ),
                  hintText: "Waiting time before Diagnose in days",
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter waiting time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: textInputDecoration.copyWith(
                    labelText: "Tests Taken Before",
                    prefixIcon: Icon(
                      Icons.book,
                      color: Theme.of(context).primaryColor,
                    )),
                value: testBefore,
                hint: const Text("Tests Taken Before"),
                items: <String>[
                  'None',
                  'Biopsy',
                  'Radiology',
                  'Bloodtests',
                  'Other'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    testBefore = newValue;
                  });
                },
                validator: (val) {
                  if (val == null) {
                    return "Please select a test";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: textInputDecoration.copyWith(
                    labelText: "Extent of Disease",
                    prefixIcon: Icon(
                      Icons.medical_information,
                      color: Theme.of(context).primaryColor,
                    )),
                value: extentOf,
                hint: const Text("Extent of Disease"),
                items: <String>[
                  'None',
                  'Small',
                  'Bowel',
                  'Colonic',
                  'Ileocolonic',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    extentOf = newValue;
                  });
                },
                validator: (val) {
                  if (val == null) {
                    return "Please select a disease extent";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: previousSergeryController,
                decoration: textInputDecoration.copyWith(
                  labelText: "Previous Surgery",
                  prefixIcon: Icon(
                    Icons.medical_information,
                    color: Theme.of(context).primaryColor,
                  ),
                  hintText: "Previous Surgery",
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter previous surgery details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await saveFormData();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => SymptomsPage(
                            userName: widget.userName,
                            email: widget.email,
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
