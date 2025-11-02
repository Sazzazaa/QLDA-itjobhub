import 'package:flutter/material.dart';
import 'package:itjobhub/features/candidate/screens/job_board_screen.dart';
import 'package:itjobhub/features/candidate/screens/applications_screen.dart';
import 'package:itjobhub/features/candidate/screens/interview_list_screen.dart';
import 'package:itjobhub/features/candidate/screens/candidate_profile_screen.dart';
import 'package:itjobhub/features/shared/screens/conversations_screen.dart';
import 'package:itjobhub/services/message_service.dart';
import 'package:itjobhub/services/review_service.dart';
import 'package:itjobhub/services/user_state.dart';
import 'package:itjobhub/services/api_client.dart';

class CandidateMainScreen extends StatefulWidget {
  const CandidateMainScreen({super.key});

  @override
  State<CandidateMainScreen> createState() => _CandidateMainScreenState();
}

class _CandidateMainScreenState extends State<CandidateMainScreen> {
  final MessageService _messageService = MessageService();
  final ReviewService _reviewService = ReviewService();
  final UserState _userState = UserState();
  final ApiClient _apiClient = ApiClient();
  int _currentIndex = 0;
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    print('🔧 CandidateMainScreen: Initializing services...');
    
    // Ensure ApiClient token is loaded first
    await _apiClient.init();
    
    // Load user state
    await _userState.loadUser();
    
    print('✅ CandidateMainScreen: Token loaded, user loaded');
    
    // Initialize services with real user data
    _messageService.initialize(
      userId: _userState.userId ?? 'guest',
      userName: _userState.name ?? 'User',
      userRole: _userState.role ?? 'candidate',
    );
    _reviewService.initialize();
    _updateUnreadCounts();
    
    print('✅ CandidateMainScreen: Initialization complete');
  }

  Future<void> _updateUnreadCounts() async {
    final messageCount = _messageService.getTotalUnreadCount();
    
    if (mounted) {
      setState(() {
        _unreadMessageCount = messageCount;
      });
    }
  }

  List<Widget> get _screens => [
    const JobBoardScreen(),
    const ApplicationsScreen(),
    const InterviewListScreen(),
    const ConversationsScreen(),
    const CandidateProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Update unread counts when navigating to messages tab
          if (index == 3) {
            _updateUnreadCounts();
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Find Jobs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Applications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Interviews',
          ),
          BottomNavigationBarItem(
            icon: _unreadMessageCount > 0
                ? Badge(
                    label: Text('$_unreadMessageCount'),
                    child: const Icon(Icons.message_outlined),
                  )
                : const Icon(Icons.message_outlined),
            activeIcon: _unreadMessageCount > 0
                ? Badge(
                    label: Text('$_unreadMessageCount'),
                    child: const Icon(Icons.message),
                  )
                : const Icon(Icons.message),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
