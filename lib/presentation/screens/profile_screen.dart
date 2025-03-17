import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../data/providers/user_provider.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'auth_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.accentColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? _buildNotLoggedIn(context)
          : _buildProfileContent(context, user, userProvider),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 100,
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Вы не вошли в аккаунт',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Войдите, чтобы получить доступ к профилю',
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Войти',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, dynamic user, UserProvider userProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                user.avatarUrl != null && user.avatarUrl.isNotEmpty
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user.avatarUrl),
                )
                    : Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.username ?? 'Пользователь',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColor,
                    foregroundColor: AppTheme.accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text('Редактировать профиль'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Statistics
          const Text(
            'Статистика',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard(context),
          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Недавняя активность',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivityList(),
          const SizedBox(height: 32),

          // Account Actions
          const Text(
            'Действия с аккаунтом',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context,
            'Избранное',
            Icons.favorite,
                () {
              // Navigation to favorites
            },
          ),
          _buildActionButton(
            context,
            'История просмотров',
            Icons.history,
                () {
              // Navigation to history
            },
          ),
          _buildActionButton(
            context,
            'Выйти из аккаунта',
            Icons.logout,
                () {
              userProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
              );
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context) {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Просмотрено', '42'),
            _buildStatItem('В избранном', '16'),
            _buildStatItem('Отзывы', '7'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    // Dummy data for recent activity
    final activities = [
      {'title': 'Добавлено в избранное', 'content': 'Kage No Jitsuryokusha', 'time': '2 часа назад'},
      {'title': 'Просмотрено', 'content': 'Jujutsu Kaisen', 'time': '1 день назад'},
      {'title': 'Загружено', 'content': 'Honkai Star Rail', 'time': '3 дня назад'},
    ];

    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFF2A2A2A)),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            title: Text(
              activity['title']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            subtitle: Text(
              activity['content']!,
              style: const TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            trailing: Text(
              activity['time']!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppTheme.errorColor : AppTheme.accentColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppTheme.errorColor : AppTheme.textColor,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.secondaryTextColor,
        ),
        onTap: onTap,
      ),
    );
  }
}