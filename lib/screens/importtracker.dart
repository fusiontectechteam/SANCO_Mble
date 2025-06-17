import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';

class ImportTracker extends StatefulWidget {
  const ImportTracker({super.key});

  @override
  State<ImportTracker> createState() => _ImportTrackerState();
}

class _ImportTrackerState extends State<ImportTracker> {
  int _selectedOption = 0;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _lineNumberController = TextEditingController();
  final TextEditingController _igmNumberController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isLoading = false;
  Map<String, dynamic>? _containerData;
  List<dynamic>? _imageContainerList;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _inputController.dispose();
    _lineNumberController.dispose();
    _igmNumberController.dispose();
    _inputFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchContainerData() async {
    if (_inputController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a container number';
        _containerData = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _containerData = null;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse(
          'http://fusiontecsoftware.com/sancowebapi/sancoapi/ContainerTracker?CONTNO=${_inputController.text.trim()}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['myRoot'] != null && data['myRoot'].isNotEmpty) {
          setState(() {
            _containerData = data['myRoot'][0];
          });
        } else {
          setState(() {
            _errorMessage = 'No container data found for this number.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchImageData() async {
    if (_igmNumberController.text.isEmpty || _lineNumberController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both IGM Number and Line Number';
        _imageContainerList = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _imageContainerList = null;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse(
          'https://fusiontecsoftware.com/sancowebapi/LineNo?data=${_igmNumberController.text.trim()}~${_lineNumberController.text.trim()}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['myRoot'] != null && data['myRoot'].isNotEmpty) {
          setState(() {
            _imageContainerList = data['myRoot'];
          });
        } else {
          setState(() {
            _errorMessage = 'No container data found for these details.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchTextChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (_selectedOption == 0) {
        _fetchContainerData();
      } else if (_igmNumberController.text.isNotEmpty && 
                  _lineNumberController.text.isNotEmpty) {
        _fetchImageData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOptionSelector(),
                      const SizedBox(height: 30),
                      _selectedOption == 0
                          ? _buildContainerInput()
                          : _buildImageInputSection(),
                      if (_isLoading) _buildLoadingIndicator(),
                      if (_errorMessage != null) _buildErrorMessage(),
                      if (_containerData != null && _selectedOption == 0) 
                        _buildContainerDetails(),
                      if (_imageContainerList != null && _selectedOption == 1) 
                        _buildImageContainerList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.import_export, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 15),
        const Text(
          'Import Tracker',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Track your containers with ease',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedOption = 0;
                _lineNumberController.clear();
                _igmNumberController.clear();
                _errorMessage = null;
                _imageContainerList = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedOption == 0 ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Container',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _selectedOption == 0 ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedOption = 1;
                _inputController.clear();
                _errorMessage = null;
                _containerData = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedOption == 1 ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _selectedOption == 1 ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerInput() {
    return Column(
      children: [
        TextField(
          controller: _inputController,
          focusNode: _inputFocusNode,
          onChanged: _onSearchTextChanged,
          decoration: InputDecoration(
            labelText: 'Container Number',
            hintText: 'e.g. TCNU8127147',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: const TextStyle(color: Color(0xFF64748B)),
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
          ),
          style: const TextStyle(color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 10),
        const Text(
          'Start typing to search automatically',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildImageInputSection() {
    return Column(
      children: [
        TextField(
          controller: _igmNumberController,
          onChanged: (value) => _onSearchTextChanged(value),
          decoration: InputDecoration(
            labelText: 'IGM Number',
            hintText: 'Enter IGM number',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: const TextStyle(color: Color(0xFF64748B)),
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
          ),
          style: const TextStyle(color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _lineNumberController,
          onChanged: (value) => _onSearchTextChanged(value),
          decoration: InputDecoration(
            labelText: 'Line Number',
            hintText: 'Enter line number',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: const TextStyle(color: Color(0xFF64748B)),
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
          ),
          style: const TextStyle(color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 10),
        const Text(
          'Both fields required for auto-search',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF2563EB),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 15),
          Text(
            _selectedOption == 0 ? 'Searching container...' : 'Searching image data...',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFFB91C1C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _containerData!['CONTNRNO'] ?? 'No Container Number',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailSection(
            title: 'Container Information',
            icon: Icons.storage,
            children: [
              _buildDetailItem('Department', _containerData!['Department']),
              _buildDetailItem('Container Size', _containerData!['CONTNRSDESC']),
              _buildDetailItem('Container Type', _containerData!['CONTNRTDESC']),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailSection(
            title: 'Vessel & Voyage',
            icon: Icons.directions_boat,
            children: [
              _buildDetailItem('Vessel', _containerData!['VSLNAME']),
              _buildDetailItem('Voyage No.', _containerData!['VOYNO']),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailSection(
            title: 'Gate Times',
            icon: Icons.schedule,
            children: [
              _buildDetailItem('Gate In Date', _formatDate(_containerData!['GIDATE'])),
              _buildDetailItem('Gate In Time', _containerData!['GITIME']),
              _buildDetailItem('Gate Out', _formatDateTime(_containerData!['GOTIME'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainerList() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                '${_imageContainerList!.length} containers found',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _imageContainerList!.length,
            itemBuilder: (context, index) {
              final container = _imageContainerList![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildCompactContainerCard(container),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactContainerCard(Map<String, dynamic> container) {
    // Generate a consistent, but distinct color for the card header
    final headerColor = _generateColorFromString(container['CONTNRNO'] ?? 'default');
    final gradientColors = [
      headerColor.withOpacity(0.9),
      headerColor.withOpacity(1.0),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with container number
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    container['CONTNRNO'] ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCompactDetailRow(
                  icon1: Icons.aspect_ratio,
                  label1: 'Size',
                  value1: container['CONTNRSDESC'],
                  icon2: Icons.category,
                  label2: 'Type',
                  value2: container['CONTNRTDESC'],
                ),
                const SizedBox(height: 12),
                _buildCompactDetailRow(
                  icon1: Icons.directions_boat,
                  label1: 'Vessel',
                  value1: container['VSLNAME'],
                  icon2: Icons.alt_route,
                  label2: 'Voyage',
                  value2: container['VOYNO'],
                ),
                const SizedBox(height: 12),
                _buildCompactDetailRow(
                  icon1: Icons.login,
                  label1: 'Gate In',
                  value1: '${_formatDate(container['GIDATE'])} ${_formatTime(container['GITIME'])}',
                  icon2: Icons.logout,
                  label2: 'Gate Out',
                  value2: _formatDateTime(container['GOTIME']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetailRow({
    required IconData icon1,
    required String label1,
    required String? value1,
    required IconData icon2,
    required String label2,
    required String? value2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildCompactDetailItem(icon1, label1, value1),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCompactDetailItem(icon2, label2, value2),
        ),
      ],
    );
  }

  Widget _buildCompactDetailItem(IconData icon, String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _generateColorFromString(String input) {
    final hash = input.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime != null) {
        return DateFormat('dd MMM yyyy').format(dateTime);
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'N/A';
    // Assuming timeString is in HH:mm:ss format or similar
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}'; // Format as HH:mm
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.tryParse(dateTimeString);
      if (dateTime != null) {
        return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
      }
      return dateTimeString;
    } catch (e) {
      return dateTimeString;
    }
  }
}