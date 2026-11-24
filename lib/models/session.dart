import 'business.dart';
import 'employee_schedule.dart';
import 'token_data.dart';
import 'user_data.dart';

/// Response login: { status, data, business[], schedule[], token }
class Session {
  final UserData user;
  final List<Business> businesses;
  final List<EmployeeSchedule> schedules;
  final TokenData token;

  const Session({
    required this.user,
    required this.businesses,
    this.schedules = const [],
    required this.token,
  });

  Session copyWith({TokenData? token}) => Session(
    user: user,
    businesses: businesses,
    schedules: schedules,
    token: token ?? this.token,
  );

  factory Session.fromJson(Map<String, dynamic> j) => Session(
    user: UserData.fromJson(Map<String, dynamic>.from(j['data'] ?? {})),
    businesses: ((j['business'] ?? []) as List)
        .map((e) => Business.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    schedules: ((j['schedule'] ?? []) as List)
        .map((e) => EmployeeSchedule.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    token: TokenData.fromJson(Map<String, dynamic>.from(j['token'] ?? {})),
  );

  Map<String, dynamic> toJson() => {
    'status': 200,
    'data': user.toJson(),
    'business': businesses.map((e) => e.toJson()).toList(),
    'schedule': schedules.map((e) => e.toJson()).toList(),
    'token': token.toJson(),
  };
}
