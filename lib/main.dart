import 'package:cowtrain/provider/user_provider.dart';
import 'package:cowtrain/screens/HomeScreen.dart';
import 'package:cowtrain/screens/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 131, 57, 0),
  )
  // textTheme: GoogleFonts.latoTextTheme(),
);

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context)=> UserProvider())
  ],

      child: const App()));
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      home:  SplashScreen(),
    );
  }
}