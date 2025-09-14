import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MediAppLoadingDialog extends StatefulWidget {
  const MediAppLoadingDialog({super.key});

  @override
  State<MediAppLoadingDialog> createState() => _MediAppLoadingDialogState();
}

class _MediAppLoadingDialogState extends State<MediAppLoadingDialog> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastLinearToSlowEaseIn,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: SpinKitCubeGrid(color: Colors.indigoAccent, size: 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
