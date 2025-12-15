import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/profile_api.dart';
import '../providers.dart';
import '../models/job.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  final String? role; // Role passed from HomeScreen

  const MatchesScreen({super.key, this.role});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  bool _loading = false;
  List<JobModel> jobs = [];

  Future<void> _loadMatches() async {
    final pid = ref.read(profileIdProvider);
    if (pid == null) return;

    setState(() => _loading = true);

    // Fetch matches from API
    final res = await ProfileApi.getMatches(pid, role: widget.role);

    setState(() {
      _loading = false;
      jobs = res
          .map((e) => JobModel.fromJson(e))
          .where((job) => widget.role == null || job.title.toLowerCase().contains(widget.role!.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadMatches());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Matches')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
              ? const Center(child: Text('No matches found.'))
              : ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(job.title),
                        subtitle: Text('${job.company ?? 'Unknown'} • ${job.location ?? 'Unknown'}'),
                        trailing: Text(job.score.toStringAsFixed(2)),
                        onTap: () {
                          if (job.url != null && job.url!.isNotEmpty) {
                            // Use url_launcher to open
                            // launchUrl(Uri.parse(job.url!));
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
