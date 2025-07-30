import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrugDetailsScreen extends StatefulWidget {
  final String drugId;
  static const String routeName = '/drug_details';
  const DrugDetailsScreen({super.key, required this.drugId});

  @override
  State<DrugDetailsScreen> createState() => _DrugDetailsScreenState();
}

class _DrugDetailsScreenState extends State<DrugDetailsScreen> {
  late Future<Drug?> _fetchDrugs;
  @override
  void initState() {
    _fetchDrugs = context.read<DrugManager>().fetchDrugDetails(
      id: widget.drugId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fetchDrugs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            showDialog(
              context: context,
              builder: (context) {
                return CustomAlertDialog();
              },
            );
          } else {
            final Drug? drug = snapshot.data;
            if (drug == null) {
              return CustomAlertDialog();
            }
            return Center(child: Text(drug.name));
          }
          return Container();
        },
      ),
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: const Text(
        'Failed to fetch drug details. Please try again later.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Back to home'),
        ),
      ],
    );
  }
}
