import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shimmer/shimmer.dart';
import '../../../flutter_gen/gen_l10n/app_localizations.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<AttendanceRecord>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    // Get the current admin's office
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get the office for this admin
    final officeSnap = await FirebaseFirestore.instance
        .collection('offices')
        .limit(1)
        .get();

    if (officeSnap.docs.isEmpty) return;
    final officeId = officeSnap.docs.first.id;

    // Get attendance records for this office
    final attendanceSnap = await FirebaseFirestore.instance
        .collection('attendance')
        .where('officeId', isEqualTo: officeId)
        .get();

    final events = <DateTime, List<AttendanceRecord>>{};

    for (final doc in attendanceSnap.docs) {
      final data = doc.data();
      final checkInTime = DateTime.parse(data['checkInAt'] as String);
      final day = DateTime(
        checkInTime.year,
        checkInTime.month,
        checkInTime.day,
      );

      // Get user name from users collection
      String userName = 'Unknown';
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .get();
        userName = userDoc.data()?['name'] ?? 'Unknown';
      } catch (e) {
        print('Error fetching user name: $e');
      }

      final record = AttendanceRecord(
        id: doc.id,
        userId: data['userId'],
        userName: userName,
        officeId: data['officeId'],
        checkInTime: checkInTime,
        checkOutTime: data['checkOutAt'] != null
            ? DateTime.parse(data['checkOutAt'] as String)
            : null,
      );

      if (events[day] == null) events[day] = [];
      events[day]!.add(record);
    }

    setState(() {
      _events = events;
      _isLoading = false;

      // Set focused day to the first day with data, or today if no data
      if (events.isNotEmpty) {
        final firstDayWithData = events.keys.first;
        _focusedDay = firstDayWithData;
        _selectedDay = firstDayWithData;
      }
    });

    // Debug information
    print('Loaded ${attendanceSnap.docs.length} attendance records');
    print('Office ID: $officeId');
    print('Events map has ${events.length} days with data');
    for (final entry in events.entries) {
      print('${entry.key}: ${entry.value.length} records');
    }
    print('Focused day set to: $_focusedDay');
    print('Selected day set to: $_selectedDay');
  }

  List<AttendanceRecord> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadAttendanceData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar<AttendanceRecord>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red),
                holidayTextStyle: TextStyle(color: Colors.red),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),

          // Selected day attendance list
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Select a date to view attendance'))
                : _buildAttendanceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return const Center(child: Text('No attendance records for this date'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final record = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: record.checkOutTime != null
                  ? Colors.green
                  : Colors.orange,
              child: Icon(
                record.checkOutTime != null
                    ? Icons.check_circle
                    : Icons.schedule,
                color: Colors.white,
              ),
            ),
            title: Text(record.userName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check-in: ${_formatTime(record.checkInTime)}'),
                if (record.checkOutTime != null)
                  Text('Check-out: ${_formatTime(record.checkOutTime!)}'),
                if (record.checkOutTime != null)
                  Text(
                    'Duration: ${_calculateDuration(record.checkInTime, record.checkOutTime!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6, // Show 6 shimmer items
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.white),
              title: Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

class AttendanceRecord {
  final String id;
  final String userId;
  final String userName;
  final String officeId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.officeId,
    required this.checkInTime,
    this.checkOutTime,
  });
}
