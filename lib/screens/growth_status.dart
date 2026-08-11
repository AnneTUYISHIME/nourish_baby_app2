import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class GrowthStatusScreen extends StatefulWidget {
  final String babyId;
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
  final TextEditingController _weightInput = TextEditingController();
  final TextEditingController _heightInput = TextEditingController();
  bool _saving = false;
  bool _seeded = false;

  CollectionReference get _historyRef => FirebaseFirestore.instance
      .collection("growth_status")
      .doc(widget.babyId)
      .collection("history");

  @override
  void initState() {
    super.initState();
    _weightInput.text = widget.weight > 0 ? widget.weight.toString() : '';
    _heightInput.text = widget.height > 0 ? widget.height.toString() : '';
    _seedFirstEntryIfEmpty();
  }

  /// If this baby has no logged growth history yet, seed it with the
  /// weight/height already on file so the chart isn't empty on first visit.
  Future<void> _seedFirstEntryIfEmpty() async {
    if (_seeded || widget.weight <= 0 || widget.height <= 0) return;
    final existing = await _historyRef.limit(1).get();
    if (existing.docs.isEmpty) {
      await _addEntry(widget.weight, widget.height, silent: true);
    }
    _seeded = true;
  }

  double _bmiOf(double weight, double height) {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Returns (label, color, plain-language explanation) for a BMI value.
  (String, Color, String) _statusFor(double bmi) {
    if (bmi <= 0) {
      return ("No data yet", Colors.grey, "Log a measurement below to see your baby's status.");
    } else if (bmi < 14) {
      return (
        "Underweight",
        Colors.redAccent,
        "Your baby's weight is a little low for their height. Try nutrient-rich foods like mashed avocado, sweet potatoes, or bananas, and mention this at your next checkup.",
      );
    } else if (bmi <= 17) {
      return (
        "On Track 💖",
        Colors.green,
        "Great job! Your baby's weight and height are growing in a healthy balance. Keep up the good feeding and care routine.",
      );
    } else {
      return (
        "Gaining Quickly",
        Colors.orange,
        "Your baby is gaining weight a bit fast for their height. Offer a balanced mix of fruits, vegetables, and milk, and it's worth mentioning at your next checkup.",
      );
    }
  }

  Future<void> _addEntry(double weight, double height, {bool silent = false}) async {
    final bmi = _bmiOf(weight, height);
    final payload = {
      "babyId": widget.babyId,
      "name": widget.name,
      "age": widget.age,
      "weight": weight,
      "height": height,
      "bmi": bmi.toStringAsFixed(2),
      "timestamp": FieldValue.serverTimestamp(),
    };

    // Keep a "latest snapshot" doc too — this is what the admin dashboard reads.
    await FirebaseFirestore.instance
        .collection("growth_status")
        .doc(widget.babyId)
        .set(payload);

    await _historyRef.add(payload);

    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Measurement logged!"), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _logMeasurement() async {
    final weight = double.tryParse(_weightInput.text.trim());
    final height = double.tryParse(_heightInput.text.trim());

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid weight and height")),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _addEntry(weight, height);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error saving: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _weightInput.dispose();
    _heightInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📊 ${widget.name.isEmpty ? 'Growth' : widget.name}'s Growth")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _historyRef.orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final entries = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            final ts = data['timestamp'] as Timestamp?;
            return _GrowthEntry(
              date: ts?.toDate() ?? DateTime.now(),
              weight: (data['weight'] as num?)?.toDouble() ?? 0,
              height: (data['height'] as num?)?.toDouble() ?? 0,
              bmi: double.tryParse(data['bmi']?.toString() ?? '') ?? 0,
            );
          }).toList();

          final latest = entries.isNotEmpty ? entries.last : null;
          final latestBmi = latest?.bmi ?? 0;
          final (statusLabel, statusColor, statusExplanation) = _statusFor(latestBmi);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FunPill(label: "📅 ${widget.age} mo", color: AppColors.blue),
                    FunPill(label: "⚖️ ${latest?.weight.toStringAsFixed(1) ?? '--'} kg", color: AppColors.teal),
                    FunPill(label: "📏 ${latest?.height.toStringAsFixed(1) ?? '--'} cm", color: AppColors.purple),
                    FunPill(label: "📊 BMI ${latestBmi > 0 ? latestBmi.toStringAsFixed(1) : '--'}", color: AppColors.orange),
                  ],
                ),
                const SizedBox(height: 20),

                // Status banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Text(statusLabel,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: statusColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(statusExplanation, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // "What is BMI" explainer
                _explainerCard(
                  emoji: "🧠",
                  title: "What does BMI mean for my baby?",
                  color: AppColors.blue,
                  body:
                      "BMI (Body Mass Index) compares your baby's weight to their height. It's a quick way to check "
                      "if they're growing in a healthy balance — not too light, not too heavy for how tall they are. "
                      "For babies, a BMI roughly between 14–17 is generally considered a healthy range, but every baby "
                      "is different, so always check with your pediatrician if you're worried.",
                ),
                const SizedBox(height: 20),

                // Log new measurement
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border(left: BorderSide(color: AppColors.pink, width: 5)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FunSectionTitle(emoji: "📏", title: "Log Today's Measurement", color: AppColors.pink),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _weightInput,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: "Weight (kg)", prefixIcon: Icon(Icons.monitor_weight_outlined)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _heightInput,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: "Height (cm)", prefixIcon: Icon(Icons.height)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _logMeasurement,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.add_chart),
                          label: Text(_saving ? "Saving..." : "Log Measurement"),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink, padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (entries.length < 2)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        const Text("📈", style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(
                          "Log a couple more measurements to start seeing your baby's growth trend here!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                else ...[
                  FunSectionTitle(emoji: "📈", title: "Weight Over Time", color: AppColors.teal),
                  SizedBox(
                    height: 220,
                    child: _GrowthLineChart(entries: entries, yLabel: "kg", valueOf: (e) => e.weight, color: AppColors.teal),
                  ),
                  _readingTip(
                    "A line that climbs steadily is exactly what you want to see — it means your baby is gaining weight over time. "
                    "A flat or dropping line across several entries is worth mentioning to your pediatrician.",
                  ),
                  const SizedBox(height: 24),
                  FunSectionTitle(emoji: "📏", title: "Height Over Time", color: AppColors.blue),
                  SizedBox(
                    height: 220,
                    child: _GrowthLineChart(entries: entries, yLabel: "cm", valueOf: (e) => e.height, color: AppColors.blue),
                  ),
                  _readingTip(
                    "Height should rise gradually and steadily — babies don't grow taller in a straight line, so small "
                    "plateaus between measurements are completely normal.",
                  ),
                ],

                const SizedBox(height: 28),
                if (entries.isNotEmpty) ...[
                  const FunSectionTitle(emoji: "🗒️", title: "History", color: AppColors.purple),
                  ...entries.reversed.take(10).map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          leading: const CircleAvatar(backgroundColor: Color(0x22A06BFF), child: Icon(Icons.event, color: AppColors.purple)),
                          title: Text(DateFormat('MMM d, yyyy').format(e.date)),
                          subtitle: Text("⚖️ ${e.weight.toStringAsFixed(1)} kg  ·  📏 ${e.height.toStringAsFixed(1)} cm  ·  BMI ${e.bmi.toStringAsFixed(1)}"),
                        ),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _explainerCard({required String emoji, required String title, required String body, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15))),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  Widget _readingTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("💡 ", style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[700], fontStyle: FontStyle.italic, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthEntry {
  final DateTime date;
  final double weight;
  final double height;
  final double bmi;
  _GrowthEntry({required this.date, required this.weight, required this.height, required this.bmi});
}

class _GrowthLineChart extends StatelessWidget {
  final List<_GrowthEntry> entries;
  final String yLabel;
  final double Function(_GrowthEntry) valueOf;
  final Color color;

  const _GrowthLineChart({
    required this.entries,
    required this.yLabel,
    required this.valueOf,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (int i = 0; i < entries.length; i++) FlSpot(i.toDouble(), valueOf(entries[i])),
    ];
    final values = spots.map((s) => s.y).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) - 1).clamp(0, double.infinity).toDouble();
    final maxY = values.reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (entries.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.15)),
            spots: spots,
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)} $yLabel', style: const TextStyle(fontSize: 11)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('MMM d').format(entries[i].date), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }
}
