import 'package:flutter/material.dart';

Widget buildSectionTitle(String title, TextTheme textTheme) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
    child: Text(
      title,
      style: textTheme.titleSmall?.copyWith(color: const Color(0xFF6B7280)),
    ),
  );
}

Widget buildSettingsCard(List<Widget> children) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
    child: Column(children: children),
  );
}

Widget buildSettingsItem({
  required IconData icon,
  required Color iconColor,
  required String title,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: Icon(icon, size: 24, color: iconColor),
    title: Text(title),
    trailing: trailing,
    onTap: onTap,
  );
}

Widget buildSwitchItem({
  required IconData icon,
  required Color iconColor,
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return buildSettingsItem(
    icon: icon,
    iconColor: iconColor,
    title: title,
    trailing: Switch(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF825A3D),
      inactiveTrackColor: const Color(0xFFD1D5DB),
    ),
  );
}
