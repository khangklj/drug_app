import 'package:drug_app/models/drug.dart';
import 'package:flutter/material.dart';

class DrugCardHorizontal extends StatelessWidget {
  final Drug drug;
  const DrugCardHorizontal({super.key, required this.drug});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Theme.of(context).splashColor,
        onTap: () {
          debugPrint('Tapped ${drug.name}');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
              width: 125,
              child: Image.network(
                drug.image,
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
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drug.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (drug.aliases!.isNotEmpty)
                    Text(
                      'Tên gọi khác: ${drug.aliases!.map((alias) => alias.name).join(', ')}',
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
