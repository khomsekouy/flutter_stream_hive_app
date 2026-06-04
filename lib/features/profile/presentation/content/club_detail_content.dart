// Presentation-only sample data for the club detail screen
// (Table / Players / Matchday).

/// A row in a league standings table.
class StandingRow {
  const StandingRow({
    required this.position,
    required this.team,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.points,
  });

  final int position;
  final String team;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int points;
}

/// A squad member.
class SquadPlayer {
  const SquadPlayer({
    required this.number,
    required this.name,
    required this.position,
  });

  final int number;
  final String name;

  /// e.g. `GK`, `DF`, `MF`, `FW`.
  final String position;
}

/// A scheduled or recent match.
class Fixture {
  const Fixture({
    required this.competition,
    required this.opponent,
    required this.dateLabel,
    required this.isHome,
  });

  final String competition;
  final String opponent;

  /// Pre-formatted, e.g. `Sat 14 Jun • 20:00`.
  final String dateLabel;
  final bool isHome;
}

/// A generic sample squad reused for every club (demo data).
const List<SquadPlayer> kSampleSquad = [
  SquadPlayer(number: 1, name: 'A. Becker', position: 'GK'),
  SquadPlayer(number: 4, name: 'V. van Dijk', position: 'DF'),
  SquadPlayer(number: 66, name: 'T. Alexander', position: 'DF'),
  SquadPlayer(number: 26, name: 'A. Robertson', position: 'DF'),
  SquadPlayer(number: 5, name: 'I. Konaté', position: 'DF'),
  SquadPlayer(number: 6, name: 'T. Adams', position: 'MF'),
  SquadPlayer(number: 8, name: 'D. Szoboszlai', position: 'MF'),
  SquadPlayer(number: 10, name: 'A. Mac Allister', position: 'MF'),
  SquadPlayer(number: 11, name: 'M. Salah', position: 'FW'),
  SquadPlayer(number: 9, name: 'D. Núñez', position: 'FW'),
  SquadPlayer(number: 7, name: 'L. Díaz', position: 'FW'),
];

/// Pre-formatted date labels used to generate sample fixtures.
const List<String> kSampleFixtureDates = [
  'Sat 14 Jun • 20:00',
  'Wed 18 Jun • 19:45',
  'Sun 22 Jun • 17:30',
  'Sat 28 Jun • 16:00',
  'Tue 01 Jul • 20:00',
];
