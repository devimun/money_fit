import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';

Widget buildSectionTitle(String title, TextTheme textTheme) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
    child: Text(title, style: textTheme.labelMedium, textAlign: TextAlign.left),
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
  required BuildContext context,
}) {
  return buildSettingsItem(
    icon: icon,
    iconColor: iconColor,
    title: title,
    trailing: Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: context.colors.brandPrimary,
      inactiveTrackColor: context.isDarkMode
          ? context.colors.calendarCellBackground
          : context.colors.border,
    ),
  );
}
