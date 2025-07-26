import 'package:drug_app/ui/components/camera_floating_button.dart';
import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  static const String routeName = "/home";

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    int textBreakPoints = 600;
    return Scaffold(
      // bottomNavigationBar: TabBarWidget(),
      floatingActionButton: CameraFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Image.asset("assets/icons/app_icon.png"),
            ),
            Text("MediApp", style: Theme.of(context).textTheme.displaySmall),
            Text(
              "Ứng dụng tra cứu thuốc tiện ích",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              "Phiên bản 1.0.0",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Column(
                    spacing: 5.0,
                    children: [
                      Text(
                        "Tìm kiếm thuốc bằng OCR",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (MediaQuery.of(context).size.width < textBreakPoints)
                        Text(
                          "Sử dụng camera để nhanh chóng\ntìm kiếm được thông tin thuốc bạn cần",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        )
                      else
                        Text(
                          "Sử dụng camera để nhanh chóng tìm kiếm được thông tin thuốc bạn cần",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          'Bắt đầu quét',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        style: Theme.of(context).iconButtonTheme.style,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm thuốc...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceBright,
              ),
              onTap: () {
                // TODO: Implement search functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
