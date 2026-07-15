import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modo de tema (claro/escuro), persistido localmente.
class ThemeNotifier extends Notifier<ThemeMode> {
  static const _chave = 'tema_escuro';

  @override
  ThemeMode build() {
    _carregar();
    return ThemeMode.light;
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final escuro = prefs.getBool(_chave) ?? false;
    state = escuro ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> alternar() async {
    final novo =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = novo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, novo == ThemeMode.dark);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
