import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/anime_provider.dart';
import '../../data/providers/game_provider.dart';
import '../widgets/anime_card.dart';
import '../widgets/game_card.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'profile_screen.dart';
import 'anime_detail_screen.dart';
import 'game_detail_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final animeProvider = Provider.of<AnimeProvider>(context, listen: false);
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      animeProvider.fetchAnimes();
      gameProvider.fetchGames();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final animeProvider = Provider.of<AnimeProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'KawaiiBox',
          style: TextStyle(
            color: AppTheme.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.accentColor),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen())
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: AppTheme.accentColor),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen())
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          tabs: const [
            Tab(text: 'Аниме', icon: Icon(Icons.movie)),
            Tab(text: 'Игры', icon: Icon(Icons.games)),
          ],
          onTap: _onTabChanged,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Anime Tab
          _buildAnimeTab(animeProvider),

          // Games Tab
          _buildGamesTab(gameProvider),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildAnimeTab(AnimeProvider animeProvider) {
    if (animeProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      );
    }

    if (animeProvider.error != null) {
      return Center(
        child: Text(
          'Произошла ошибка: ${animeProvider.error}',
          style: const TextStyle(color: AppTheme.errorColor),
        ),
      );
    }

    if (animeProvider.animes.isEmpty) {
      return const Center(
        child: Text(
          'Аниме не найдено',
          style: TextStyle(color: AppTheme.secondaryTextColor),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Популярное аниме', animeProvider.getPopularAnimes()),
          _buildSection('Недавно добавленные', animeProvider.getRecentAnimes()),
          _buildSection('Рекомендуемые', animeProvider.getRecommendedAnimes()),
        ],
      ),
    );
  }

  Widget _buildGamesTab(GameProvider gameProvider) {
    if (gameProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      );
    }

    if (gameProvider.error != null) {
      return Center(
        child: Text(
          'Произошла ошибка: ${gameProvider.error}',
          style: const TextStyle(color: AppTheme.errorColor),
        ),
      );
    }

    if (gameProvider.games.isEmpty) {
      return const Center(
        child: Text(
          'Игры не найдены',
          style: TextStyle(color: AppTheme.secondaryTextColor),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameSection('Популярные игры', gameProvider.getPopularGames()),
          _buildGameSection('Недавно добавленные', gameProvider.getRecentGames()),
          _buildGameSection('Рекомендуемые', gameProvider.getRecommendedGames()),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List animes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            itemCount: animes.length,
            itemBuilder: (context, index) {
              final anime = animes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimeCard(
                  anime: anime,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimeDetailScreen(anime: anime),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameSection(String title, List games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GameCard(
                  game: game,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailScreen(game: game),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}