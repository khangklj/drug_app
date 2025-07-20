import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/drug_alias.dart';
import 'package:drug_app/models/drug_data.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class DrugService {
  static String getImageUrl(PocketBase pb, RecordModel model, {String? thumb}) {
    final imageName = model.getStringValue('image');
    return pb.files.getUrl(model, imageName, thumb: thumb).toString();
  }

  Future<Drug?> getDrug(PocketBase pb, String id) async {
    var logger = Logger();
    final List<DrugData> dataList = [];
    final List<DrugAlias> aliasList = [];

    try {
      final drugModel = await pb
          .collection('drug')
          .getOne(id, expand: 'data,aliases');

      final drugDataModels = drugModel.get<List<RecordModel>>("expand.data");
      for (final drugDataModel in drugDataModels) {
        final data = DrugData.fromJson(
          drugDataModel.toJson()
            ..addAll({'image': getImageUrl(pb, drugDataModel)}),
        );
        dataList.add(data);
      }

      final drugAliasModels = drugModel.get<List<RecordModel>>(
        "expand.aliases",
      );
      for (final drugAliasModel in drugAliasModels) {
        final alias = DrugAlias.fromJson(drugAliasModel.toJson());
        aliasList.add(alias);
      }

      return Drug.fromJson(
        drugModel.toJson()..addAll({
          'image': getImageUrl(pb, drugModel),
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
