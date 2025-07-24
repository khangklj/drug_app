import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/drug_alias.dart';
import 'package:drug_app/models/drug_data.dart';
import 'package:drug_app/services/pocketbase_client.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DrugService {
  static String getImageUrl(PocketBase pb, RecordModel model, {String? thumb}) {
    final imageName = model.getStringValue('image');
    return pb.files.getUrl(model, imageName, thumb: thumb).toString();
  }

  Future<List<Drug>> fetchDrugs({
    int page = 1,
    int perPage = 30,
    String? thumb,
    String? filter,
  }) async {
    var logger = Logger();
    final List<Drug> drugs = [];
    try {
      final pb = await getPocketBaseInstance();
      final resultList = await pb
          .collection('drug')
          .getList(page: page, perPage: perPage, filter: filter);

      for (final model in resultList.items) {
        final drug = Drug.fromJson(
          model.toJson()..addAll({
            'image': getImageUrl(pb, model, thumb: thumb),
            'data': null,
            'aliases': null,
          }),
        );
        drugs.add(drug);
      }
    } catch (error) {
      logger.e(error);
    }
    return drugs;
  }

  Future<Drug?> fetchDrugDetails(
    String id, {
    bool expandData = true,
    bool expandAliases = true,
    String? thumb,
  }) async {
    var logger = Logger();
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
            drugDataModel.toJson()..addAll({
              'image': getImageUrl(pb, drugDataModel),
              'expand.data': 'testing',
            }),
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
      logger.e(error);
      return null;
    }
  }
}
