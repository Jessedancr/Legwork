import 'package:dartz/dartz.dart';
import 'package:legwork/features/auth/domain/Entities/user_entities.dart';

import '../../../../core/enums/user_type.dart';

/**
 * THIS CLASS INTERFACES BETWEEN THE DATA LAYER AND THE APP'S BUSINESS LOGIC
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * CONVERTS THE USER MODEL RETURNED BY THE DATA LAYER INTO A USER ENTITY
 */

abstract class AuthRepo {
  // Login method
  Future<Either<String, UserEntity>> userLogin({
    required String email,
    required String password,
    String userType,
  });

  // Sign up method
  Future<Either<String, UserEntity>> userSignUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required int phoneNumber,
    required String password,
    required UserType userType,
    dynamic porfolio,
    String? organizationName, // for client
    List<dynamic>? danceStyles, // for dancer
  });
}
