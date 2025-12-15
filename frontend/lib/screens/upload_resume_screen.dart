import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../api/profile_api.dart';
import '../providers.dart';

class UploadResumeScreen extends ConsumerStatefulWidget {
  const UploadResumeScreen({super.key});

  @override
  ConsumerState<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends ConsumerState<UploadResumeScreen> {
  PlatformFile? _file;
  bool _loading = false;

  void _pick() async {
    final res = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );

    if (res != null && res.files.isNotEmpty) {
      setState(() => _file = res.files.first);
    }
  }

  void _upload() async {
    if (_file == null) return;

    setState(() => _loading = true);
    final email = ref.read(emailProvider) ?? 'no@email.com';
    final resp = await ProfileApi.uploadResume(email, _file!);
    setState(() => _loading = false);

    if (resp != null) {
      ref.read(profileIdProvider.notifier).state = resp['profile_id'];
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Resume uploaded successfully')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Upload failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Resume')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pick, child: const Text('Pick File')),
            const SizedBox(height: 10),
            Text(_file?.name ?? 'No file chosen'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _upload,
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
