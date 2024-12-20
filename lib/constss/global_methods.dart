import 'package:flutter/material.dart';

Future<void> showError({
  required context,
  required String title,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Row(
          children: [
            Text("An error accoured "),
          ],
        ),
        content: Text(title),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Ok",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showMessageDialog({
  required String title,
  required BuildContext ctx,
  required String content,
  required Function ontapok,
}) async {
  return showDialog(
    context: ctx,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: const Text(
            "cancel",
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            ontapok();
            if (Navigator.canPop(ctx)) {
              Navigator.pop(ctx);
            }
          },
          child: const Text(
            "Ok",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}
