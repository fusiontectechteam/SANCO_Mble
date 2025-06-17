import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ExportYardApp());
}

class ExportYardApp extends StatelessWidget {
  const ExportYardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Import Yard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ).copyWith(
          primary: const Color(0xFF5C6BC0), // A slightly softer primary blue
          secondary: const Color(0xFFFFB74D), // A softer orange accent
          surface: const Color(0xFFF5F5F5), // Lighter background for general content
          onPrimary: Colors.white, // Text/icons on primary color
          onSecondary: Colors.black, // Text/icons on secondary color
          onSurfaceVariant: Colors.grey.shade800, // Darker text on surface
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
              fontSize: 57, fontWeight: FontWeight.bold, color: Colors.black),
          displayMedium: GoogleFonts.poppins(
              fontSize: 45, fontWeight: FontWeight.bold, color: Colors.black),
          displaySmall: GoogleFonts.poppins(
              fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
          headlineLarge: GoogleFonts.poppins(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          headlineMedium: GoogleFonts.poppins(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          headlineSmall: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          titleLarge: GoogleFonts.montserrat(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          titleMedium: GoogleFonts.montserrat(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          titleSmall: GoogleFonts.montserrat(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
          bodyLarge: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
          bodyMedium: GoogleFonts.roboto(fontSize: 14, color: Colors.black87),
          bodySmall: GoogleFonts.roboto(fontSize: 12, color: Colors.black54),
          labelLarge: GoogleFonts.roboto(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          labelMedium: GoogleFonts.roboto(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
          labelSmall: GoogleFonts.roboto(
              fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        cardTheme: CardThemeData(
          elevation: 4, // Slightly reduced elevation for a calmer look
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.08), // Softer shadow
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF5C6BC0), // Matches primary color
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Pure white for input fields
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF5C6BC0), width: 2), // Focus border matches primary
          ),
          hintStyle: GoogleFonts.roboto(color: Colors.grey.shade500),
          prefixIconColor: Colors.grey.shade600,
        ),
      ),
      home: const ImportYardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImportYardScreen extends StatefulWidget {
  const ImportYardScreen({super.key});

  @override
  State<ImportYardScreen> createState() => _ImportYardScreenState();
}

class _ImportYardScreenState extends State<ImportYardScreen> {
  List<Map<String, dynamic>> _containerData = [];
  List<Map<String, dynamic>> _originalContainerData = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchContainerData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterData);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchContainerData() async {
    setState(() => _isLoading = true);

    try {
      final formattedStart = _formatDate(_startDate);
      final formattedEnd = _formatDate(_endDate);
      final response = await http.get(Uri.parse(
          'https://fusiontecsoftware.com/sancowebapi/sancoapi/GetGateOUTDetails?dates=$formattedStart~$formattedEnd'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['myRoot'] != null) {
          setState(() {
            _originalContainerData = (jsonData['myRoot'] as List)
                .map((item) => _processDataItem(item))
                .toList();
            _filterData(); // Apply filter immediately after fetching data to show totals
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _processDataItem(dynamic item) {
    return {
      'agent': item['SNAME'] ?? 'Unknown',
      'pnr20': item['PNR20'] ?? 0,
      'pnr40': item['PNR40'] ?? 0,
      'dpdcfs20': item['DPDCFS20'] ?? 0,
      'dpdcfs40': item['DPDCFS40'] ?? 0,
      'dpdpdp20': item['DPDDPD20'] ?? 0,
      'dpdpdp40': item['DPDDPD40'] ?? 0,
      'enblock20': item['ENBLOCK20'] ?? 0,
      'enblock40': item['ENBLOCK40'] ?? 0,
      'total20': item['TOTAL20'] ?? 0,
      'total40': item['TOTAL40'] ?? 0,
      'teus': item['TUES'] ?? 0,
    };
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> filteredList;

    if (query.isEmpty) {
      filteredList = List.from(_originalContainerData);
    } else {
      filteredList = _originalContainerData.where((item) {
        final agentName = item['agent'].toString().toLowerCase();
        return agentName.contains(query);
      }).toList();
    }

    final totals = {
      'agent': 'TOTAL',
      'pnr20': filteredList.fold(0, (sum, item) => sum + (item['pnr20'] as int)),
      'pnr40': filteredList.fold(0, (sum, item) => sum + (item['pnr40'] as int)),
      'dpdcfs20': filteredList.fold(0, (sum, item) => sum + (item['dpdcfs20'] as int)),
      'dpdcfs40': filteredList.fold(0, (sum, item) => sum + (item['dpdcfs40'] as int)),
      'dpdpdp20': filteredList.fold(0, (sum, item) => sum + (item['dpdpdp20'] as int)),
      'dpdpdp40': filteredList.fold(0, (sum, item) => sum + (item['dpdpdp40'] as int)),
      'enblock20': filteredList.fold(0, (sum, item) => sum + (item['enblock20'] as int)),
      'enblock40': filteredList.fold(0, (sum, item) => sum + (item['enblock40'] as int)),
      'total20': filteredList.fold(0, (sum, item) => sum + (item['total20'] as int)),
      'total40': filteredList.fold(0, (sum, item) => sum + (item['total40'] as int)),
      'teus': filteredList.fold(0, (sum, item) => sum + (item['teus'] as int)),
    };

    setState(() {
      _containerData = filteredList;
      if (filteredList.isNotEmpty || query.isEmpty) {
        _containerData.add(totals);
      }
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).colorScheme.surface),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && (picked.start != _startDate || picked.end != _endDate)) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchContainerData();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // A more readable date format for display
  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSummary = _containerData.firstWhere(
      (item) => item['agent'] == 'TOTAL',
      orElse: () => {'total20': 0, 'total40': 0, 'teus': 0},
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('IMPORT YARD'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Select Date Range',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Display selected date range prominently
                Text(
                  'Selected Date Range: ${_formatDisplayDate(_startDate)} - ${_formatDisplayDate(_endDate)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Agent...',
                    prefixIcon: const Icon(Icons.search),
                    // Adding a clear button for search input
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterData();
                            },
                          )
                        : null,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: [
                _buildSummaryChip(
                  context,
                  '20\' Containers',
                  totalSummary['total20'],
                  Icons.archive_outlined,
                  Theme.of(context).colorScheme.primary,
                ),
                _buildSummaryChip(
                  context,
                  '40\' Containers',
                  totalSummary['total40'],
                  Icons.business_center_outlined,
                  Theme.of(context).colorScheme.primary,
                ),
                _buildSummaryChip(
                  context,
                  'Total TEUS',
                  totalSummary['teus'],
                  Icons.analytics_outlined,
                  Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _containerData.isEmpty && !_isLoading
                    ? Center(
                        child: Text(
                          'No data found for the selected date range or search.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _containerData.length,
                        itemBuilder: (context, index) {
                          final item = _containerData[index];
                          final isTotalRow = item['agent'] == 'TOTAL';

                          return Card(
                            color: isTotalRow
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                                : Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isTotalRow
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                                    : Colors.grey.shade200,
                                width: isTotalRow ? 1.5 : 1,
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: InkWell(
                              onTap: isTotalRow
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AgentDetailScreen(agentData: item),
                                        ),
                                      );
                                    },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: isTotalRow
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                      child: Text(
                                        isTotalRow ? '' : (index + 1).toString(),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['agent'],
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: isTotalRow
                                                      ? Theme.of(context).colorScheme.primary
                                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                                  fontWeight: isTotalRow
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item['total20']}x20\' | ${item['total40']}x40\'',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'TEUS',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                        ),
                                        Text(
                                          item['teus'].toString(),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: isTotalRow ? Colors.transparent : Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(
      BuildContext context, String label, dynamic value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    Text(
                      '$value',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AgentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> agentData;

  const AgentDetailScreen({super.key, required this.agentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(agentData['agent']),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailSummaryItem(
                      context,
                      'Total 20\'',
                      agentData['total20'].toString(),
                      Theme.of(context).colorScheme.primary,
                    ),
                    _buildDetailSummaryItem(
                      context,
                      'Total 40\'',
                      agentData['total40'].toString(),
                      Theme.of(context).colorScheme.primary,
                    ),
                    _buildDetailSummaryItem(
                      context,
                      'Total TEUS',
                      agentData['teus'].toString(),
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Container Breakdown',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
                  },
                  border: TableBorder.all(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    width: 1,
                  ),
                  children: [
                    _buildTableRow(context, 'PNR 20\'', agentData['pnr20']),
                    _buildTableRow(context, 'PNR 40\'', agentData['pnr40']),
                    _buildTableRow(context, 'DPDCFS 20\'', agentData['dpdcfs20']),
                    _buildTableRow(context, 'DPDCFS 40\'', agentData['dpdcfs40']),
                    _buildTableRow(context, 'DPDPDP 20\'', agentData['dpdpdp20']),
                    _buildTableRow(context, 'DPDPDP 40\'', agentData['dpdpdp40']),
                    _buildTableRow(context, 'ENBLOCK 20\'', agentData['enblock20']),
                    _buildTableRow(context, 'ENBLOCK 40\'', agentData['enblock40']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, String label, dynamic value) {
    return TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSummaryItem(
      BuildContext context, String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}