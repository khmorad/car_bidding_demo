import 'package:flutter/material.dart';
import '../models/engine.dart';

class EngineInfoSheet extends StatelessWidget {
  final Engine engine;

  const EngineInfoSheet({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Engine Info',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (engine.size != null)
              _InfoRow(icon: Icons.straighten, label: '${engine.size}L engine'),
            if (engine.driveType != null || engine.transmission != null)
              _InfoRow(
                icon: Icons.settings,
                label: [
                  if (engine.driveType != null) engine.driveType,
                  if (engine.transmission != null) engine.transmission,
                ].where((e) => e != null && e.isNotEmpty).join(' • '),
              ),
            if (engine.fuelType != null)
              _InfoRow(icon: Icons.local_gas_station, label: engine.fuelType!),
            // Add more rows as needed, e.g. horsepower, valves, etc.
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
