import 'package:flutter/material.dart';
import 'package:itjobhub/features/employer/screens/employer_jobs_screen.dart';
import 'package:itjobhub/features/employer/screens/employer_applications_screen.dart';
import 'package:itjobhub/features/employer/screens/employer_profile_screen.dart';
import 'package:itjobhub/features/shared/screens/conversations_screen.dart';
import 'package:itjobhub/services/message_service.dart';
import 'package:itjobhub/services/review_service.dart';
import 'package:itjobhub/services/user_state.dart';
import 'package:itjobhub/services/api_client.dart';

class EmployerMainScreen extends StatefulWidget {
  final int? initialIndex;
  final String? filterJobId;
  
  const EmployerMainScreen({super.key, this.initialIndex, this.filterJobId});

  @override
  State<EmployerMainScreen> createState() => _EmployerMainScreenState();
}

class _EmployerMainScreenState extends State<EmployerMainScreen> {
  final MessageService _messageService = MessageService();
  final ReviewService _reviewService = ReviewService();
  final UserState _userState = UserState();
  final ApiClient _apiClient = ApiClient();
  late int _currentIndex;
  int _unreadMessageCount = 0;
  String? _filterJobId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _filterJobId = widget.filterJobId;
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    print('🔧 EmployerMainScreen: Initializing services...');
    
    // Ensure ApiClient token is loaded first
    await _apiClient.init();
    
    // Load user state
    await _userState.loadUser();
    
    print('✅ EmployerMainScreen: Token loaded, user loaded');
    
    // Initialize services with real user data
    _messageService.initialize(
      userId: _userState.userId ?? 'guest',
      userName: _userState.name ?? 'Employer',
      userRole: _userState.role ?? 'employer',
    );
    _reviewService.initialize();
    _updateUnreadCount();
    
    print('✅ EmployerMainScreen: Initialization complete');
  }

  void _updateUnreadCount() {
    setState(() {
      _unreadMessageCount = _messageService.getTotalUnreadCount();
    });
  }

  List<Widget> get _screens => [
    const EmployerJobsScreen(),
    EmployerApplicationsScreen(filterJobId: _filterJobId),
    const ConversationsScreen(),
    const EmployerProfileScreen(),
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
          // Update unread count when navigating to messages tab
          if (index == 2) {
            _updateUnreadCount();
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Applications',
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
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Company',
          ),
        ],
      ),
    );
  }
}
