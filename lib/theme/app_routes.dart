import 'package:flutter/material.dart';
import '../screens/listings/listings_screen.dart';
import '../screens/listings/listing_detail_screen.dart';
import '../screens/listings/add_listing_screen.dart';
import '../screens/visits/visits_screen.dart';
import '../screens/visits/visit_questionnaire_screen.dart';
import '../screens/visits/visit_summary_screen.dart';
import '../screens/compare/compare_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/desiderata_screen.dart';

class AppRoutes {
  static const String listings = '/';
  static const String listingDetail = '/listing/detail';
  static const String addListing = '/listing/add';

  static const String visits = '/visits';
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
        visitQuestionnaire: (_) => const VisitQuestionnaireScreen(),
        visitSummary: (_) => const VisitSummaryScreen(),
        compare: (_) => const CompareScreen(),
        profile: (_) => const ProfileScreen(),
        desiderata: (_) => const DesiderataScreen(),
      };
}
