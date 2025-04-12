import 'package:anyen_clinic/widget/QuestionCardInList.dart';
import 'package:anyen_clinic/widget/menu.dart';
import 'package:flutter/material.dart';
import 'psychological_test_screen.dart';

class PsychologicalTestHomeScreen extends StatefulWidget {
  const PsychologicalTestHomeScreen({super.key});
  static const List<Map<String, String>> questions = [
    {
      'title': 'Bài kiểm tra trầm cảm',
      'status': 'Đã hoàn thành',
      'questionCount': '6 câu hỏi',
      'buttonText': 'LÀM LẠI',
      'description':
          'Hãy đọc kỹ từng nhóm câu và chọn một câu mô tả đúng nhất về cảm xúc của bạn trong hai tuần qua.',
    },
    {
      'title': 'Bài kiểm tra lo âu',
      'status': 'Chưa làm',
      'questionCount': '6 câu hỏi',
      'buttonText': 'LÀM',
      'description':
          'Trong 2 tuần qua, bạn cảm thấy những điều sau đây với mức độ nào?',
    },
    {
      'title': 'Trắc nghiệm căng thẳng',
      'status': 'Chưa làm',
      'questionCount': '6 câu hỏi',
      'buttonText': 'LÀM',
      'description':
          'Trắc nghiệm giúp bạn đánh giá mức độ căng thẳng hiện tại.',
    },
    {
      'title': 'Trắc nghiệm EQ',
      'status': 'Chưa làm',
      'questionCount': '5 câu hỏi',
      'buttonText': 'LÀM',
      'description': 'Trắc nghiệm đo lường khả năng kiểm soát cảm xúc của bạn.',
    },
    {
      'title': 'Đánh giá giấc ngủ',
      'status': 'Chưa làm',
      'questionCount': '4 câu hỏi',
      'buttonText': 'LÀM',
      'description': 'Đánh giá nhanh tình trạng rối loạn giấc ngủ.',
    },
  ];

  @override
  State<PsychologicalTestHomeScreen> createState() =>
      _QuestionListScreenState();
}

class _QuestionListScreenState extends State<PsychologicalTestHomeScreen> {
  late ScrollController _scrollController;
  final List<Map<String, String>> _displayedQuestions = [];
  int _currentPage = 1;
  final int _itemsPerPage = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadMoreQuestions(); // Load dữ liệu ban đầu
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
      _loadMoreQuestions();
    }
  }

  void _loadMoreQuestions() {
    if (_isLoading ||
        _displayedQuestions.length >=
            PsychologicalTestHomeScreen.questions.length) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > PsychologicalTestHomeScreen.questions.length) {
      endIndex = PsychologicalTestHomeScreen.questions.length;
    }

    List<Map<String, String>> newQuestions =
        PsychologicalTestHomeScreen.questions.sublist(startIndex, endIndex);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _displayedQuestions.addAll(newQuestions);
        _currentPage++;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Trắc nghiệm tâm lý",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      floatingActionButton: Menu(),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenWidth * 0.05),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _displayedQuestions.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _displayedQuestions.length) {
              return Center(child: CircularProgressIndicator());
            }
            final question = _displayedQuestions[index];
            return QuestionCardInList(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              title: question['title'] ?? '',
              status: question['status'] ?? '',
              questionCount: question['questionCount'] ?? '',
              buttonText: question['buttonText'] ?? '',
              description: question['description'] ?? '',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PsychologicalTestScreen(
                              title: question['title'] ?? '',
                            )));
              },
            );
          },
        ),
      ),
    );
  }
}
