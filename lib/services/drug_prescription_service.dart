import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/drug_prescription_item_service.dart';
import 'package:drug_app/services/pocketbase_client.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DrugPrescriptionService {
  final _logger = Logger();
  late final DrugPrescriptionItemService _dpItemService;

  DrugPrescriptionService() {
    _dpItemService = DrugPrescriptionItemService();
  }

  List<DrugPrescriptionItem> _parseDrugPrescriptionItems(
    RecordModel drugPrescriptionModel,
  ) {
    final List<DrugPrescriptionItem> drugPrescriptionItems = [];
    final drugPrescriptionItemModels = drugPrescriptionModel
        .get<List<RecordModel>>("expand.items");
    for (final drugPrescriptionItemModel in drugPrescriptionItemModels) {
      final alias = DrugPrescriptionItem.fromJson(
        drugPrescriptionItemModel.toJson(),
      );
      drugPrescriptionItems.add(alias);
    }
    return drugPrescriptionItems;
  }

  Future<List<DrugPrescription>> fetchDrugPrescriptions({
    required String deviceId,
  }) async {
    final List<DrugPrescription> drugPrescriptions = [];
    try {
      final pb = await getPocketBaseInstance();
      final recordList = await pb
          .collection('drug_prescription')
          .getFullList(expand: 'items', filter: "device_id = '$deviceId'");
      for (final record in recordList) {
        final dpItems = _parseDrugPrescriptionItems(record);
        drugPrescriptions.add(
          DrugPrescription.fromJson(
            record.toJson()..addAll({'items': dpItems}),
          ),
        );
      }

      return drugPrescriptions;
    } catch (error) {
      _logger.e("Fail to fetch drug prescriptions: $error");
      return [];
    }
  }

  Future<DrugPrescription?> addDrugPrescription(
    DrugPrescription drugPrescription,
  ) async {
    try {
      final pb = await getPocketBaseInstance();

      // Add drug prescription items first
      final List<DrugPrescriptionItem> items = [];
      for (final item in drugPrescription.items) {
        final newDPItem = await _dpItemService.addDrugPrescriptionItem(item);
        if (newDPItem == null) {
          throw Exception("Fail to add drug prescription item");
        }
        items.add(newDPItem);
      }

      final itemIds = items.map((item) => item.id).toList();
      final drugPrescriptionModel = await pb
          .collection('drug_prescription')
          .create(
            body: drugPrescription.toJson()..addAll({'items': itemIds}),
            expand: 'items',
          );

      final newDP = DrugPrescription.fromJson(
        drugPrescriptionModel.toJson()..addAll({'items': items}),
      );

      return newDP;
    } catch (error) {
      _logger.e("Fail to add drug prescription: $error");
      return null;
    }
  }

  Future<DrugPrescription?> updateDrugPrescription(
    DrugPrescription drugPrescription,
  ) async {
    try {
      final pb = await getPocketBaseInstance();
      final List<DrugPrescriptionItem> dpItems = [];
      // Add or Update or Delete drug precription items first
      final dpModel = await pb
          .collection('drug_prescription')
          .getOne(drugPrescription.id!, expand: 'items');
      final List<DrugPrescriptionItem> existingDPItems =
          _parseDrugPrescriptionItems(dpModel);
      for (final dpItem in drugPrescription.items) {
        if (dpItem.id == null) {
          final newDPItem = await _dpItemService.addDrugPrescriptionItem(
            dpItem,
          );
          if (newDPItem == null) {
            throw Exception("Fail to add drug prescription item");
          }
          dpItems.add(newDPItem);
        } else if (existingDPItems.any((item) => item.id == dpItem.id)) {
          final updateDPItem = await _dpItemService.updateDrugPrescriptionItem(
            dpItem,
          );
          if (updateDPItem == null) {
            throw Exception("Fail to update drug prescription item");
          }
          dpItems.add(updateDPItem);
        }
      }

      final dpItemIds = dpItems.map((item) => item.id).toList();
      final deleteDPItemIds = existingDPItems
          .map((item) => item.id)
          .where((id) => !dpItemIds.contains(id))
          .toList();
      for (final deleteDPItemId in deleteDPItemIds) {
        final isDeleted = await _dpItemService.removeDrugPrescriptionItem(
          deleteDPItemId!,
        );
        if (!isDeleted) {
          throw Exception("Fail to delete drug prescription item");
        }
      }

      final drugPrescriptionModel = await pb
          .collection('drug_prescription')
          .update(
            drugPrescription.id!,
            body: drugPrescription.toJson()..addAll({'items': dpItemIds}),
            expand: 'items',
          );
      final updatedDP = DrugPrescription.fromJson(
        drugPrescriptionModel.toJson()..addAll({'items': dpItems}),
      );
      return updatedDP;
    } catch (error) {
      _logger.e("Fail to update drug prescription: $error");
      return null;
    }
  }

  Future<bool> removeDrugPrescription(String id) async {
    try {
      final pb = await getPocketBaseInstance();

      // Delete items first
      final dpModel = await pb
          .collection('drug_prescription')
          .getOne(id, expand: 'items');
      final dpItems = _parseDrugPrescriptionItems(dpModel);
      for (final dpItem in dpItems) {
        final isDeleted = await _dpItemService.removeDrugPrescriptionItem(
          dpItem.id!,
        );
        if (!isDeleted) {
          throw Exception("Fail to delete drug prescription item");
        }
      }

      // Delete record
      await pb.collection('drug_prescription').delete(id);
      return true;
    } catch (error) {
      _logger.e("Fail to remove drug prescription: $error");
      return false;
    }
  }
}
