import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/drug_alias.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/services/drug_service.dart';
import 'package:drug_app/services/pocketbase_client.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DrugPrescriptionService {
  final _logger = Logger();

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

  Future<Drug?> findRefDrug(PocketBase pb, DrugPrescriptionItem item) async {
    final recordList = await pb
        .collection('drug')
        .getFullList(
          filter: "name~'${item.drugName}'||aliases.name?~'${item.drugName}'",
          expand: 'data,aliases',
        );
    for (final record in recordList) {
      final List<DrugAlias> aliasList = DrugService.parseDrugAliases(record);
      final drug = Drug.fromJson(
        record.toJson()..addAll({
          'image': DrugService.getImageUrl(pb, record),
          'aliases': aliasList,
          'data': null,
        }),
      );

      if (drug.name.toLowerCase() == item.drugName.toLowerCase() ||
          (drug.aliases != null &&
              drug.aliases!.any(
                (element) =>
                    element.name.toLowerCase() == item.drugName.toLowerCase(),
              ))) {
        return drug;
      }
    }
    return null;
  }

  Future<DrugPrescription?> addDrugPrescription(
    DrugPrescription drugPrescription,
  ) async {
    try {
      final pb = await getPocketBaseInstance();
      final batch = pb.createBatch();
      for (var item in drugPrescription.items) {
        final drug = await findRefDrug(pb, item);
        item = item.copyWith(drugId: drug?.id);
        batch
            .collection('drug_prescription_item')
            .create(body: item.toJson()..addAll({'drug': item.drugId}));
      }
      final results = await batch.send();

      final newDPItems = results.map((result) {
        final body = result.body as Map<String, dynamic>;
        body.addAll({'drugId': body['drug']});
        return DrugPrescriptionItem.fromJson(body);
      }).toList();
      final drugPrescriptionModel = await pb
          .collection('drug_prescription')
          .create(
            body: drugPrescription.toJson()
              ..addAll({'items': newDPItems.map((e) => e.id).toList()}),
            expand: 'items',
          );
      final newDP = DrugPrescription.fromJson(
        drugPrescriptionModel.toJson()..addAll({'items': newDPItems}),
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
      final dpModel = await pb
          .collection('drug_prescription')
          .getOne(drugPrescription.id!, expand: 'items');
      final List<DrugPrescriptionItem> existingDPItems =
          _parseDrugPrescriptionItems(dpModel);

      final addDPitems = drugPrescription.items.where(
        (item) => item.id == null,
      );
      final updateDPItems = drugPrescription.items.where(
        (item) => existingDPItems.any((dpItem) => dpItem.id == item.id),
      );
      final deleteDPItemIds = existingDPItems
          .map((item) => item.id)
          .where((id) => !drugPrescription.items.any((item) => item.id == id))
          .toList();

      final batch = pb.createBatch();
      for (var item in addDPitems) {
        final drug = await findRefDrug(pb, item);
        item = item.copyWith(drugId: drug?.id);
        batch
            .collection('drug_prescription_item')
            .create(body: item.toJson()..addAll({'drug': item.drugId}));
      }

      for (var item in updateDPItems) {
        final drug = await findRefDrug(pb, item);
        item = item.copyWith(drugId: drug?.id);
        batch
            .collection('drug_prescription_item')
            .update(
              item.id!,
              body: item.toJson()..addAll({'drug': item.drugId}),
            );
      }
      for (final deleteDPItemId in deleteDPItemIds) {
        batch.collection('drug_prescription_item').delete(deleteDPItemId!);
      }

      final results = await batch.send();
      final List<DrugPrescriptionItem> newDPItem = [];
      for (final result in results) {
        final body = result.body as Map<String, dynamic>?;
        if (body == null) continue; // skip delete case
        final dpItemModel = DrugPrescriptionItem.fromJson(body);
        newDPItem.add(dpItemModel);
      }
      final drugPrescriptionModel = await pb
          .collection('drug_prescription')
          .update(
            drugPrescription.id!,
            body: drugPrescription.toJson()
              ..addAll({'items': newDPItem.map((e) => e.id).toList()}),
            expand: 'items',
          );
      final updatedDP = DrugPrescription.fromJson(
        drugPrescriptionModel.toJson()..addAll({'items': newDPItem}),
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

      final dpModel = await pb
          .collection('drug_prescription')
          .getOne(id, expand: 'items');
      final dpItems = _parseDrugPrescriptionItems(dpModel);
      final batch = pb.createBatch();
      for (final dpItem in dpItems) {
        batch.collection('drug_prescription_item').delete(dpItem.id!);
      }
      await batch.send();
      await pb.collection('drug_prescription').delete(id);

      return true;
    } catch (error) {
      _logger.e("Fail to remove drug prescription: $error");
      return false;
    }
  }
}
