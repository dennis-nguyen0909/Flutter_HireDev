class CertificateModel {
  final String? id;
  final String? name;
  final String? organization;
  final String? issueDate;
  final String? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? userId;

  CertificateModel({
    this.id,
    this.name,
    this.organization,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.userId,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['_id'],
      name: json['name'],
      organization: json['organization'],
      issueDate: json['issueDate'],
      expiryDate: json['expiryDate'],
      credentialId: json['credentialId'],
      credentialUrl: json['credentialUrl'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'organization': organization,
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
      'userId': userId,
    };
  }
}
