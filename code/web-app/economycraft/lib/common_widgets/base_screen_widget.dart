import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseScreenWidget extends StatelessWidget {
  final void Function()? onBackPressed;
  final Widget? child;
  final Text? appBarTitle;
  final List<Widget>? appBarActions;

  const BaseScreenWidget({
    super.key,
    this.onBackPressed,
    this.child,
    this.appBarTitle,
    this.appBarActions,
  });

  static const Color _accentTealLight = Color.fromARGB(255, 229, 255, 252);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(children: [_buildBackground(), Center(child: child)]),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          appBarTitle ??
              const Text(
                '',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
        ],
      ),
      centerTitle: true,
      backgroundColor: _accentTealLight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            context.pop();
          }
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/background_images/quartz_background.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
