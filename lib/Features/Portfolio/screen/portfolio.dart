import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rasid_intern_taks/Features/Portfolio/widgets/build_arabic_form.dart';
import 'package:rasid_intern_taks/Features/Portfolio/widgets/build_english_form.dart';
import 'package:share_plus/share_plus.dart';

enum Language { arabic, english }

String? _pdfFilePath;

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Language _selectedLanguage = Language.english;
  final _formKey = GlobalKey<FormState>();
  final _enPersonalInfoController = TextEditingController();
  final _enContactController = TextEditingController();
  final _enExperienceController = TextEditingController();
  final _enSkillsController = TextEditingController();
  final _enEducationController = TextEditingController();
  final _arPersonalInfoController = TextEditingController();
  final _arContactController = TextEditingController();
  final _arExperienceController = TextEditingController();
  final _arSkillsController = TextEditingController();
  final _arEducationController = TextEditingController();
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Portfolio Generator',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Select Language: ',
                      style: TextStyle(color: Colors.white),
                    ),
                    ChoiceChip(
                      checkmarkColor: Colors.white,
                      label: const Text(
                        'English',
                        style: TextStyle(color: Colors.white),
                      ),
                      selected: _selectedLanguage == Language.english,
                      selectedColor:
                          const Color(0xff4caf50), // Sky blue for selection
                      backgroundColor:
                          const Color(0xFFBBDEFB), // Light blue background
                      onSelected: (selected) {
                        setState(() {
                          _selectedLanguage = Language.english;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text(
                        'Arabic',
                        style: TextStyle(color: Colors.white),
                      ),
                      selected: _selectedLanguage == Language.arabic,
                      selectedColor: const Color(0xff4caf50),
                      checkmarkColor: Colors.white,
                      backgroundColor: const Color(0xFFBBDEFB),
                      onSelected: (selected) {
                        setState(() {
                          _selectedLanguage = Language.arabic;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                _selectedLanguage == Language.english
                    ? BuildEnglishForm(
                        enContactController: _enContactController,
                        enExperienceController: _enExperienceController,
                        enEducationController: _enEducationController,
                        enSkillsController: _enSkillsController,
                        enPersonalInfoController: _enPersonalInfoController,
                      )
                    : BuildArabicForm(
                        arContactController: _arContactController,
                        arPersonalInfoController: _arPersonalInfoController,
                        arExperienceController: _arExperienceController,
                        arEducationController: _arEducationController,
                        arSkillsController: _arSkillsController,
                      ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: generatePDF,
                  icon: _isClicked
                      ? const SizedBox.shrink()
                      : const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: _isClicked
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Generate & View PDF',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff4caf50), // Deep blue for buttons
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pdfFilePath != null
                      ? () async {
                          await sharePdf(_pdfFilePath!);
                        }
                      : null,
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: Text(
                    'Share PDF',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xffFD9600
                        ), // Sky blue for secondary button
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generatePDF() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isClicked = true;
    });

    final pdf = pw.Document(pageMode: PdfPageMode.outlines);
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final englishFont = await PdfGoogleFonts.robotoRegular();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          buildBackground: (context) => pw.Padding(
            padding: const pw.EdgeInsets.all(0),
            child: pw.Container(),
          ),
        ),
        header: (context) => pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            textDirection: _selectedLanguage == Language.english
                ? pw.TextDirection.ltr
                : pw.TextDirection.rtl,
            _selectedLanguage == Language.english
                ? 'Professional Portfolio'
                : 'السيرة الذاتية المهنية',
            style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
                font: _selectedLanguage == Language.english
                    ? englishFont
                    : arabicFont),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 20),
            child: pw.Column(
              crossAxisAlignment: _selectedLanguage == Language.english
                  ? pw.CrossAxisAlignment.start
                  : pw.CrossAxisAlignment.end,
              children: _buildPortfolioSections(arabicFont),
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/professional_portfolio.pdf');
    await file.writeAsBytes(await pdf.save());
    setState(() {
      _pdfFilePath = file.path;
      _isClicked = false;
    });
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  List<pw.Widget> _buildPortfolioSections(var arabicFont) {
    final personalInfoController = _selectedLanguage == Language.english
        ? _enPersonalInfoController
        : _arPersonalInfoController;
    final contactController = _selectedLanguage == Language.english
        ? _enContactController
        : _arContactController;
    final experienceController = _selectedLanguage == Language.english
        ? _enExperienceController
        : _arExperienceController;
    final educationController = _selectedLanguage == Language.english
        ? _enEducationController
        : _arEducationController;
    final skillsController = _selectedLanguage == Language.english
        ? _enSkillsController
        : _arSkillsController;

    final textDirection = _selectedLanguage == Language.english
        ? pw.TextDirection.ltr
        : pw.TextDirection.rtl;
    final textFont = arabicFont;
    final sectionTitles = _selectedLanguage == Language.english
        ? [
            'Personal Information',
            'Contact Details',
            'Professional Experience',
            'Education',
            'Skills'
          ]
        : [
            'المعلومات الشخصية',
            'بيانات الاتصال',
            'الخبرة المهنية',
            'التعليم',
            'المهارات'
          ];

    return [
      pw.Text(
        sectionTitles[0],
        style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
            font: textFont),
        textDirection: textDirection,
      ),
      pw.Divider(color: PdfColors.blue700),
      pw.Text(
        personalInfoController.text,
        style: pw.TextStyle(fontSize: 16, font: textFont),
        textDirection: textDirection,
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        sectionTitles[1],
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          font: textFont,
          color: PdfColors.blue800,
        ),
        textDirection: textDirection,
      ),
      pw.Text(
        contactController.text,
        style: pw.TextStyle(fontSize: 12, font: textFont),
        textDirection: textDirection,
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        sectionTitles[2],
        style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
            font: textFont),
        textDirection: textDirection,
      ),
      pw.Text(
        experienceController.text,
        style: pw.TextStyle(fontSize: 12, font: textFont),
        textDirection: textDirection,
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        sectionTitles[3],
        style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
            font: textFont),
        textDirection: textDirection,
      ),
      pw.Text(
        educationController.text,
        style: pw.TextStyle(fontSize: 12, font: textFont),
        textDirection: textDirection,
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        sectionTitles[4],
        style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
            font: textFont),
        textDirection: textDirection,
      ),
      pw.Text(
        skillsController.text,
        style: pw.TextStyle(fontSize: 12, font: textFont),
        textDirection: textDirection,
      ),
    ];
  }

  Future<void> sharePdf(String pdfPath) async {
    try {
      await Share.shareXFiles([XFile(pdfPath)],
          text: 'Check out this PDF file!');
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }
}
