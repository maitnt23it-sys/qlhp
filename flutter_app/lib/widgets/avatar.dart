import 'dart:convert';
import 'package:material_ui/material_ui.dart';

class Avatar extends StatelessWidget {
  final String base64Image;
  final double radius;
  const Avatar({super.key, required this.base64Image, this.radius = 28});

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    if (base64Image.isNotEmpty) {
      try {
        provider = MemoryImage(base64Decode(base64Image));
      } catch (_) {}
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: provider,
      child: provider == null ? Icon(Icons.person, size: radius) : null,
    );
  }
}
