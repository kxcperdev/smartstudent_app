class Sesja {
  final String data;
  final String typ;

  Sesja({
    required this.data,
    required this.typ,
  });

  String get kodHistorii => '$data|$typ';

  factory Sesja.zKodu(String kod) {
    final parts = kod.split('|');
    return Sesja(
      data: parts[0],
      typ: parts[1],
    );
  }
}