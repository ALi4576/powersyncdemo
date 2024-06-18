import 'package:flutter/material.dart';
import 'package:powersyncdemo/product.dart';
import 'package:powersyncdemo/schema.dart';
import 'package:powersyncdemo/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

loadSupabase() async {
  await Supabase.initialize(
    url: '',
    anonKey:
        '',
    // debug: false,
    // authOptions: const FlutterAuthClientOptions(
    //   autoRefreshToken: false,
    // ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSupabase();
  if (supabase.auth.currentSession != null) {
    await supabase.auth.refreshSession();
    await openDatabase();
  }
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
      home: supabase.auth.currentSession == null
          ? const Signup()
          : const ProductView(),
    );
  }
}
