import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/search_screen.dart';
import 'screens/book_details_screen.dart';
import 'screens/minigames_screen.dart';
import 'screens/my_shelf_screen.dart';
import 'screens/main_layout.dart';
import 'screens/games/cover_reveal_screen.dart';
import 'screens/games/sentence_decryption_screen.dart';
import 'screens/games/timeline_screen.dart';
import 'models/book.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BookFusionApp(),
    ),
  );
}

class BookFusionApp extends StatelessWidget {
  const BookFusionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookFusion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.pastelLight,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final book = settings.arguments as Book;
          return MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => Consumer<AppState>(
          builder: (context, state, child) {
            if (state.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return state.isLoggedIn ? const MainLayout() : const LoginScreen();
          },
        ),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainLayout(),
        '/search': (context) => const SearchScreen(),
        '/shelf': (context) => const MyShelfScreen(),
        '/minigames': (context) => const MinigamesScreen(),
        '/minigames/cover_reveal': (context) => const CoverRevealScreen(),
        '/minigames/decryption': (context) => const SentenceDecryptionScreen(),
        '/minigames/timeline': (context) => const TimelineScreen(),
      },
    );
  }
}
