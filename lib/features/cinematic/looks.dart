import 'package:flutter/material.dart';

/// Film-lab looks applied as a live ColorFilter on the preview.
class CinematicLook {
  final String id;
  final String name;
  final String description;
  final List<double> matrix; // 4x5 color matrix
  final Color? wash;
  final double vignette;

  const CinematicLook({
    required this.id,
    required this.name,
    required this.description,
    required this.matrix,
    this.wash,
    this.vignette = 0.35,
  });

  ColorFilter get filter => ColorFilter.matrix(matrix);
}

class CinematicLooks {
  static const identity = <double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const looks = <CinematicLook>[
    CinematicLook(
      id: 'none',
      name: 'Clean',
      description: 'Unlooked original',
      matrix: identity,
      vignette: 0,
    ),
    CinematicLook(
      id: 'teal-orange',
      name: 'Teal & Orange',
      description: 'Blockbuster grade',
      matrix: <double>[
        1.15, -0.05, 0.05, 0, 12,
        -0.04, 1.02, 0.06, 0, 0,
        0.12, 0.04, 1.18, 0, 8,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.4,
    ),
    CinematicLook(
      id: 'noir',
      name: 'Noir',
      description: 'Ink shadows, silver mids',
      matrix: <double>[
        0.33, 0.5, 0.16, 0, -12,
        0.33, 0.5, 0.16, 0, -12,
        0.33, 0.5, 0.16, 0, -8,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.55,
    ),
    CinematicLook(
      id: 'bleach',
      name: 'Bleach Bypass',
      description: 'Harsh contrast, silver skip-bleach',
      matrix: <double>[
        1.4, -0.1, -0.05, 0, -10,
        -0.08, 1.25, -0.05, 0, -10,
        -0.05, -0.05, 1.1, 0, -6,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.45,
    ),
    CinematicLook(
      id: 'night-drive',
      name: 'Night Drive',
      description: 'Cool neon, crushed blacks',
      matrix: <double>[
        0.85, 0.05, 0.15, 0, -8,
        0.02, 0.95, 0.18, 0, 0,
        0.08, 0.12, 1.25, 0, 18,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.5,
    ),
    CinematicLook(
      id: 'golden',
      name: 'Golden Hour',
      description: 'Warm late-day wrap',
      matrix: <double>[
        1.22, 0.08, -0.04, 0, 18,
        0.06, 1.05, -0.02, 0, 8,
        -0.08, 0.0, 0.82, 0, -6,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.28,
    ),
    CinematicLook(
      id: 'arctic',
      name: 'Arctic',
      description: 'Cold documentary',
      matrix: <double>[
        0.9, 0.02, 0.12, 0, 6,
        0.0, 1.02, 0.1, 0, 8,
        0.04, 0.08, 1.2, 0, 16,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.22,
    ),
    CinematicLook(
      id: 'print',
      name: 'Print Film',
      description: 'Kodak-inspired print',
      matrix: <double>[
        1.12, 0.06, -0.04, 0, 6,
        -0.02, 1.08, 0.04, 0, 2,
        -0.04, 0.04, 0.96, 0, -4,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.32,
    ),
    CinematicLook(
      id: 'horror',
      name: 'Undergrowth',
      description: 'Sickly green shadows',
      matrix: <double>[
        0.85, 0.1, 0.0, 0, -16,
        0.05, 1.15, 0.05, 0, 8,
        0.0, 0.12, 0.8, 0, -10,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.6,
    ),
    CinematicLook(
      id: 'fade',
      name: 'Super 8 Fade',
      description: 'Lifted blacks, faded color',
      matrix: <double>[
        0.95, 0.08, 0.05, 0, 22,
        0.06, 0.92, 0.06, 0, 18,
        0.04, 0.06, 0.85, 0, 14,
        0, 0, 0, 1, 0,
      ],
      vignette: 0.38,
    ),
  ];

  static CinematicLook byId(String id) =>
      looks.firstWhere((l) => l.id == id, orElse: () => looks.first);
}
