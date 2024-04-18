import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/Views/history_page.dart';
import 'package:sqlite_flutter_crud/Views/user_profile.dart';
import 'package:sqlite_flutter_crud/JsonModels/health_result.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';

class HealthCheckPage extends StatefulWidget {
  const HealthCheckPage({Key? key});

  @override
  State<HealthCheckPage> createState() => _HealthCheckPageState();
}

class _HealthCheckPageState extends State<HealthCheckPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _cholesterolController = TextEditingController();
  String healthStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Health Check'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
            icon: const Icon(Icons.access_time),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'Weight (kg):',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter your weight in kg',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Height (cm):',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter your height in cm',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Blood Pressure:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _bpController,
              decoration: const InputDecoration(
                hintText: 'Enter your BP (e.g., 120/80)',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sugar:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _sugarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter your sugar level before eating (mg/dL)',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cholesterol:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _cholesterolController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter your cholesterol level (mg/dL)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _calculateHealthStatus();
              },
              child: const Text('Check'),
            ),
            const SizedBox(height: 20),
            Text(
              healthStatus,
              style: TextStyle(
                fontSize: 20,
                color: healthStatus.contains('good') ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateHealthStatus() async {
    // Get input values
    double weight = double.tryParse(_weightController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;
    String bp = _bpController.text.trim();
    double sugar = double.tryParse(_sugarController.text) ?? 0;
    double cholesterol = double.tryParse(_cholesterolController.text) ?? 0;

    // Calculate BMI
    double bmi = weight / ((height / 100) * (height / 100));

    // Check BP
    String bpStatus = _checkBP(bp);

    // Check Sugar level
    String sugarStatus = _checkSugar(sugar);

    // Check Cholesterol level
    String cholesterolStatus = _checkCholesterol(cholesterol);

    // Determine overall health status
    String status;
    if (bmi >= 18.5 &&
        bmi < 25 &&
        bpStatus == 'Normal' &&
        sugarStatus == 'Normal' &&
        cholesterolStatus == 'Normal') {
      status = 'Your health condition is good';
    } else {
      status = 'Your health condition is not normal.';

      // Append specific conditions if not normal
      if (bmi < 18.5) {
        status += '\nBMI is underweight';
      }
      if (bmi >= 25) {
        status += '\nBMI indicates overweight or obesity';
      }
      if (bpStatus != 'Normal') {
        status += '\nBlood Pressure: $bpStatus';
      }
      if (sugarStatus != 'Normal') {
        status += '\nSugar Level: $sugarStatus';
      }
      if (cholesterolStatus != 'Normal') {
        status += '\nCholesterol: $cholesterolStatus';
      }
    }

    setState(() {
      healthStatus = status;
    });

    // Store health check-up result
    HealthCheck healthCheck = HealthCheck(
      userId: 1, // Assuming user ID 1 for demonstration
      healthStatus: status,
      checkUpDate: DateTime.now().toIso8601String(),
    );

    DatabaseHelper dbHelper = DatabaseHelper();
    int result = await dbHelper.storeHealthCheck(healthCheck);

    if (result != 0) {
      // Health check-up result stored successfully
      print('Health check-up result stored successfully');
    } else {
      // Error occurred while storing health check-up result
      print('Error occurred while storing health check-up result');
    }
  }

  String _checkBP(String bp) {
    List<String> parts = bp.split('/');
    int systolic = int.tryParse(parts[0]) ?? 0;
    int diastolic = int.tryParse(parts[1]) ?? 0;

    if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    } else if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      return 'Elevated';
    } else if ((systolic >= 130 && systolic <= 139) ||
        (diastolic >= 80 && diastolic <= 89)) {
      return 'High Blood Pressure (Hypertension) Stage 1';
    } else if (systolic >= 140 || diastolic >= 90) {
      return 'High Blood Pressure (Hypertension) Stage 2';
    } else if (systolic > 180 || diastolic > 120) {
      return 'Hypertensive Crisis (Emergency care needed)';
    } else {
      return 'Unknown';
    }
  }

  String _checkSugar(double sugar) {
    if (sugar < 140) {
      return 'Normal';
    } else if (sugar >= 140 && sugar <= 199) {
      return 'Prediabetes';
    } else {
      return 'Diabetes';
    }
  }

  String _checkCholesterol(double cholesterol) {
    if (cholesterol < 200) {
      return 'Normal';
    } else if (cholesterol >= 200 && cholesterol < 240) {
      return 'Borderline high';
    } else {
      return 'High';
    }
  }
}
