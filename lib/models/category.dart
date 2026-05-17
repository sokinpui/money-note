import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final String iconName;
  final String type; // 'Expense' or 'Income'

  Category({
    this.id,
    required this.name,
    required this.iconName,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'type': type,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      iconName: map['iconName'],
      type: map['type'],
    );
  }

  static IconData getIconData(String name) {
    switch (name) {
      case 'fitness_center': return Icons.fitness_center;
      case 'toys': return Icons.toys;
      case 'book': return Icons.book;
      case 'directions_bus': return Icons.directions_bus;
      case 'checkroom': return Icons.checkroom;
      case 'restaurant': return Icons.restaurant;
      case 'photo': return Icons.photo;
      case 'phone_android': return Icons.phone_android;
      case 'movie': return Icons.movie;
      case 'devices': return Icons.devices;
      case 'payments': return Icons.payments;
      case 'category': return Icons.category;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'home': return Icons.home;
      case 'pets': return Icons.pets;
      case 'work': return Icons.work;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'medical_services': return Icons.medical_services;
      case 'school': return Icons.school;
      default: return Icons.category;
    }
  }
}
