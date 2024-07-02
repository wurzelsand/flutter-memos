import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_database_provider.dart';

class MyInputDialog extends StatelessWidget {
  MyInputDialog.create({super.key}) : _id = null;
  MyInputDialog.update({super.key, required DataPair dataPair})
      : _id = dataPair.id {
    _firstController.text = dataPair.first;
    _secondController.text = dataPair.second;
  }

  final _firstController = TextEditingController();
  final _secondController = TextEditingController();
  final int? _id;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        insetPadding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: TextFormField(
                    controller: _firstController,
                    decoration: const InputDecoration(
                      label: Text('first'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: TextFormField(
                    controller: _secondController,
                    decoration: const InputDecoration(
                      label: Text('second'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final datePair = DataPair(
                                id: _id,
                                first: _firstController.text,
                                second: _secondController.text);
                            Navigator.pop(context, datePair);
                          },
                          child: const Text('Submit'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _id == null
                          ? null
                          : () {
                              context
                                  .read<MyDatabaseProvider>()
                                  .delete(id: _id);
                              Navigator.pop(context);
                            },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
