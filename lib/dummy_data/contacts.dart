import 'dart:math';

import '../core/models/models.dart';

final _random = Random();

/// All contacts saved in user's phone
final List<Contact> contacts = List<Contact>.generate(
  30,
  (index) => Contact(
    name: 'User ${++index}',
    phNumber: '+91-987654321',
  ),
)..sort((a, b) => a.name.compareTo(b.name));
