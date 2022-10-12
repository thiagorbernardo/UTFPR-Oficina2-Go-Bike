import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_bike/cubit/theme_cubit.dart';
import 'package:restart_app/restart_app.dart';

import 'package:go_bike/ui/app_bar/bottom_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      extendBody: false,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            SettingsItem(
                icon: FontAwesomeIcons.bicycle,
                title: "Dono da Bicicleta",
                onPressed: () => {
                      context.read<ThemeCubit>().toggleOwnership(),
                      Restart.restartApp(),
                    }),
          ],
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final Function()? onPressed;
  final IconData icon;
  final String title;
  final Color? color;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.title,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed != null ? () => onPressed!() : null,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(
          color ?? Colors.white,
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(
            width: 30,
          ),
          Text(title),
          const Spacer(),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return Switch(
                value: context.read<ThemeCubit>().state.isOwner,
                onChanged: onPressed != null ? (_) => onPressed!() : null,
              );
            },
          )
        ],
      ),
    );
  }
}
