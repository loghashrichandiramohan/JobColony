// === file: lib/screens/experience_screen.dart ===
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/profile_api.dart';
import '../providers.dart'; // contains emailProvider and profileIdProvider

class ExperienceScreen extends ConsumerStatefulWidget {
  const ExperienceScreen({super.key});

  @override
  ConsumerState<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends ConsumerState<ExperienceScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);

    // Ensure emailProvider is defined in providers.dart
    final email = ref.read(emailProvider) ?? 'no@email.com';
    final res = await ProfileApi.typeExperience(email, _ctrl.text.trim());

    setState(() => _loading = false);

    if (res != null) {
      ref.read(profileIdProvider.notifier).state = res['profile_id'];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile created')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Type Experience')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Describe your experience...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
