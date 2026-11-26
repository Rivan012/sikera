class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? role;
  final String? avatar;
  final String? initials;
  final int? usia;
  final String? gender;
  final String? agama;
  final String? prodi;
  final String? fakultas;
  final String? pendidikanTerakhir;
  final String? nim;
  final int points;
  final int streakDays;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.role,
    this.avatar,
    this.initials,
    this.usia,
    this.gender,
    this.agama,
    this.prodi,
    this.fakultas,
    this.pendidikanTerakhir,
    this.nim,
    this.points = 0,
    this.streakDays = 0,
  });

  bool get isAdmin {
    final normalized = role?.trim().toLowerCase() ?? '';
    return normalized == 'admin' ||
        normalized == 'super_admin' ||
        normalized == 'superadmin';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role']?.toString().trim();
    final resolvedRole = (rawRole != null && rawRole.isNotEmpty)
        ? rawRole
        : (json['is_admin'] == true ? 'admin' : null);

    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      role: resolvedRole,
      avatar: json['avatar']?.toString(),
      initials: json['initials']?.toString(),
      usia: json['usia'] is int ? json['usia'] : int.tryParse(json['usia']?.toString() ?? ''),
      gender: json['gender']?.toString(),
      agama: json['agama']?.toString(),
      prodi: json['prodi']?.toString(),
      fakultas: json['fakultas']?.toString(),
      pendidikanTerakhir: json['pendidikan_terakhir']?.toString(),
      nim: json['nim']?.toString(),
      points: json['points'] is int ? json['points'] : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      streakDays: json['streak_days'] is int ? json['streak_days'] : int.tryParse(json['streak_days']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'initials': initials,
      'usia': usia,
      'gender': gender,
      'agama': agama,
      'prodi': prodi,
      'fakultas': fakultas,
      'pendidikan_terakhir': pendidikanTerakhir,
      'nim': nim,
      'points': points,
      'streak_days': streakDays,
    };
  }
}
