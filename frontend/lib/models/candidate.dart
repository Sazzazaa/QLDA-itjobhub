class Candidate {
  final String id;
  final String name;
  final String title;
  final List<String> skills;
  final int years;
  final String location;
  final int expectedSalary;
  final String avatarUrl;
  final String cvUrl;

  const Candidate({
    required this.id,
    required this.name,
    required this.title,
    required this.skills,
    required this.years,
    required this.location,
    required this.expectedSalary,
    required this.avatarUrl,
    required this.cvUrl,
  });

  static List<Candidate> samples() => const [
        Candidate(
          id: '1',
          name: 'Alex Nguyen',
          title: 'Flutter Developer',
          skills: ['Dart', 'Flutter', 'Firebase'],
          years: 3,
          location: 'Hanoi',
          expectedSalary: 1200,
          avatarUrl: 'https://i.pravatar.cc/300?img=1',
          cvUrl: 'https://example.com/cv/alex.pdf',
        ),
        Candidate(
          id: '2',
          name: 'Linh Tran',
          title: 'Backend Engineer',
          skills: ['Java', 'Spring', 'SQL'],
          years: 5,
          location: 'HCMC',
          expectedSalary: 2000,
          avatarUrl: 'https://i.pravatar.cc/300?img=2',
          cvUrl: 'https://example.com/cv/linh.pdf',
        ),
        Candidate(
          id: '3',
          name: 'Quang Le',
          title: 'DevOps',
          skills: ['AWS', 'K8s', 'CI/CD'],
          years: 4,
          location: 'Da Nang',
          expectedSalary: 1800,
          avatarUrl: 'https://i.pravatar.cc/300?img=3',
          cvUrl: 'https://example.com/cv/quang.pdf',
        ),
      ];
}

