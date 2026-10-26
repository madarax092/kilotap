import 'package:flutter/material.dart';

/// The one look for an empty section or list: plain grey text on the page
/// background, no card or border (the collector dashboard's Assigned Route
/// style). Set [centered] for a whole-page empty message.
class EmptySectionText extends StatelessWidget {
  final String message;
  final EdgeInsets padding;
  final bool centered;

  const EmptySectionText(
    this.message, {
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.centered = false,
  });

  static const TextStyle style =
      TextStyle(fontSize: 14, color: Color(0xFF6B7280));

  @override
  Widget build(BuildContext context) {
    final text = Padding(
      padding: centered ? const EdgeInsets.all(24) : padding,
      child: Text(message,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: style),
    );
    return centered ? Center(child: text) : text;
  }
}
