import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fee_policy.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<Locale>((ref) => const Locale('tr'));
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final feePolicyProvider = StateProvider<FeePolicy>((ref) => const FeePolicy());
