import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_only/cubit/error_message_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/database_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final errorCubit = ErrorMessageCubit();
  final databaseCubit = DatabaseCubit(errorCubit: errorCubit);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider.value(value: errorCubit),
      BlocProvider.value(value: databaseCubit),
    ],
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainApp(),
    ),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ErrorMessageCubit, List<ErrorMessage>>(
      listener: (context, state) {
        final errorMessage = state.firstOrNull;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage.message)));
          context.read<ErrorMessageCubit>().removeErrorMessage(errorMessage);
        }
      },
      child: Scaffold(
        appBar: AppBar(actions: [
          IconButton(
            onPressed: () => showDialog<Person>(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: NameAndAgeForm(),
                );
              },
            ).then(context.read<DatabaseCubit>().writePerson),
            icon: const Icon(Icons.add),
          )
        ]),
        body: Center(
          child: BlocBuilder<DatabaseCubit, DatabaseState>(
            builder: (context, state) {
              return ListView(
                children: state.persons
                    .map(
                      (person) => ListTile(
                        title: Text(
                            '${person.name.forename} ${person.name.surname}, age: ${person.age}'),
                        onTap: () => context
                            .read<DatabaseCubit>()
                            .removeEntry(person.id),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
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
                if (value == null || value.isEmpty) {
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
                if (value == null || value.isEmpty) {
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
                if (value == null || int.tryParse(value) == null) {
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
                  final person = Person(
                      name: Name(
                        forename: forename,
                        surname: surname,
                      ),
                      age: age);
                  Navigator.pop(context, person);
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
