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
  String _uploadStatus = ''; // 업로드 상태 메시지

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage({
    required File image,
    required String clothingName,
    required int rating,
    required String clothingType,
    required String clothingStyle,
    required String memo,
  }) async {
    final response = await _apiService.uploadImage(
      image: image,
      clothingName: clothingName,
      rating: rating,
      clothingType: clothingType,
      clothingStyle: clothingStyle,
      memo: memo,
    );

    setState(() {
      if (response) {
        _uploadStatus = 'Image uploaded successfully!';
      } else {
        _uploadStatus = 'Image upload failed!';
      }
    });
  }

  void _navigateToClothesRegistration() {
    if (_selectedImage == null) {
      setState(() {
        _uploadStatus = 'Please select an image first.';
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClothesRegistrationScreen(
          userImage: _selectedImage!,
          onSubmit: _uploadImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Back 버튼 비활성화
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
              onPressed: _navigateToClothesRegistration,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Register Clothes', style: TextStyle(fontSize: 18)),
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

// ClothesRegistrationScreen
class ClothesRegistrationScreen extends StatefulWidget {
  final File userImage;
  final Function({
  required File image,
  required String clothingName,
  required int rating,
  required String clothingType,
  required String clothingStyle,
  required String memo,
  }) onSubmit;

  const ClothesRegistrationScreen({
    super.key,
    required this.userImage,
    required this.onSubmit,
  });

  @override
  State<ClothesRegistrationScreen> createState() =>
      _ClothesRegistrationScreenState();
}

class _ClothesRegistrationScreenState
    extends State<ClothesRegistrationScreen> {
  final TextEditingController _clothingNameController =
  TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  String selectedClothingType = '';
  String selectedClothingStyle = '';
  int selectedRating = 0;

  void _validateAndSubmit() {
    setState(() {
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
      if (selectedClothingType.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a clothing type")),
        );
        return;
      }
      if (selectedClothingStyle.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a clothing style")),
        );
        return;
      }
    });

    widget.onSubmit(
      image: widget.userImage,
      clothingName: _clothingNameController.text,
      rating: selectedRating,
      clothingType: selectedClothingType,
      clothingStyle: selectedClothingStyle,
      memo: _memoController.text,
    );

    Navigator.pop(context);
  }

  Widget _buildSelectableButton(String label, bool isSelected, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        title: const Text('옷 등록'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.file(
                widget.userImage,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clothingNameController,
              decoration: const InputDecoration(hintText: '옷 이름을 입력하세요'),
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
                  .map((type) => _buildSelectableButton(
                type,
                selectedClothingType == type,
                    () => setState(() {
                  selectedClothingType = type;
                }),
              ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text("Clothing Style:"),
            Wrap(
              children: ['캐주얼', '빈티지', '포멀', '미니멀']
                  .map((style) => _buildSelectableButton(
                style,
                selectedClothingStyle == style,
                    () => setState(() {
                  selectedClothingStyle = style;
                }),
              ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: '추가 메모를 입력하세요'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateAndSubmit,
              child: const Text('등록하기'),
            ),
          ],
        ),
      ),
    );
  }
}