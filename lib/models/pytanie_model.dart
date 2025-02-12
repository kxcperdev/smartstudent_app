class Pytanie {
  final String id;
  final String tresc;
  final List<String> odpowiedzi;
  final int poprawnaOdpowiedz;
  final String kategoria;
  int liczbaPoprawnychOdpowiedzi;
  int liczbaProb;

  Pytanie({
    required this.id,
    required this.tresc,
    required this.odpowiedzi,
    required this.poprawnaOdpowiedz,
    required this.kategoria,
    this.liczbaPoprawnychOdpowiedzi = 0,
    this.liczbaProb = 0,
  });

  Map<String, dynamic> doMapy() {
    return {
      'id': id,
      'tresc': tresc,
      'odpowiedzi': odpowiedzi,
      'poprawnaOdpowiedz': poprawnaOdpowiedz,
      'kategoria': kategoria,
      'liczbaPoprawnychOdpowiedzi': liczbaPoprawnychOdpowiedzi,
      'liczbaProb': liczbaProb,
    };
  }

  factory Pytanie.zMapy(Map<String, dynamic> mapa) {
    return Pytanie(
      id: mapa['id'],
      tresc: mapa['tresc'],
      odpowiedzi: List<String>.from(mapa['odpowiedzi']),
      poprawnaOdpowiedz: mapa['poprawnaOdpowiedz'],
      kategoria: mapa['kategoria'],
      liczbaPoprawnychOdpowiedzi: mapa['liczbaPoprawnychOdpowiedzi'] ?? 0,
      liczbaProb: mapa['liczbaProb'] ?? 0,
    );
  }
}