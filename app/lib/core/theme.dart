import 'package:flutter/material.dart';

/// Tema Material 3 do app. Paleta sóbria com semente índigo.
class AppTheme {
  static const seed = Color(0xFF3F51B5);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
      ),
    );
  }
}

/// Cores por bloco de prova (para o calendário do plano).
class BlocoCores {
  static const _mapa = <String, Color>{
    'P1': Color(0xFF2E7D32), // verde  — básicos
    'P2': Color(0xFF1565C0), // azul   — específicos
    'P3': Color(0xFF6A1B9A), // roxo   — especializados
    'P4': Color(0xFFEF6C00), // laranja — discursiva
    'FORA': Color(0xFF757575), // cinza — fora do edital
  };

  static Color de(String bloco) => _mapa[bloco] ?? const Color(0xFF757575);

  static String rotulo(String bloco) {
    switch (bloco) {
      case 'P1':
        return 'Básicos';
      case 'P2':
        return 'Específicos';
      case 'P3':
        return 'Especializados';
      case 'P4':
        return 'Discursiva';
      default:
        return 'Fora do edital';
    }
  }
}

/// Cores por tipo de sessão de estudo.
class SessaoCores {
  static Color de(String tipo, ColorScheme s) {
    switch (tipo.toUpperCase()) {
      case 'REVISAO':
        return s.tertiary;
      case 'ESTUDO':
        return s.primary;
      case 'EXERCICIOS':
        return s.secondary;
      default:
        return s.outline;
    }
  }

  static String rotulo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'REVISAO':
        return 'Revisão';
      case 'ESTUDO':
        return 'Estudo';
      case 'EXERCICIOS':
        return 'Exercícios';
      default:
        return tipo;
    }
  }
}
