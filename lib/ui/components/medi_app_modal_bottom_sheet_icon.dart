import 'package:flutter/material.dart';

class MediAppModalBottomSheetIcon extends StatelessWidget {
  const MediAppModalBottomSheetIcon({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });
  final Icon icon;
  final Text text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 5.0,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [icon, text],
            ),
          ),
        ),
      ),
    );
  }
}
