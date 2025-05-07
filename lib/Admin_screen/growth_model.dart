class GrowthStatus {
  String id;
  String babyName;
  double height;
  double weight;
  int month;
  double bmi;
  String advice;

  GrowthStatus({
    required this.id,
    required this.babyName,
    required this.height,
    required this.weight,
    required this.month,
    required this.bmi,
    required this.advice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyName': babyName,
      'height': height,
      'weight': weight,
      'month': month,
      'bmi': bmi,
      'advice': advice,
    };
  }

  factory GrowthStatus.fromMap(Map<String, dynamic> map) {
    return GrowthStatus(
      id: map['id'],
      babyName: map['babyName'],
      height: map['height'],
      weight: map['weight'],
      month: map['month'],
      bmi: map['bmi'],
      advice: map['advice'],
    );
  }
}
