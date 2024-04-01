class ProviderList {
  ProviderList(
      {required this.name,
      required this.email,
      required this.dropdownValue,
      required this.number,
      required this.serviceCharges});

  final String name;
  final String email;
  final String dropdownValue;
  final String number;
  final String serviceCharges;

  factory ProviderList.fromMap(Map<String, dynamic> map, String id) {
    return ProviderList(
      name: map['username'] ?? '',
      email: map['email'] ?? '',
      dropdownValue: map['dropdownValue'] ?? '',
      number: map['phonenumber'] ?? '',
      serviceCharges: map["serviceCharges"] ?? '',
    );
  }
}
