import 'package:flutter/material.dart';
import 'package:japan_app/constants.dart';
import 'package:japan_app/models/day_model.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({
    super.key,
    required this.days,
    required this.selectedDaysIds,
    required this.selectedTags,
    required this.onDayToggled,
    required this.onTagToggled,
  });

  final List<DayModel> days;
  final List<String> selectedDaysIds;
  final List<String> selectedTags;
  final Function(DayModel) onDayToggled;
  final Function(String) onTagToggled;

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  bool _panelOpen = false;

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters =
        widget.selectedDaysIds.isNotEmpty || widget.selectedTags.isNotEmpty;

    return Positioned(
      top: 50,
      left: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bouton burger
          GestureDetector(
            onTap: () => setState(() => _panelOpen = !_panelOpen),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _panelOpen ? Icons.close : Icons.tune,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_panelOpen) ...[
            SizedBox(height: 8),
            Container(
              width: 240,
              constraints: BoxConstraints(maxHeight: 400),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jours',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8),
                    widget.days.isEmpty
                        ? Text(
                            'Aucun jour créé',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: widget.days.map((e) {
                              final selected =
                                  widget.selectedDaysIds.contains(e.id);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      widget.selectedDaysIds.remove(e.id);
                                    } else {
                                      widget.selectedDaysIds.add(e.id);
                                    }
                                  });
                                  widget.onDayToggled.call(e);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.black87
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    e.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: selected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    SizedBox(height: 14),
                    Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: predefinedTags.map((e) {
                        final selected = widget.selectedTags.contains(e);
                        final color = tagColors[e] ?? defaultMarkerColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                widget.selectedTags.remove(e);
                              } else {
                                widget.selectedTags.add(e);
                              }
                            });
                            widget.onTagToggled.call(e);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color
                                  : color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 12,
                                color: selected ? Colors.white : color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}