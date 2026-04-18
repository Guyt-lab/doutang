/// Coordonnées du contact pour une annonce (agence ou particulier).
class ListingContact {
  final String? agencyName;
  final String? contactName;
  final String? phone;
  final String? email;
  final bool isAgency;

  const ListingContact({
    this.agencyName,
    this.contactName,
    this.phone,
    this.email,
    this.isAgency = false,
  });

  bool get isEmpty =>
      agencyName == null &&
      contactName == null &&
      phone == null &&
      email == null;

  Map<String, dynamic> toJson() => {
        'agency_name': agencyName,
        'contact_name': contactName,
        'phone': phone,
        'email': email,
        'is_agency': isAgency,
      };

  factory ListingContact.fromJson(Map<String, dynamic> json) => ListingContact(
        agencyName: json['agency_name'] as String?,
        contactName: json['contact_name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        isAgency: json['is_agency'] as bool? ?? false,
      );
}
