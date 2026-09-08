import 'package:flutter/material.dart';

Future<void> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
  String confirmText = '확인',
  String cancelText = '취소',
  bool barrierDismissible = false, //바깥 영역 터치 동작 설정
}) {
  return showDialog<void>(
    context: context,

    // false: 팝업 바깥을 눌러도 닫히지 않음
    // true: 팝업 바깥을 누르면 닫힘
    barrierDismissible: barrierDismissible,

    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
              child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
              child: Text(confirmText),
          ),
        ],
      );
    },
  );
}