import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/theme.dart';
import 'package:japan_app/widgets/user_avatar.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({super.key, required this.friend});

  final UserModel friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSolid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadow,
      ),
      child: Row(
        children: [
          UserAvatar(user: friend, size: 42),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${friend.firstName} ${friend.lastName ?? ''}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  friend.email,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: AppTheme.textLight),
        ],
      ),
    );
  }
}