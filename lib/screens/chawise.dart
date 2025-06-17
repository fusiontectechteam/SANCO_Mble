import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHA Wise Report',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CHAWisePage(),
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
          'http://fusiontecsoftware.com/sancowebapi/sancoapi/GateINExportChartWise?dates=$fromDateStr~$toDateStr');

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
        title: const Text('CHA WISE REPORT'),
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
                            itemCount: _filteredData.length + 1, // +1 for the total row
                            itemBuilder: (context, index) {
                              if (index == _filteredData.length) {
                                // This is the total row
                                return _buildTotalRow(context, totalSummary);
                              }
                              
                              final item = _filteredData[index];
                              final chaName = item['CHANAME']?.toString() ?? 'Unknown';
                              final pnr20 = int.tryParse(item['PNR20']?.toString() ?? '0') ?? 0;
                              final pnr40 = int.tryParse(item['PNR40']?.toString() ?? '0') ?? 0;
                              final teus = int.tryParse(item['TUES']?.toString() ?? '0') ?? 0;

                              return Card(
                                color: Theme.of(context).colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
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
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailStat(
                          context,
                          '20\' Containers',
                          pnr20.toString(),
                          Icons.archive_outlined,
                          Colors.blue,
                        ),
                        _buildDetailStat(
                          context,
                          '40\' Containers',
                          pnr40.toString(),
                          Icons.business_center_outlined,
                          Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailStat(
                          context,
                          'Total Containers',
                          total.toString(),
                          Icons.storage_outlined,
                          Colors.green,
                        ),
                        _buildDetailStat(
                          context,
                          'Total TEUS',
                          teus.toString(),
                          Icons.analytics_outlined,
                          Colors.green,
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(context, '20\' Containers', pnr20.toString()),
                    const Divider(),
                    _buildDetailRow(context, '40\' Containers', pnr40.toString()),
                    const Divider(),
                    _buildDetailRow(context, 'Total Containers', total.toString()),
                    const Divider(),
                    _buildDetailRow(context, 'Total TEUS', teus.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Add more detailed information or charts here if needed
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(
      BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}