import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지
import 'dart:io';
import '../services/api_service.dart'; // ApiService 불러오기

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  File? _selectedImage; // 선택된 이미지 파일
  Offset? _includePoint; // 초록색 마스킹 좌표
  Offset? _excludePoint; // 빨간색 마스킹 좌표
  String _uploadStatus = ''; // 업로드 상태 메시지

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _navigateToMaskingScreen() {
    if (_selectedImage == null) {
      setState(() {
        _uploadStatus = 'Please select an image first.';
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageMaskingScreen(
          image: _selectedImage!,
          onSubmit: ({required Offset includePoint, required Offset excludePoint}) {
            setState(() {
              _includePoint = includePoint;
              _excludePoint = excludePoint;
            });

            print("Include Point: $_includePoint");
            print("Exclude Point: $_excludePoint");

            // 화면 전환을 약간 지연
            Future.delayed(Duration(milliseconds: 100), () {
              _navigateToClothesRegistration();
            });
          },
        ),
      ),
    );
  }

  void _navigateToClothesRegistration() {
    if (_includePoint == null || _excludePoint == null) {
      print("Error: Masking points are null. Cannot proceed.");
      return;
    }

    print("Navigating to ClothesRegistrationScreen");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClothesRegistrationScreen(
          userImage: _selectedImage!,
          includePoint: _includePoint!,
          excludePoint: _excludePoint!,
          onSubmit: _uploadImage,
        ),
      ),
    );
    print("Navigation to ClothesRegistrationScreen completed");
  }

  Future<void> _uploadImage({
    required File image,
    required String clothingName,
    required int rating,
    required List<String> clothingTypes, // 다중 선택
    required List<String> clothingStyles, // 다중 선택
    required String memo,
    required Offset includePoint,
    required Offset excludePoint,
  }) async {
    final response = await _apiService.uploadImage(
      image: image,
      clothingName: clothingName,
      rating: rating,
      clothingTypes: clothingTypes,
      clothingStyles: clothingStyles,
      memo: memo,
      includePoint: includePoint,
      excludePoint: excludePoint,
    );

    setState(() {
      if (response) {
        _uploadStatus = 'Image uploaded successfully!';
      } else {
        _uploadStatus = 'Image upload failed!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, ${widget.email}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              Column(
                children: [
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Pick an Image', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _navigateToMaskingScreen,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Upload Image', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _uploadStatus,
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ImageMaskingScreen extends StatefulWidget {
  final File image;
  final Function({
  required Offset includePoint,
  required Offset excludePoint,
  }) onSubmit;

  const ImageMaskingScreen({
    super.key,
    required this.image,
    required this.onSubmit,
  });

  @override
  State<ImageMaskingScreen> createState() => _ImageMaskingScreenState();
}

class _ImageMaskingScreenState extends State<ImageMaskingScreen> {
  Offset? _includePoint;
  Offset? _excludePoint;

  @override
  void initState() {
    super.initState();
    // 초기 상태: 좌표는 null
  }

  void _onImageTap(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.localPosition);

    setState(() {
      if (_includePoint == null) {
        _includePoint = localOffset;
      } else if (_excludePoint == null) {
        _excludePoint = localOffset;
      }
    });
  }

  void _resetPoints() {
    setState(() {
      _includePoint = null;
      _excludePoint = null;
    });
  }

  void _submit() {
    if (_includePoint == null || _excludePoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all required points")),
      );
      return;
    }

    widget.onSubmit(
      includePoint: _includePoint!,
      excludePoint: _excludePoint!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Masking points saved successfully!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Masking Points'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTapUp: _onImageTap,
            child: Stack(
              children: [
                Image.file(
                  widget.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                if (_includePoint != null)
                  Positioned(
                    left: _includePoint!.dx,
                    top: _includePoint!.dy,
                    child: const Icon(Icons.circle, color: Colors.green, size: 12),
                  ),
                if (_excludePoint != null)
                  Positioned(
                    left: _excludePoint!.dx,
                    top: _excludePoint!.dy,
                    child: const Icon(Icons.circle, color: Colors.red, size: 12),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _resetPoints,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Reset Points', style: TextStyle(fontSize: 18)),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save Points', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
class ClothesRegistrationScreen extends StatefulWidget {
  final File userImage;
  final Offset includePoint;
  final Offset excludePoint;
  final Function({
  required File image,
  required String clothingName,
  required int rating,
  required List<String> clothingTypes,
  required List<String> clothingStyles,
  required String memo,
  required Offset includePoint,
  required Offset excludePoint,
  }) onSubmit;

  const ClothesRegistrationScreen({
    super.key,
    required this.userImage,
    required this.includePoint,
    required this.excludePoint,
    required this.onSubmit,
  });

  @override
  State<ClothesRegistrationScreen> createState() =>
      _ClothesRegistrationScreenState();
}

class _ClothesRegistrationScreenState
    extends State<ClothesRegistrationScreen> {
  final TextEditingController _clothingNameController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  List<String> selectedClothingTypes = [];
  List<String> selectedClothingStyles = [];
  int selectedRating = 0;

  void _validateAndSubmit() {
    if (_clothingNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Clothing name cannot be empty")),
      );
      return;
    }
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating")),
      );
      return;
    }
    if (selectedClothingTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one type")),
      );
      return;
    }
    if (selectedClothingStyles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one style")),
      );
      return;
    }

    widget.onSubmit(
      image: widget.userImage,
      clothingName: _clothingNameController.text,
      rating: selectedRating,
      clothingTypes: selectedClothingTypes,
      clothingStyles: selectedClothingStyles,
      memo: _memoController.text,
      includePoint: widget.includePoint,
      excludePoint: widget.excludePoint,
    );

    Navigator.pop(context);
  }

  Widget _buildMultiSelectableButton(String label, List<String> list) {
    final isSelected = list.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            list.remove(label);
          } else {
            list.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothes Registration'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3, // 원하는 비율로 조정 가능
                  child: Image.file(
                    widget.userImage,
                    width: double.infinity,
                    fit: BoxFit.contain, // 이미지 전체가 보이도록 설정
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _clothingNameController,
                  decoration: const InputDecoration(
                      hintText: 'Enter clothing name'),
                ),
                const SizedBox(height: 12),
                Text("Rating:"),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text("Clothing Type:"),
                Wrap(
                  children: ['상의', '하의', '외투', '원피스', '액세서리']
                      .map((type) =>
                      _buildMultiSelectableButton(type, selectedClothingTypes))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Text("Clothing Style:"),
                Wrap(
                  children: ['캐주얼', '빈티지', '포멀', '미니멀']
                      .map((style) =>
                      _buildMultiSelectableButton(
                          style, selectedClothingStyles))
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _memoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Enter additional notes'),
                ),
                const SizedBox(height: 80), // 버튼 하단 여백
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Upload', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}