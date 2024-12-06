import 'package:flutter/material.dart';

import '../screen/portfolio.dart';
import 'build_text_field.dart';

class BuildEnglishForm extends StatelessWidget {
  const BuildEnglishForm({
    super.key,
    required this.enContactController,
    required this.enExperienceController,
    required this.enEducationController,
    required this.enSkillsController,
    required this.enPersonalInfoController,
  });
  final TextEditingController enPersonalInfoController;
  final TextEditingController enContactController;
  final TextEditingController enExperienceController;
  final TextEditingController enEducationController;
  final TextEditingController enSkillsController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuildTextField(
          controller: enPersonalInfoController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person,
          maxLines: 1,
          selectedLanguage: Language.english,
        ),
        const SizedBox(height: 10),
        BuildTextField(
          controller: enContactController,
          label: 'Contact Information',
          hint: 'Email, Phone, LinkedIn',
          icon: Icons.contact_mail,
          maxLines: 1,
          selectedLanguage: Language.english,
        ),
        const SizedBox(height: 10),
        BuildTextField(
          controller: enExperienceController,
          label: 'Work Experience',
          hint: 'Briefly describe your professional experience',
          icon: Icons.work,
          maxLines: 3,
          selectedLanguage: Language.english,
        ),
        const SizedBox(height: 10),
        BuildTextField(
          controller: enEducationController,
          label: 'Education',
          hint: 'Your academic background',
          icon: Icons.school,
          maxLines: 2,
          selectedLanguage: Language.english,
        ),
        const SizedBox(height: 10),
        BuildTextField(
          controller: enSkillsController,
          label: 'Skills',
          hint: 'Your professional skills',
          icon: Icons.stars,
          maxLines: 2,
          selectedLanguage: Language.english,
        ),
      ],
    );
  }
}
