import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ItemProvider with ChangeNotifier {
  ItemProvider() {
    addHundredItems();
  }

  final items = <String>[];
  var _counter = 0;

  void addHundredItems() {
    final hundredItems = List<String>.generate(
        100, (index) => 'This is item number ${++_counter}.');
    items.addAll(hundredItems);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) => ItemProvider(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Container(
        decoration: BoxDecoration(border: Border.all()),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isDialogOpen
                  ? null
                  : () {
                      setState(() => _isDialogOpen = true);
                      _openModelessDialog(
                        context,
                        onClose: () => setState(() => _isDialogOpen = false),
                      );
                    },
              child: const Text('open Dialog'),
            ),
            Expanded(
              child: ListView(
                children: context
                    .watch<ItemProvider>()
                    .items
                    .map((item) => Text(item))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openModelessDialog(BuildContext context, {void Function()? onClose}) {
  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (context) => _Dialog(
      entry: entry,
      onClose: onClose,
    ),
  );
  Overlay.of(context).insert(entry);
}

class _Dialog extends StatefulWidget {
  const _Dialog({
    required this.entry,
    this.onClose,
  });
  final void Function()? onClose;
  final OverlayEntry? entry;

  @override
  State<_Dialog> createState() => __DialogState();
}

class __DialogState extends State<_Dialog> {
  Offset? _offset;

  @override
  void dispose() {
    widget.entry?.dispose();
    if (widget.onClose != null) {
      SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => widget.onClose!(),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogBox = _dialogBox(context);
    return _offset == null
        ? Center(
            child: OverflowBox(
                // to prevent scaling on small screens
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: _draggable(dialogBox)),
          )
        : Positioned(
            top: _offset!.dy,
            left: _offset!.dx,
            child: _draggable(dialogBox),
          );
  }

  Widget _draggable(Widget dialogBox) {
    return Draggable(
      onDragEnd: (details) {
        setState(() {
          _offset = details.offset;
        });
      },
      feedback: dialogBox,
      childWhenDragging: Container(),
      child: dialogBox,
    );
  }

  Widget _dialogBox(BuildContext context) {
    return FittedBox(
      child: ClipRect(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
              width: 0,
            ),
          ),
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _dialogContent,
            ),
          ),
        ),
      ),
    );
  }

  Widget get _dialogContent => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 400, maxWidth: 400),
            child: TextFormField(
              decoration: const InputDecoration(
                label: Text('Input'),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ItemProvider>().addHundredItems(),
            child: const Text('Add 100 items'),
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: () {
              widget.entry?.remove();
            },
            child: const Text('Close'),
          ),
        ],
      );
}
