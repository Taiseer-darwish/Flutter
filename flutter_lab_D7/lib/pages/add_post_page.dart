import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './home_page.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  Future<void> submitPost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (_textController.text.trim().isEmpty || currentUser == null) {
      print("Post submission cancelled: empty text or user null");
      return;
    }

    print("Starting post submission...");

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': currentUser.uid,
        'username': currentUser.email ?? 'Unknown',
        'text': _textController.text.trim(),
        'likes': [],
        'commentCount': 0,
        'timestamp': Timestamp.now(),
      });

      print("Post submitted successfully!");
    } catch (e) {
      print("Error while submitting post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        backgroundColor: const Color(0xff61169E),
      ),
      body:_isLoading
    ? const Center(child: CircularProgressIndicator())
    : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  print("Button pressed!");
                  setState(() => _isLoading = true);
                  await submitPost();
                  setState(() => _isLoading = false);
                  print("Navigating to home...");
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text("Post"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff61169E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
