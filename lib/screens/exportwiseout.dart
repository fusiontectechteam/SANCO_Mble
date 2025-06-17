import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ExportWiseOut());
}

class ExportWiseOut extends StatelessWidget {
  const ExportWiseOut({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExportWise GateOut Report',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ).copyWith(
          primary: const Color(0xFF5C6BC0),
          secondary: const Color(0xFFFFB74D),
          surface: const Color(0xFFF5F5F5),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurfaceVariant: Colors.grey.shade800,
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
          elevation: 4,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.08),
          clipBehavior: Clip.antiAlias,
          surfaceTintColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF5C6BC0),
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
          fillColor: Colors.white,
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
            borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 2),
          ),
          hintStyle: GoogleFonts.roboto(color: Colors.grey.shade500),
          prefixIconColor: Colors.grey.shade600,
        ),
      ),
      home: const CHAWisePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CHAWisePage extends StatefulWidget {
  const CHAWisePage({super.key});

  @override
  State<CHAWisePage> createState() => _CHAWisePageState();
}

class _CHAWisePageState extends State<CHAWisePage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  List<dynamic> _apiData = [];
  List<dynamic> _filteredData = [];
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterData);
    _searchController.dispose();
    super.dispose();
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
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _apiData = [];
      _filteredData = [];
    });

    try {
      final fromDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final toDateStr = DateFormat('yyyy-MM-dd').format(_endDate);
      final url = Uri.parse(
          'http://fusiontecsoftware.com/sancowebapi/sancoapi/GateOUTExportChartWise?dates=$fromDateStr~$toDateStr');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['myRoot'] != null) {
          setState(() {
            _apiData = data['myRoot'];
            _filteredData = List.from(_apiData);
          });
        } else {
          setState(() {
            _errorMessage = 'No data available for selected dates';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredData = List.from(_apiData);
      } else {
        _filteredData = _apiData.where((item) {
          final chaName = item['CHANAME']?.toString().toLowerCase() ?? '';
          return chaName.contains(query);
        }).toList();
      }
    });
  }

  Map<String, dynamic> _calculateTotals() {
    int pnr20Total = _filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['PNR20']?.toString() ?? '0') ?? 0));
    int pnr40Total = _filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['PNR40']?.toString() ?? '0') ?? 0));
    int totalTotal = _filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['TOTAL']?.toString() ?? '0') ?? 0));
    int teusTotal = _filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['TUES']?.toString() ?? '0') ?? 0));

    return {
      'CHANAME': 'TOTAL',
      'PNR20': pnr20Total,
      'PNR40': pnr40Total,
      'TOTAL': totalTotal,
      'TUES': teusTotal,
    };
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToDetailScreen(BuildContext context, dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CHADetailScreen(
          chaData: item,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSummary = _filteredData.isNotEmpty ? _calculateTotals() : {
      'PNR20': 0,
      'PNR40': 0,
      'TOTAL': 0,
      'TUES': 0,
    };

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('EXPORT WISE GATE OUT'),
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
                    hintText: 'Search by CHA Name...',
                    prefixIcon: const Icon(Icons.search),
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
                  totalSummary['PNR20'],
                  Icons.archive_outlined,
                  Theme.of(context).colorScheme.primary,
                ),
                _buildSummaryChip(
                  context,
                  '40\' Containers',
                  totalSummary['PNR40'],
                  Icons.business_center_outlined,
                  Theme.of(context).colorScheme.primary,
                ),
                _buildSummaryChip(
                  context,
                  'Total Containers',
                  totalSummary['TOTAL'],
                  Icons.storage_outlined,
                  Theme.of(context).colorScheme.secondary,
                ),
                _buildSummaryChip(
                  context,
                  'Total TEUS',
                  totalSummary['TUES'],
                  Icons.analytics_outlined,
                  Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          _errorMessage,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _filteredData.isEmpty
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
                            itemCount: _filteredData.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _filteredData.length) {
                                return _buildTotalRow(context, totalSummary);
                              }
                              
                              final item = _filteredData[index];
                              final chaName = item['CHANAME']?.toString() ?? 'Unknown';
                              final pnr20 = int.tryParse(item['PNR20']?.toString() ?? '0') ?? 0;
                              final pnr40 = int.tryParse(item['PNR40']?.toString() ?? '0') ?? 0;
                              final total = int.tryParse(item['TOTAL']?.toString() ?? '0') ?? 0;
                              final teus = int.tryParse(item['TUES']?.toString() ?? '0') ?? 0;

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _navigateToDetailScreen(context, item),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.8),
                                          child: Text(
                                            (index + 1).toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
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
                                                chaName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '$pnr20 x 20\' | $pnr40 x 40\'',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: Colors.grey.shade700,
                                                  ),
                                            ),
                                            Text(
                                              teus.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 18,
                                            color: Colors.grey.shade400,
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

  Widget _buildTotalRow(BuildContext context, Map<String, dynamic> totalSummary) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.summarize, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalSummary['PNR20']}x20\' | ${totalSummary['PNR40']}x40\'',
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
                  totalSummary['TUES'].toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
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

class CHADetailScreen extends StatelessWidget {
  final dynamic chaData;
  final DateTime startDate;
  final DateTime endDate;

  const CHADetailScreen({
    super.key,
    required this.chaData,
    required this.startDate,
    required this.endDate,
  });

  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final chaName = chaData['CHANAME']?.toString() ?? 'Unknown';
    final pnr20 = int.tryParse(chaData['PNR20']?.toString() ?? '0') ?? 0;
    final pnr40 = int.tryParse(chaData['PNR40']?.toString() ?? '0') ?? 0;
    final total = int.tryParse(chaData['TOTAL']?.toString() ?? '0') ?? 0;
    final teus = int.tryParse(chaData['TUES']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(chaName),
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range: ${_formatDisplayDate(startDate)} - ${_formatDisplayDate(endDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailSummaryItem(
                          context,
                          '20\' Containers',
                          pnr20.toString(),
                          Theme.of(context).colorScheme.primary,
                        ),
                        _buildDetailSummaryItem(
                          context,
                          '40\' Containers',
                          pnr40.toString(),
                          Theme.of(context).colorScheme.primary,
                        ),
                        _buildDetailSummaryItem(
                          context,
                          'Total TEUS',
                          teus.toString(),
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Container Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    _buildTableRow(context, '20\' Containers', pnr20),
                    _buildTableRow(context, '40\' Containers', pnr40),
                    _buildTableRow(context, 'Total Containers', total),
                    _buildTableRow(context, 'Total TEUS', teus),
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