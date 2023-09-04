import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

// States:

sealed class UserStatus extends Equatable {
  const UserStatus({this.errorText});

  final String? errorText;

  UserStatus errorCleaned();

  @override
  List<Object?> get props => [errorText];
}

class Authenticated extends UserStatus {
  const Authenticated({required this.user, super.errorText});

  final User user;

  @override
  Authenticated errorCleaned() => Authenticated(user: user);

  @override
  List<Object?> get props => [user, errorText];
}

class Unauthenticated extends UserStatus {
  const Unauthenticated({super.errorText});

  @override
  Unauthenticated errorCleaned() => const Unauthenticated();
}

// Events:

sealed class AuthChanged {
  const AuthChanged();
}

class LoginRequested extends AuthChanged {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;
}

class LogoutRequested extends AuthChanged {
  const LogoutRequested({required this.user});

  final User user;
}

class _ActuallyLoggedIn extends AuthChanged {
  const _ActuallyLoggedIn({required this.user});

  final User user;
}

class _ActuallyLoggedOut extends AuthChanged {
  const _ActuallyLoggedOut();
}

class ErrorHandled extends AuthChanged {
  const ErrorHandled();
}

// Bloc:

class AuthBloc extends Bloc<AuthChanged, UserStatus> {
  AuthBloc({required this.auth}) : super(const Unauthenticated()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<_ActuallyLoggedIn>(_onActuallyLoggedIn);
    on<_ActuallyLoggedOut>(_onActuallyLoggedOut);
    on<ErrorHandled>(_onErrorHandled);

    _authSubscription = auth.authStateChanges().listen((user) {
      if (user != null) {
        add(_ActuallyLoggedIn(user: user));
      } else {
        add(const _ActuallyLoggedOut());
      }
    });
  }

  final FirebaseAuth auth;
  late final StreamSubscription<User?> _authSubscription;

  void _onLoginRequested(LoginRequested event, Emitter<UserStatus> emit) async {
    try {
      await auth.signInWithEmailAndPassword(
          email: event.email, password: event.password);
    } on FirebaseAuthException catch (e) {
      emit(Unauthenticated(errorText: e.message));
    }
  }

  void _onLogoutRequested(
      LogoutRequested event, Emitter<UserStatus> emit) async {
    try {
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      emit(Authenticated(user: event.user, errorText: e.message));
    }
  }

  void _onActuallyLoggedIn(_ActuallyLoggedIn event, Emitter<UserStatus> emit) {
    emit(Authenticated(user: event.user));
  }

  void _onActuallyLoggedOut(
      _ActuallyLoggedOut event, Emitter<UserStatus> emit) {
    emit(const Unauthenticated());
  }

  void _onErrorHandled(ErrorHandled event, Emitter<UserStatus> emit) {
    emit(state.errorCleaned());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}

// Main:

final _routes = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      name: 'home',
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: 'profile',
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    )
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authBloc = AuthBloc(auth: FirebaseAuth.instance);
  runApp(BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, UserStatus>(
      builder: (context, state) {
        if (state is Authenticated) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: _routes,
          );
        }
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: BlocListener<AuthBloc, UserStatus>(
          listener: (context, state) {
            final errorText = state.errorText;
            if (errorText != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(errorText)));
              context.read<AuthBloc>().add(const ErrorHandled());
            }
          },
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(),
                      helperText: ' ',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateNotEmpty.then(_validateEmail),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(),
                      helperText: ' ',
                    ),
                    validator: _validateNotEmpty,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(LoginRequested(
                            email: _emailController.text,
                            password: _passwordController.text));
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static String? _validateNotEmpty(String? value) {
    if (value == null || value.isNotEmpty) {
      return null;
    }
    return 'Required';
  }

  static String? _validateEmail(String? value) {
    final regExp = RegExp(
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
    if (value == null || regExp.hasMatch(value)) {
      return null;
    }
    return 'Please enter valid email';
  }
}

typedef ValidatorFunction = String? Function(String?);

extension Concatenation on ValidatorFunction {
  ValidatorFunction then(ValidatorFunction validator) {
    return (value) {
      final messageText = this(value);
      if (messageText == null) {
        return validator(value);
      }
      return messageText;
    };
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<AuthBloc, UserStatus>(builder: (context, state) {
            final user = (state as Authenticated).user;
            return IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(LogoutRequested(user: user)),
            );
          })
        ],
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.goNamed('profile'),
          child: const Text('Profile'),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<AuthBloc, UserStatus>(builder: (context, state) {
            final user = (state as Authenticated).user;
            return IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(LogoutRequested(user: user)),
            );
          })
        ],
        title: const Text('Profile Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.goNamed('home'),
          child: const Text('Home'),
        ),
      ),
    );
  }
}
