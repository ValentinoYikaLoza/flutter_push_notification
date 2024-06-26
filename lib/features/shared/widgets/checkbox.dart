import 'package:flutter/material.dart';


class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final void Function(bool value) onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: value
                    ? const Color(0xFF0e9bcc)
                    : const Color(0xFF181A37),
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color:
                      value ? const Color(0xFF0e9bcc) : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          if (label != null)
            const SizedBox(
              width: 10,
            ),
          if (label != null)
            Text(
              label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                height: 22 / 14,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            )
        ],
      ),
    );
  }
}
