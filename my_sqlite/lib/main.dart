import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_database_provider.dart';
import 'my_input_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(ChangeNotifierProvider(
    create: (context) => MyDatabaseProvider(subdir: 'english'),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: Builder(
          builder: (materialContext) {
            return FloatingActionButton(
              onPressed: () => addNewDataPair(materialContext),
              child: const Icon(Icons.add),
            );
          },
        ),
        body: Consumer<MyDatabaseProvider>(
          builder: (context, myDatabaseProvider, child) {
            return FutureBuilder(
                future: myDatabaseProvider.getAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final table = snapshot.data!;
                    return table.isEmpty
                        ? const Center(child: Text('Database empty'))
                        : SafeArea(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Table(
                                  border: TableBorder.all(),
                                  columnWidths: const {0: FixedColumnWidth(40)},
                                  children: buildTableRows(table, context),
                                ),
                              ),
                            ),
                          );
                  } else {
                    return const CircularProgressIndicator();
                  }
                });
          },
        ),
      ),
    );
  }

  void addNewDataPair(BuildContext context) async {
    final dataPair = await showDialog<DataPair?>(
        context: context, builder: (context) => MyInputDialog.create());
    if (dataPair == null) {
      return;
    }
    if (context.mounted) {
      final db = context.read<MyDatabaseProvider>();
      db.add(dataPair);
    }
  }
}

List<TableRow> buildTableRows(List<DataPair> table, BuildContext context) {
  return table
      .map(
        (dataPair) => TableRow(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final newDataPair = await showDialog(
                  context: context,
                  builder: (context) => MyInputDialog.update(
                    dataPair: dataPair,
                  ),
                );
                if (context.mounted && newDataPair != null) {
                  final db = context.read<MyDatabaseProvider>();
                  db.update(newDataPair);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                dataPair.first,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dataPair.second,
                )),
          ],
        ),
      )
      .toList();
}
