import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class ConverterScreen extends StatefulWidget {
  final String fromLocation;
  final String toLocation;
  final Map<String, String> cityZones;

  const ConverterScreen({
    super.key,
    required this.fromLocation,
    required this.toLocation,
    required this.cityZones,
  });

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late String fromLocation;
  late String toLocation;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    fromLocation = widget.fromLocation;
    toLocation = widget.toLocation;
  }

  tz.TZDateTime convertedTime() {
    final fromZone = tz.getLocation(widget.cityZones[fromLocation]!);
    final toZone = tz.getLocation(widget.cityZones[toLocation]!);

    final source = tz.TZDateTime(
      fromZone,
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return tz.TZDateTime.from(source, toZone);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3949AB),
              secondary: Color(0xFF7E57C2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3949AB),
              secondary: Color(0xFF7E57C2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String selectedDateText() {
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

    return '${months[selectedDate.month - 1]} '
        '${selectedDate.day}, ${selectedDate.year}';
  }

  String dayText() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return days[selectedDate.weekday - 1];
  }

  String timeText(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String resultTime(tz.TZDateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String resultDate(tz.TZDateTime time) {
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

  String resultOffset(tz.TZDateTime time) {
    final offset = time.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';

    final hours = offset.inHours.abs().toString().padLeft(2, '0');

    final minutes =
    (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    return 'UTC$sign$hours:$minutes';
  }

  void swap() {
    setState(() {
      final temp = fromLocation;
      fromLocation = toLocation;
      toLocation = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = convertedTime();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF3949AB),
          ),
        ),
        title: const Text(
          'Time Converter',
          style: TextStyle(
            color: Color(0xFF202124),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Convert Any Time',
              style: TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.w900,
                color: Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a date, exact time and locations.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 22),

            _locationBox(),

            const SizedBox(height: 16),

            _dateTimeBox(),

            const SizedBox(height: 20),

            _resultCard(result),
          ],
        ),
      ),
    );
  }

  Widget _locationBox() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          _locationDropdown(
            'From',
            fromLocation,
            Icons.flight_takeoff_rounded,
                (value) {
              if (value != null) {
                setState(() => fromLocation = value);
              }
            },
          ),

          const SizedBox(height: 8),

          GestureDetector(
            onTap: swap,
            child: Container(
              height: 43,
              width: 43,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3949AB),
                    Color(0xFF7E57C2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_vert_rounded,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 8),

          _locationDropdown(
            'To',
            toLocation,
            Icons.flight_land_rounded,
                (value) {
              if (value != null) {
                setState(() => toLocation = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _locationDropdown(
      String label,
      String value,
      IconData icon,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF5E35B1),
        ),
        filled: true,
        fillColor: const Color(0xFFF7F6FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      items: widget.cityZones.keys.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateTimeBox() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Date & Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _selectionTile(
                  Icons.calendar_month_rounded,
                  dayText(),
                  selectedDateText(),
                  pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _selectionTile(
                  Icons.access_time_rounded,
                  'Exact Time',
                  timeText(selectedTime),
                  pickTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectionTile(
      IconData icon,
      String title,
      String value,
      VoidCallback onTap,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F6FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF5E35B1),
              size: 24,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(tz.TZDateTime result) {
    return Container(
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
          const Text(
            'CONVERTED LOCAL TIME',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            toLocation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              resultTime(result),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            resultDate(result),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              resultOffset(result),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '$fromLocation  →  $toLocation',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}