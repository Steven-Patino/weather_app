import 'package:flutter/material.dart';

Color _fade(Color color, double opacity) =>
    color.withAlpha((255 * opacity).round());

class WeatherSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onLocationRequested;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onLocationRequested,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              _fade(Colors.white, 0.07),
              _fade(Colors.white, 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: _fade(Colors.white, 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Buscar ciudad...',
                  hintStyle: TextStyle(color: _fade(Colors.white, 0.72)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => onSearch(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  _ActionButton(
                    icon: Icons.search,
                    onPressed: onSearch,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    icon: Icons.my_location,
                    onPressed: onLocationRequested,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _fade(Colors.white, 0.06),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}
