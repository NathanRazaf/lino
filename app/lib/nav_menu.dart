import 'package:Lino_app/common/widgets/appbar/appbar.dart';
import 'package:Lino_app/common/widgets/floating_action_button/floating_action_button.dart';
import 'package:Lino_app/pages/map_screen.dart';
import 'package:Lino_app/pages/test_map_screen.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/utils/mock_data/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: LinoAppBar(),
      floatingActionButton: LinoFloatingButton(),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 10,
          selectedIndex: controller.selectedIndex.value,
          indicatorColor: LinoColors.accent,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.book),
              label: 'Books',
            ),
            NavigationDestination(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat),
              label: 'Forum',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  /// TODO: change screen here
  final screens = [
    Container(
        color: Colors.white,
        child: Center(child: Text('Placeholder for Books Screen'))),
    MapScreen(),
    Container(
        color: Colors.white,
        child: Center(child: Text('Placeholder for Forum Screen'))),
  ];
}
