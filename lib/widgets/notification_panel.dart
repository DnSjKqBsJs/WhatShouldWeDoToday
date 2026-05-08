import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japan_app/models/friend_request_model.dart';
import 'package:japan_app/models/trip_invitation_model.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/friend_service.dart';
import 'package:japan_app/services/trip_invitation_service.dart';
import 'package:japan_app/theme.dart';
import 'package:japan_app/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({
    super.key,
    required this.friendNotifications,
    required this.tripNotifications,
    required this.friendSenders,
    required this.tripSenders,
    required this.onClose,
    required this.onFriendAction,
    required this.onTripAction,
  });

  final List<FriendRequestModel> friendNotifications;
  final List<TripInvitationModel> tripNotifications;
  final List<UserModel?> friendSenders;
  final List<UserModel?> tripSenders;
  final VoidCallback onClose;
  final Function(int, bool) onFriendAction;
  final Function(int, bool) onTripAction;

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  @override
  Widget build(BuildContext context) {
    final pendingCount = context.read<AppState>().pendingNotification;
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.74),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.75)),
              boxShadow: AppTheme.shadowMd,
            ),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Spacer(),
                    if (pendingCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF453A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingCount',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => widget.onClose.call(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: AppTheme.textMid,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                if (widget.friendNotifications.isEmpty &&
                    widget.tripNotifications.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'All caught up ✓',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                  )
                else ...[
                  ...widget.friendNotifications.asMap().entries.map(
                    (e) => _buildNotifItem(
                      sender: widget.friendSenders[e.key],
                      message: 'wants to be your travel friend',
                      onAccept: () async {
                        await FriendService().acceptFriendRequest(
                          widget.friendNotifications[e.key],
                        );
                        widget.onFriendAction(0,true);
                        if (mounted) {
                          setState(() {
                            widget.friendSenders.removeAt(e.key);
                            widget.friendNotifications.removeAt(e.key);
                          });
                        }
                      },
                      onRefuse: () async {
                        await FriendService().declineFriendRequest(
                          widget.friendNotifications[e.key],
                        );
                        widget.onFriendAction(0,false);
                        if (mounted) {
                          setState(() {
                            widget.friendSenders.removeAt(e.key);
                            widget.friendNotifications.removeAt(e.key);
                          });
                        }
                      },
                    ),
                  ),
                  ...widget.tripNotifications.asMap().entries.map(
                    (e) => _buildNotifItem(
                      sender: widget.tripSenders[e.key],
                      message: 'invited you to join a trip',
                      onAccept: () async {
                        final appState = Provider.of<AppState>(
                          context,
                          listen: false,
                        );
                        await TripInvitationService().acceptTripInvitation(
                          widget.tripNotifications[e.key],
                        );
                        widget.onTripAction(0,true);
                        if (mounted) {
                          setState(() {
                            widget.tripSenders.removeAt(e.key);
                            widget.tripNotifications.removeAt(e.key);
                          });
                          appState.requestTripRefresh();
                        }
                      },
                      onRefuse: () async {
                        await TripInvitationService().declineTripInvitation(
                          widget.tripNotifications[e.key],
                        );
                        widget.onTripAction(0,false);
                        if (mounted) {
                          setState(() {
                            widget.tripSenders.removeAt(e.key);
                            widget.tripNotifications.removeAt(e.key);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotifItem({
    required UserModel? sender,
    required String message,
    required VoidCallback onAccept,
    required VoidCallback onRefuse,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          UserAvatar(user: sender, size: 38),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${sender?.firstName ?? '?'} ',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: message,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onAccept,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFD4EDDA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 13, color: Color(0xFF2D6A4F)),
                ),
              ),
              SizedBox(width: 6),
              GestureDetector(
                onTap: onRefuse,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE5E5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 13, color: Color(0xFFC0392B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
