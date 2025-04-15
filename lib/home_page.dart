import 'package:aiassistant/feature_box.dart';
import 'package:aiassistant/openai_service.dart';
import 'package:aiassistant/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String response = '';
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int end = 200;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTectToSpeech();
    
  
  }

  Future<void> initTectToSpeech() async {
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setSharedInstance(true);
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) async {
      if (result.finalResult) {
        setState(() {
          lastWords = result.recognizedWords;
        });

        final speech = await openAIService.isArtPromptAPI(lastWords);

        if (speech.contains('https')) {
          generatedImageUrl = speech;
          generatedContent = null;
        } else {
          generatedImageUrl = null;
          generatedContent = speech;
        }

        setState(() {}); // Update UI after processing
        await speak(speech);
      }
    

    setState(() {
      print(result.recognizedWords);
      lastWords = result.recognizedWords;
    });
  }
  

  final messageController = TextEditingController();
  @override
  void dispose() {
    messageController.dispose();
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            generatedContent = null;
            generatedImageUrl = null;
            messageController.clear();
            setState(() {});
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: BounceInDown(child: Text('AI Assistant')),
        centerTitle: true,
        actions: [
          Visibility(
            visible: isSpeaking,
            child: IconButton(
              onPressed: () {
                flutterTts.pause();
                setState(() {});
              },
              icon: Icon(Icons.stop),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ZoomIn(
                      child: Stack(
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
                    ),
                    FadeInRight(
                      child: Visibility(
                        visible: generatedImageUrl == null,
                        child: Container(
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
                              generatedContent == null
                                  ? 'Good Morning, What task can I do for you today?'
                                  : generatedContent!,
                              style: TextStyle(
                                fontFamily: 'Cera Pro',
                                fontSize: generatedContent == null ? 20 : 18,
                                fontWeight: FontWeight.w500,
                                color: Pallete.mainFontColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (generatedImageUrl != null)
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        height: 200,
                        width: MediaQuery.of(context).size.width - 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(generatedImageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    SlideInLeft(
                      child: Visibility(
                        visible:
                            generatedImageUrl == null &&
                            generatedContent == null,
                        child: Container(
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
                      ),
                    ),
                    Visibility(
                      visible:
                          generatedImageUrl == null && generatedContent == null,
                      child: Column(
                        children: [
                          SlideInLeft(
                            delay: Duration(milliseconds: start),
                            child: FeatureBox(
                              color: Pallete.firstSuggestionBoxColor,
                              headerText: 'Gemini',
                              descriptionText:
                                  'An AI-driven chat engine that understands, responds, and evolves—making every conversation smarter',
                            ),
                          ),
                          SlideInLeft(
                            delay: Duration(milliseconds: start + end),
                            child: FeatureBox(
                              color: Pallete.secondSuggestionBoxColor,
                              headerText: 'Dall-E',
                              descriptionText:
                                  'An AI image generator that creates stunning visuals from text prompts, transforming imagination into reality',
                            ),
                          ),
                          SlideInLeft(
                            delay: Duration(milliseconds: start + end * 2),
                            child: FeatureBox(
                              color: Pallete.thirdSuggestionBoxColor,
                              headerText: 'Smart voice assistant',
                              descriptionText:
                                  'An AI voice assistant that understands and responds to your commands, making daily tasks easier and more efficient',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ZoomIn(
              delay: Duration(milliseconds: start + end * 3),
              child: IntrinsicHeight(
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
                              borderSide: BorderSide(
                                color: Pallete.borderColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      FloatingActionButton(
                        onPressed: () async {
                          if (messageController.text.isNotEmpty) {
                            lastWords = messageController.text.trim();
                            final speech = await openAIService.isArtPromptAPI(
                              lastWords,
                            );
                            if (speech.contains('https')) {
                              generatedImageUrl = null;
                              generatedContent = speech;
                              setState(() {});
                              await speak(speech);
                            } else {
                              generatedImageUrl = null;
                              generatedContent = speech;
                              setState(() {});
                              await speak(speech);
                            }
                            await openAIService.isArtPromptAPI(lastWords);
                            await flutterTts.stop();
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
                            await flutterTts.stop();
                            await startListening();
                          } else if (speechToText.isListening) {
                            await stopListening();

                              final speech = await openAIService.isArtPromptAPI(
                                lastWords,
                              );
                              if (speech.contains('https')) {
                                generatedImageUrl = null;
                                generatedContent = speech;
                                setState(() {});
                                await speak(speech);
                              } else {
                                generatedImageUrl = null;
                                generatedContent = speech;
                                setState(() {});
                                await speak(speech);
                              }
                            
                          } else {
                            initSpeechToText();
                            setState(() {
                              
                            });
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
            ),
          ],
        ),
      ),
    );
  }
}
