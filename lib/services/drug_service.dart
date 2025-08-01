import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/drug_alias.dart';
import 'package:drug_app/models/drug_data.dart';
import 'package:drug_app/services/pocketbase_client.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DrugService {
  final _logger = Logger();
  static String getImageUrl(PocketBase pb, RecordModel model, {String? thumb}) {
    final imageName = model.getStringValue('image');
    return pb.files.getUrl(model, imageName, thumb: thumb).toString();
  }

  // Helper functions
  List<DrugAlias> _parseDrugAliases(RecordModel drugModel) {
    final List<DrugAlias> aliasList = [];
    final drugAliasModels = drugModel.get<List<RecordModel>>("expand.aliases");
    for (final drugAliasModel in drugAliasModels) {
      final alias = DrugAlias.fromJson(drugAliasModel.toJson());
      aliasList.add(alias);
    }
    return aliasList;
  }

  Future<List<Drug>> fetchDrugs({
    int page = 1,
    int perPage = 30,
    String? thumb,
    String? filter,
  }) async {
    final List<Drug> drugs = [];
    try {
      final pb = await getPocketBaseInstance();
      final resultList = await pb
          .collection('drug')
          .getList(
            page: page,
            perPage: perPage,
            filter: filter,
            expand: 'aliases',
          );

      for (final drugModel in resultList.items) {
        final List<DrugAlias> aliasList = _parseDrugAliases(drugModel);

        final drug = Drug.fromJson(
          drugModel.toJson()..addAll({
            'image': getImageUrl(pb, drugModel, thumb: thumb),
            'data': null,
            'aliases': aliasList,
          }),
        );
        drugs.add(drug);
      }
    } catch (error) {
      _logger.e(error);
    }
    return drugs;
  }

  Future<Drug?> fetchDrugDetails(
    String id, {
    bool expandData = true,
    bool expandAliases = true,
    String? thumb,
  }) async {
    final List<DrugData> dataList = [];
    final List<DrugAlias> aliasList = [];

    try {
      final pb = await getPocketBaseInstance();
      final drugModel = await pb
          .collection('drug')
          .getOne(id, expand: 'data,aliases');

      if (expandData) {
        final drugDataModels = drugModel.get<List<RecordModel>>("expand.data");
        for (final drugDataModel in drugDataModels) {
          final data = DrugData.fromJson(
            drugDataModel.toJson()
              ..addAll({'image': getImageUrl(pb, drugDataModel)}),
          );
          dataList.add(data);
        }
      }

      if (expandAliases) {
        final drugAliasModels = drugModel.get<List<RecordModel>>(
          "expand.aliases",
        );
        for (final drugAliasModel in drugAliasModels) {
          final alias = DrugAlias.fromJson(drugAliasModel.toJson());
          aliasList.add(alias);
        }
      }

      return Drug.fromJson(
        drugModel.toJson()..addAll({
          'image': getImageUrl(pb, drugModel, thumb: thumb),
          'data': dataList,
          'aliases': aliasList,
        }),
      );
    } catch (error) {
      _logger.e(error);
      return null;
    }
  }

  Future<List<Drug>> fetchDrugMetadata({String? thumb}) async {
    final List<Drug> drugsMetadata = [];
    try {
      final pb = await getPocketBaseInstance();
      final recordList = await pb
          .collection('drug')
          .getFullList(expand: 'aliases');
      for (final record in recordList) {
        final List<DrugAlias> aliasList = _parseDrugAliases(record);
        final drug = Drug.fromJson(
          record.toJson()..addAll({
            'image': getImageUrl(pb, record, thumb: thumb),
            'aliases': aliasList,
            'data': null,
          }),
        );
        drugsMetadata.add(drug);
      }
    } catch (error) {
      _logger.e(error);
    }

    return drugsMetadata;
  }
}
