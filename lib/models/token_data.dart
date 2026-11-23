class TokenData {
  final String accessToken;
  final String refreshToken;

  const TokenData({required this.accessToken, required this.refreshToken});

  TokenData copyWith({String? accessToken, String? refreshToken}) => TokenData(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
      );

  factory TokenData.fromJson(Map<String, dynamic> j) => TokenData(
        accessToken: j['access_token'] ?? '',
        refreshToken: j['refresh_token'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
}