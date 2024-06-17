import 'package:powersync/powersync.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const schema = Schema([
  Table('app_taxprofile', [
    Column.text('tax_name'),
    Column.real('tax_percentage'),
    Column.text('createdAt'),
    Column.text('updatedAt'),
    Column.integer('restaurant_id'),
    Column.text('ntak_name')
  ]),
  Table('product', [Column.text('product_name'), Column.real('price')]),
  Table('users',
      [Column.text('rest_id'), Column.text('role'), Column.text('pk')]),
  Table('app_product', [
    Column.text('product_name'),
    Column.integer('restaurant_id'),
    Column.text('user_id'),
    Column.real('price'),
    Column.integer('category_id')
  ])
]);

late PowerSyncDatabase db;

final List<RegExp> fatalResponseCodes = [
  RegExp(r'^22...$'),
  RegExp(r'^23...$'),
  RegExp(r'^42501$'),
];

class SupabaseConnector extends PowerSyncBackendConnector {
  PowerSyncDatabase db;

  Future<void>? _refreshFuture;

  SupabaseConnector(this.db);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    await _refreshFuture;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return null;
    }

    final token = session.accessToken;

    final userId = session.user.id;
    final expiresAt = session.expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 2000);
    return PowerSyncCredentials(
      endpoint: 'https://6666c4fcd7363928f51aab41.powersync.journeyapps.com',
      token: token,
      userId: userId,
      expiresAt: expiresAt,
    );
  }

  @override
  void invalidateCredentials() {
    _refreshFuture = Supabase.instance.client.auth
        .refreshSession()
        .timeout(const Duration(seconds: 5))
        .then((response) => null, onError: (error) => null);
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) {
      return;
    }

    final rest = Supabase.instance.client.rest;
    CrudEntry? lastOp;
    try {
      for (var op in transaction.crud) {
        lastOp = op;

        final table = rest.from(op.table);
        if (op.op == UpdateType.put) {
          var data = Map<String, dynamic>.of(op.opData!);
          data['id'] = op.id;
          await table.upsert(data);
        } else if (op.op == UpdateType.patch) {
          await table.update(op.opData!).eq('id', op.id);
        } else if (op.op == UpdateType.delete) {
          await table.delete().eq('id', op.id);
        }
      }

      await transaction.complete();
    } on PostgrestException catch (e) {
      if (e.code != null &&
          fatalResponseCodes.any((re) => re.hasMatch(e.code!))) {
        print(lastOp);
        await transaction.complete();
      } else {
        rethrow;
      }
    }
  }
}

bool isLoggedIn() {
  return Supabase.instance.client.auth.currentSession?.accessToken != null;
}

String? getUserId() {
  return Supabase.instance.client.auth.currentSession?.user.id;
}

Future<String> getDatabasePath() async {
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, 'powersync-demo.db');
}

Future<void> openDatabase() async {
  db = PowerSyncDatabase(
    schema: schema,
    path: await getDatabasePath(),
  );
  await db.initialize();

  SupabaseConnector? currentConnector;

  if (isLoggedIn()) {
    currentConnector = SupabaseConnector(db);
    db.connect(connector: currentConnector);
  }

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      currentConnector = SupabaseConnector(db);
      db.connect(connector: currentConnector!);
    } else if (event == AuthChangeEvent.signedOut) {
      currentConnector = null;
      await db.disconnect();
    } else if (event == AuthChangeEvent.tokenRefreshed) {
      currentConnector?.prefetchCredentials();
    }
  });
}

Future<void> logout() async {
  await Supabase.instance.client.auth.signOut();
  await db.disconnectAndClear();
}
