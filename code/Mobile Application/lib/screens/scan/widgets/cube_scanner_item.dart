import 'package:flutter/material.dart';
import 'package:sm_iot_lab/constants/colors.dart';

class CubeScannerItem extends StatefulWidget {
  final VoidCallback onTap;
  final String name;
  final bool underline;

  const CubeScannerItem({
    super.key,
    required this.name,
    required this.underline,
    required this.onTap,
  });

  @override
  State<CubeScannerItem> createState() => _CubeScannerItemState();
}

class _CubeScannerItemState extends State<CubeScannerItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: widget.underline
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.gray,
                    width: 1.5, // Underline thickness
                  ),
                ),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const IconButton(
              padding: EdgeInsets.all(0),
              onPressed: null,
              icon: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.blue,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
