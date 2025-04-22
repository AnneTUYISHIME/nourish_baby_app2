import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GrowthStatusScreen extends StatelessWidget {
  final int babyId;
  final String name;
  final int age;
  final double weight;
  final double height;

  const GrowthStatusScreen({
    Key? key,
    required this.babyId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
  }) : super(key: key);

  double calculateBMI() {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String getHealthAdvice(double bmi) {
    if (bmi < 14) {
      return "Your baby may be underweight. Consider nutritious foods like mashed avocado, sweet potatoes, or bananas. Please consult a pediatrician.";
    } else if (bmi >= 14 && bmi <= 17) {
      return "Great job! Your baby’s growth is on track. Keep up the good feeding and care routines 💖";
    } else {
      return "Your baby may be gaining weight quickly. Offer a balanced mix of fruits and vegetables, and consult a pediatrician.";
    }
  }

  List<FlSpot> getWeightSpots() {
    return [
      FlSpot(1, weight - 2),
      FlSpot(2, weight - 1.5),
      FlSpot(3, weight - 1),
      FlSpot(4, weight - 0.5),
      FlSpot(age.toDouble(), weight),
    ];
  }

  List<FlSpot> getHeightSpots() {
    return [
      FlSpot(1, height - 10),
      FlSpot(2, height - 7),
      FlSpot(3, height - 5),
      FlSpot(4, height - 2),
      FlSpot(age.toDouble(), height),
    ];
  }

  List<FlSpot> getCombinedGrowthSpots() {
    return [
      FlSpot(weight - 2, height - 10),
      FlSpot(weight - 1.5, height - 7),
      FlSpot(weight - 1, height - 5),
      FlSpot(weight - 0.5, height - 2),
      FlSpot(weight, height),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bmi = calculateBMI();
    final advice = getHealthAdvice(bmi);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Growth Status", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👶 Baby: $name", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("📅 Age: $age months"),
            Text("⚖️ Weight: $weight kg"),
            Text("📏 Height: $height cm"),
            const SizedBox(height: 10),
            Text("📊 BMI: ${bmi.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("🩺 Advice:", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(advice, style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            const SizedBox(height: 30),

            const Text("📈 Weight Progress", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 220, child: LineChartWidget(spots: getWeightSpots(), yLabel: "kg")),

            const SizedBox(height: 30),
            const Text("📏 Height Progress", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 220, child: LineChartWidget(spots: getHeightSpots(), yLabel: "cm")),

            const SizedBox(height: 30),
            const Text("🔄 Weight vs Height (Combined)", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 250, child: ScatterChartWidget(spots: getCombinedGrowthSpots())),
          ],
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;
  final String yLabel;

  const LineChartWidget({Key? key, required this.spots, required this.yLabel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 1,
        maxX: 12,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.pinkAccent,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: Colors.pinkAccent.withOpacity(0.2)),
            spots: spots,
          )
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
              return Text("${value.toStringAsFixed(0)} $yLabel", style: const TextStyle(fontSize: 12));
            }),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text("${value.toInt()} mo"),
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
      ),
    );
  }
}

class ScatterChartWidget extends StatelessWidget {
  final List<FlSpot> spots;

  const ScatterChartWidget({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
       scatterSpots: spots.map((spot) => ScatterSpot(
  spot.x,
  spot.y,
  dotPainter: FlDotCirclePainter(
    radius: 6,
    color: Colors.teal,
    strokeWidth: 1,
    strokeColor: Colors.white,
  ),
)).toList(),

        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text("${value.toInt()} cm"),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text("${value.toInt()} kg"),
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: spots.first.x - 2,
        maxX: spots.last.x + 2,
        minY: spots.first.y - 10,
        maxY: spots.last.y + 10,
      ),
    );
  }
}
