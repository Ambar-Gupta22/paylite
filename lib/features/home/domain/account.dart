class Account {
  final String maskedNumber;
  final int balancePaise;
  final String primaryVpa;

  const Account({
    required this.maskedNumber,
    required this.balancePaise,
    required this.primaryVpa,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      maskedNumber: json['maskedNumber'] as String,
      balancePaise: json['balancePaise'] as int,
      primaryVpa: json['primaryVpa'] as String,
    );
  }
}
