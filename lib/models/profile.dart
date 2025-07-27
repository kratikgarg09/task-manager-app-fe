class UserProfile {
  final String name;
  final String email;
  final String mobileNumber;

  UserProfile({required this.name, required this.email, required this.mobileNumber,});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['emailId'],
      mobileNumber: json['mobileNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'emailId': email,
    'mobileNumber' : mobileNumber,
  };
}