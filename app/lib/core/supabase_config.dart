import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuração do Supabase.
///
/// O conteúdo (módulos, lições, plano, concurso) é lido do Supabase com a
/// chave anônima (leitura pública). Login e progresso por usuário usam o
/// Supabase Auth com OAuth do Google.
class SupabaseConfig {
  static const url = 'https://wlogwtbfxnomuakklrpy.supabase.co';
  static const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indsb2d3dGJmeG5vbXVha2tscnB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQwNzUwNjQsImV4cCI6MjA5OTY1MTA2NH0.FW13oD5mqcLBSXGvWa_CkpLY5K0UrNpwCDuf9s6EXR4';

  /// URL pública do app (GitHub Pages). Usada como redirect do OAuth na web.
  static const paginaWeb = 'https://samuel-haddad.github.io/app-concursos/';

  /// Deep link de retorno do OAuth no desktop/mobile.
  static const redirectDesktop = 'br.samuel.estudotcdf://login-callback';

  /// Redirect efetivo conforme a plataforma.
  static String get redirect => kIsWeb ? paginaWeb : redirectDesktop;

  /// Login/progresso via Supabase (Google). Ativado após configurar o Google.
  static const usarSupabaseAuth = true;
}
