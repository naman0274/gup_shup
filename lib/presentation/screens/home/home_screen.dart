import 'package:flutter/material.dart';
import 'package:gup_shup/data/repositories/contact_repository.dart';
import 'package:gup_shup/data/services/service_locator.dart';
import 'package:gup_shup/logic/cubits/auth/auth_cubit.dart';
import 'package:gup_shup/presentation/screens/auth/login_screen.dart';
import 'package:gup_shup/router/app_router.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    super.initState();
  }

  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactRepository.getRegisterContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No contacts found"));
                    }

                    final contacts = snapshot.data!;
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            child: Text(contact["name"][0].toUpperCase()),
                          ),
                          title: Text(contact["name"]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(fontSize: 24)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () async {
                await getIt<AuthCubit>().signOut();
                getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: const Center(child: Text("User is authenticated")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactList(context),
        child: const Icon(Icons.chat),
        foregroundColor: Colors.white,
      ),
    );
  }
}
