import 'package:flutter/material.dart';
import 'package:powersyncdemo/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

loadSupabase() async {
  await Supabase.initialize(
    url: 'https://psagzvmjohwcpcjdzpww.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzYWd6dm1qb2h3Y3BjamR6cHd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTgwMDgyMDEsImV4cCI6MjAzMzU4NDIwMX0.GmsKn0Dvf54GHd0z62FFXlowirq7ZTdFclFVt9y68b0',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSupabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Signup(),
    );
  }
}
