import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
          child: user?.photoURL == null ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? 'No Name',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(user?.email ?? 'No Email'),
        const SizedBox(height: 20),
        const Divider(),
      ],
    );
  }
}
