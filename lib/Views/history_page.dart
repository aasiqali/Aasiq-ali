import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/JsonModels/health_result.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<HealthCheck> healthChecks = [];

  @override
  void initState() {
    super.initState();
    fetchHealthChecks();
  }

  Future<void> fetchHealthChecks() async {
    try {
      final db = DatabaseHelper();
      final List<HealthCheck> fetchedHealthChecks = await db.getHealthChecks();
      setState(() {
        healthChecks = fetchedHealthChecks;
      });
    } catch (e) {
      print('Error fetching health checks: $e');
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort the healthChecks list by checkUpDate in descending order
    healthChecks.sort((a, b) => b.checkUpDate.compareTo(a.checkUpDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('History Page'),
      ),
      body: Center(
        child: healthChecks.isEmpty
            ? const Text('No health checks found')
            : ListView.builder(
                itemCount: healthChecks.length,
                itemBuilder: (context, index) {
                  final healthCheck = healthChecks[index];
                  return ListTile(
                    title: Text('Health Status: ${healthCheck.healthStatus}'),
                    subtitle: Text('Check Up Date: ${healthCheck.checkUpDate}'),
                  );
                },
              ),
      ),
    );
  }
}
