import 'package:drug_app/models/drug.dart';
import 'package:drug_app/ui/components/add_to_favorite_button.dart';
import 'package:flutter/material.dart';

class DrugCard extends StatelessWidget {
  final Drug drug;
  final bool hideFavoriteButton;
  final double? imageWidth;
  final double? imageHeight;
  const DrugCard({
    super.key,
    required this.drug,
    this.hideFavoriteButton = false,
    this.imageWidth,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Theme.of(context).splashColor,
        onTap: () {
          Navigator.of(context).pushNamed('/drug_details', arguments: drug.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              SizedBox(
                width: imageWidth ?? 200,
                height: imageHeight ?? 125,
                child: Image.network(
                  drug.getImage(thumb: '250x250f'),
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                drug.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              if (drug.aliases != null && drug.aliases!.isNotEmpty)
                Text(
                  'Tên gọi khác: ${drug.aliases!.map((e) => e.name).toList().join(', ')}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              if (!hideFavoriteButton) AddToFavoriteButton(drug: drug),
            ],
          ),
        ),
      ),
    );
  }
}
