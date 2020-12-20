class User {
  String username;
  String firstName;
  String middleName;
  String lastName;
  String email;
  String phone;
  String dob;
  String role;
  int numSuccess;
  int numCancel;
  double wallet;
  double rating;

  User(
      {
      this.username,
      this.firstName,
      this.middleName,
      this.lastName,
      this.email,
      this.phone,
      this.dob,
      this.role,
      this.numSuccess,
      this.numCancel,
      this.wallet,
      this.rating
      });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      dob: json['dob'],
      role: json['role'],
      numSuccess: json['numSuccess'],
      numCancel: json['numCancel'],
      wallet: json['wallet'],
      rating: json['rating'],
    );
  }
}
