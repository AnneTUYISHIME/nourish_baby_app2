import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthStatusScreen extends StatefulWidget {
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

  @override
  _GrowthStatusScreenState createState() => _GrowthStatusScreenState();
}

class _GrowthStatusScreenState extends State<GrowthStatusScreen> {
  late double currentWeight;
  late double currentHeight;

  @override
  void initState() {
    super.initState();
    currentWeight = widget.weight;
    currentHeight = widget.height;
  }

  double calculateBMI() {
    final heightInMeters = currentHeight / 100;
    return currentWeight / (heightInMeters * heightInMeters);
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
      FlSpot(1, currentWeight - 2),
      FlSpot(2, currentWeight - 1.5),
      FlSpot(3, currentWeight - 1),
      FlSpot(4, currentWeight - 0.5),
      FlSpot(widget.age.toDouble(), currentWeight),
    ];
  }

  List<FlSpot> getHeightSpots() {
    return [
      FlSpot(1, currentHeight - 10),
      FlSpot(2, currentHeight - 7),
      FlSpot(3, currentHeight - 5),
      FlSpot(4, currentHeight - 2),
      FlSpot(widget.age.toDouble(), currentHeight),
    ];
  }

  List<FlSpot> getCombinedGrowthSpots() {
    return [
      FlSpot(currentWeight - 2, currentHeight - 10),
      FlSpot(currentWeight - 1.5, currentHeight - 7),
      FlSpot(currentWeight - 1, currentHeight - 5),
      FlSpot(currentWeight - 0.5, currentHeight - 2),
      FlSpot(currentWeight, currentHeight),
    ];
  }

  Future<void> sendGrowthDataToFirebase(BuildContext context) async {
    final bmi = calculateBMI();

    try {
      final docRef = FirebaseFirestore.instance
          .collection("growth_status")
          .doc(widget.babyId.toString());

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({
          "babyId": widget.babyId,
          "name": widget.name,
          "age": widget.age,
          "weight": currentWeight,
          "height": currentHeight,
          "bmi": bmi.toStringAsFixed(2),
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Growth data updated in Firebase!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await docRef.set({
          "babyId": widget.babyId,
          "name": widget.name,
          "age": widget.age,
          "weight": currentWeight,
          "height": currentHeight,
          "bmi": bmi.toStringAsFixed(2),
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Growth data added to Firebase!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Firebase Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error sending data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            Text("👶 Baby: ${widget.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("📅 Age: ${widget.age} months"),
            Text("⚖️ Weight: $currentWeight kg"),
            Text("📏 Height: $currentHeight cm"),
            const SizedBox(height: 10),
            Text("📊 BMI: ${bmi.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            const Text("🩺 Advice:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(advice, style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            const SizedBox(height: 30),
            const Text("📈 Weight Progress", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 220, child: LineChartWidget(spots: getWeightSpots(), yLabel: "kg", age: widget.age)),
            const SizedBox(height: 30),
            const Text("📏 Height Progress", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 220, child: LineChartWidget(spots: getHeightSpots(), yLabel: "cm", age: widget.age)),
            const SizedBox(height: 30),
            const Text("🔄 Weight vs Height (Combined)", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 250, child: ScatterChartWidget(spots: getCombinedGrowthSpots())),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => sendGrowthDataToFirebase(context),
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Update Growth Data (Firebase)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;
  final String yLabel;
  final int age;

  const LineChartWidget({
    Key? key,
    required this.spots,
    required this.yLabel,
    required this.age,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 1,
        maxX: age < 12 ? age.toDouble() : 12,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.pinkAccent,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.pinkAccent.withOpacity(0.2),
            ),
            spots: spots,
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toStringAsFixed(0)} $yLabel', style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final valid = value.toInt();
                if (valid >= 1 && valid <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('$valid mo', style: const TextStyle(fontSize: 12)),
                  );
                }
                return const SizedBox.shrink();
              },
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

  const ScatterChartWidget({Key? key, required this.spots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: spots
            .map((spot) => ScatterSpot(
                  spot.x,
                  spot.y,
                  dotPainter: FlDotCirclePainter(
                    radius: 6,
                    color: Colors.teal,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  ),
                ))
            .toList(),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text('${value.toInt()} cm'),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('${value.toInt()} kg'),
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: spots.first.x - 2,
        maxX: spots.last.x + 2,
        minY: spots.first.y - 5,
        maxY: spots.last.y + 5,
      ),
    );
  }
}
