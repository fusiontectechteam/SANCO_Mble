import 'package:flutter/material.dart';
import 'dairyreport.dart';
import 'streamerin.dart';
import 'streamerout.dart';
import 'importtracker.dart';
import 'exportwisein.dart';
import 'exportwiseout.dart';
import 'chawise.dart';
import 'Exporttracker.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  bool isImportExpanded = false;
  bool isExportExpanded = false;
  bool isBondsExpanded = false;
  bool isTrackerExpanded = false;

  void _collapseOtherSections(String expandedSection) {
    setState(() {
      if (expandedSection != 'tracker') isTrackerExpanded = false;
      if (expandedSection != 'import') isImportExpanded = false;
      if (expandedSection != 'export') isExportExpanded = false;
      if (expandedSection != 'bonds') isBondsExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'TradeFlow',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'SANCO DASHBOARD',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tracker Card
                    _buildSectionCard(
                      title: "Tracker",
                      isExpanded: isTrackerExpanded,
                      onTap: () {
                        setState(() {
                          isTrackerExpanded = !isTrackerExpanded;
                          if (isTrackerExpanded) {
                            _collapseOtherSections('tracker');
                          }
                        });
                      },
                      color: Colors.deepPurple,
                      icon: Icons.track_changes,
                      children: [
                        _buildMenuItem(
                          icon: Icons.trending_up,
                          label: "Export Tracker",
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ExportTracker()),
                            );
                          },
                          color: Colors.deepPurple,
                        ),
                        _buildMenuItem(
                          icon: Icons.trending_down,
                          label: "Import Tracker",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ImportTracker()),
                            );
                          },
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Import Card
                    _buildSectionCard(
                      title: "Import Operations",
                      isExpanded: isImportExpanded,
                      onTap: () {
                        setState(() {
                          isImportExpanded = !isImportExpanded;
                          if (isImportExpanded) {
                            _collapseOtherSections('import');
                          }
                        });
                      },
                      color: Colors.blue,
                      icon: Icons.import_export,
                      children: [
                        _buildMenuItem(
                          icon: Icons.assignment,
                          label: "Daily Dairy Report",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WarehouseApp()),
                            );
                          },
                          color: Colors.blue,
                        ),
                        _buildMenuItem(
                          icon: Icons.input,
                          label: "Streamer Wise In",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ImportYardApp()),
                            );
                          },
                          color: Colors.blue,
                        ),
                        _buildMenuItem(
                          icon: Icons.output,
                          label: "Streamer Wise Out",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ExportYardApp()),
                            );
                          },
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Export Card
                    _buildSectionCard(
                      title: "Export Operations",
                      isExpanded: isExportExpanded,
                      onTap: () {
                        setState(() {
                          isExportExpanded = !isExportExpanded;
                          if (isExportExpanded) {
                            _collapseOtherSections('export');
                          }
                        });
                      },
                      color: Colors.green,
                      icon: Icons.upload,
                      children: [
                        _buildMenuItem(
                          icon: Icons.arrow_circle_right,
                          label: "Export Wise In",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ExportWiseIn()),
                            );
                          },
                          color: Colors.green,
                        ),
                        _buildMenuItem(
                          icon: Icons.arrow_circle_left,
                          label: "Export Wise Out",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ExportWiseOut()),
                            );
                          },
                          color: Colors.green,
                        ),
                        _buildMenuItem(
                          icon: Icons.corporate_fare,
                          label: "CHA Wise",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyApp()),
                            );
                          },
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bonds Card
                    _buildSectionCard(
                      title: "Bond Management",
                      isExpanded: isBondsExpanded,
                      onTap: () {
                        setState(() {
                          isBondsExpanded = !isBondsExpanded;
                          if (isBondsExpanded) {
                            _collapseOtherSections('bonds');
                          }
                        });
                      },
                      color: Colors.orange,
                      icon: Icons.assignment,
                      children: [
                        _buildTextItem("Secure Bond Registration"),
                        _buildTextItem("Automated Bond Renewal"),
                        _buildTextItem("Comprehensive Duty-Free Management"),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Color color,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: Icon(icon, color: color),
            title: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: color,
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ListTile(
      onTap: onPressed,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: color),
    );
  }

  Widget _buildTextItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}