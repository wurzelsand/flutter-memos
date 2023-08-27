import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum AuthStatus { loggedIn, loggedOut, pending }

class AuthChanged {
  AuthChanged._(this.authStatus);

  AuthChanged.login() : this._(AuthStatus.loggedIn);
  AuthChanged.logout() : this._(AuthStatus.loggedOut);

  final AuthStatus authStatus;
}

class AuthBloc extends Bloc<AuthChanged, AuthStatus> {
  AuthBloc() : super(AuthStatus.loggedOut) {
    on<AuthChanged>(
      (event, emit) async {
        emit(AuthStatus.pending);
        await Future.delayed(const Duration(seconds: 1));
        emit(event.authStatus);
      },
    );
  }
}

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

final _materialApp = MaterialApp.router(
  routerConfig: _routes,
  debugShowCheckedModeBanner: false,
);

void main() {
  final authBloc = AuthBloc();
  runApp(
    BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: BlocBuilder<AuthBloc, AuthStatus>(
        bloc: authBloc,
        builder: (context, state) {
          if (state == AuthStatus.loggedIn) {
            return _materialApp;
          }
          return const MaterialApp(
            home: AuthGate(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: BlocBuilder<AuthBloc, AuthStatus>(builder: (context, state) {
          if (state == AuthStatus.loggedOut) {
            return ElevatedButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(AuthChanged.login()),
              child: const Text('Login'),
            );
          }
          return const CircularProgressIndicator();
        }),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(AuthChanged.logout()),
          )
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(AuthChanged.logout()),
          )
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
