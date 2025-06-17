import 'package:flutter/material.dart';

class ExportTracker extends StatelessWidget {
  const ExportTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Export Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/index.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Export Tracker Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Sample content list
                Expanded(
                  child: ListView.builder(
                    itemCount: 5, // replace with your dynamic count
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.greenAccent.withOpacity(0.5),
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.local_shipping, color: Colors.greenAccent),
                          title: Text(
                            'Export Order #${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            'Status: In Transit',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.greenAccent),
                          onTap: () {
                            // Implement detailed view here
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
