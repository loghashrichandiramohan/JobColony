import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _jobRoleController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  List<dynamic> matchedJobs = [];
  List<String> skills = [];

  bool loading = false;
  String selectedCountry = 'Any';
  String selectedWorkType = 'Any';
  int selectedExperience = 0;

  final List<String> countries = [
    'Any','Africa','Argentina','Australia','Brazil','Canada','Chile','China',
    'Colombia','Denmark','Egypt','Finland','France','Germany','Hong Kong','India',
    'Indonesia','Ireland','Italy','Japan','Kenya','Malaysia','Mexico',
    'Netherlands','New Zealand','Nigeria','Norway','Philippines','Singapore',
    'South Korea','Spain','Sweden','Switzerland','Thailand',
    'United Kingdom','United States','Vietnam',
  ];

  final List<String> workTypes = ['Any', 'Remote', 'Hybrid', 'Full-time'];

  Future<void> findMatches() async {
    final role = _jobRoleController.text.trim();
    setState(() => loading = true);

    try {
      final uri = Uri.parse(
        'http://192.168.1.105:8000/search_jobs'
        '?role=$role'
        '&country=$selectedCountry'
        '&work_type=$selectedWorkType'
        '&experience=$selectedExperience'
        '&skills=${skills.join(",")}',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => matchedJobs = data['jobs'] ?? []);
      } else {
        setState(() => matchedJobs = []);
      }
    } catch (e) {
      setState(() => matchedJobs = []);
    }

    setState(() => loading = false);
  }

  void addSkill(String value) {
    final skill = value.trim();
    if (skill.isNotEmpty && !skills.contains(skill)) {
      setState(() => skills.add(skill));
    }
    _skillsController.clear();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ref.read(emailProvider.notifier).state = null;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(emailProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo_main.png', height: 30),
            const SizedBox(width: 8),
            Image.asset('assets/logo_splash.png', height: 36),
          ],
        ),
      ),

      /// ☰ THREE-DASH MENU
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName: const Text('Logged in as'),
              accountEmail: Text(email ?? 'Unknown'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ROLE
              TextField(
                controller: _jobRoleController,
                decoration: InputDecoration(
                  labelText: 'Role / Area of Expertise',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// SKILLS
              TextField(
                controller: _skillsController,
                onSubmitted: addSkill,
                decoration: InputDecoration(
                  labelText: 'Skills (press enter)',
                  prefixIcon: const Icon(Icons.code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              if (skills.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    children: skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        onDeleted: () =>
                            setState(() => skills.remove(skill)),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 20),

              /// COUNTRY
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: countries
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => selectedCountry = val!),
              ),
              const SizedBox(height: 12),

              /// WORK TYPE
              DropdownButtonFormField<String>(
                value: selectedWorkType,
                decoration: InputDecoration(
                  labelText: 'Work Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: workTypes
                    .map((w) =>
                        DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => selectedWorkType = val!),
              ),
              const SizedBox(height: 12),

              /// EXPERIENCE
              Text('Minimum Experience: $selectedExperience years'),
              Slider(
                value: selectedExperience.toDouble(),
                min: 0,
                max: 30,
                divisions: 30,
                onChanged: (val) =>
                    setState(() => selectedExperience = val.toInt()),
              ),

              const SizedBox(height: 20),

              /// FIND MATCHES
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: findMatches,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Find Matches',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              /// RESULTS
              if (!loading && matchedJobs.isNotEmpty)
                Column(
                  children: matchedJobs.map((job) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(job['title']),
                        subtitle: Text(
                          '${job['company']} • ${job['location']}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (job['url'] != null) {
                              _launchURL(job['url']);
                            }
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
