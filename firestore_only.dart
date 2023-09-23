import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

typedef Json = Map<String, dynamic>;

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: () => showDialog<Json>(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: NameAndAgeForm(),
              );
            },
          ).then(writeJson),
          icon: const Icon(Icons.add),
        )
      ]),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('persons')
              .orderBy('name.surname') // ASCII order only
              .snapshots(),
          builder: (context, snapshot) {
            final snapshotData = snapshot.data;
            if (snapshotData == null) return const CircularProgressIndicator();
            return ListView(
              children: snapshotData.docs
                  .map(
                    (doc) {
                      if (doc.data()
                          case {
                            'name': {
                              'forename': String forename,
                              'surname': String surname,
                            },
                            'age': int age,
                          }) {
                        return ListTile(
                          title: Text('$forename $surname, age: $age'),
                          onTap: () => removeEntry(doc.id), // doc.id captured
                        );
                      }
                      return null;
                    },
                  )
                  .whereType<Widget>()
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  void writeJson(Json? json) {
    if (json == null) return;
    try {
      FirebaseFirestore.instance.collection('persons').add(json);
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    }
  }

  void removeEntry(String id) {
    try {
      FirebaseFirestore.instance.collection('persons').doc(id).delete();
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    }
  }
}

class NameAndAgeForm extends StatefulWidget {
  const NameAndAgeForm({super.key});

  @override
  State<NameAndAgeForm> createState() => _NameAndAgeFormState();
}

class _NameAndAgeFormState extends State<NameAndAgeForm> {
  final _formkey = GlobalKey<FormState>();
  final _forenameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            TextFormField(
              controller: _forenameController,
              decoration: const InputDecoration(
                hintText: 'Forename',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isEmpty) {
                  return 'missing';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _surnameController,
              decoration: const InputDecoration(
                hintText: 'Surname',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isEmpty) {
                  return 'missing';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                hintText: 'Age',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && int.tryParse(value) == null) {
                  return 'not whole number';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  final forename = _forenameController.text;
                  final surname = _surnameController.text;
                  final age = int.parse(_ageController.text);
                  final json = {
                    'name': {'forename': forename, 'surname': surname},
                    'age': age
                  };
                  Navigator.pop(context, json);
                }
              },
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
