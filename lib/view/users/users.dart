import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/common/color_extension.dart';
import 'user_model.dart';
import 'bar_chart_page.dart';
import 'dart:async';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];
  Map<String, int> unreadCounts = {}; // Store unread message counts for each user
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String? currentUserId;
  
  // Stream subscription for real-time updates
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _getCurrentUser();
    fetchUsers();
    _searchController.addListener(() {
      filterUsers(_searchController.text);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh unread counts when app becomes active
    if (state == AppLifecycleState.resumed && currentUserId != null) {
      _setupUnreadMessagesListener();
    }
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      print('Fetched ${snapshot.docs.length} users ======================');

      final users = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final uid = doc.id;
            final name = data['name']?.toString() ?? '';
            return UserModel(uid: uid, name: name);
          })
          .where((user) => user.name.isNotEmpty)
          .toList();

      setState(() {
        allUsers = users;
        // Initialize filteredUsers with all users by default
        filteredUsers = List.from(users);
        isLoading = false;
      });
      
      // Set up real-time listener for unread messages
      if (currentUserId != null) {
        _setupUnreadMessagesListener();
      }
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load users. Please try again.';
      });
      debugPrint('Error fetching users: $e');
    }
  }

  void _setupUnreadMessagesListener() {
    if (currentUserId == null) return;

    // Cancel existing subscription if any
    _messagesSubscription?.cancel();

    // Listen for real-time changes to messages where current user is receiver
    _messagesSubscription = FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
            _updateUnreadCounts(snapshot);
          },
          onError: (error) {
            debugPrint('Error listening to messages: $error');
          },
        );
  }

  void _updateUnreadCounts(QuerySnapshot snapshot) {
    final Map<String, int> counts = {};
    
    // Count unread messages per sender
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final senderId = data['senderId'] ?? data['userId']; // Using userId as fallback
      
      if (senderId != null && senderId != currentUserId) { // Don't count own messages
        counts[senderId] = (counts[senderId] ?? 0) + 1;
      }
    }

    // Only update if counts have actually changed
    bool hasChanged = false;
    if (unreadCounts.length != counts.length) {
      hasChanged = true;
    } else {
      for (String key in counts.keys) {
        if (unreadCounts[key] != counts[key]) {
          hasChanged = true;
          break;
        }
      }
    }

    if (hasChanged) {
      setState(() {
        unreadCounts = counts;
        // Re-sort users after updating unread counts
        _sortAndFilterUsers();
      });
      print('Updated unread counts: $counts');
    }
  }

  void _sortAndFilterUsers() {
    // Sort users: unread messages first, then alphabetically
    final query = _searchController.text.toLowerCase();
    
    // Filter users based on search query (empty query shows all users)
    List<UserModel> filtered = allUsers
        .where((user) => query.isEmpty || user.name.toLowerCase().contains(query))
        .toList();
    
    // Sort filtered users: unread messages first, then alphabetically
    filtered.sort((a, b) {
      final aUnread = unreadCounts[a.uid] ?? 0;
      final bUnread = unreadCounts[b.uid] ?? 0;
      
      // If one has unread messages and the other doesn't
      if (aUnread > 0 && bUnread == 0) return -1;
      if (aUnread == 0 && bUnread > 0) return 1;
      
      // If both have unread messages, sort by unread count (descending)
      if (aUnread > 0 && bUnread > 0) {
        final unreadComparison = bUnread.compareTo(aUnread);
        if (unreadComparison != 0) return unreadComparison;
      }
      
      // Finally, sort alphabetically by name
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    
    setState(() {
      filteredUsers = filtered;
    });
  }

  void filterUsers(String query) {
    _sortAndFilterUsers();
  }

  Future<void> _refreshUsers() async {
    await fetchUsers();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[name.hashCode % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _animationController.dispose();
    _messagesSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TColor.gray60.withOpacity(0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users by name...',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).hintColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Theme.of(context).hintColor),
                  onPressed: () {
                    _searchController.clear();
                    filterUsers('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUnreadBadge(int count) {
    if (count == 0) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUserCard(UserModel user, int index) {
    final unreadCount = unreadCounts[user.uid] ?? 0;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: unreadCount > 0 ? 5 : 3, // Higher elevation for unread messages
        shadowColor: unreadCount > 0 
            ? Colors.red.withOpacity(0.2) 
            : Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: unreadCount > 0 
              ? BorderSide(color: Colors.red.withOpacity(0.3), width: 1)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            // Navigate to chat immediately without waiting for database update
            final navigator = Navigator.of(context);
            
            // Navigate first
            await navigator.push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    BarChartPage(userId: user.uid),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
            
            // Mark messages as read after returning from chat
            // This ensures the read status is updated when user comes back
            await _markMessagesAsRead(user.uid);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with unread indicator
                Stack(
                  children: [
                    Hero(
                      tag: 'avatar_${user.uid}',
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: _getAvatarColor(user.name),
                        child: Text(
                          _getInitials(user.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // Unread indicator dot
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ),
                          _buildUnreadBadge(unreadCount),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unreadCount > 0 
                            ? '$unreadCount unread message${unreadCount == 1 ? '' : 's'}'
                            : 'Tap to view analytics',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: unreadCount > 0 
                              ? Colors.red.shade600 
                              : Theme.of(context).hintColor,
                          fontWeight: unreadCount > 0 ? FontWeight.w500 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (unreadCount > 0 
                        ? Colors.red 
                        : Theme.of(context).primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: unreadCount > 0 
                        ? Colors.red 
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to mark messages as read when user clicks on a chat
  Future<void> _markMessagesAsRead(String senderId) async {
    if (currentUserId == null) return;

    try {
      // Get all unread messages from this sender to current user
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (messagesSnapshot.docs.isEmpty) {
        print('No unread messages found for sender: $senderId');
        return;
      }

      // Create a batch to update all messages at once
      final batch = FirebaseFirestore.instance.batch();
      
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(), // Add timestamp when read
        });
      }
      
      // Commit the batch
      await batch.commit();
      
      // Immediately update local state to reflect the change
      setState(() {
        unreadCounts[senderId] = 0;
        _sortAndFilterUsers();
      });
      
      print('Marked ${messagesSnapshot.docs.length} messages as read for sender: $senderId');
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isEmpty ? 'No users found' : 'No users match your search',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty 
                ? 'Users will appear here once they sign up'
                : 'Try searching with a different name',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                filterUsers('');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: fetchUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading users...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch the user data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalUnreadMessages = unreadCounts.values.fold(0, (sum, count) => sum + count);
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? TColor.gray80
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? TColor.gray60
            : TColor.back,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? TColor.white
              : TColor.gray60,
        ),
        title: Row(
          children: [
            Text(
              'User Directory',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TColor.white
                    : TColor.gray60,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (totalUnreadMessages > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  totalUnreadMessages > 99 ? '99+' : totalUnreadMessages.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshUsers,
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TColor.white
                  : TColor.gray60,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).dividerColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          
          // User count indicator with unread messages info
          if (!isLoading && !hasError)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredUsers.length} ${filteredUsers.length == 1 ? 'user' : 'users'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (totalUnreadMessages > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.mail,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalUnreadMessages unread',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUsers,
              color: Theme.of(context).primaryColor,
              child: isLoading
                  ? _buildLoadingState()
                  : hasError
                      ? _buildErrorState()
                      : filteredUsers.isEmpty
                          ? _buildEmptyState()
                          : FadeTransition(
                              opacity: _fadeAnimation,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = filteredUsers[index];
                                  return _buildUserCard(user, index);
                                },
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}