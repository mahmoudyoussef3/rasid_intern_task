import 'package:flutter/material.dart';
import 'package:rasid_intern_taks/Features/Portfolio/screen/portfolio.dart';

import 'build_text_field.dart';

class BuildArabicForm extends StatelessWidget {
  const BuildArabicForm({
    super.key,
    required this.arContactController,
    required this.arPersonalInfoController,
    required this.arExperienceController,
    required this.arEducationController,
    required this.arSkillsController,
  });
  final TextEditingController arPersonalInfoController;
  final TextEditingController arContactController;
  final TextEditingController arExperienceController;
  final TextEditingController arEducationController;
  final TextEditingController arSkillsController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuildTextField(
          controller: arPersonalInfoController,
          label: 'الاسم الكامل',
          hint: 'أدخل اسمك الكامل',
          icon: Icons.person,
          maxLines: 1,
          selectedLanguage: Language.arabic,
        ),
        const SizedBox(height: 10),
        BuildTextField(
          controller: arContactController,
          label: 'معلومات الاتصال',
          hint: 'البريد الإلكتروني، الهاتف، LinkedIn',
          icon: Icons.contact_mail,
          maxLines: 1,
          selectedLanguage: Language.arabic,
        ),
        const SizedBox(height: 10),
        BuildTextField(
          controller: arExperienceController,
          label: 'الخبرة المهنية',
          hint: 'صف خبرتك المهنية بإيجاز',
          icon: Icons.work,
          maxLines: 3,
          selectedLanguage: Language.arabic,
        ),
        const SizedBox(height: 10),
        BuildTextField(
          controller: arEducationController,
          label: 'التعليم',
          hint: 'خلفيتك الأكاديمية',
          icon: Icons.school,
          maxLines: 2,
          selectedLanguage: Language.arabic,
        ),
        const SizedBox(height: 10),
        BuildTextField(
          controller: arSkillsController,
          label: 'المهارات',
          hint: 'مهاراتك المهنية',
          icon: Icons.stars,
          maxLines: 2,
          selectedLanguage: Language.arabic,
        ),
      ],
    );
  }
}
