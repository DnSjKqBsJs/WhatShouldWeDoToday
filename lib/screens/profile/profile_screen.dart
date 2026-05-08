import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:japan_app/models/friend_request_model.dart';
import 'package:japan_app/models/trip_invitation_model.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/screens/profile/friends_screen.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/auth_service.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:japan_app/services/friend_service.dart';
import 'package:japan_app/services/trip_invitation_service.dart';
import 'package:japan_app/theme.dart';
import 'package:japan_app/widgets/friend_card.dart';
import 'package:japan_app/widgets/notification_panel.dart';
import 'package:japan_app/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  List<UserModel> _friends = [];
  bool _loading = false;
  bool _editMode = false;
  bool _notifOpen = false;
  bool _saving = false;
  String _localImagePath = '';
  final ImagePicker _picker = ImagePicker();

  // Notification data
  List<FriendRequestModel> _friendNotifications = [];
  List<TripInvitationModel> _tripNotifications = [];
  List<UserModel?> _friendSenders = [];
  List<UserModel?> _tripSenders = [];

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (_loading) return;
    _loading = true;
    setState(() => user = null);
    final result = await FirestoreService().getUser(
      FirebaseAuth.instance.currentUser!.uid,
    );
    user = result;
    if (user != null) {
      _firstName.text = user!.firstName;
      _lastName.text = user!.lastName;
      _friends = await FirestoreService().getUsers(user!.friends ?? []);
    }
    _loading = false;
    setState(() {});
  }

  Future<void> _loadNotifications() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _friendNotifications = await FriendService().getFriendRequests(uid);
    _tripNotifications = await TripInvitationService().getTripInvitations(uid);
    _friendSenders = [];
    for (final e in _friendNotifications) {
      _friendSenders.add(await FirestoreService().getUser(e.fromId));
    }
    _tripSenders = [];
    for (final e in _tripNotifications) {
      _tripSenders.add(await FirestoreService().getUser(e.fromId));
    }
    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => _saving = true);
    String photoUrl = user!.photoUrl;
    if (_localImagePath.isNotEmpty) {
      final ref = FirebaseStorage.instance.ref().child(
        'users/${user!.id}/profile.jpg',
      );
      await ref.putFile(File(_localImagePath));
      photoUrl = await ref.getDownloadURL();
    }
    final updatedUser = UserModel(
      id: user!.id,
      email: user!.email,
      firstName: _firstName.text,
      lastName: _lastName.text,
      photoUrl: photoUrl,
      friends: user!.friends,
    );
    await FirestoreService().updateUser(updatedUser);
    _localImagePath = '';
    _loading = false;
    setState(() {
      user = updatedUser;
      _editMode = false;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    final pendingCount = context.watch<AppState>().pendingNotification;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      children: [
                        Text(
                          'Profile',
                          style: GoogleFonts.dmSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Spacer(),
                        // Bouton cloche
                        GestureDetector(
                          onTap: () async {
                            if (!_notifOpen) await _loadNotifications();
                            setState(() => _notifOpen = !_notifOpen);
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _notifOpen
                                      ? AppTheme.accent
                                      : AppTheme.surfaceSolid,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.border),
                                  boxShadow: AppTheme.shadow,
                                ),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  size: 18,
                                  color: _notifOpen
                                      ? Colors.white
                                      : AppTheme.textMid,
                                ),
                              ),
                              if (pendingCount > 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFF453A),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.bg,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        // Bouton edit
                        GestureDetector(
                          onTap: () => setState(() => _editMode = !_editMode),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _editMode
                                  ? AppTheme.accent
                                  : AppTheme.surfaceSolid,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border),
                              boxShadow: AppTheme.shadow,
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: _editMode
                                  ? Colors.white
                                  : AppTheme.textMid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Avatar + Info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _editMode
                                  ? () async {
                                      final img = await _picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (img != null) {
                                        setState(
                                          () => _localImagePath = img.path,
                                        );
                                      }
                                    }
                                  : null,
                              child: UserAvatar(
                                user: user,
                                size: 90,
                                localImagePath: _localImagePath,
                              ),
                            ),
                            if (_editMode)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (_editMode) ...[
                          _buildEditField('First Name', _firstName),
                          SizedBox(height: 10),
                          _buildEditField('Last Name', _lastName),
                          SizedBox(height: 14),
                          GestureDetector(
                            onTap: _saving ? null : _saveProfile,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accent.withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _saving
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Save Changes',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            '${user!.firstName} ${user!.lastName ?? ''}',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user!.email,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppTheme.textMid,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      children: [
                        _buildStatCard('${_friends.length}', 'Friends'),
                        SizedBox(width: 10),
                        _buildStatCard(
                          '${user!.friends?.length ?? 0}',
                          'Connections',
                        ),
                      ],
                    ),
                  ),
                ),

                // Friends
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        Text(
                          'Travel Friends',
                          style: GoogleFonts.dmSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendsScreen(),
                            ),
                          ).then((_) => _loadUser()),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_add_outlined,
                                  size: 13,
                                  color: AppTheme.accent,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Add',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: FriendCard(friend: _friends[index]),
                      ),
                      childCount: _friends.length,
                    ),
                  ),
                ),

                // Déconnexion
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<AppState>(
                          context,
                          listen: false,
                        ).cancelNotificationListener();
                        AuthService().signOut();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          'Sign Out',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Panel notifs flottant
          if (_notifOpen)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: NotificationPanel(
                friendNotifications: _friendNotifications,
                tripNotifications: _tripNotifications,
                friendSenders: _friendSenders,
                tripSenders: _tripSenders,
                onClose: () {
                  setState(() {
                    _notifOpen = false;
                  });
                },
                onFriendAction: (p0, accept) async {
                  if (accept) await _loadUser();
                },
                onTripAction: (p0, accept) {
                  if (accept) {
                    Provider.of<AppState>(
                      context,
                      listen: false,
                    ).requestTripRefresh();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLight,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: AppTheme.surfaceSolid,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.accent, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSolid,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadow,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.accent,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
