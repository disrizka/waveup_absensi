class Business {
  final String idBusiness;
  final String name;
  final String logo;
  final String logoPath;
  final String username;
  final String about;
  final String website;
  final bool canBeSoldOutOfStock;
  final String userRoleName;
  final String roleId;
  final bool isPremium;
  final String? premiumStartAt;
  final String? premiumExpiresAt;
  final String banned;

  const Business({
    required this.idBusiness,
    required this.name,
    required this.logo,
    required this.logoPath,
    required this.username,
    required this.about,
    required this.website,
    required this.canBeSoldOutOfStock,
    required this.userRoleName,
    required this.roleId,
    required this.isPremium,
    required this.premiumStartAt,
    required this.premiumExpiresAt,
    required this.banned,
  });

  factory Business.fromJson(Map<String, dynamic> j) => Business(
        idBusiness: j['idBusiness'] ?? '',
        name: j['name'] ?? '',
        logo: j['logo'] ?? '',
        logoPath: j['logoPath'] ?? '',
        username: j['username'] ?? '',
        about: j['about'] ?? '',
        website: j['website'] ?? '',
        canBeSoldOutOfStock: j['canBeSoldOutOfStock'] ?? false,
        userRoleName: j['userRoleName'] ?? '',
        roleId: j['roleId'] ?? '',
        isPremium: j['isPremium'] ?? false,
        premiumStartAt: j['premiumStartAt'],
        premiumExpiresAt: j['premiumExpiresAt'],
        banned: j['banned']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'idBusiness': idBusiness,
        'name': name,
        'logo': logo,
        'logoPath': logoPath,
        'username': username,
        'about': about,
        'website': website,
        'canBeSoldOutOfStock': canBeSoldOutOfStock,
        'userRoleName': userRoleName,
        'roleId': roleId,
        'isPremium': isPremium,
        'premiumStartAt': premiumStartAt,
        'premiumExpiresAt': premiumExpiresAt,
        'banned': banned,
      };
}