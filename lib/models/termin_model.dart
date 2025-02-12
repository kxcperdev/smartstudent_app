class Termin {
  final String tytul;
  final String opis;
  final DateTime data;
  final String typ;
  final String id;
  final int trudnosc;

  Termin({
    required this.tytul,
    required this.opis,
    required this.data,
    required this.typ,
    required this.id,
    required this.trudnosc,
  });

  Map<String, dynamic> doMapy() {
    return {
      'tytul': tytul,
      'opis': opis,
      'data': data.toIso8601String(),
      'typ': typ,
      'id': id,
      'trudnosc': trudnosc,
    };
  }

  factory Termin.zMapy(Map<String, dynamic> mapa) {
    return Termin(
      tytul: mapa['tytul'],
      opis: mapa['opis'],
      data: DateTime.parse(mapa['data']),
      typ: mapa['typ'],
      id: mapa['id'],
      trudnosc: mapa['trudnosc'] ?? 1,
    );
  }
}