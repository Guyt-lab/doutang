import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/listing.dart';
import '../models/profile.dart';
import '../models/visit.dart';
import '../screens/compare/compare_screen.dart';
import '../screens/listings/add_listing_screen.dart';
import '../screens/listings/listing_detail_screen.dart';
import '../screens/listings/listings_screen.dart';
import '../screens/profile/desiderata_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/visits/visit_detail_screen.dart';
import '../screens/visits/visit_questionnaire_screen.dart';
import '../screens/visits/visit_summary_screen.dart';
import '../screens/visits/visits_screen.dart';

class AppRoutes {
  static const String listings = '/';
  static const String listingDetail = '/listing/detail';
  static const String addListing = '/listing/add';

  static const String visits = '/visits';
  static const String visitDetail = '/visits/detail';
  static const String visitQuestionnaire = '/visits/questionnaire';
  static const String visitSummary = '/visits/summary';

  static const String compare = '/compare';

  static const String profile = '/profile';
  static const String desiderata = '/profile/desiderata';

  static Map<String, WidgetBuilder> get routes => {
        listings: (_) => const ListingsScreen(),
        listingDetail: (_) => const ListingDetailScreen(),
        addListing: (_) => const AddListingScreen(),
        visits: (_) => const VisitsScreen(),

        // Détail visite : attend {visit: Visit, listing: Listing}.
        visitDetail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final visit = args?['visit'] as Visit?;
          final listing = args?['listing'] as Listing?;
          return VisitDetailScreen(
            visit: visit ?? Visit(listingId: '', owner: 'demo'),
            listing: listing ??
                Listing(title: 'Annonce sans titre', addedBy: 'demo'),
          );
        },

        // Questionnaire : attend {listing: Listing, profile: UserProfile}.
        visitQuestionnaire: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final listing = args?['listing'] as Listing?;
          final profile = args?['profile'] as UserProfile?;
          final existingVisit = args?['existingVisit'] as Visit?;
          return VisitQuestionnaireScreen(
            listing: listing ??
                Listing(title: 'Annonce sans titre', addedBy: 'demo'),
            profile: profile ?? UserProfile(owner: 'demo'),
            existingVisit: existingVisit,
          );
        },

        // Bilan : attend {visit: Visit, listing: Listing, blockers: List<Blocker>}.
        visitSummary: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final visit = args?['visit'] as Visit?;
          final listing = args?['listing'] as Listing?;
          final blockers =
              (args?['blockers'] as List?)?.cast<Blocker>() ?? <Blocker>[];
          return VisitSummaryScreen(
            visit: visit ??
                Visit(listingId: '', owner: 'demo'),
            listing: listing ??
                Listing(title: 'Annonce sans titre', addedBy: 'demo'),
            blockers: blockers,
          );
        },

        compare: (_) => const CompareScreen(),
        profile: (_) => const ProfileScreen(),
        desiderata: (_) => const DesiderataScreen(),
      };
}
