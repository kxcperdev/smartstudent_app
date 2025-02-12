class Notatka {
  final String id;
  final String tytul;
  final String tresc;

  Notatka({
    required this.id,
    required this.tytul,
    required this.tresc,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tytul': tytul,
      'tresc': tresc,
    };
  }

  factory Notatka.fromMap(Map<String, dynamic> map, String id) {
    return Notatka(
      id: id,
      tytul: map['tytul'] ?? '',
      tresc: map['tresc'] ?? '',
    );
  }
}