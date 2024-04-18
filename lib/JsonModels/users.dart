class Users {
  final int? usrId;
  final String usrName;
  final String usrPassword;
  final String usrEmail;
  final String usrPhoneNumber;

  Users({
    this.usrId,
    required this.usrName,
    required this.usrPassword,
    required this.usrEmail,
    required this.usrPhoneNumber,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        usrName: json["usrName"],
        usrPassword: json["usrPassword"],
        usrEmail: json["usrEmail"],
        usrPhoneNumber: json["usrPhoneNumber"],
      );

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "usrName": usrName,
        "usrPassword": usrPassword,
        "usrEmail": usrEmail,
        "usrPhoneNumber": usrPhoneNumber,
      };
}
