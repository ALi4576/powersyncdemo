import 'package:flutter/material.dart';
import 'package:powersyncdemo/schema.dart';
import 'package:powersyncdemo/signup.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Signup(),
                ),
              );
            },
          ),
        ],
      ),
      // body: FutureBuilder(
      //   future: db.getAll('SELECT * FROM product'),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasError) {
      //       return const Text('An error occurred');
      //     }
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Text('Loading');
      //     }
      //     final data = snapshot.data;
      //     if (data == null) return const Text('No data');

      //     return ListView.builder(
      //       shrinkWrap: true,
      //       itemCount: data.length,
      //       itemBuilder: (context, index) {
      //         final item = data[index];
      //         final productName =
      //             TextEditingController(text: item['product_name']);
      //         final price =
      //             TextEditingController(text: item['price'].toString());
      //         return ListTile(
      //           title: Text(item['id'] + ' -----   ' + item['product_name']),
      //           subtitle: Text(item['price'].toString()),
      //           onTap: () {
      //             showDialog(
      //               context: context,
      //               builder: (context) {
      //                 return AlertDialog(
      //                   title: Text(item['product_name']),
      //                   content: Column(
      //                     children: [
      //                       TextField(
      //                         controller: productName,
      //                       ),
      //                       TextField(
      //                         controller: price,
      //                       ),
      //                       ElevatedButton(
      //                         onPressed: () {
      //                           await db.execute('');
      //                         },
      //                         child: const Text('Update'),
      //                       ),
      //                     ],
      //                   ),
      //                 );
      //               },
      //             );
      //           },
      //         );
      //       },
      //     );
      //   },
      // ),
      body: StreamBuilder(
        stream: db.watch(
          'SELECT * FROM product where rest_id = 1',
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('An error occurred');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          final data = snapshot.data;
          if (data == null) return const Text('No data');

          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final productName =
                  TextEditingController(text: item['product_name']);
              final price =
                  TextEditingController(text: item['price'].toString());
              return ListTile(
                title: Text(item['id'] + ' -----   ' + item['product_name']),
                subtitle: Text(item['price'].toString()),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(item['product_name']),
                        content: Column(
                          children: [
                            TextField(
                              controller: productName,
                            ),
                            TextField(
                              controller: price,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                print(price.text);
                                print(productName.text);
                                await db
                                    .execute(
                                  "UPDATE product SET product_name = '${productName.text}' ,price = ${double.parse(price.text)} WHERE id = ${item['id']}",
                                )
                                    .then((value) {
                                  print(value.rows);
                                  Navigator.pop(context);
                                });
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
