import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WarehouseApp());
}

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Report',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
      ),
      home: const WarehouseScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  DateTime selectedDate = DateTime.now();
  List<dynamic> receiptData = [];
  bool isLoading = false;
  String? error;
  double totalReceiptTeus = 0;
  double totalDeliveryTeus = 0;
  double currentStockTeus = 0;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final String receiptApiUrl =
        'http://fusiontecsoftware.com/sancowebapi/sancoapi/LoadReceiptDetails?dates=$formattedDate';
    final String currentStockApiUrl =
        'https://fusiontecsoftware.com/sancowebapi/sancoapi/GetCurrentStock?dates=banu~$formattedDate';

    try {
      final responses = await Future.wait([
        http.get(Uri.parse(receiptApiUrl)),
        http.get(Uri.parse(currentStockApiUrl)),
      ]);

      // Reset values before processing new data
      setState(() {
        receiptData = [];
        totalReceiptTeus = 0;
        totalDeliveryTeus = 0;
        currentStockTeus = 0;
      });

      // Process Receipt Details Response
      final receiptResponse = responses[0];
      if (receiptResponse.statusCode == 200) {
        final decodedReceipt = jsonDecode(receiptResponse.body);
        if (decodedReceipt['myRoot'] != null) {
          setState(() {
            receiptData = decodedReceipt['myRoot'] ?? [];
            
            for (var item in receiptData) {
              if (item['COLDESC']?.toString().toLowerCase().contains('total receipt') ?? false) {
                totalReceiptTeus = (item['TUES'] ?? 0).toDouble();
              } else if (item['COLDESC']?.toString().toLowerCase().contains('total delivery') ?? false) {
                totalDeliveryTeus = (item['TUES'] ?? 0).toDouble();
              }
            }
          });
        }
      } else {
        setState(() {
          error = 'Server Error (Receipt): ${receiptResponse.statusCode}';
        });
      }

      // Process Current Stock Response
      final stockResponse = responses[1];
      if (stockResponse.statusCode == 200) {
        final decodedStock = jsonDecode(stockResponse.body);
        if (decodedStock['myRoot'] != null && decodedStock['myRoot'].isNotEmpty) {
          setState(() {
            currentStockTeus = (decodedStock['myRoot'][0]['TUES'] ?? 0).toDouble();
          });
        }
      } else {
        setState(() {
          error = error != null
              ? '$error\nServer Error (Stock): ${stockResponse.statusCode}'
              : 'Server Error (Stock): ${stockResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C5CE7),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await fetchData();
    }
  }

  List<ActivityData> _getActivityData() {
    return receiptData.map((item) {
      final sourceType = item['COLDESC']?.toString() ?? 'Unknown';
      final isTotal = sourceType.toLowerCase().contains('total');

      Color color;
      IconData icon;

      if (sourceType.toLowerCase().contains('receipt')) {
        color = const Color(0xFF00B894);
        icon = isTotal ? Icons.summarize : Icons.input;
      } else if (sourceType.toLowerCase().contains('delivery')) {
        color = const Color(0xFF0984E3);
        icon = isTotal ? Icons.summarize : Icons.output;
      } else if (sourceType.toLowerCase().contains('de-stuffing')) {
        color = const Color(0xFFFDCB6E);
        icon = Icons.unarchive;
      } else {
        color = const Color(0xFF6C5CE7);
        icon = Icons.info_outline;
      }

      return ActivityData(
        title: sourceType,
        values: [
          (item['SIZE20'] ?? 0).toInt(),
          (item['SIZE40'] ?? 0).toInt(),
          (item['SIZE45'] ?? 0).toInt(),
        ],
        total: (item['TOTAL'] ?? 0).toInt(),
        teus: (item['TUES'] ?? 0).toInt(),
        icon: icon,
        color: color,
        isTotal: isTotal,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).padding.top + kToolbarHeight * 1.2,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Daily Report',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                background: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _selectDate(context),
                  tooltip: 'Select Date',
                ),
              ],
            ),
          ];
        },
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    _buildDateHeader(context),
                    const SizedBox(height: 24),
                    _buildSummaryDashboard(),
                    const SizedBox(height: 24),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                        ),
                      )
                    else if (receiptData.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              'ACTIVITY LOG',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${receiptData.length} Activities',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6C5CE7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._getActivityData()
                          .map((activity) => _ActivityTile(activity: activity))
                          ,
                    ] else if (!isLoading && receiptData.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No data available for selected date',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select another date or check back later',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OPERATIONS SUMMARY',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchData,
              color: const Color(0xFF6C5CE7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDashboard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F9FA), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DashboardMetric(
                title: 'Receipt',
                value: totalReceiptTeus,
                unit: 'TEUS',
                color: const Color(0xFF00B894),
                icon: Icons.import_export,
              ),
              _DashboardMetric(
                title: 'Delivery',
                value: totalDeliveryTeus,
                unit: 'TEUS',
                color: const Color(0xFF0984E3),
                icon: Icons.local_shipping,
              ),
              _DashboardMetric(
                title: 'Stock',
                value: currentStockTeus,
                unit: 'TEUS',
                color: const Color(0xFF6C5CE7),
                icon: Icons.warehouse,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TeusProgressIndicator(
            receipt: totalReceiptTeus,
            delivery: totalDeliveryTeus,
            stock: currentStockTeus,
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final Color color;
  final IconData icon;

  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _TeusProgressIndicator extends StatelessWidget {
  final double receipt;
  final double delivery;
  final double stock;

  const _TeusProgressIndicator({
    required this.receipt,
    required this.delivery,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final total = receipt + delivery + stock;
    final receiptPercent = total > 0 ? receipt / total : 0.0;
    final deliveryPercent = total > 0 ? delivery / total : 0.0;
    final stockPercent = total > 0 ? stock / total : 0.0;

    int receiptFlex = (receiptPercent * 100).toInt();
    int deliveryFlex = (deliveryPercent * 100).toInt();
    int stockFlex = (stockPercent * 100).toInt();

    // Adjust flex values to ensure they sum to 100
    int totalFlex = receiptFlex + deliveryFlex + stockFlex;
    if (totalFlex < 100) {
      // Add remaining to the largest segment
      if (receiptFlex >= deliveryFlex && receiptFlex >= stockFlex) {
        receiptFlex += (100 - totalFlex);
      } else if (deliveryFlex >= receiptFlex && deliveryFlex >= stockFlex) {
        deliveryFlex += (100 - totalFlex);
      } else {
        stockFlex += (100 - totalFlex);
      }
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: receiptFlex,
              child: Container(
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00B894),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: deliveryFlex,
              child: Container(
                height: 8,
                color: const Color(0xFF0984E3),
              ),
            ),
            Expanded(
              flex: stockFlex,
              child: Container(
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ProgressLegend(
              color: const Color(0xFF00B894),
              label: 'Receipt',
              value: receipt,
            ),
            _ProgressLegend(
              color: const Color(0xFF0984E3),
              label: 'Delivery',
              value: delivery,
            ),
            _ProgressLegend(
              color: const Color(0xFF6C5CE7),
              label: 'Stock',
              value: stock,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressLegend extends StatelessWidget {
  final Color color;
  final String label;
  final double value;

  const _ProgressLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ActivityData {
  final String title;
  final List<int> values;
  final int total;
  final int teus;
  final IconData icon;
  final Color color;
  final bool isTotal;

  ActivityData({
    required this.title,
    required this.values,
    required this.total,
    required this.teus,
    required this.icon,
    required this.color,
    required this.isTotal,
  });
}

class _ActivityTile extends StatelessWidget {
  final ActivityData activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activity.color.withOpacity(0.3),
                  activity.color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon, color: activity.color),
          ),
          title: Text(
            activity.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${activity.total} containers',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activity.color.withOpacity(0.2),
                  activity.color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${activity.teus} TEUS',
              style: TextStyle(
                color: activity.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ContainerSizeIndicator(
                        size: '20\'',
                        count: activity.values[0],
                        color: activity.color,
                      ),
                      _ContainerSizeIndicator(
                        size: '40\'',
                        count: activity.values[1],
                        color: activity.color,
                      ),
                      _ContainerSizeIndicator(
                        size: '45\'',
                        count: activity.values[2],
                        color: activity.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: activity.total > 0 ? activity.total / (activity.total + (activity.isTotal ? 0 : 20)) : 0,
                    backgroundColor: activity.color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(activity.color),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Container Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${activity.total} containers',
                        style: TextStyle(
                          fontSize: 12,
                          color: activity.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContainerSizeIndicator extends StatelessWidget {
  final String size;
  final int count;
  final Color color;

  const _ContainerSizeIndicator({
    required this.size,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          size,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}