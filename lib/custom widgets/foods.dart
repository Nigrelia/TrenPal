import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';

class JsonDataEditor extends StatefulWidget {
  final String jsonPath;
  final Map<String, dynamic> jsonStructure;
  final List<String> displayColumns;
  final String searchHint;
  final Color primaryColor;
  final Color accentColor;
  final int itemsPerPage;
  final Map<String, String> columnLabels;
  final double? width;
  final double? height;
  final String title;
  final bool showAddButton;
  final String firstButtonText;
  final String secondButtonText;
  final String thirdButtonText;
  final String fourthButtonText;
  final Function(Map<String, dynamic>)? onFirstButtonPressed;
  final Function(Map<String, dynamic>)? onSecondButtonPressed;
  final Function(Map<String, dynamic>)? onThirdButtonPressed;
  final Function(Map<String, dynamic>)? onFourthButtonPressed;
  final bool showNutritionFacts;

  const JsonDataEditor({
    super.key,
    required this.jsonPath,
    required this.jsonStructure,
    this.displayColumns = const [
      'name',
      'calories',
      'carbs',
      'fats',
      'protein',
    ],
    this.searchHint = 'Search foods...',
    this.primaryColor = const Color(0xFF2A2A2A),
    this.accentColor = Colors.redAccent,
    this.itemsPerPage = 10,
    this.columnLabels = const {
      'name': 'Food',
      'calories': 'Calories',
      'carbs': 'Carbs (g)',
      'fats': 'Fats (g)',
      'protein': 'Protein (g)',
    },
    this.width,
    this.height,
    this.title = 'Nutrition Data Explorer',
    this.showAddButton = true,
    this.firstButtonText = 'Add to Meal',
    this.secondButtonText = 'Nutrition',
    this.thirdButtonText = 'Favorite',
    this.fourthButtonText = 'Compare',
    this.onFirstButtonPressed,
    this.onSecondButtonPressed,
    this.onThirdButtonPressed,
    this.onFourthButtonPressed,
    this.showNutritionFacts = true,
  });

  @override
  State<JsonDataEditor> createState() => _JsonDataEditorState();
}

class _JsonDataEditorState extends State<JsonDataEditor> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final Set<int> _expandedRows = <int>{};
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
    _loadJsonData();
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

  Future<void> _loadJsonData() async {
    setState(() => _isLoading = true);

    try {
      final jsonString = await rootBundle.loadString(widget.jsonPath);
      final jsonData = json.decode(jsonString) as List;

      _allItems = jsonData.map((item) => item as Map<String, dynamic>).toList();
      _filteredItems = List.from(_allItems);
    } catch (e) {
      debugPrint('Error loading JSON file: $e');
      _allItems = [];
      _filteredItems = [];
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveJsonData() async {
    debugPrint('Saving JSON data (simulated)');
    debugPrint(json.encode(_allItems));
  }

  Future<void> _addNewItem(Map<String, dynamic> newItem) async {
    setState(() {
      _allItems.add(newItem);
      _filteredItems = List.from(_allItems);
    });
    await _saveJsonData();
  }

  Future<void> _showAddItemDialog() async {
    final formKey = GlobalKey<FormState>();
    Map<String, dynamic> newItem = {};

    widget.jsonStructure.forEach((key, value) {
      newItem[key] = value is String ? '' : (value is int ? 0 : 0.0);
    });

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.primaryColor,
                      Color.lerp(widget.primaryColor, Colors.black, 0.3)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.accentColor.withOpacity(0.3),
                                    widget.accentColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: widget.accentColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Add New Food Item',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  ...widget.jsonStructure.entries.map((entry) {
                                    final key = entry.key;
                                    final value = entry.value;

                                    if (value is String) {
                                      return _buildTextField(
                                        label: widget.columnLabels[key] ?? key,
                                        value: newItem[key] as String,
                                        onChanged: (val) => newItem[key] = val,
                                        isRequired: true,
                                      );
                                    } else if (value is int ||
                                        value is double) {
                                      return _buildNumberField(
                                        label: widget.columnLabels[key] ?? key,
                                        value: newItem[key] as num,
                                        onChanged: (val) => newItem[key] = val,
                                        isInt: value is int,
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  }),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildDialogButton(
                                      'Cancel',
                                      Colors.grey[800]!,
                                      () => Navigator.pop(context),
                                      icon: Icons.close,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDialogButton(
                                      'Add Food',
                                      widget.accentColor,
                                      () {
                                        if (formKey.currentState!.validate()) {
                                          _addNewItem(newItem);
                                          Navigator.pop(context);
                                        }
                                      },
                                      icon: Icons.check,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              initialValue: value,
              style: TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: widget.accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: widget.accentColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: isRequired
                  ? (value) => value?.isEmpty ?? true ? 'Required field' : null
                  : null,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required num value,
    required ValueChanged<num> onChanged,
    bool isInt = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              initialValue: value.toString(),
              keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
              style: TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: widget.accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: widget.accentColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixText: isInt ? '' : 'g',
                suffixStyle: TextStyle(color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required field';
                final numValue = isInt
                    ? int.tryParse(value)
                    : double.tryParse(value);
                if (numValue == null) return 'Invalid number';
                return null;
              },
              onChanged: (value) {
                final numValue = isInt
                    ? int.tryParse(value)
                    : double.tryParse(value);
                if (numValue != null) onChanged(numValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton(
    String text,
    Color color,
    VoidCallback onPressed, {
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 20),
              if (icon != null) const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final responsiveWidth = widget.width ?? min(screenSize.width * 0.95, 800);
    final responsiveHeight = widget.height ?? screenSize.height * 0.7;
    final borderRadius = min(responsiveWidth * 0.02, 16.0);
    final horizontalPadding = min(responsiveWidth * 0.04, 20.0);
    final fontSize = min(responsiveHeight * 0.025, 18.0);
    final iconSize = min(responsiveHeight * 0.04, 26.0);

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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                Text(
                  '${_filteredItems.length} food items',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: fontSize * 0.8,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (widget.showAddButton)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white, size: iconSize),
                onPressed: _showAddItemDialog,
                style: IconButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  padding: const EdgeInsets.all(12),
                ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: widget.accentColor, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            'Loading nutrition data...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 0.3,
            ),
          ),
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
              flex: column == 'name' ? 2 : 1,
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
                    flex: column == 'name' ? 2 : 1,
                    child: Text(
                      _formatValue(item[column]),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: column == 'name'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: fontSize * 0.9,
                        letterSpacing: 0.3,
                      ),
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
      'calories',
      'protein',
      'carbs',
      'fats',
      'sugars',
      'fiber',
    ];

    const vitamins = [
      'vitaminA',
      'vitaminC',
      'vitaminD',
      'vitaminE',
      'vitaminK',
      'thiamin',
      'riboflavin',
      'niacin',
      'vitaminB6',
      'folate',
      'vitaminB12',
    ];

    const minerals = [
      'calcium',
      'iron',
      'magnesium',
      'phosphorus',
      'potassium',
      'sodium',
      'zinc',
      'copper',
      'manganese',
      'selenium',
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
          const SizedBox(height: 20),

          // First row of action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Edit',
                  () => _showEditItemDialog(item),
                  fontSize,
                  icon: Icons.edit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Delete',
                  () => _showDeleteConfirmation(item),
                  fontSize,
                  isDelete: true,
                  icon: Icons.delete,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row of programmable buttons
          Row(
            children: [
              if (widget.onFirstButtonPressed != null)
                Expanded(
                  child: _buildActionButton(
                    widget.firstButtonText,
                    () => widget.onFirstButtonPressed!(item),
                    fontSize,
                    icon: Icons.restaurant,
                  ),
                ),
              if (widget.onFirstButtonPressed != null &&
                  widget.onSecondButtonPressed != null)
                const SizedBox(width: 12),
              if (widget.onSecondButtonPressed != null)
                Expanded(
                  child: _buildActionButton(
                    widget.secondButtonText,
                    () => widget.onSecondButtonPressed!(item),
                    fontSize,
                    icon: Icons.food_bank,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Third row of programmable buttons
          Row(
            children: [
              if (widget.onThirdButtonPressed != null)
                Expanded(
                  child: _buildActionButton(
                    widget.thirdButtonText,
                    () => widget.onThirdButtonPressed!(item),
                    fontSize,
                    icon: Icons.favorite_border,
                  ),
                ),
              if (widget.onThirdButtonPressed != null &&
                  widget.onFourthButtonPressed != null)
                const SizedBox(width: 12),
              if (widget.onFourthButtonPressed != null)
                Expanded(
                  child: _buildActionButton(
                    widget.fourthButtonText,
                    () => widget.onFourthButtonPressed!(item),
                    fontSize,
                    icon: Icons.compare_arrows,
                  ),
                ),
            ],
          ),
        ],
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

  Widget _buildActionButton(
    String text,
    VoidCallback onPressed,
    double fontSize, {
    bool isDelete = false,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDelete
                  ? [Colors.red.withOpacity(0.8), Colors.red.withOpacity(0.6)]
                  : [
                      widget.accentColor.withOpacity(0.8),
                      widget.accentColor.withOpacity(0.6),
                    ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDelete
                  ? Colors.red.withOpacity(0.3)
                  : widget.accentColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, color: Colors.white, size: fontSize * 0.9),
              if (icon != null) const SizedBox(width: 8),
              Text(
                text,
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
      ),
    );
  }

  Future<void> _showEditItemDialog(Map<String, dynamic> item) async {
    final formKey = GlobalKey<FormState>();
    Map<String, dynamic> editedItem = Map.from(item);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.primaryColor,
                      Color.lerp(widget.primaryColor, Colors.black, 0.3)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.accentColor.withOpacity(0.3),
                                    widget.accentColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: widget.accentColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Edit Food Item',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  ...item.entries.map((entry) {
                                    final key = entry.key;
                                    final value = entry.value;

                                    if (value is String) {
                                      return _buildTextField(
                                        label: widget.columnLabels[key] ?? key,
                                        value: editedItem[key] as String,
                                        onChanged: (val) =>
                                            editedItem[key] = val,
                                        isRequired: true,
                                      );
                                    } else if (value is int ||
                                        value is double) {
                                      return _buildNumberField(
                                        label: widget.columnLabels[key] ?? key,
                                        value: editedItem[key] as num,
                                        onChanged: (val) =>
                                            editedItem[key] = val,
                                        isInt: value is int,
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  }),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildDialogButton(
                                      'Cancel',
                                      Colors.grey[800]!,
                                      () => Navigator.pop(context),
                                      icon: Icons.close,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDialogButton(
                                      'Save Changes',
                                      widget.accentColor,
                                      () {
                                        if (formKey.currentState!.validate()) {
                                          _updateItem(item, editedItem);
                                          Navigator.pop(context);
                                        }
                                      },
                                      icon: Icons.check,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateItem(
    Map<String, dynamic> oldItem,
    Map<String, dynamic> newItem,
  ) async {
    setState(() {
      final index = _allItems.indexWhere((item) => item == oldItem);
      if (index != -1) {
        _allItems[index] = newItem;
        _filteredItems = List.from(_allItems);
      }
    });
    await _saveJsonData();
  }

  Future<void> _showDeleteConfirmation(Map<String, dynamic> item) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirm Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to delete "${item['name']}"?',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        'Cancel',
                        Colors.grey[800]!,
                        () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDialogButton('Delete', Colors.red, () {
                        _deleteItem(item);
                        Navigator.pop(context);
                      }),
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

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    setState(() {
      _allItems.remove(item);
      _filteredItems = List.from(_allItems);
    });
    await _saveJsonData();
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
