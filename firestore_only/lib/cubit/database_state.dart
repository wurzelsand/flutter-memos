part of 'database_cubit.dart';

class Person extends Equatable {
  const Person({required this.name, required this.age, this.id});

  final Name name;
  final int age;
  final String? id;

  @override
  List<Object?> get props => [name, age, id];
}

class Name extends Equatable {
  const Name({required this.forename, required this.surname});

  final String forename;
  final String surname;

  @override
  List<Object?> get props => [forename, surname];
}

class DatabaseState extends Equatable {
  const DatabaseState({this.persons = const []});
  final List<Person> persons;

  @override
  List<Object?> get props => [persons];
}
