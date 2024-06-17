import 'package:flutter/material.dart';
import 'package:powersync/powersync.dart';
import 'package:powersyncdemo/main.dart';
import 'package:powersyncdemo/product.dart';
import 'package:powersyncdemo/schema.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Future<void> uploadData() async {
    final batch = await db.getCrudBatch();
    if (batch == null) return;
    final rest = Supabase.instance.client.rest;

    for (var op in batch.crud) {
      final table = rest.from(op.table);

      switch (op.op) {
        case UpdateType.put:
          // Send the data to your backend service
          // Replace `_myApi` with your own API client or service
          var data = Map<String, dynamic>.of(op.opData!);
          data['id'] = op.id;
          await table.upsert(data);
          break;
        default:
          // TODO: implement the other operations (patch, delete)
          break;
      }
    }
    await batch.complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.center,
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
                  await supabase.auth
                      .signInWithPassword(
                    email: email,
                    password: password,
                  )
                      .then((value) async {
                    await openDatabase().then((value) async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductView(),
                        ),
                      );
                    });
                  });
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('Sign In'),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     try {
            //       final products = await db
            //           .execute("SELECT id,restaurant_id FROM app_product");

            //       for (var i in products) {
            //         print(i);
            //       }

            //       // inset new product
            //       // await db.execute("INSERT INTO app_product (id,product_name, restaurant_id, user_id) VALUES (uuid(),'Product 1', 50, '83f752e2-9184-40a3-908b-38390861d768')");
            //     } catch (e, stack) {
            //       print(stack);
            //     }
            //   },
            //   child: const Text('Test'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     try {
            //       await db.execute(
            //           "UPDATE app_product set product_name = 'Product 7' where id = '85802'");
            //       await db.execute(
            //           "INSERT INTO app_product (id,product_name, restaurant_id, user_id) VALUES (uuid(),'Product 1', 50, '83f752e2-9184-40a3-908b-38390861d768')");

            //       final prod = await db
            //           .get("SELECT * FROM app_product where id = '85802'");
            //       print(prod);
            //       // await uploadData().then(
            //       //   (value) {
            //       //     print('Data pushed');
            //       //   },
            //       // );

            //       // sync database
            //     } catch (e, stack) {
            //       print(stack);
            //     }
            //   },
            //   child: const Text('Push Data'),
            // ),
          ],
        ),
      ),
    );
  }
}
