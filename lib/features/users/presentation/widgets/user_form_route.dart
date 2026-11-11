import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../pages/user_form_page.dart';

// Role helpers now live in their own file; re-exported so screens that
// import this one (Users list, Profile) keep working unchanged.
export 'user_roles.dart';

/// Opens the user form as a full page and returns what the admin saved,
/// or null if they backed out. Kept under its original name and signature.
Future<UserInput?> showUserFormDialog(
    BuildContext context, {
      UserEntity? existing,
    }) {
  return Navigator.of(context).push<UserInput>(
    MaterialPageRoute(builder: (_) => UserFormPage(existing: existing)),
  );
}