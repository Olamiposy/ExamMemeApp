import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MemeQuizApp());
}

class MemeQuizApp extends StatelessWidget {
  const MemeQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meme Quiz',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MemeQuizScreen(),
    );
  }
}

class MemeQuizScreen extends StatefulWidget {
  const MemeQuizScreen({super.key});

  @override
  State<MemeQuizScreen> createState() => _MemeQuizScreenState();
}

class _MemeQuizScreenState extends State<MemeQuizScreen> {
  String memeText = '';
  String audioUrl = '';
  String guess = '';
  String resultMessage = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> fetchMeme() async {
    try {
      final res = await http.get(Uri.parse('http://10.0.2.2:5000/api/meme')); // use localhost for emulator
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          memeText = data['text'];
          audioUrl = data['audioUrl'];
          resultMessage = '';
          guess = '';
        });
      } else {
        setState(() => resultMessage = 'Failed to load meme.');
      }
    } catch (e) {
      setState(() => resultMessage = 'Error: $e');
    }
  }

  Future<void> checkAnswer() async {
    if (guess.isEmpty) return;
    final res = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/check'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'guess': guess}),
    );
    final data = json.decode(res.body);
    setState(() {
      resultMessage = data['correct'] ? ' Correct!' : ' Try again!';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMeme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Naija Meme Quiz')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                memeText.isEmpty ? 'Loading meme...' : memeText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.music_note, size: 40, color: Colors.green),
                onPressed: () => _audioPlayer.play(UrlSource(audioUrl)),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Guess who said it',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => guess = val,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: checkAnswer,
                child: const Text('Check Answer'),
              ),
              const SizedBox(height: 20),
              Text(resultMessage, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
