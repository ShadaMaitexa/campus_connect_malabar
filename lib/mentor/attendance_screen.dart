import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late String department;
  bool loading = true;

  final String today =
      DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    loadMentorDepartment();
  }

  Future<void> loadMentorDepartment() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    department = doc['department'];
    setState(() => loading = false);
  }

  Future<void> markAttendance(
      String studentId, bool present) async {
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(today)
        .set({
      studentId: {
        'present': present,
        'markedBy': FirebaseAuth.instance.currentUser!.uid,
        'department': department,
        'timestamp': Timestamp.now(),
      }
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance – $department"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('department', isEqualTo: department)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students found"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc['name']),
                  trailing: Switch(
                    value: true,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    onChanged: (value) {
                      markAttendance(doc.id, value);
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
