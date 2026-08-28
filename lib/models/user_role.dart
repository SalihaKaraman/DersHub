enum UserRole {
  teacher,
  parent;

  String get displayName {
    switch (this) {
      case UserRole.teacher:
        return 'Öğretmen';
      case UserRole.parent:
        return 'Veli';
    }
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.teacher,
    );
  }
}
