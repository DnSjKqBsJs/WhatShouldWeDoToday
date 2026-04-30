import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japan_app/models/trip_model.dart';
import 'package:japan_app/screens/trip/create_trip_screen.dart';
import 'package:japan_app/screens/trip/day_screen.dart';
import 'package:japan_app/screens/trip/invite_user_screen.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:japan_app/theme.dart';
import 'package:provider/provider.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key, required this.onTripSelected});
  final VoidCallback onTripSelected;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  late Future<List<TripModel>> _future;
  List<TripModel> _trips = [];
  bool _isGrid = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = FirestoreService().getTrips(
        FirebaseAuth.instance.currentUser!.uid,
      );
    });
  }

  // Génère une couleur de dégradé basée sur le nom du trip
  List<Color> _tripGradient(String name) {
    final gradients = [
      [Color(0xFFE8856A), Color(0xFFC0392B)],
      [Color(0xFFF4A261), Color(0xFFE76F51)],
      [Color(0xFF52B788), Color(0xFF2D6A4F)],
      [Color(0xFF74B3CE), Color(0xFF2E6E8E)],
      [Color(0xFFB392AC), Color(0xFF6D4C7A)],
    ];
    final index = name.codeUnitAt(0) % gradients.length;
    return gradients[index];
  }

  Widget _buildCoverArt(TripModel trip, {bool isGrid = true}) {
    final colors = _tripGradient(trip.name);
    final initial = trip.name.isNotEmpty ? trip.name[0].toUpperCase() : '?';

    return Container(
      width: isGrid ? double.infinity : 56,
      height: isGrid ? 160 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: trip.coverUrl != null && trip.coverUrl!.isNotEmpty
              ? colors
              : colors,
        ),
        borderRadius: isGrid
            ? BorderRadius.vertical(top: Radius.circular(20))
            : BorderRadius.circular(28),
        image: trip.coverUrl != null && trip.coverUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(trip.coverUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: trip.coverUrl == null || trip.coverUrl!.isEmpty
          ? Stack(
              children: [
                // Radial highlight
                Container(
                  decoration: BoxDecoration(
                    borderRadius: isGrid
                        ? BorderRadius.vertical(top: Radius.circular(20))
                        : BorderRadius.circular(28),
                    gradient: RadialGradient(
                      center: Alignment(-0.4, -0.5),
                      radius: 0.8,
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                if (isGrid)
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Text(
                      initial,
                      style: GoogleFonts.dmSans(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.22),
                        height: 1,
                      ),
                    ),
                  ),
                Center(
                  child: Text(
                    isGrid ? trip.name.toUpperCase() : initial,
                    style: GoogleFonts.dmSans(
                      fontSize: isGrid ? 13 : 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.92),
                      letterSpacing: isGrid ? 1.5 : 0,
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildGridCard(TripModel trip, int index) {
    return GestureDetector(
      key: ValueKey(trip.id),
      onTap: () {
        Provider.of<AppState>(context, listen: false).setCurrentTrip(trip);
        widget.onTripSelected();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceSolid,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.shadow,
          border: Border.all(color: AppTheme.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverArt(trip, isGrid: true),
            Padding(
              padding: EdgeInsets.fromLTRB(13, 12, 13, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    trip.countryName,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStat(
                          trip.users.length.toString(),
                          'people',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppTheme.border,
                      ),
                      Expanded(
                        child: _buildStat('—', 'days'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.accent,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(TripModel trip, int index) {
    return GestureDetector(
      key: ValueKey(trip.id),
      onTap: () {
        Provider.of<AppState>(context, listen: false).setCurrentTrip(trip);
        widget.onTripSelected();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSolid,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.shadow,
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            _buildCoverArt(trip, isGrid: false),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    trip.countryName,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppTheme.textLight, size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'select', child: Text('Select')),
                PopupMenuItem(value: 'days', child: Text('Days')),
                PopupMenuItem(value: 'modify', child: Text('Modify')),
                PopupMenuItem(value: 'invite', child: Text('Invite')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
              onSelected: (value) => _handleAction(value, trip, index),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String value, TripModel trip, int index) {
    if (value == 'select') {
      Provider.of<AppState>(context, listen: false).setCurrentTrip(trip);
      widget.onTripSelected();
    } else if (value == 'days') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DayScreen(tripId: trip.id)),
      );
    } else if (value == 'modify') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateTripScreen(trip: trip),
        ),
      ).then((_) => _refresh());
    } else if (value == 'invite') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InviteUserScreen(tripId: trip.id),
        ),
      );
    } else if (value == 'delete') {
      FirestoreService()
          .deleteUser(FirebaseAuth.instance.currentUser!.uid, trip.id)
          .then((_) {
            if (trip.id ==
                Provider.of<AppState>(context, listen: false).currentTrip?.id) {
              Provider.of<AppState>(context, listen: false).resetCurrentTrip();
            }
            _refresh();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.tripNeedRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refresh();
        appState.tripRefreshDone();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: FutureBuilder<List<TripModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              );
            }

            if (snapshot.hasData) _trips = snapshot.data!;

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Trips',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_trips.length} adventure${_trips.length != 1 ? 's' : ''} planned',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Toggle grille/liste
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                children: [
                                  _buildToggleBtn(
                                    Icons.grid_view_rounded,
                                    _isGrid,
                                    () => setState(() => _isGrid = true),
                                  ),
                                  _buildToggleBtn(
                                    Icons.list_rounded,
                                    !_isGrid,
                                    () => setState(() => _isGrid = false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 18)),

                    // Trips
                    if (_trips.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Text(
                              'No trips yet\nTap + to create one',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (_isGrid)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 120),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.65,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildGridCard(_trips[index], index),
                            childCount: _trips.length,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 120),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: _buildListCard(_trips[index], index),
                            ),
                            childCount: _trips.length,
                          ),
                        ),
                      ),
                  ],
                ),

                // FAB
                Positioned(
                  bottom: 96,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateTripScreen(),
                      ),
                    ).then((_) => _refresh()),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.4),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleBtn(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]
              : [],
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? AppTheme.accent : AppTheme.textLight,
        ),
      ),
    );
  }
}