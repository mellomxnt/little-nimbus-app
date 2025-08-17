import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cloud_database.dart';
import '../../models/cloud_info.dart';
import '../../theme/app_colors.dart';
import 'cloud_detail_page.dart';

class CloudLearningPage extends StatefulWidget {
  @override
  State<CloudLearningPage> createState() => _CloudLearningPageState();
}

class _CloudLearningPageState extends State<CloudLearningPage> with SingleTickerProviderStateMixin {
  List<CloudInfo> _allClouds = [];
  List<CloudInfo> _displayedClouds = [];
  String _selectedType = 'ทั้งหมด';
  String _searchQuery = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _cloudTypes = [
    {'name': 'ทั้งหมด', 'icon': Icons.cloud_outlined, 'color': AppColors.primary},
    {'name': 'cumulus', 'icon': Icons.cloud, 'color': AppColors.accent},
    {'name': 'cirrus', 'icon': Icons.air, 'color': AppColors.lavender},
    {'name': 'stratus', 'icon': Icons.layers, 'color': AppColors.mintGreen},
    {'name': 'nimbostratus', 'icon': Icons.water_drop, 'color': AppColors.sunYellow},
    {'name': 'altocumulus', 'icon': Icons.filter_drama, 'color': AppColors.peach},
    {'name': 'altostratus', 'icon': Icons.horizontal_split, 'color': AppColors.primaryDark},
    {'name': 'cumulonimbus', 'icon': Icons.thunderstorm, 'color': AppColors.accentDark},
    {'name': 'cirrocumulus', 'icon': Icons.grain, 'color': AppColors.primary},
    {'name': 'cirrostratus', 'icon': Icons.blur_on, 'color': AppColors.accent},
    {'name': 'stratocumulus', 'icon': Icons.dashboard, 'color': AppColors.mintGreen},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _loadClouds();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadClouds() async {
    final clouds = await CloudDatabase.instance.getAllClouds();
    setState(() {
      _allClouds = clouds;
      _displayedClouds = clouds;
    });
  }

  void _filterClouds(String type) {
    setState(() {
      _selectedType = type;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<CloudInfo> filtered = _selectedType == 'ทั้งหมด'
        ? _allClouds
        : _allClouds.where((c) => (c.name ?? '').toLowerCase().contains(_selectedType.toLowerCase())).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        final name = c.name?.toLowerCase() ?? '';
        final desc = c.description?.toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase()) || desc.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _displayedClouds = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      appBar: _buildAppBar(isDarkMode),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchBar(isDarkMode),
            _buildFilterChips(isDarkMode),
            _buildInfoBanner(isDarkMode),
            Expanded(
              child: _displayedClouds.isEmpty 
                  ? _buildEmptyState(isDarkMode)
                  : _buildCloudGrid(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.white10 : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('☁️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'เรียนรู้เมฆ',
              style: GoogleFonts.notoSansThai(
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _applyFilters();
            });
          },
          style: GoogleFonts.notoSansThai(
            fontSize: 14,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'ค้นหาชื่อเมฆ...',
            hintStyle: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: isDarkMode ? Colors.white54 : AppColors.textMuted,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDarkMode ? Colors.white54 : AppColors.textMuted,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDarkMode) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _cloudTypes.length,
        itemBuilder: (context, index) {
          final type = _cloudTypes[index];
          final isSelected = type['name'] == _selectedType;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type['icon'],
                    size: 16,
                    color: isSelected ? Colors.white : type['color'],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type['name'] == 'ทั้งหมด' ? 'ทั้งหมด' : type['name'].toUpperCase(),
                    style: GoogleFonts.notoSansThai(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              onSelected: (_) => _filterClouds(type['name']),
              backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
              selectedColor: type['color'],
              side: BorderSide(
                color: isSelected 
                    ? type['color'] 
                    : (isDarkMode ? Colors.white10 : AppColors.borderLight),
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white : AppColors.textPrimary),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppColors.darkPrimary.withOpacity(0.2)
            : AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? AppColors.darkPrimary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 18,
              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'แตะที่การ์ดเพื่อดูข้อมูลเพิ่มเติม',
              style: GoogleFonts.notoSansThai(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudGrid(bool isDarkMode) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _displayedClouds.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final cloud = _displayedClouds[index];
        return _buildCloudCard(cloud, index, isDarkMode);
      },
    );
  }

  Widget _buildCloudCard(CloudInfo cloud, int index, bool isDarkMode) {
    final name = cloud.name ?? 'ไม่ระบุชื่อ';
    final description = cloud.description ?? 'ไม่มีคำอธิบาย';
    
    // Find matching cloud type for color
    final cloudType = _cloudTypes.firstWhere(
      (type) => type['name'].toLowerCase() == name.toLowerCase(),
      orElse: () => _cloudTypes[0],
    );
    final cardColor = cloudType['color'] as Color;

    return Hero(
      tag: 'cloud_$name',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    CloudDetailPage(cloudName: name),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: (cloud.imageUrl != null && cloud.imageUrl!.isNotEmpty)
                            ? Image.asset(
                                cloud.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: cardColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.cloud_outlined,
                                      size: 50,
                                      color: cardColor,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: cardColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.cloud_outlined,
                                  size: 50,
                                  color: cardColor,
                                ),
                              ),
                      ),
                      // Gradient Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cloud Name
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name.toUpperCase(),
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Description
                        Expanded(
                          child: Text(
                            description,
                            style: GoogleFonts.notoSansThai(
                              fontSize: 11,
                              color: isDarkMode ? Colors.white70 : AppColors.textMuted,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.bgGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: isDarkMode ? Colors.white38 : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบข้อมูลเมฆ',
            style: GoogleFonts.notoSansThai(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองค้นหาด้วยคำอื่น หรือเลือกประเภทอื่น',
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}