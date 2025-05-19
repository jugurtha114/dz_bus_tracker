// lib/screens/passenger/line_search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/line_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/passenger/line_list_item.dart';
import '../../helpers/error_handler.dart';

class LineSearchScreen extends StatefulWidget {
  const LineSearchScreen({Key? key}) : super(key: key);

  @override
  State<LineSearchScreen> createState() => _LineSearchScreenState();
}

class _LineSearchScreenState extends State<LineSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLines() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lineProvider = Provider.of<LineProvider>(context, listen: false);
      await lineProvider.fetchLines(isActive: true);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Map<String, dynamic>> _getFilteredLines() {
    final lineProvider = Provider.of<LineProvider>(context);

    if (_searchQuery.isEmpty) {
      return lineProvider.lines;
    }

    return lineProvider.lines.where((line) {
      final name = line['name']?.toString().toLowerCase() ?? '';
      final code = line['code']?.toString().toLowerCase() ?? '';
      final description = line['description']?.toString().toLowerCase() ?? '';

      return name.contains(_searchQuery) ||
          code.contains(_searchQuery) ||
          description.contains(_searchQuery);
    }).toList();
  }

  void _onLineSelected(Map<String, dynamic> line) {
    final lineProvider = Provider.of<LineProvider>(context, listen: false);
    lineProvider.setSelectedLine(line);
    AppRouter.navigateTo(context, AppRoutes.lineDetails);
  }

  @override
  Widget build(BuildContext context) {
    final filteredLines = _getFilteredLines();

    return Scaffold(
      appBar: const DzAppBar(
        title: 'Search Lines',
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by line name, code, or description',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
              child: LoadingIndicator(),
            )
                : filteredLines.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: AppColors.mediumGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No lines available'
                        : 'No lines matching "$_searchQuery"',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredLines.length,
              itemBuilder: (context, index) {
                final line = filteredLines[index];

                return LineListItem(
                  line: line,
                  onTap: () => _onLineSelected(line),
                  showStops: true,
                  showSchedule: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}