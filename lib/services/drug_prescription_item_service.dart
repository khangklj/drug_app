import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/pocketbase_client.dart';
import 'package:logger/logger.dart';

class DrugPrescriptionItemService {
  var logger = Logger();
  Future<DrugPrescriptionItem?> addDrugPrescriptionItem(
    DrugPrescriptionItem drugPrescriptionItem,
  ) async {
    try {
      final pb = await getPocketBaseInstance();

      final drugPrescriptionItemModel = await pb
          .collection('drug_prescription_item')
          .create(body: drugPrescriptionItem.toJson());
      final dpItem = DrugPrescriptionItem.fromJson(
        drugPrescriptionItemModel.toJson(),
      );
      return dpItem;
    } catch (error) {
      logger.e("Fail to add drug prescription item: $error");
      return null;
    }
  }

  Future<DrugPrescriptionItem?> updateDrugPrescriptionItem(
    DrugPrescriptionItem drugPrescriptionItem,
  ) async {
    try {
      final pb = await getPocketBaseInstance();

      final dpItemModel = await pb
          .collection('drug_prescription_item')
          .update(
            drugPrescriptionItem.id!,
            body: drugPrescriptionItem.toJson(),
          );
      final newDPItem = DrugPrescriptionItem.fromJson(dpItemModel.toJson());
      return newDPItem;
    } catch (error) {
      logger.e("Fail to update drug prescription item: $error");
      return null;
    }
  }

  Future<bool> removeDrugPrescriptionItem(String id) async {
    try {
      final pb = await getPocketBaseInstance();
      await pb.collection('drug_prescription_item').delete(id);
      return true;
    } catch (error) {
      logger.e("Fail to remove drug prescription item: $error");
      return false;
    }
  }
}
