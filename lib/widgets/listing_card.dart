import 'package:flutter/material.dart';
import '../theme/doutang_theme.dart';
import '../models/listing.dart';
import '../services/score_service.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.matchingScore,
    this.onTap,
  });

  final Listing listing;
  final double? matchingScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: DRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(DSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: DSpacing.sm),
                  _StatusChip(status: listing.status),
                ],
              ),
              const SizedBox(height: DSpacing.sm),
              Row(
                children: [
                  if (listing.price != null) ...[
                    Icon(Icons.euro, size: 14,
                        color: DoutangTheme.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      '${listing.price!.toStringAsFixed(0)} €',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: DSpacing.md),
                  ],
                  if (listing.surface != null) ...[
                    Icon(Icons.square_foot, size: 14,
                        color: DoutangTheme.textSecondary),
                    const SizedBox(width: 2),
                    Text('${listing.surface} m²',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: DSpacing.md),
                  ],
                  if (listing.rooms != null) ...[
                    Icon(Icons.meeting_room_outlined, size: 14,
                        color: DoutangTheme.textSecondary),
                    const SizedBox(width: 2),
                    Text('${listing.rooms}P',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
              if (listing.address != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 13,
                      color: DoutangTheme.textHint),
                  const SizedBox(width: 2),
                  Text(listing.address!,
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
              ],
              if (matchingScore != null) ...[
                const SizedBox(height: DSpacing.sm),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: matchingScore,
                        backgroundColor: DoutangTheme.border,
                        color: DoutangTheme.scoreColor(matchingScore! * 5),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSpacing.sm),
                  Text(
                    '${(matchingScore! * 100).round()}% match',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DoutangTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ListingStatus status;

  Color get _color => switch (status) {
        ListingStatus.aContacter => DoutangTheme.textHint,
        ListingStatus.visiteePlanifiee => DoutangTheme.accent,
        ListingStatus.visitee => DoutangTheme.primary,
        ListingStatus.eliminee => DoutangTheme.danger,
        ListingStatus.favorite => DoutangTheme.primaryLight,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
