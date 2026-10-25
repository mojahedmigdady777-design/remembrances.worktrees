import 'package:flutter/material.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B5E20);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "تطبيق خيركم",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // القسم العلوي: الأيقونة، اسم التطبيق، والوصف
              Column(
                children: [
                  const SizedBox(height: 30),

                  // 1. أيقونة المشروع (icon.jpeg)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/images/icon.jpeg',
                        fit: BoxFit.cover,
                        // عرض أيقونة افتراضية في حال عدم وجود الصورة بعد
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.mosque,
                              size: 60,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. اسم التطبيق
                  const Text(
                    "تطبيق خيركم",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Cairo',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 3. وصف التطبيق
                  const Text(
                    "سجل المتابعة الشهرية للعبادات والأعمال الصالحة\nيسهل عليك تنظيم أوقاتك ومتابعة طاعاتك اليومية بكل يسر وسهولة.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.6,
                    ),
                  ),
                ],
              ),

              // القسم السفلي: التوقيع داخل Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_note_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                        children: [
                          TextSpan(text: "إعداد: "),
                          TextSpan(
                            text: "مجاهد مقدادي\nMojahed migdady", // قم باستبدال هذا باسمك
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}