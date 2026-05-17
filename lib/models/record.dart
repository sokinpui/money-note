class Record {
  final int? id;
  final String name;
  final double value;
  final String type; // 'Expense' or 'Income'
  final String category;
  final String? note;
  final DateTime date;

  Record({
    this.id,
    required this.name,
    required this.value,
    required this.type,
    required this.category,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'type': type,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      name: map['name'],
      value: map['value'],
      type: map['type'],
      category: map['category'],
      note: map['note'],
      date: DateTime.parse(map['date']),
    );
  }

  Record copyWith({
    int? id,
    String? name,
    double? value,
    String? type,
    String? category,
    String? note,
    DateTime? date,
  }) {
    return Record(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }
}
