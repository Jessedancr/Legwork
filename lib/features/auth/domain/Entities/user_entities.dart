/**
 * BASE ENTITY FOR USER
 */
abstract class UserEntity {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final int phoneNumber;
  final String password;
  final String userType;
  final String? bio;
  dynamic profilePicture;

  // Constructor
  UserEntity({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.userType,
    this.profilePicture,
    this.bio,
  });

  //UserType get userType;
}

/// DANCER ENTITY
class DancerEntity extends UserEntity {
  final List<dynamic> danceStyles;
  final Map<String, dynamic>? resume;
  List? jobPrefs;

  // Constructor
  DancerEntity({
    required super.firstName,
    required super.lastName,
    required super.username,
    required super.email,
    required super.password,
    required super.phoneNumber,
    required super.userType,
    required this.danceStyles,
    super.profilePicture,
    super.bio,
    this.resume,
    this.jobPrefs,
  });

  // @override
  // UserType get userType => UserType.dancer;

  @override
  String toString() {
    return 'DancerEntity(email: $email, userType: $userType)';
  }
}

/// CLIENT ENTITY
class ClientEntity extends UserEntity {
  final String? organisationName;

  // Constructor
  ClientEntity({
    required super.firstName,
    required super.lastName,
    required super.username,
    required super.email,
    required super.phoneNumber,
    required super.password,
    super.profilePicture,
    super.bio,
    this.organisationName,
    required super.userType,
  });

  // @override
  // UserType get userType => UserType.client;

  @override
  String toString() {
    return 'ClientEntity(email: $email, organisationName: $organisationName, userType: $userType)';
  }
}
