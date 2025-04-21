import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class GrowthStatusScreen extends StatelessWidget {
  final String babyName;
  final int babyAgeMonths;
  final double babyWeight;
  final double babyHeight;

  GrowthStatusScreen({
    super.key,
    required this.babyName,
    required this.babyAgeMonths,
    required this.babyWeight,
    required this.babyHeight,
  });

  // Simulated monthly growth data
  final List<Map<String, dynamic>> growthData = [
    {"month": 1, "weight": 3.5, "height": 50.0},
    {"month": 2, "weight": 4.2, "height": 54.0},
    {"month": 3, "weight": 5.0, "height": 57.0},
    {"month": 4, "weight": 5.8, "height": 60.0},
    {"month": 5, "weight": 5.5, "height": 59.0}, // Simulate drop
    {"month": 6, "weight": 6.2, "height": 63.0},
  ];

  double calculateBMI(double weight, double heightCm) {
    double heightM = heightCm / 100;
    return weight / pow(heightM, 2);
  }

  String getAdvice(double currentWeight, double prevWeight, double currentHeight, double prevHeight) {
    if (currentWeight < prevWeight || currentHeight < prevHeight) {
      return "⚠️ Growth has slightly dropped. Consider a pediatric checkup or updating the meal plan.";
    }
    return "✅ Growth is progressing well! Keep up the great work!";
  }

  @override
  Widget build(BuildContext context) {
    final latest = growthData.last;
    final previous = growthData[growthData.length - 2];
    final bmi = calculateBMI(latest['weight'], latest['height']);
    final advice = getAdvice(latest['weight'], previous['weight'], latest['height'], previous['height']);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("📊 Growth Stats of $babyName", style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Baby Growth Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),

            // Chart
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}m', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  barGroups: growthData.map((data) {
                    final month = data['month'] as int;
                    final weight = (data['weight'] as num).toDouble();
                    final height = (data['height'] as num).toDouble();

                    return BarChartGroupData(
                      x: month,
                      barRods: [
                        BarChartRodData(toY: weight, color: Colors.blue, width: 7),
                        BarChartRodData(toY: height / 10, color: Colors.green, width: 7),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Stats
            Text("Latest Weight: ${latest['weight']} kg", style: const TextStyle(fontSize: 16)),
            Text("Latest Height: ${latest['height']} cm", style: const TextStyle(fontSize: 16)),
            Text("BMI: ${bmi.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(advice, style: TextStyle(fontSize: 14, color: bmi < 14 ? Colors.red : Colors.green)),
          ],
        ),
      ),
    );
  }
}
