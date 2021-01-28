class Customer {
  String username;

  String fullname;

  String dob;
  String role;
  int numSuccess;
  int numCancel;
  double wallet;
  String addresses;

  Customer(
      {this.username,
      this.fullname,
      this.dob,
      this.role,
      this.numSuccess,
      this.numCancel,
      this.wallet,
      this.addresses});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      username: json['username'],
      fullname: json['fullname'],
      dob: json['dob'],
      role: json['role'],
      numSuccess: json['numSuccess'],
      numCancel: json['numCancel'],
      wallet: json['wallet'],
      addresses: json['addresses'],
    );
  }
}
