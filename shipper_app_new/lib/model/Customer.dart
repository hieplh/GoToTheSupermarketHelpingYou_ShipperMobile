class Customer {
  String id;
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
  String addresses;

  Customer(
      {this.id,
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
      this.addresses});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
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
      addresses: json['addresses'],
    );
  }
}
