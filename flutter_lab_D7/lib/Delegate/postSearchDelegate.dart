import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/edit_post_page.dart';

class PostSearchDelegate extends SearchDelegate<String> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching posts"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final text = data['text']?.toLowerCase() ?? '';
              final username = data['username']?.toLowerCase() ?? '';
              return text.contains(query.toLowerCase()) || username.contains(query.toLowerCase());
            })
            .toList();

        if (posts.isEmpty) {
          return const Center(child: Text("No posts found."));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final data = post.data() as Map<String, dynamic>;
            final likes = List<String>.from(data['likes'] ?? []);
            final isLiked = likes.contains(currentUser?.uid);
            final postId = post.id;

            return Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['username'] ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(data['text'] ?? ''),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
                            if (isLiked) {
                              postRef.update({
                                'likes': FieldValue.arrayRemove([currentUser?.uid]),
                              });
                            } else {
                              postRef.update({
                                'likes': FieldValue.arrayUnion([currentUser?.uid]),
                              });
                            }
                          },
                        ),
                        Text("${likes.length}"),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.grey),
                          onPressed: () => showCommentDialog(context, postId),
                        ),
                      ],
                    ),
                    if (currentUser?.uid == data['userId'])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPostPage(
                                    postId: postId,
                                    currentText: data['text'] ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Post"),
                                  content: const Text("Are you sure you want to delete this post?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId)
                                    .delete();
                              }
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(postId)
                          .collection('comments')
                          .orderBy('timestamp', descending: false)
                          .snapshots(),
                      builder: (context, commentSnapshot) {
                        if (commentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Loading comments...");
                        }
                        if (!commentSnapshot.hasData || commentSnapshot.data!.docs.isEmpty) {
                          return const Text("No comments yet.");
                        }
                        final comments = commentSnapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: comments.map((comment) {
                            final c = comment.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.chat, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "${c['username'] ?? 'User'}: ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: c['text'] ?? '',
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink(); // No suggestions needed, handled in buildResults
  }

  void showCommentDialog(BuildContext context, String postId) {
    final TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(hintText: "Enter your comment"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final text = commentController.text.trim();
              if (text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('comments')
                    .add({
                      'text': text,
                      'userId': currentUser?.uid,
                      'username': currentUser?.email,
                      'timestamp': Timestamp.now(),
                    });
              }
              Navigator.pop(context);
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }
}