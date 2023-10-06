import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'error_message_cubit.dart';

part 'database_state.dart';

class DatabaseCubit extends Cubit<DatabaseState> {
  DatabaseCubit({required this.errorCubit}) : super(const DatabaseState()) {
    _streamSubscription = FirebaseFirestore.instance
        .collection('persons')
        .orderBy('name.surname') // ASCII order only
        .snapshots()
        .listen(
      (database) {
        final List<Person> persons = [];
        for (final doc in database.docs) {
          if (doc.data()
              case {
                'name': {
                  'forename': String forename,
                  'surname': String surname,
                },
                'age': int age,
              }) {
            persons.add(Person(
                name: Name(
                  forename: forename,
                  surname: surname,
                ),
                age: age,
                id: doc.id));
          }
        }
        emit(DatabaseState(persons: persons));
      },
    );
  }

  late final StreamSubscription _streamSubscription;
  final ErrorMessageCubit errorCubit;

  void writePerson(Person? person) {
    if (person == null) return;
    final json = {
      'name': {
        'forename': person.name.forename,
        'surname': person.name.surname
      },
      'age': person.age
    };
    try {
      FirebaseFirestore.instance.collection('persons').add(json);
    } on FirebaseException catch (e) {
      final errorMessage = ErrorMessage(
        message: e.message ?? 'FirebaseException',
        type: e.runtimeType,
      );
      errorCubit.addErrorMessge(errorMessage);
    }
  }

  void removeEntry(String? id) {
    if (id == null) return;
    try {
      FirebaseFirestore.instance.collection('persons').doc(id).delete();
    } on FirebaseException catch (e) {
      final errorMessage = ErrorMessage(
        message: e.message ?? 'FirebaseException',
        type: e.runtimeType,
      );
      errorCubit.addErrorMessge(errorMessage);
    }
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }
}
