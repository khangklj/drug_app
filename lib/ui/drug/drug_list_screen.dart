import 'package:drug_app/ui/drug/drug_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DrugListScreen extends StatefulWidget {
  const DrugListScreen({super.key});

  @override
  State<DrugListScreen> createState() => _DrugListScreenState();
}

class _DrugListScreenState extends State<DrugListScreen> {
  late Future<void> _fetchDrugs;
  var logger = Logger();

  @override
  void initState() {
    _fetchDrugs = context.read<DrugManager>().fetchDrugs(
      page: 1,
      perPage: 5,
      thumb: '125x125f',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDrugs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Consumer<DrugManager>(
          builder: (_, manager, __) {
            return Image.network(
              manager.drugs[0].image,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        );
      },
    );
  }
}
