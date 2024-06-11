import 'package:flutter/material.dart';
import 'package:powersyncdemo/main.dart';
import 'package:powersyncdemo/schema.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController.text = 'aliasad71734@gmail.com';
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text;
                String password = _passwordController.text;
                try {
                  await supabase.auth.signInWithPassword(
                    email: email,
                    password: password,
                  );
                  await openDatabase();
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await db
                      .get('SELECT * FROM users WHERE id = ?', [getUserId()]);

                  print(user);
                  print('******************');
                  print(user['rest_id']);
                  print('******************');

                  final products = await db.get(
                    'SELECT email, restaurant_name, phone FROM app_restaurant WHERE id = ?',
                    [user['rest_id']],
                  );
                  print(products);
                } catch (e, stack) {
                  print(stack);
                }
              },
              child: const Text('Test'),
            ),
          ],
        ),
      ),
    );
  }
}
