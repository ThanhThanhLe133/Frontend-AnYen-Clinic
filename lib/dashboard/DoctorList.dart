import 'package:anyen_clinic/widget/DoctorCardInListRow.dart';
import 'package:flutter/material.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({super.key});

  static const List<Map<String, String>> doctors = [
    {
      'name': 'BS.CKI Marcus Horizon',
      'specialty': 'Tâm lý - Nội tổng quát',
      'workplace': 'Bệnh viện ĐH Y Dược',
      'image': 'https://i.imgur.com/Y6W5JhB.png'
    },
    {
      'name': 'BS.CKI Anna Smith',
      'specialty': 'Da liễu - Thẩm mỹ',
      'workplace': 'Bệnh viện Chợ Rẫy',
      'image': 'https://i.imgur.com/Y6W5JhB.png'
    },
    {
      'name': 'BS.CKI Michael Tran',
      'specialty': 'Nội khoa - Tim mạch',
      'workplace': 'Bệnh viện Bình Dân',
      'image': 'https://i.imgur.com/Y6W5JhB.png'
    },
    {
      'name': 'BS.CKI Emily Johnson',
      'specialty': 'Nhi khoa - Hô hấp',
      'workplace': 'Bệnh viện Nhi Đồng',
      'image': 'https://i.imgur.com/Y6W5JhB.png'
    },
  ];

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  late ScrollController _scrollController;
  final List<Map<String, String>> _displayedDoctors = [];
  int _currentPage = 1;
  final int _itemsPerPage = 4;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadMoreDoctors();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading) {
      _loadMoreDoctors();
    }
  }

  void _loadMoreDoctors() {
    if (_isLoading || _displayedDoctors.length >= DoctorList.doctors.length) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > DoctorList.doctors.length) {
      endIndex = DoctorList.doctors.length;
    }

    List<Map<String, String>> newDoctors =
        DoctorList.doctors.sublist(startIndex, endIndex);

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _displayedDoctors.addAll(newDoctors);
        _currentPage++;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.5, // Giới hạn chiều cao để tránh lỗi layout
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        shrinkWrap: true,
        itemCount: _displayedDoctors.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _displayedDoctors.length) {
            return Center(child: CircularProgressIndicator());
          }
          return DoctorCardInListRow(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            name: _displayedDoctors[index]['name']!,
            specialty: _displayedDoctors[index]['specialty']!,
            workplace: _displayedDoctors[index]['workplace']!,
            imageUrl: _displayedDoctors[index]['image']!,
          );
        },
      ),
    );
  }
}
