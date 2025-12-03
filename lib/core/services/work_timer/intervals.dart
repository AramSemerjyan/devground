  enum WorkInterval {
    /// For tests!!
    work1(title: '1 min', duration: Duration(minutes: 1)),

    work25(title: '25 min', duration: Duration(minutes: 25)),
    work45(title: '45 min', duration: Duration(minutes: 45)),
    work60(title: '1 hour', duration: Duration(hours: 1)),
    work120(title: '2 hours', duration: Duration(hours: 2));

    final String title;
    final Duration duration;
    const WorkInterval({required this.title, required this.duration});
  }

  enum BreakInterval {
    /// For tests!!
    break1(title: '1 min', duration: Duration(minutes: 1)),

    break5(title: '5 min', duration: Duration(minutes: 5)),
    break10(title: '10 min', duration: Duration(minutes: 10)),
    break15(title: '15 min', duration: Duration(minutes: 15)),
    break30(title: '30 min', duration: Duration(minutes: 30));

    final String title;
    final Duration duration;
    const BreakInterval({required this.title, required this.duration});
  }