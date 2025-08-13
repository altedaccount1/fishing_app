// services/scoring_service.dart
import '../utils/constants.dart';

class ScoringService {
  // Score calculation cache for performance
  static final Map<String, int> _scoreCache = {};

  /// Calculate points for a fish based on length, weight, and species
  static int calculatePoints({
    required double length,
    required double weight,
    required String species,
    bool useCache = true,
  }) {
    // Create cache key
    final cacheKey = '${length}_${weight}_$species';

    if (useCache && _scoreCache.containsKey(cacheKey)) {
      return _scoreCache[cacheKey]!;
    }

    // Base calculation: (length * lengthMultiplier) + (weight * weightMultiplier)
    double basePoints = (length * AppConstants.lengthMultiplier) +
        (weight * AppConstants.weightMultiplier);

    // Apply species multiplier if available
    double speciesMultiplier = AppConstants.speciesMultipliers[species] ?? 1.0;

    double totalPoints = basePoints * speciesMultiplier;
    final result = totalPoints.round();

    // Cache the result
    if (useCache) {
      _scoreCache[cacheKey] = result;
    }

    return result;
  }

  /// Advanced validation with detailed error reporting
  static Map<String, String?> validateFishMeasurements({
    required double length,
    required double weight,
    required String species,
    String? location,
    DateTime? caughtTime,
  }) {
    Map<String, String?> errors = {};

    // Length validation
    if (length < AppConstants.minFishLength) {
      errors['length'] =
          'Length must be at least ${AppConstants.minFishLength} inches';
    } else if (length > AppConstants.maxFishLength) {
      errors['length'] =
          'Length cannot exceed ${AppConstants.maxFishLength} inches';
    }

    // Weight validation
    if (weight < AppConstants.minFishWeight) {
      errors['weight'] =
          'Weight must be at least ${AppConstants.minFishWeight} pounds';
    } else if (weight > AppConstants.maxFishWeight) {
      errors['weight'] =
          'Weight cannot exceed ${AppConstants.maxFishWeight} pounds';
    }

    // Species validation
    if (species.isEmpty) {
      errors['species'] = 'Please select a species';
    } else if (!AppConstants.commonSpecies.contains(species)) {
      errors['species'] = 'Selected species is not in the approved list';
    }

    // Biological proportions check (enhanced)
    if (length > 0 && weight > 0) {
      final lengthWeightRatio = weight / length;
      final speciesRatios = _getSpeciesLengthWeightRatios();

      if (speciesRatios.containsKey(species)) {
        final expectedRatio = speciesRatios[species]!;
        final tolerance = expectedRatio * 0.5; // 50% tolerance

        if (lengthWeightRatio < (expectedRatio - tolerance)) {
          errors['proportion'] =
              'Weight seems too low for a $species of this length';
        } else if (lengthWeightRatio > (expectedRatio + tolerance)) {
          errors['proportion'] =
              'Weight seems too high for a $species of this length';
        }
      } else {
        // Generic proportion check for unlisted species
        if (lengthWeightRatio < 0.05) {
          errors['proportion'] = 'Weight seems too low for the given length';
        } else if (lengthWeightRatio > 2.0) {
          errors['proportion'] = 'Weight seems too high for the given length';
        }
      }
    }

    // Time validation
    if (caughtTime != null) {
      final now = DateTime.now();
      if (caughtTime.isAfter(now)) {
        errors['time'] = 'Catch time cannot be in the future';
      } else if (caughtTime.isBefore(now.subtract(const Duration(days: 7)))) {
        errors['time'] = 'Catch time cannot be more than 7 days ago';
      }
    }

    // Seasonal restrictions
    if (caughtTime != null) {
      final seasonalErrors = _validateSeasonalRestrictions(species, caughtTime);
      if (seasonalErrors.isNotEmpty) {
        errors['season'] = seasonalErrors;
      }
    }

    // Location-specific validations
    if (location != null && location.isNotEmpty) {
      final locationErrors = _validateLocationRestrictions(species, location);
      if (locationErrors.isNotEmpty) {
        errors['location'] = locationErrors;
      }
    }

    return errors;
  }

  /// Check if fish meets minimum size requirements for the species
  static bool meetsMinimumSize({
    required double length,
    required double weight,
    required String species,
  }) {
    final minimumLengths = _getMinimumLengths();
    final minimumWeights = _getMinimumWeights();

    final minLength = minimumLengths[species] ?? 0.0;
    final minWeight = minimumWeights[species] ?? 0.0;

    return length >= minLength && weight >= minWeight;
  }

  /// Get species-specific minimum lengths
  static Map<String, double> _getMinimumLengths() {
    return const {
      'Striped Bass': 18.0,
      'Red Drum': 20.0,
      'Black Drum': 16.0,
      'Fluke/Summer Flounder': 18.0,
      'Weakfish': 13.0,
      'Tautog': 15.0,
      'Sea Bass': 12.5,
      'Scup': 9.0,
      'Bluefish': 0.0, // No minimum
      'Kingfish': 0.0, // No minimum
    };
  }

  /// Get species-specific minimum weights
  static Map<String, double> _getMinimumWeights() {
    return const {
      'Striped Bass': 3.0,
      'Red Drum': 4.0,
      'Black Drum': 2.5,
      'Fluke/Summer Flounder': 2.0,
      'Weakfish': 1.5,
      'Tautog': 2.0,
      'Sea Bass': 1.0,
      'Scup': 0.5,
      'Bluefish': 0.0,
      'Kingfish': 0.0,
    };
  }

  /// Get expected length-to-weight ratios for species
  static Map<String, double> _getSpeciesLengthWeightRatios() {
    return const {
      'Striped Bass': 0.35,
      'Red Drum': 0.30,
      'Black Drum': 0.40,
      'Fluke/Summer Flounder': 0.25,
      'Weakfish': 0.20,
      'Tautog': 0.45,
      'Sea Bass': 0.35,
      'Scup': 0.25,
      'Bluefish': 0.30,
      'Kingfish': 0.15,
    };
  }

  /// Validate seasonal restrictions
  static String _validateSeasonalRestrictions(
      String species, DateTime caughtTime) {
    final month = caughtTime.month;

    // Example seasonal restrictions (these would be based on actual regulations)
    switch (species) {
      case 'Striped Bass':
        if (month >= 1 && month <= 3) {
          return 'Striped Bass season is closed January-March';
        }
        break;
      case 'Fluke/Summer Flounder':
        if (month < 5 || month > 10) {
          return 'Fluke season is typically May-October';
        }
        break;
      case 'Tautog':
        if (month >= 6 && month <= 8) {
          return 'Tautog season is closed June-August';
        }
        break;
    }

    return '';
  }

  /// Validate location-specific restrictions
  static String _validateLocationRestrictions(String species, String location) {
    // Example location restrictions
    const restrictedAreas = {
      'Marine Protected Area': ['Striped Bass', 'Red Drum'],
      'Spawning Sanctuary': ['Weakfish', 'Fluke/Summer Flounder'],
    };

    for (final area in restrictedAreas.keys) {
      if (location.toLowerCase().contains(area.toLowerCase())) {
        if (restrictedAreas[area]!.contains(species)) {
          return '$species fishing is restricted in $area';
        }
      }
    }

    return '';
  }

  /// Get species multiplier for display
  static double getSpeciesMultiplier(String species) {
    return AppConstants.speciesMultipliers[species] ?? 1.0;
  }

  /// Check if species has a bonus multiplier
  static bool hasSpeciesBonus(String species) {
    return getSpeciesMultiplier(species) > 1.0;
  }

  /// Calculate what the points would be without species multiplier
  static int calculateBasePoints({
    required double length,
    required double weight,
  }) {
    double basePoints = (length * AppConstants.lengthMultiplier) +
        (weight * AppConstants.weightMultiplier);
    return basePoints.round();
  }

  /// Get detailed breakdown of how points were calculated
  static Map<String, dynamic> getPointsBreakdown({
    required double length,
    required double weight,
    required String species,
  }) {
    double lengthPoints = length * AppConstants.lengthMultiplier;
    double weightPoints = weight * AppConstants.weightMultiplier;
    double basePoints = lengthPoints + weightPoints;
    double speciesMultiplier = getSpeciesMultiplier(species);
    double bonusPoints = basePoints * (speciesMultiplier - 1.0);
    int totalPoints = calculatePoints(
      length: length,
      weight: weight,
      species: species,
    );

    return {
      'lengthPoints': lengthPoints.round(),
      'weightPoints': weightPoints.round(),
      'basePoints': basePoints.round(),
      'speciesMultiplier': speciesMultiplier,
      'bonusPoints': bonusPoints.round(),
      'totalPoints': totalPoints,
      'hasBonus': hasSpeciesBonus(species),
      'formula': _getCalculationFormula(species, speciesMultiplier),
    };
  }

  static String _getCalculationFormula(String species, double multiplier) {
    const base =
        '(Length × ${AppConstants.lengthMultiplier}) + (Weight × ${AppConstants.weightMultiplier})';

    if (multiplier > 1.0) {
      return '$base × $multiplier ($species bonus)';
    } else {
      return base;
    }
  }

  /// Get comprehensive species information for judges
  static Map<String, dynamic> getSpeciesInfo(String species) {
    return {
      'name': species,
      'multiplier': getSpeciesMultiplier(species),
      'hasBonus': hasSpeciesBonus(species),
      'minimumLength': _getMinimumLengths()[species] ?? 0.0,
      'minimumWeight': _getMinimumWeights()[species] ?? 0.0,
      'expectedRatio': _getSpeciesLengthWeightRatios()[species],
      'commonSizes': _getCommonSizes(species),
      'tips': _getJudgingTips(species),
      'habitat': _getHabitaInfo(species),
      'identification': _getIdentificationTips(species),
    };
  }

  static Map<String, String> _getCommonSizes(String species) {
    const Map<String, Map<String, String>> sizes = {
      'Striped Bass': {
        'small': '18-24" (schoolie)',
        'medium': '24-32" (keeper)',
        'large': '32-40" (trophy)',
        'trophy': '40"+ (cow)',
      },
      'Red Drum': {
        'small': '20-27" (slot limit)',
        'medium': '27-35" (over-slot)',
        'large': '35-45" (bull red)',
        'trophy': '45"+ (monster)',
      },
      'Bluefish': {
        'small': '12-18" (snapper)',
        'medium': '18-24" (cocktail)',
        'large': '24-30" (chopper)',
        'trophy': '30"+ (gorilla)',
      },
      'Fluke/Summer Flounder': {
        'small': '18-22" (keeper)',
        'medium': '22-26" (nice fish)',
        'large': '26-30" (doormat)',
        'trophy': '30"+ (barn door)',
      },
      'Tautog': {
        'small': '15-18" (keeper)',
        'medium': '18-22" (nice tog)',
        'large': '22-26" (jumbo)',
        'trophy': '26"+ (monster)',
      },
    };
    return sizes[species] ??
        const {'info': 'Size data not available for this species'};
  }

  static List<String> _getJudgingTips(String species) {
    const Map<String, List<String>> tips = {
      'Striped Bass': [
        'Measure from tip of nose to end of tail (total length)',
        'Check for distinctive dark horizontal stripes',
        'Look for silvery sides with dark back',
        'Verify proper catch method - no high-grading',
      ],
      'Red Drum': [
        'Look for distinctive black spot(s) near tail',
        'Copper-bronze to reddish coloration',
        'Measure total length, not fork length',
        'Popular target species with good point values',
      ],
      'Bluefish': [
        'Sharp teeth - handle carefully during measurement',
        'Silvery-blue coloration with darker back',
        'Aggressive fighter - verify legal catch method',
        'No minimum size in most tournament areas',
      ],
      'Fluke/Summer Flounder': [
        'Both eyes on dark (left) side of head',
        'Measure from nose to longest tail fin ray',
        'Check for proper flatfish identification',
        'Summer species - peak season May-October',
      ],
      'Tautog': [
        'Dark mottled coloration, robust body',
        'Large lips and strong jaw',
        'Rocky bottom species',
        'Fall fishing typically produces larger fish',
      ],
      'Black Drum': [
        'Distinguished from red drum by coloration',
        'Barbels under chin',
        'Large specimens may have worms (still legal)',
        'Popular in spring tournaments',
      ],
    };
    return tips[species] ??
        const ['Standard measuring and verification procedures apply'];
  }

  static String _getHabitaInfo(String species) {
    const habitatMap = {
      'Striped Bass':
          'Anadromous, found in surf, bays, and rivers. Migrates seasonally.',
      'Red Drum':
          'Coastal waters, marshes, and surf zones. Year-round in southern waters.',
      'Bluefish':
          'Pelagic species, common in surf and offshore. Highly migratory.',
      'Fluke/Summer Flounder':
          'Bottom dweller in sandy areas. Inshore spring-fall.',
      'Tautog': 'Structure-oriented fish around rocks, wrecks, and jetties.',
      'Black Drum': 'Bottom feeder in bays, surf, and near-shore waters.',
      'Weakfish': 'Schooling fish in bays and surf. Declining populations.',
      'Sea Bass': 'Bottom fish around structure. Offshore in winter.',
      'Scup': 'Bottom fish, common in bays and near-shore waters.',
      'Kingfish': 'Surf zone bottom dweller. Good beginner target.',
    };
    return habitatMap[species] ?? 'Habitat information not available.';
  }

  static List<String> _getIdentificationTips(String species) {
    const Map<String, List<String>> identification = {
      'Striped Bass': [
        '7-8 distinct dark horizontal stripes',
        'Silvery body with greenish back',
        'Two separate dorsal fins',
        'White belly',
      ],
      'Red Drum': [
        'Copper to bronze coloration',
        'Black spot(s) near tail base',
        'No barbels on chin',
        'Squared-off tail',
      ],
      'Bluefish': [
        'Blue-green back, silver sides',
        'Sharp, prominent teeth',
        'Forked tail',
        'Single dorsal fin',
      ],
      'Black Drum': [
        'Dark gray to black coloration',
        'Barbels under chin',
        'High-backed profile',
        'No spots on tail',
      ],
    };
    return identification[species] ??
        const ['Consult field guide for identification'];
  }

  /// Performance optimization
  static void clearCache() {
    _scoreCache.clear();
  }

  static int getCacheSize() {
    return _scoreCache.length;
  }

  /// Weight-length relationship validation
  static bool isReasonableWeightForLength({
    required double length,
    required double weight,
    required String species,
  }) {
    final expectedRatios = _getSpeciesLengthWeightRatios();
    final expectedRatio = expectedRatios[species];

    if (expectedRatio == null) {
      // Use generic validation for unknown species
      final ratio = weight / length;
      return ratio >= 0.05 && ratio <= 2.0;
    }

    final actualRatio = weight / length;
    final tolerance = expectedRatio * 0.6; // 60% tolerance

    return actualRatio >= (expectedRatio - tolerance) &&
        actualRatio <= (expectedRatio + tolerance);
  }
}
