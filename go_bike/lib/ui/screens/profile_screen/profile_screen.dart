import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:go_bike/cubit/bottom_nav_cubit.dart';
import 'package:go_bike/ui/app_bar/bottom_bar.dart';
import 'package:go_bike/utils/app_colors.dart';
import 'package:go_bike/utils/routes/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      // appBar: TopBar(
      //   title: Text(tr("profile_screen.top_bar")),
      //   hasBackButton: false,
      // ),
      extendBody: false,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            const Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://picsum.photos/200/300',
                ),
                radius: 75,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
