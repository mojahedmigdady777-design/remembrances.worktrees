import 'package:flutter/material.dart';

class CustomHabitDialog extends StatefulWidget {
  const CustomHabitDialog({super.key});

  @override
  State<CustomHabitDialog> createState() =>
      _CustomHabitDialogState();
}

class _CustomHabitDialogState
    extends State<CustomHabitDialog> {

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      title: const Text("إضافة عبادة"),

      content: TextField(

        controller: controller,

        decoration: const InputDecoration(
          hintText: "اسم العبادة",
        ),

      ),

      actions: [

        TextButton(

          onPressed: (){

            Navigator.pop(context);

          },

          child: const Text("إلغاء"),

        ),

        ElevatedButton(

          onPressed: (){

            Navigator.pop(
              context,
              controller.text,
            );

          },

          child: const Text("إضافة"),

        ),

      ],

    );

  }

}