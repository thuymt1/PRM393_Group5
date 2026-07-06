import 'package:flutter/material.dart';

class AddHomestayBasicInfoScreen extends StatefulWidget {
  const AddHomestayBasicInfoScreen({super.key});

  @override
  State<AddHomestayBasicInfoScreen> createState() => _AddHomestayBasicInfoScreenState();
}

class _AddHomestayBasicInfoScreenState extends State<AddHomestayBasicInfoScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedStayType = 'Toàn bộ nhà';
  int _maxGuests = 2;

  final List<Map<String, dynamic>> _stayTypes = [
    {'label': 'Toàn bộ nhà', 'icon': Icons.home_outlined, 'desc': 'Khách thuê riêng cả căn'},
    {'label': 'Phòng riêng', 'icon': Icons.bedroom_parent_outlined, 'desc': 'Phòng riêng trong nhà bạn'},
    {'label': 'Phòng chung', 'icon': Icons.people_outline, 'desc': 'Chia sẻ không gian chung'},
    {'label': 'Khách sạn', 'icon': Icons.hotel_outlined, 'desc': 'Phòng trong cơ sở lưu trú'},
  ];

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close, color: Color(0xFF374151), size: 20),
          ),
        ),
        title: const Text(
          'Đăng tin mới',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _buildAnimatedProgress(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(),
                  const SizedBox(height: 24),
                  _buildInputField(
                    label: 'Tên Homestay',
                    hint: 'VD: The Pine Hill Dalat',
                    controller: _nameController,
                    icon: Icons.home_work_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'Mô tả',
                    hint: 'Giới thiệu về không gian, tiện ích và phong cách sống tại đây...',
                    controller: _descriptionController,
                    maxLines: 4,
                    icon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildMaxGuestsPicker(),
                  const SizedBox(height: 24),
                  _buildStayTypeSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildAnimatedProgress() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (_, __) => LinearProgressIndicator(
        value: _progressAnimation.value,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE07A5F)),
        minHeight: 4,
      ),
    );
  }

  Widget _buildStepHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B4A35), Color(0xFF5D3A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bước 1 / 4 — Thông tin cơ bản',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Bắt đầu bằng những chi tiết cốt lõi về không gian của bạn.',
                  style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151), fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE07A5F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFFE07A5F), size: 16),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxGuestsPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số khách tối đa',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151), fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE07A5F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people_outline, color: Color(0xFFE07A5F), size: 16),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Số khách', style: TextStyle(color: Color(0xFF374151), fontSize: 14)),
              ),
              Row(
                children: [
                  _counterButton(Icons.remove, () {
                    if (_maxGuests > 1) setState(() => _maxGuests--);
                  }),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$_maxGuests',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
                    ),
                  ),
                  _counterButton(Icons.add, () {
                    if (_maxGuests < 20) setState(() => _maxGuests++);
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E0D0)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF5D3A2E)),
      ),
    );
  }

  Widget _buildStayTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại chỗ ở',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151), fontSize: 14),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: _stayTypes.length,
          itemBuilder: (context, i) {
            final type = _stayTypes[i];
            final isSelected = _selectedStayType == type['label'];

            return GestureDetector(
              onTap: () => setState(() => _selectedStayType = type['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5D3A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: const Color(0xFF5D3A2E).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      type['icon'],
                      size: 22,
                      color: isSelected ? Colors.white : const Color(0xFFE07A5F),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['label'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          type['desc'],
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected ? Colors.white60 : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          // Step indicator dots
          Row(
            children: List.generate(4, (i) {
              return Container(
                margin: const EdgeInsets.only(right: 6),
                width: i == 0 ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == 0 ? const Color(0xFFE07A5F) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin')));
                 return;
              }
              Navigator.pushNamed(context, '/add-homestay-location', arguments: {
                'name': _nameController.text,
                'description': _descriptionController.text,
                'max_guests': _maxGuests,
                'category_id': 1, // Default mapping
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D3A2E),
              minimumSize: const Size(140, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tiếp theo', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}