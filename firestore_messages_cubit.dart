import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Model:

class SimpleUser extends Equatable {
  const SimpleUser({this.email, required this.id});

  final String? email;
  final String id;

  @override
  List<Object?> get props => [email, id];
}

extension Converting on User {
  SimpleUser get toSimpleUser => SimpleUser(email: email, id: uid);
}

class Message extends Equatable {
  Message({required this.content, required this.simpleUser, int? timestamp})
      : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  final String content;
  final SimpleUser simpleUser;
  final int timestamp;

  @override
  List<Object?> get props => [content, simpleUser, timestamp];
}

// State: List<Message>

// Cubit:
class MessagesCubit extends Cubit<List<Message>> {
  MessagesCubit({required this.store, required this.auth}) : super(const []) {
    auth.userChanges().listen((user) {
      if (user != null) {
        _guestbookSubscription = store
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          List<Message> messages = [];

          for (final document in snapshot.docs) {
            messages.add(Message(
                content: document.data()['content'],
                simpleUser: SimpleUser(
                    id: document.data()['user_id'],
                    email: document.data()['user_email']),
                timestamp: document.data()['timestamp']));
            refresh(messages: messages);
          }
        });
      } else {
        refresh(messages: []);
        _guestbookSubscription?.cancel();
      }
    });
  }

  final FirebaseFirestore store;
  final FirebaseAuth auth;

  StreamSubscription<QuerySnapshot>? _guestbookSubscription;

  void refresh({required List<Message> messages}) {
    emit(messages);
  }

  void sendMessage(Message message) {
    store.collection('guestbook').add({
      'content': message.content,
      'user_email': message.simpleUser.email,
      'user_id': message.simpleUser.id,
      'timestamp': message.timestamp
    });
  }

  @override
  Future<void> close() {
    _guestbookSubscription?.cancel();
    return super.close();
  }
}
