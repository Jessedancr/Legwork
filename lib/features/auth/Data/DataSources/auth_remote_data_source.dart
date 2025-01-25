import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legwork/Features/auth/Data/Models/resume_model.dart';
import 'package:legwork/Features/auth/Data/Models/user_model.dart';

import '../../../../core/Enums/user_type.dart';

/**
 * AUTH ABSTRACT CLASS
 */
abstract class AuthRemoteDataSource {
  /// USER SIGN UP METHOD
  Future<Either<String, dynamic>> userSignUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required int phoneNumber,
    required String password,
    required UserType userType,
    List<dynamic>? danceStyles,
    Map<String, dynamic>? resume,
    String? bio,
    List<String>? jobPrefs,
    List<dynamic>? danceStylePrefs,
  });

  /// USER LOGIN METHOD
  Future<Either<String, dynamic>> userLogin({
    required String email,
    required String password,
  });
}

/**
 * CONCRETE IMPLEMENTATION OF AUTH ABSTRACT CLASS
 */
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Instance of firebase auth and firestore
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  /// USER SIGN IN METHOD
  @override
  Future<Either<String, dynamic>> userSignUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required int phoneNumber,
    required String password,
    required UserType userType,
    dynamic profilePicture,
    String? bio,
    List<String>? jobPrefs, // for dancers
    List<dynamic>? danceStyles, // for dancers
    Map<String, dynamic>? resume, // For dancers => 'hiringHistory' for clients
    String? organisationName, // for clients
    List<dynamic>? danceStylePrefs, // for clients
    List<dynamic>? jobOfferings, // for clients
  }) async {
    try {
      // Sign dancer in
      final userCred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;

      // Check if user is null
      if (user == null) {
        return const Left('User not found');
      }
      final uid = user.uid;

      // if user is client
      if (userType == UserType.client) {
        // Store client data
        final clientData = {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'organisationName': organisationName ?? '',
          'password': password,
          'email': email,
          'phoneNumber': phoneNumber,
          'userType': UserType.client.name, // Store the userType
          'profilePicture': profilePicture,
          'bio': bio ?? '',
          'danceStylePrefs': danceStylePrefs ?? [],
          'jobOfferings': jobOfferings ?? [],
          'hiringHistory': resume ?? {},
        };

        await db.collection('clients').doc(uid).set(clientData);
        DocumentSnapshot userDoc =
            await db.collection('clients').doc(uid).get();
        final clientModel = ClientModel.fromDocument(userDoc);
        return Right(clientModel);
      }

      // If user is dancer
      else if (userType == UserType.dancer) {
        // Store additional dancer's data to firebase
        final dancerData = {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'danceStyles': danceStyles ?? [],
          'resume': resume ?? {},
          'password': password,
          'profilePicture': profilePicture,
          'bio': bio ?? '',
          'userType': UserType.dancer.name, // Store the userType
          'jobPrefs': jobPrefs,
        };

        await db.collection('dancers').doc(uid).set(dancerData);

        // Fetch additional info like username
        DocumentSnapshot userDoc =
            await db.collection('dancers').doc(uid).get();

        // Convert firebase doc to user profile do we can use in the app
        final dancerModel = DancerModel.fromDocument(userDoc);
        return Right(dancerModel);
      }
      return const Left('Invalid user type');
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Signup error: $e");
      if (e.code == 'network-request-failed') {
        return const Left('Check your internet connection and try again');
      }
      return Left(e.message ?? 'Unexpected error');
    }
  }

  /// USER LOGIN METHOD
  @override
  Future<Either<String, dynamic>> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      // sign User in using the sign in method in firebase auth
      final userCred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCred.user;

      // Check if user is null or if user exists
      if (user == null) {
        return const Left('User not found');
      }
      // get uid of current user
      final uid = user.uid;

      // the Future.wait method checks both collections at the same time
      final results = await Future.wait([
        db.collection('dancers').doc(uid).get(),
        db.collection('clients').doc(uid).get()
      ]);
      final dancersDoc = results[0];
      final clientsDoc = results[1];

      // Check if the document is in the dancers collection and if it has userType field
      if (dancersDoc.exists) {
        // Extracting the data fronm the dancers doc using the .data() method and converting it to a map
        final dancersData = dancersDoc.data() as Map<String, dynamic>;
        final userType = dancersData['userType'];
        if (userType == UserType.dancer.name) {
          // convert firebase doc to user profile so we can use in the app
          final dancerModel = DancerModel.fromDocument(dancersDoc);
          return Right(dancerModel);
        }
      }

      // Same check for client
      else if (clientsDoc.exists) {
        // Extracting the data fronm the dancers doc using the .data() method and converting it to a map
        final clientsData = clientsDoc.data() as Map<String, dynamic>;
        final userType = clientsData['userType'];
        if (userType == UserType.client.name) {
          // convert firebase doc to user profile so we can use in the app
          final clientModel = ClientModel.fromDocument(clientsDoc);
          return Right(clientModel);
        }
      }
      debugPrint('User not found brr');
      return const Left('User not found');
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase  Login error: ${e.code}");
      if (e.code == 'user-not-found') {
        return const Left('No user found for this email.');
      } else if (e.code == 'wrong-password') {
        return const Left('Incorrect password. Please try again.');
      } else if (e.code == 'invalid-credential') {
        return const Left('Invalid email or password.');
      } else {
        return const Left('An unexpected error occurred.');
      }
    } catch (e) {
      debugPrint("An unknown error occurred while logging in");
      return Left(e.toString());
    }
  }
}

/**
 * RESUME UPLOAD ABSTRACT CLASS
 */
abstract class ResumeUploadRemoteDataSource {
  // METHOD TO UPLOAD RESUME
  Future<Either<String, ResumeModel>> uploadResume({
    required String professionalTitle,
    required List<Map<String, dynamic>> workExperience,
    dynamic resumeFile,
  });
}

class ResumeUploadRemoteDataSourceImpl extends ResumeUploadRemoteDataSource {
  // Instance of firebase auth and firestore
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  @override
  Future<Either<String, ResumeModel>> uploadResume({
    required String professionalTitle,
    required List<Map<String, dynamic>> workExperience,
    dynamic resumeFile,
  }) async {
    try {
      // Get uid of currently logged in user
      final uid = auth.currentUser!.uid;

      // Get the resume details from user
      final resumeDetails = {
        'professionalTitle': professionalTitle,
        'workExperience': workExperience,
        'resumeFile': resumeFile,
      };

      // Query the database to save the resume details and also retrieve it
      await db.collection('dancers').doc(uid).set(resumeDetails);
      DocumentSnapshot userDoc = await db.collection('dancers').doc(uid).get();

      // Convert firebase doc to Resume  so we can use in app
      final resumeModel = ResumeModel.fromDocument(userDoc);
      return Right(resumeModel);
    } catch (e) {
      debugPrint('error with uploading or updating resume');
      return Left(e.toString());
    }
  }
}

/**
 * UPDATE PROFILE CLASS
 */
class UpdateProfile {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Future<Either<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      // Get current user and check if null
      final user = auth.currentUser;
      if (user == null) {
        debugPrint('User not found');
        return const Left('User not found');
      }

      // Get current user's uid and check both the dancers and clients collections
      final String uid = user.uid;
      final results = await Future.wait([
        db.collection('dancers').doc(uid).get(),
        db.collection('clients').doc(uid).get()
      ]);

      final dancersDoc = results[0];
      final clientsDoc = results[1];

      // IF DOCUMENT IS IN DANCERS COLLECTION
      if (dancersDoc.exists) {
        await db.collection('dancers').doc(uid).update(data);
        DocumentSnapshot userDoc =
            await db.collection('dancers').doc(uid).get();
        final dancerModel = DancerModel.fromDocument(userDoc);
        return Right(dancerModel);
      }

      // IF DOCUMENT IS IN CLIENTS COLLECTION
      else if (clientsDoc.exists) {
        await db.collection('clients').doc(uid).update(data);
        DocumentSnapshot userDoc =
            await db.collection('clients').doc(uid).get();
        final clientModel = ClientModel.fromDocument(userDoc);
        return Right(clientModel);
      } else {
        return const Left('User not found');
      }
    } catch (e) {
      debugPrint('error updating profile to firebaseeeeeeeee');
      return Left(e.toString());
    }
  }
}
