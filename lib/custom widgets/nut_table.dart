import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedNutritionTable extends StatefulWidget {
  final List<String>? csvPaths; // Made optional
  final String? csvPath; // Added single path option
  final List<String> displayColumns;
  final String searchHint;
  final Color primaryColor;
  final Color accentColor;
  final int itemsPerPage;
  final bool showNutritionFacts;
  final Map<String, String> columnLabels;
  final double? width;
  final double? height;
  final String title;
  final String firstButtonText;
  final String secondButtonText;
  final Function(Map<String, dynamic>)? onFirstButtonPressed;
  final Function(Map<String, dynamic>)? onSecondButtonPressed;
  final bool showDataSource;
  final Map<String, String>? csvLabels;

  const EnhancedNutritionTable({
    super.key,
    this.csvPaths, // Optional multiple paths
    this.csvPath, // Optional single path
    this.displayColumns = const ['food', 'Caloric Value', 'Protein', 'Fat'],
    this.searchHint = 'Search foods...',
    this.primaryColor = const Color(0xFF2A2A2A),
    this.accentColor = Colors.redAccent,
    this.itemsPerPage = 10,
    this.showNutritionFacts = true,
    this.columnLabels = const {
      'food': 'Food',
      'Caloric Value': 'Calories',
      'Protein': 'Protein (g)',
      'Fat': 'Fat (g)',
    },
    this.width,
    this.height,
    this.title = 'Nutrition Data Explorer',
    this.firstButtonText = 'Action 1',
    this.secondButtonText = 'Action 2',
    this.onFirstButtonPressed,
    this.onSecondButtonPressed,
    this.showDataSource = false,
    this.csvLabels,
  }) : assert(
         (csvPath != null && csvPaths == null) ||
             (csvPath == null && csvPaths != null),
         'Either csvPath or csvPaths must be provided, but not both',
       );

  // Helper getter to get all paths as a list
  List<String> get _allCsvPaths {
    if (csvPath != null) {
      return [csvPath!];
    }
    return csvPaths ?? [];
  }

  @override
  State<EnhancedNutritionTable> createState() => _EnhancedNutritionTableState();
}

class _EnhancedNutritionTableState extends State<EnhancedNutritionTable>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final Set<int> _expandedRows = <int>{};
  bool _isSearchFocused = false;
  final Map<String, int> _loadingProgress = {};
  int _totalCsvFiles = 0;
  int _loadedCsvFiles = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
    _totalCsvFiles = widget._allCsvPaths.length;
    _loadAllCsvData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = _allItems.where((item) {
        return item.entries.any(
          (entry) => entry.value.toString().toLowerCase().contains(query),
        );
      }).toList();
      _currentPage = 0;
      _expandedRows.clear();
    });
  }

  Future<void> _loadAllCsvData() async {
    setState(() {
      _isLoading = true;
      _loadedCsvFiles = 0;
      _allItems.clear();
    });

    List<Map<String, dynamic>> combinedItems = [];
    final csvPaths = widget._allCsvPaths;

    // Load all CSV files concurrently
    List<Future<List<Map<String, dynamic>>>> loadingFutures = [];

    for (int i = 0; i < csvPaths.length; i++) {
      final csvPath = csvPaths[i];
      loadingFutures.add(_loadSingleCsvData(csvPath, i));
    }

    try {
      // Wait for all CSV files to load
      List<List<Map<String, dynamic>>> results = await Future.wait(
        loadingFutures,
      );

      // Combine all results
      for (var result in results) {
        combinedItems.addAll(result);
      }

      _allItems = combinedItems;
      _filteredItems = List.from(_allItems);
    } catch (e) {
      debugPrint('Error loading CSV files: $e');
      _allItems = [];
      _filteredItems = [];
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadSingleCsvData(
    String csvPath,
    int csvIndex,
  ) async {
    try {
      final csvString = await rootBundle.loadString(csvPath);
      final lines = csvString.split('\n');

      if (lines.isEmpty) {
        throw Exception('CSV file is empty: $csvPath');
      }

      final headers = lines.first.split(',').map((h) => h.trim()).toList();

      List<Map<String, dynamic>> items = lines
          .skip(1)
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            final values = line.split(',');
            final item = <String, dynamic>{};

            for (int i = 0; i < headers.length && i < values.length; i++) {
              final header = headers[i];
              final value = values[i].trim();
              item[header] = double.tryParse(value) ?? value;
            }

            // Add metadata about data source
            item['_csvPath'] = csvPath;
            item['_csvIndex'] = csvIndex;
            item['_csvLabel'] =
                widget.csvLabels?[csvPath] ?? 'Dataset ${csvIndex + 1}';

            return item;
          })
          .toList();

      // Update loading progress
      if (mounted) {
        setState(() {
          _loadedCsvFiles++;
          _loadingProgress[csvPath] = items.length;
        });
      }

      return items;
    } catch (e) {
      debugPrint('Error loading CSV file $csvPath: $e');
      if (mounted) {
        setState(() {
          _loadedCsvFiles++;
          _loadingProgress[csvPath] = 0;
        });
      }
      return [];
    }
  }

  List<Map<String, dynamic>> get _paginatedItems {
    if (_filteredItems.isEmpty) return [];
    final start = _currentPage * widget.itemsPerPage;
    final end = start + widget.itemsPerPage;
    return _filteredItems.sublist(start, end.clamp(0, _filteredItems.length));
  }

  int get _totalPages {
    if (_filteredItems.isEmpty) return 1;
    return (_filteredItems.length / widget.itemsPerPage).ceil();
  }

  void _toggleRowExpansion(int index) {
    setState(() {
      if (_expandedRows.contains(index)) {
        _expandedRows.remove(index);
      } else {
        _expandedRows.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final orientation = MediaQuery.of(context).orientation;

    // Calculate responsive dimensions
    double responsiveWidth;
    double responsiveHeight;

    if (widget.width != null && widget.height != null) {
      responsiveWidth = widget.width!;
      responsiveHeight = widget.height!;
    } else {
      if (orientation == Orientation.portrait) {
        responsiveWidth = screenWidth * 0.95;
        responsiveHeight = screenHeight * 0.7;
      } else {
        responsiveWidth = screenWidth * 0.8;
        responsiveHeight = screenHeight * 0.8;
      }
      responsiveWidth = responsiveWidth.clamp(300.0, 800.0);
      responsiveHeight = responsiveHeight.clamp(400.0, 700.0);
    }

    double borderRadius = responsiveWidth * 0.02;
    double horizontalPadding = responsiveWidth * 0.04;
    double fontSize = responsiveHeight * 0.025;
    double iconSize = responsiveHeight * 0.04;

    borderRadius = borderRadius.clamp(8.0, 16.0);
    horizontalPadding = horizontalPadding.clamp(12.0, 20.0);
    fontSize = fontSize.clamp(14.0, 18.0);
    iconSize = iconSize.clamp(20.0, 26.0);

    return SizedBox(
      width: responsiveWidth,
      height: responsiveHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF404040), Color(0xFF2A2A2A)],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.6),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(horizontalPadding, fontSize, iconSize),
              _buildSearchBar(horizontalPadding, fontSize, iconSize),
              Expanded(
                child: _isLoading
                    ? _buildLoading()
                    : _buildTable(fontSize, iconSize),
              ),
              if (!_isLoading && _filteredItems.isNotEmpty)
                _buildPagination(fontSize, iconSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    double horizontalPadding,
    double fontSize,
    double iconSize,
  ) {
    final csvPaths = widget._allCsvPaths;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withOpacity(0.2),
            widget.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant, color: widget.accentColor, size: iconSize),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (csvPaths.length > 1)
                  Text(
                    '${csvPaths.length} data sources',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: fontSize * 0.8,
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${_filteredItems.length} items',
            style: TextStyle(
              color: widget.accentColor,
              fontWeight: FontWeight.w500,
              fontSize: fontSize * 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    double horizontalPadding,
    double fontSize,
    double iconSize,
  ) {
    bool hasValue = _searchController.text.isNotEmpty;
    bool shouldShowFloatingLabel = _isSearchFocused || hasValue;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Stack(
        children: [
          // Floating label
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 12,
            top: shouldShowFloatingLabel ? 0 : 22,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: shouldShowFloatingLabel
                    ? (_isSearchFocused ? widget.accentColor : Colors.grey[300])
                    : Colors.grey[400],
                fontSize: shouldShowFloatingLabel ? 12 : fontSize * 0.9,
                fontWeight: shouldShowFloatingLabel
                    ? FontWeight.w600
                    : FontWeight.w500,
                letterSpacing: 0.5,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: shouldShowFloatingLabel ? 1.0 : 0.7,
                child: Container(
                  padding: shouldShowFloatingLabel
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                      : EdgeInsets.zero,
                  decoration: shouldShowFloatingLabel
                      ? BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        )
                      : null,
                  child: Text(widget.searchHint),
                ),
              ),
            ),
          ),
          // Search input
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(top: shouldShowFloatingLabel ? 18 : 0),
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isSearchFocused
                    ? [const Color(0xFF404040), const Color(0xFF2A2A2A)]
                    : [const Color(0xFF363636), const Color(0xFF1F1F1F)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isSearchFocused
                    ? widget.accentColor.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.2),
                width: _isSearchFocused ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _isSearchFocused
                      ? widget.accentColor
                      : Colors.grey[400],
                  size: iconSize,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: widget.accentColor,
                          size: iconSize * 0.8,
                        ),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    final csvPaths = widget._allCsvPaths;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: widget.accentColor),
          const SizedBox(height: 16),
          Text(
            'Loading nutrition data...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loaded $_loadedCsvFiles of $_totalCsvFiles files',
            style: TextStyle(
              color: widget.accentColor,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          if (_loadingProgress.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...csvPaths.map((path) {
              final count = _loadingProgress[path] ?? 0;
              final label = widget.csvLabels?[path] ?? path.split('/').last;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '$label: $count items',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTable(double fontSize, double iconSize) {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'No matching foods found',
              style: TextStyle(
                color: Colors.white70,
                fontSize: fontSize,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildTableHeader(fontSize),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _paginatedItems.length,
            itemBuilder: (context, index) {
              final item = _paginatedItems[index];
              final isExpanded = _expandedRows.contains(index);
              return _buildTableRow(
                item,
                index,
                isExpanded,
                fontSize,
                iconSize,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withOpacity(0.2),
            widget.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          ...widget.displayColumns.map(
            (column) => Expanded(
              flex: column == 'food' ? 2 : 1,
              child: Text(
                widget.columnLabels[column] ?? column,
                style: TextStyle(
                  color: widget.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize * 0.9,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          if (widget.showDataSource && widget._allCsvPaths.length > 1)
            Expanded(
              flex: 1,
              child: Text(
                'Source',
                style: TextStyle(
                  color: widget.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize * 0.9,
                  letterSpacing: 0.3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    Map<String, dynamic> item,
    int index,
    bool isExpanded,
    double fontSize,
    double iconSize,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF404040), const Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.accentColor,
              size: iconSize,
            ),
            title: Row(
              children: [
                ...widget.displayColumns.map(
                  (column) => Expanded(
                    flex: column == 'food' ? 2 : 1,
                    child: Text(
                      _formatValue(item[column]),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: column == 'food'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: fontSize * 0.9,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                if (widget.showDataSource && widget._allCsvPaths.length > 1)
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['_csvLabel'] ?? 'Unknown',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: fontSize * 0.7,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () => _toggleRowExpansion(index),
          ),
          if (isExpanded) _buildExpandedContent(item, fontSize),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Map<String, dynamic> item, double fontSize) {
    const nutritionFacts = [
      'Caloric Value',
      'Protein',
      'Fat',
      'Carbohydrates',
      'Sugars',
      'Dietary Fiber',
      'Sodium',
      'Cholesterol',
    ];
    const vitamins = [
      'Vitamin A',
      'Vitamin B1',
      'Vitamin B2',
      'Vitamin B3',
      'Vitamin B6',
      'Vitamin B12',
      'Vitamin C',
      'Vitamin D',
      'Vitamin E',
    ];
    const minerals = [
      'Calcium',
      'Iron',
      'Magnesium',
      'Phosphorus',
      'Potassium',
      'Sodium',
      'Zinc',
      'Copper',
      'Manganese',
      'Selenium',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Data source info
          if (widget._allCsvPaths.length > 1)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor.withOpacity(0.3),
                    widget.accentColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.accentColor.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.source, color: widget.accentColor, size: fontSize),
                  const SizedBox(width: 8),
                  Text(
                    'Source: ${item['_csvLabel']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 0.9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

          if (widget.showNutritionFacts) ...[
            _buildNutritionSection(
              'Nutrition Facts',
              nutritionFacts,
              item,
              fontSize,
            ),
            const SizedBox(height: 16),
          ],
          _buildNutritionSection('Vitamins', vitamins, item, fontSize),
          const SizedBox(height: 16),
          _buildNutritionSection('Minerals', minerals, item, fontSize),
          const SizedBox(height: 16),
          // Action buttons for each expanded item
          _buildItemActionButtons(item, fontSize),
        ],
      ),
    );
  }

  Widget _buildItemActionButtons(Map<String, dynamic> item, double fontSize) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            widget.firstButtonText,
            () => widget.onFirstButtonPressed?.call(item),
            fontSize,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            widget.secondButtonText,
            () => widget.onSecondButtonPressed?.call(item),
            fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    VoidCallback onPressed,
    double fontSize,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.accentColor.withOpacity(0.8),
              widget.accentColor.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.accentColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize * 0.9,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSection(
    String title,
    List<String> keys,
    Map<String, dynamic> item,
    double fontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: widget.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keys.map((key) {
            final value = item[key];
            return value != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.accentColor.withOpacity(0.2),
                          widget.accentColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.columnLabels[key] ?? key}: ${_formatValue(value)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize * 0.8,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }).toList(),
        ),
      ],
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  Widget _buildPagination(double fontSize, double iconSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withOpacity(0.1),
            widget.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${_currentPage + 1} of $_totalPages',
            style: TextStyle(
              color: Colors.white70,
              fontSize: fontSize * 0.9,
              letterSpacing: 0.3,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPaginationButton(Icons.chevron_left, _currentPage > 0, () {
                setState(() => _currentPage--);
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }, iconSize),
              const SizedBox(width: 8),
              _buildPaginationButton(
                Icons.chevron_right,
                _currentPage < _totalPages - 1,
                () {
                  setState(() => _currentPage++);
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                iconSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(
    IconData icon,
    bool enabled,
    VoidCallback onPressed,
    double iconSize,
  ) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor.withOpacity(0.8),
                    widget.accentColor.withOpacity(0.6),
                  ],
                )
              : null,
          color: enabled ? null : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? widget.accentColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey,
          size: iconSize,
        ),
      ),
    );
  }
}
