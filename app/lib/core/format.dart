import 'package:intl/intl.dart';

/// Utilitários de formatação (datas em pt_BR, minutos → h/min).
class Fmt {
  static final _diaMes = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
  static final _curto = DateFormat('dd/MM/yyyy', 'pt_BR');

  static String dataLonga(DateTime d) {
    final s = _diaMes.format(d);
    return s[0].toUpperCase() + s.substring(1);
  }

  static String dataCurta(DateTime d) => _curto.format(d);

  static String minutos(int min) {
    if (min <= 0) return '0 min';
    final h = min ~/ 60;
    final m = min % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  /// yyyy-MM-dd sem depender de locale.
  static String iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
