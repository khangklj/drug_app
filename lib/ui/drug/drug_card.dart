import 'package:flutter/material.dart';

class DrugCard extends StatelessWidget {
  const DrugCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          debugPrint('Card tapped.');
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: [Text("HEee")]),
      ),
    );
  }
}
