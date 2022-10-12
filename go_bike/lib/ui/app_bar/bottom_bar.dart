import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_bike/cubit/bottom_nav_cubit.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, count) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Container(
            color: Colors.white,
            child: SalomonBottomBar(
              currentIndex: count,
              onTap: (i) {
                int oldState = context.read<BottomNavCubit>().state;
                if (oldState == i) {
                  return;
                }
                context.read<BottomNavCubit>().changePage(i);
                if (i == 0) {
                  Navigator.pop(context);
                  return;
                }
                Navigator.pushNamed(
                    context, context.read<BottomNavCubit>().path);
              },
              selectedItemColor: Colors.black,
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(FontAwesomeIcons.mapLocationDot),
                  activeIcon: const Icon(FontAwesomeIcons.mapLocationDot),
                  title: const Text('Home'),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(FontAwesomeIcons.gear),
                  activeIcon: const Icon(FontAwesomeIcons.gear),
                  title: const Text('Configurações'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
