// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import './post_card.dart';

// class MyPostsList extends StatelessWidget {
//   final String userId;
//   const MyPostsList({required this.userId, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('posts')
//           .where('userId', isEqualTo: userId)
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text("You haven't posted anything yet."));
//         }

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             final doc = snapshot.data!.docs[index];
//             final data = doc.data() as Map<String, dynamic>;
//             return PostCard(
//               postId: doc.id,
//               postData: data,
//               showEditButtons: true, // دائماً متاح هنا
//               onEdit: () => Navigator.pushNamed(
//                 context,
//                 '/edit',
//                 arguments: {'postId': doc.id, 'text': data['text']},
//               ),
//               onDelete: () async {
//                 final ok = await showDialog<bool>(
//                   context: context,
//                   builder: (_) => AlertDialog(
//                     title: const Text('Delete Post'),
//                     content: const Text('Confirm deletion?'),
//                     actions: [
//                       TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//                       TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
//                     ],
//                   ),
//                 );
//                 if (ok == true) {
//                   await FirebaseFirestore.instance.collection('posts').doc(doc.id).delete();
//                 }
//               },
//               onComment: null,
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './post_card.dart';
import '../pages/edit_post_page.dart';

class MyPostsList extends StatelessWidget {
  final String userId;
  const MyPostsList({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("You haven't posted anything yet.");
        }

        final posts = snapshot.data!.docs;

        return Column(
          children: posts.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return PostCard(
              postId: doc.id,
              postData: data,
              showEditButtons: true,
              onEdit: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditPostPage(
        postId: doc.id,
        currentText: data['text'] ?? '',
      ),
    ),
  );
},

              onDelete: () async {
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
                      .doc(doc.id)
                      .delete();
                }
              },
              onComment: null,
            );
          }).toList(),
        );
      },
    );
  }
}
