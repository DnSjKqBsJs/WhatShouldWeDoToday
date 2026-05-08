import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/theme.dart';

Color _avatarColor(String name) {
  final colors = [
    Color(0xFF2A8FA0),
    Color(0xFFE8856A),
    Color(0xFF52B788),
    Color(0xFFB392AC),
    Color(0xFF74B3CE),
  ];
  if (name.isEmpty) return colors[0];
  return colors[name.codeUnitAt(0) % colors.length];
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    required this.size,
    this.localImagePath,
  });

  final UserModel? user;
  final double size;
  final String? localImagePath;

  @override
  Widget build(BuildContext context) {
    final initials = user != null
        ? '${user!.firstName.isNotEmpty ? user!.firstName[0] : ''}${user!.lastName.isNotEmpty == true ? user!.lastName![0] : ''}'
              .toUpperCase()
        : '?';
    final hasPhoto =
        (localImagePath != null && localImagePath!.isNotEmpty) ||
        (user?.photoUrl.isNotEmpty == true);
    final color = user != null
        ? _avatarColor(user!.firstName)
        : AppTheme.accent;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasPhoto
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
        image: hasPhoto
            ? DecorationImage(
                image: localImagePath != null && localImagePath!.isNotEmpty
                    ? FileImage(File(localImagePath!)) as ImageProvider
                    : NetworkImage(user!.photoUrl),
                fit: BoxFit.cover,
              )
            : null,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                initials,
                style: GoogleFonts.dmSans(
                  fontSize: size * 0.34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
    );
    ;
  }
}
