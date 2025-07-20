import 'package:drug_app/models/drug.dart';
import 'package:drug_app/services/drug_service.dart';
import 'package:drug_app/services/pocketbase_client.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<void> _test() async {
    var pb = await getPocketBaseInstance();
    DrugService drugSerivice = DrugService();
    Drug? drug = await drugSerivice.getDrug(pb, 'x9sx98j6n7c77dm');
    var logger = Logger();
    if (drug != null) {
    } else {
      logger.e('Error: Drug not found');
    }
  }

  void _incrementCounter() {
    _test();
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
