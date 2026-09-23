class Vpa {
  final String address;
  final String verifiedName;

  const Vpa({
    required this.address,
    required this.verifiedName,
  });

  factory Vpa.fromJson(Map<String, dynamic> json) {
    return Vpa(
      address: json['address'] as String,
      verifiedName: json['verifiedName'] as String,
    );
  }
}
