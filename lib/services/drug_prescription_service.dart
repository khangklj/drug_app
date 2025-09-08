import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/pocketbase_client.dart';
import 'package:logger/logger.dart';

class DrugPrescriptionService {
  var logger = Logger();
  Future<DrugPrescription?> addDrugPrescription(
    DrugPrescription drugPrescription,
  ) async {
    try {
      final pb = await getPocketBaseInstance();

      // Add drug prescription items first
      final List<DrugPrescriptionItem> items = [];
      for (final item in drugPrescription.items) {
        final drugPrescriptionItemModel = await pb
            .collection('drug_prescription_item')
            .create(body: item.toJson());
        final drugPrescriptionItem = DrugPrescriptionItem.fromJson(
          drugPrescriptionItemModel.toJson(),
        );
        items.add(drugPrescriptionItem);
      }

      final itemIds = items.map((item) => item.id).toList();
      final drugPrescriptionModel = await pb
          .collection('drug_prescription')
          .create(
            body: drugPrescription.toJson()..addAll({'items': itemIds}),
            expand: 'items',
          );

      final newDrugPrescription = DrugPrescription.fromJson(
        drugPrescriptionModel.toJson()..addAll({'items': items}),
      );

      return newDrugPrescription;
    } catch (error) {
      logger.e("Fail to add drug prescription: $error");
      return null;
    }
  }
}
