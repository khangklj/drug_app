import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:drug_app/manager/drug_favorite_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddToFavoriteButton extends StatelessWidget {
  const AddToFavoriteButton({super.key, required this.drug});
  final Drug drug;

  @override
  Widget build(BuildContext context) {
    final drugFavoriteManger = context.read<DrugFavoriteManager>();
    final bool isFavorite = context.watch<DrugFavoriteManager>().isFavorite(
      drug,
    );
    return IconButton(
      onPressed: () {
        if (isFavorite) {
          drugFavoriteManger.removeFavoriteDrug(drug);
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Đã xóa khỏi yêu thích',
              message: 'Thuốc đã xóa khỏi danh sách yêu thích!',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        } else {
          drugFavoriteManger.saveFavoriteDrug(drug);
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Đã lưu vào yêu thích',
              message: 'Thuốc đã được lưu vào danh sách yêu thích!',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      },
      icon: isFavorite
          ? Icon(Icons.star_outlined, color: Colors.yellow[700])
          : Icon(Icons.star_border),
    );
  }
}
