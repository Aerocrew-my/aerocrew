import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';

class CrewRatingsScreen extends StatefulWidget {
  const CrewRatingsScreen({super.key});

  @override
  State<CrewRatingsScreen> createState() => _CrewRatingsScreenState();
}

class _CrewRatingsScreenState extends State<CrewRatingsScreen> {
  String selectedFilter = 'all';

  final List<Map<String, dynamic>> ratings = [
    {
      'crew': 'Faiz Zakaria',
      'initials': 'FZ',
      'rating': 5,
      'comment': 'Ahmad was on time and very professional. Clean vehicle.',
      'tags': ['On time', 'Clean vehicle', 'Professional'],
      'date': 'Mon 16 Jun 2026',
      'route': 'PJ → SZB',
    },
    {
      'crew': 'Siti Nabilah',
      'initials': 'SN',
      'rating': 5,
      'comment': 'Great driver, smooth ride. Always reliable!',
      'tags': ['Safe driving', 'Friendly driver'],
      'date': 'Mon 16 Jun 2026',
      'route': 'PJ → SZB',
    },
    {
      'crew': 'Razif Azman',
      'initials': 'RA',
      'rating': 4,
      'comment': 'Good but was 3 minutes late to my pickup.',
      'tags': ['Good route'],
      'date': 'Tue 17 Jun 2026',
      'route': 'Damansara → KLIA',
    },
    {
      'crew': 'Ahmad Syafiq',
      'initials': 'AS',
      'rating': 5,
      'comment': 'Perfect as always. 5 stars!',
      'tags': ['On time', 'Professional', 'Friendly driver'],
      'date': 'Wed 18 Jun 2026',
      'route': 'Shah Alam → KLIA',
    },
    {
      'crew': 'Nurul Ain',
      'initials': 'NA',
      'rating': 5,
      'comment': '',
      'tags': ['On time', 'Clean vehicle'],
      'date': 'Wed 18 Jun 2026',
      'route': 'Shah Alam → KLIA',
    },
  ];

  List<Map<String, dynamic>> get filtered {
    if (selectedFilter == 'all') return ratings;
    final star = int.tryParse(selectedFilter) ?? 5;
    return ratings.where((r) => r['rating'] == star).toList();
  }

  double get avgRating =>
      ratings.fold(0, (s, r) => s + (r['rating'] as int)) /
      ratings.length;

  Map<int, int> get ratingCounts {
    final counts = <int, int>{};
    for (final r in ratings) {
      final star = r['rating'] as int;
      counts[star] = (counts[star] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                    _buildFilterRow(),
                    const SizedBox(height: 12),
                    ...filtered.map(_buildRatingCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AeroColors.navyCard,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AeroColors.divider, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CREW RATINGS',
                  style: TextStyle(
                      fontSize: 11,
                      color: AeroColors.amber,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              Text('What crew say about you',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: AeroColors.amber,
                      letterSpacing: -2)),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          Icons.star,
                          size: 16,
                          color: i < avgRating.round()
                              ? AeroColors.amber
                              : AeroColors.divider,
                        )),
              ),
              Text('${ratings.length} reviews',
                  style: const TextStyle(
                      fontSize: 11, color: AeroColors.grey)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = ratingCounts[star] ?? 0;
                final ratio = ratings.isEmpty ? 0.0 : count / ratings.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star',
                          style: const TextStyle(
                              fontSize: 11, color: AeroColors.grey)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star,
                          size: 10, color: AeroColors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor:
                                AeroColors.amber.withOpacity(0.1),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AeroColors.amber),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('$count',
                          style: const TextStyle(
                              fontSize: 11, color: AeroColors.grey)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'All'),
          const SizedBox(width: 6),
          _buildFilterChip('5', '5 ★'),
          const SizedBox(width: 6),
          _buildFilterChip('4', '4 ★'),
          const SizedBox(width: 6),
          _buildFilterChip('3', '3 ★'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = id),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AeroColors.amber : AeroColors.navyCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AeroColors.amber : AeroColors.divider,
            width: 0.5,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AeroColors.grey)),
      ),
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> r) {
    final rating = r['rating'] as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AeroColors.navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AeroColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AeroColors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(r['initials'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AeroColors.amber)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['crew'] as String,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    Text(
                        '${r['route']} · ${r['date']}',
                        style: const TextStyle(
                            fontSize: 11, color: AeroColors.grey)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(Icons.star,
                        size: 13,
                        color: i < rating
                            ? AeroColors.amber
                            : AeroColors.divider)),
              ),
            ],
          ),
          if ((r['comment'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r['comment'] as String,
                style: const TextStyle(
                    fontSize: 12,
                    color: AeroColors.greyLight,
                    height: 1.4)),
          ],
          if ((r['tags'] as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (r['tags'] as List<String>).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AeroColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AeroColors.success.withOpacity(0.2),
                          width: 0.5),
                    ),
                    child: Text(tag,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AeroColors.success,
                            fontWeight: FontWeight.w500)),
                  )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}