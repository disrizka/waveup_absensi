class UserData {
  final String idUser;
  final String firstname;
  final String lastname;
  final String phone;
  final String email;
  final String photo;
  final String photoPath;
  final bool isDeactivated;
  final String username;
  final bool hasPage;
  final String userRoleName;
  final String roleId;

  const UserData({
    required this.idUser,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.email,
    required this.photo,
    required this.photoPath,
    required this.isDeactivated,
    required this.username,
    required this.hasPage,
    required this.userRoleName,
    required this.roleId,
  });

  String get fullName => '$firstname $lastname'.trim();

  factory UserData.fromJson(Map<String, dynamic> j) => UserData(
        idUser: j['idUser'] ?? '',
        firstname: j['firstname'] ?? '',
        lastname: j['lastname'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        photo: j['photo'] ?? '',
        photoPath: j['photoPath'] ?? '',
        isDeactivated: j['isDeactivated'] ?? false,
        username: j['username'] ?? '',
        hasPage: j['hasPage'] ?? false,
        userRoleName: j['userRoleName'] ?? '',
        roleId: j['roleId'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'idUser': idUser,
        'firstname': firstname,
        'lastname': lastname,
        'phone': phone,
        'email': email,
        'photo': photo,
        'photoPath': photoPath,
        'isDeactivated': isDeactivated,
        'username': username,
        'hasPage': hasPage,
        'userRoleName': userRoleName,
        'roleId': roleId,
      };
}