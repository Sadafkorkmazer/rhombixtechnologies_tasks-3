import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'converter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime now = DateTime.now();

  String selectedCity1 = 'Islamabad';
  String selectedCity2 = 'London';

  final Map<String, String> cityZones = {
    'Islamabad': 'Asia/Karachi',
    'Dubai': 'Asia/Dubai',
    'Abu Dhabi': 'Asia/Dubai',
    'Riyadh': 'Asia/Riyadh',
    'Doha': 'Asia/Qatar',
    'Istanbul': 'Europe/Istanbul',
    'London': 'Europe/London',
    'Paris': 'Europe/Paris',
    'Berlin': 'Europe/Berlin',
    'Rome': 'Europe/Rome',
    'Madrid': 'Europe/Madrid',
    'Cairo': 'Africa/Cairo',
    'Johannesburg': 'Africa/Johannesburg',
    'Moscow': 'Europe/Moscow',
    'New York': 'America/New_York',
    'Toronto': 'America/Toronto',
    'Chicago': 'America/Chicago',
    'Los Angeles': 'America/Los_Angeles',
    'Mexico City': 'America/Mexico_City',
    'São Paulo': 'America/Sao_Paulo',
    'Tokyo': 'Asia/Tokyo',
    'Seoul': 'Asia/Seoul',
    'Beijing': 'Asia/Shanghai',
    'Hong Kong': 'Asia/Hong_Kong',
    'Singapore': 'Asia/Singapore',
    'Bangkok': 'Asia/Bangkok',
    'Sydney': 'Australia/Sydney',
    'Melbourne': 'Australia/Melbourne',
  };

  @override
  void initState() {
    super.initState();

    tz_data.initializeTimeZones();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  tz.TZDateTime cityTime(String city) {
    return tz.TZDateTime.from(
      now,
      tz.getLocation(cityZones[city]!),
    );
  }

  String timeText(tz.TZDateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute:$second $period';
  }

  String dateText(tz.TZDateTime time) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${days[time.weekday - 1]}, '
        '${months[time.month - 1]} ${time.day}, ${time.year}';
  }

  String offsetText(tz.TZDateTime time) {
    final offset = time.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60)
        .toString()
        .padLeft(2, '0');

    return 'UTC$sign$hours:$minutes';
  }

  String differenceText() {
    final first = cityTime(selectedCity1);
    final second = cityTime(selectedCity2);

    final difference =
        second.timeZoneOffset.inMinutes -
            first.timeZoneOffset.inMinutes;

    if (difference == 0) {
      return 'Same time zone';
    }

    final hours = difference.abs() ~/ 60;
    final minutes = difference.abs() % 60;

    String value = '';

    if (hours > 0) {
      value += '$hours hr';
    }

    if (minutes > 0) {
      if (value.isNotEmpty) value += ' ';
      value += '$minutes min';
    }

    return difference > 0
        ? '$selectedCity2 is $value ahead'
        : '$selectedCity2 is $value behind';
  }

  @override
  Widget build(BuildContext context) {
    final firstTime = cityTime(selectedCity1);
    final secondTime = cityTime(selectedCity2);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _liveClock(firstTime)),
            SliverToBoxAdapter(child: _sectionTitle()),
            SliverToBoxAdapter(
              child: _citySelector(
                'Location 1',
                selectedCity1,
                Icons.flight_takeoff_rounded,
                    (value) {
                  if (value != null) {
                    setState(() => selectedCity1 = value);
                  }
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _citySelector(
                'Location 2',
                selectedCity2,
                Icons.flight_land_rounded,
                    (value) {
                  if (value != null) {
                    setState(() => selectedCity2 = value);
                  }
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _comparisonCards(firstTime, secondTime),
            ),
            SliverToBoxAdapter(child: _differenceCard()),
            SliverToBoxAdapter(child: _converterButton()),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3949AB),
                  Color(0xFF7E57C2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.public_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIME ZONE',
                  style: TextStyle(
                    color: Color(0xFF7E57C2),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'World Clock',
                  style: TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveClock(tz.TZDateTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF303F9F),
              Color(0xFF5E35B1),
              Color(0xFF7E57C2),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3949AB).withOpacity(.25),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.my_location_rounded,
                  color: Colors.white70,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'LOCAL TIME',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              selectedCity1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              child: Text(
                timeText(time),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              dateText(time),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(22, 28, 22, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compare Locations',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202124),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Compare local times across different cities.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _citySelector(
      String label,
      String value,
      IconData icon,
      ValueChanged<String?> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xFFE4E1EE),
          ),
        ),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF5E35B1),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF5E35B1),
          ),
          items: cityZones.keys.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _comparisonCards(
      tz.TZDateTime first,
      tz.TZDateTime second,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 7, 20, 0),
      child: Row(
        children: [
          Expanded(child: _timeCard(selectedCity1, first)),
          const SizedBox(width: 12),
          Expanded(child: _timeCard(selectedCity2, second)),
        ],
      ),
    );
  }

  Widget _timeCard(String city, tz.TZDateTime time) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            city,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              timeText(time),
              style: const TextStyle(
                color: Color(0xFF3949AB),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            dateText(time),
            maxLines: 2,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            offsetText(time),
            style: const TextStyle(
              color: Color(0xFF7E57C2),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _differenceCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.compare_arrows_rounded,
              color: Color(0xFF5E35B1),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TIME DIFFERENCE',
                    style: TextStyle(
                      color: Color(0xFF7E57C2),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    differenceText(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _converterButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: SizedBox(
        height: 58,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConverterScreen(
                  fromLocation: selectedCity1,
                  toLocation: selectedCity2,
                  cityZones: cityZones,
                ),
              ),
            );
          },
          icon: const Icon(Icons.swap_horiz_rounded),
          label: const Text(
            'Open Time Converter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3949AB),
            foregroundColor: Colors.white,
            elevation: 5,
            shadowColor: const Color(0xFF3949AB).withOpacity(.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
      ),
    );
  }
}