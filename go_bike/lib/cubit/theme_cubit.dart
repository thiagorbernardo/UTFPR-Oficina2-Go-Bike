import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_bike/config/theme.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_state.dart';

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(ThemeState(AppThemes.darkTheme, true));

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    ThemeData theme =
        json['isDark'] as bool ? AppThemes.darkTheme : AppThemes.lightTheme;

    return ThemeState(theme, json['isOwner'] as bool);
  }

  @override
  Map<String, bool>? toJson(ThemeState state) {
    return {
      'isDark': state.themeData.brightness == Brightness.dark,
      'isOwner': state.isOwner
    };
  }

  void toggleOwnership() async {
    emit(ThemeState(state.themeData, !state.isOwner));
    await subscribeIfNeeded();
  }

  Future<void> subscribeIfNeeded() async {
    if (state.isOwner) {
      await FirebaseMessaging.instance.subscribeToTopic("bike_owner");
      print("SUBSCRIBED TO BIKE_OWNER TOPIC");
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic("bike_owner");
      print("UNSUBSCRIBED TO BIKE_OWNER TOPIC");
    }
  }
}
