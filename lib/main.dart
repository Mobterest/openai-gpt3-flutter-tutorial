import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';
import 'package:openai_client/openai_client.dart';
import 'package:openai_gpt3_flutter_tutorial/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
              fontFamily: GoogleFonts.quicksand().fontFamily,
              bodyColor: Colors.white70),
          inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.white24)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 3, color: Colors.white54))),
          hintColor: Colors.white70),
      home: const Main(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final TextEditingController topicController = TextEditingController();
  final TextEditingController keywordController = TextEditingController();
  String selectedLangauge = Languages.english.name;
  String resultCompletion = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackPrimaryColor,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderWidget(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputWidget(
                  controller: topicController,
                  minLines: 4,
                  hintText: hintTopic,
                  hintMaxLines: 4,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputWidget(
                  controller: keywordController,
                  minLines: 2,
                  hintText: hintKeyword,
                  hintMaxLines: 4,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 10.0),
                child: Row(
                  children: [
                    const Text(
                      "Language",
                      style: TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 200,
                      child: LanguagePickerDropdown(
                        initialValue: Languages.english,
                        itemBuilder: ((language) => DropdownMenuItem(
                                child: Text(
                              language.name,
                              style: const TextStyle(
                                  color: brandColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                        onValuePicked: (Language language) {
                          setState(() {
                            selectedLangauge = language.name;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    sendPrompt();
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(400, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text(
                    buttonText,
                    style: TextStyle(fontSize: 18),
                  )),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SelectableText(
                  resultCompletion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: brandColor, fontSize: 18),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  sendPrompt() async {
    final client = OpenAIClient(
        configuration: const OpenAIConfiguration(apiKey: apiKey),
        enableLogging: true);
    final completion = await client.completions
        .create(
            model: 'text-davinci-002',
            temperature: 0,
            maxTokens: 500,
            prompt: generatedPrompt
                .replaceAll("SELECTEDLANG", selectedLangauge)
                .replaceAll("TOPIC", topicController.text)
                .replaceAll("KEYWORD", keywordController.text))
        .data;

    setState(() {
      resultCompletion = completion.choices[0].text;
      topicController.clear();
      keywordController.clear();
    });
  }
}

//Header
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Column(
          children: const [
            Text(
              appTitle,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                instruction,
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ));
  }
}

class InputWidget extends StatefulWidget {
  final TextEditingController controller;
  final int minLines;
  final String hintText;
  final int hintMaxLines;
  const InputWidget(
      {Key? key,
      required this.controller,
      required this.minLines,
      required this.hintText,
      required this.hintMaxLines})
      : super(key: key);

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      minLines: widget.minLines,
      maxLines: null,
      decoration: InputDecoration(
          hintText: widget.hintText, hintMaxLines: widget.hintMaxLines),
    );
  }
}
