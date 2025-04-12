import 'package:aiassistant/feature_box.dart';
import 'package:aiassistant/pallete.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final speechToText = SpeechToText();
  String lastWords = '';
  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  final messageController = TextEditingController();
  @override
  void dispose() {
    messageController.dispose();
    speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: Text('Mano الشطورة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Container(
                            height: 120,
                            width: 120,
                            margin: EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              color: Pallete.firstSuggestionBoxColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Container(
                          height: 125,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/virtualAssistant.png',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 40,
                      ).copyWith(top: 20),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Pallete.borderColor),
                        borderRadius: BorderRadius.circular(
                          20,
                        ).copyWith(topLeft: Radius.zero),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          lastWords.isNotEmpty
                              ? lastWords
                              : 'أنا اشطر مانو امرنى يا عسل عالصبح انا اقدر اعملك اللى امك متعرفش تعمله',
                          //'Good Morning, What task can I do for you today?',
                          style: TextStyle(
                            fontFamily: 'Cera Pro',
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Pallete.mainFontColor,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top: 10, left: 25),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Here are some suggestions',
                        style: TextStyle(
                          fontFamily: 'Cera Pro',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Pallete.mainFontColor,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        FeatureBox(
                          color: Pallete.firstSuggestionBoxColor,
                          headerText: 'Chat GPT',
                          descriptionText:
                              'An AI-driven chat engine that understands, responds, and evolves—making every conversation smarter',
                        ),
                        FeatureBox(
                          color: Pallete.secondSuggestionBoxColor,
                          headerText: 'Dall-E',
                          descriptionText:
                              'An AI image generator that creates stunning visuals from text prompts, transforming imagination into reality',
                        ),
                        FeatureBox(
                          color: Pallete.thirdSuggestionBoxColor,
                          headerText: 'Smart voice assistant',
                          descriptionText:
                              'An AI voice assistant that understands and responds to your commands, making daily tasks easier and more efficient',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IntrinsicHeight(
              child: Container(
                constraints: BoxConstraints(maxHeight: 200, minHeight: 100),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  border: Border(
                    top: BorderSide(color: Pallete.borderColor, width: 1),
                  ),
                ),
                padding: EdgeInsets.only(top: 10, left: 10, bottom: 20),
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 160,
                      ),
                      child: TextFormField(
                        controller: messageController,
                        maxLines: null,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            fontFamily: 'Cera Pro',
                            color: Pallete.mainFontColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Pallete.borderColor),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          lastWords = messageController.text.trim();
                          messageController.clear();
                        }
                      },
                      child: Icon(Icons.send),
                    ),
                    SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: () async {
                        if (await speechToText.hasPermission &&
                            speechToText.isNotListening) {
                          await startListening();
                        } else if (speechToText.isListening) {
                          await stopListening();
                        }
                      },
                      child:
                          speechToText.isListening
                              ? Icon(Icons.pause)
                              : Icon(Icons.mic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
