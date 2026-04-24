import 'dart:ui';

const List<String> predefinedTags = [
  'Restaurant',
  'Café',
  'Bar',
  'Visite',
  'Boutique',
  'Hôtel',
  'Activité',
  'Transport',
  'Nature',
  'Photo spot',
];

const Color defaultMarkerColor = Color(0xFF9E9E9E); // gris

const Map<String, Color> tagColors = {
  'Restaurant': Color(0xFFE53935), // rouge
  'Café': Color(0xFF795548),       // marron
  'Bar': Color(0xFF8E24AA),        // violet
  'Visite': Color(0xFF1E88E5),     // bleu
  'Boutique': Color(0xFFEC407A),   // rose
  'Hôtel': Color(0xFF00ACC1),      // cyan
  'Activité': Color(0xFFFF7043),   // orange
  'Transport': Color(0xFF546E7A),  // gris bleu
  'Nature': Color(0xFF43A047),     // vert
  'Photo spot': Color(0xFFFFB300), // jaune/or
};