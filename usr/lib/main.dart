import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const BubbleCashApp());
}

class BubbleCashApp extends StatelessWidget {
  const BubbleCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Cash Rewards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
      },
    );
  }
}

// --- State Management (Simple Global State for Demo) ---
class UserState {
  static int coins = 200;
  static int stars = 0;
}

// --- Home Screen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF48017D), Color(0xFF1E0036)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Stats Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Welcome to", style: TextStyle(fontSize: 18, color: Colors.white70)),
                    Row(
                      children: [
                        _buildStatChip(Icons.add_circle, UserState.coins.toString(), Colors.greenAccent),
                        const SizedBox(width: 10),
                        _buildStatChip(Icons.star, UserState.stars.toString(), Colors.yellowAccent),
                      ],
                    ),
                  ],
                ),
              ),

              // Header Icon Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderIconButton(Icons.settings, Colors.grey),
                    _buildHeaderIconButton(Icons.card_giftcard, Colors.yellow),
                    _buildHeaderIconButton(Icons.leaderboard, Colors.green),
                    _buildHeaderIconButton(Icons.help_outline, Colors.blue),
                  ],
                ),
              ),

              const Spacer(),

              // Logo
              Text(
                "BUBBLE\nCASH",
                textAlign: TextAlign.center,
                style: GoogleFonts.luckiestGuy(
                  fontSize: 60,
                  color: Colors.white,
                  letterSpacing: 5,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Menu Buttons
              _buildMenuButton(
                context,
                "Play Game",
                Icons.play_arrow,
                const Color(0xFFFFC107),
                () => Navigator.pushNamed(context, '/game').then((_) => _updateState()),
              ),
              _buildMenuButton(
                context,
                "Redeem",
                Icons.redeem,
                const Color(0xFF7E57C2),
                () {}, // Placeholder
              ),
              _buildMenuButton(
                context,
                "Refer & Earn",
                Icons.group_add,
                const Color(0xFF4CAF50),
                () {}, // Placeholder
              ),
              _buildMenuButton(
                context,
                "Rate Us",
                Icons.star_rate,
                const Color(0xFFE91E63),
                () {}, // Placeholder
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black87),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          shadowColor: color.withOpacity(0.7),
        ),
      ),
    );
  }
}

// --- Game Screen (Bubble Shooter Logic) ---
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int rows = 10;
  static const int cols = 8;
  static const double bubbleSize = 40.0;

  final List<Color> _bubbleColors = [
    Colors.blue.shade700,
    Colors.green.shade700,
    Colors.orange.shade700,
    Colors.purple.shade700,
    Colors.red.shade700,
  ];
  final List<Map<String, dynamic>?> _grid = [];

  Color _currentBubbleColor = Colors.blue;
  bool _isShooting = false;
  Offset _bubblePosition = Offset.zero;
  int _shotsLeft = 30;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _grid.clear();
    _grid.addAll(List.generate(rows * cols, (index) {
      if (index < (rows * cols) / 2.5) {
        return {
          "color": _bubbleColors[Random().nextInt(_bubbleColors.length)],
          "type": Random().nextDouble() > 0.9 ? "snowflake" : "normal",
        };
      }
      return null;
    }));
    _loadNextBubble();
  }

  void _loadNextBubble() {
    _currentBubbleColor = _bubbleColors[Random().nextInt(_bubbleColors.length)];
  }

  void _shootBubble() {
    if (_isShooting || _shotsLeft <= 0) return;

    setState(() {
      _isShooting = true;
      _shotsLeft--;
      final screenWidth = MediaQuery.of(context).size.width;
      _bubblePosition = Offset(screenWidth / 2 - bubbleSize / 2, MediaQuery.of(context).size.height - 150);
    });

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _bubblePosition = Offset(_bubblePosition.dx, _bubblePosition.dy - 15);
      });

      if (_bubblePosition.dy <= 50) {
        timer.cancel();
        _settleBubble();
      }
    });
  }

  void _settleBubble() {
    setState(() {
      _isShooting = false;
      UserState.coins += 10;
      _loadNextBubble();

      if (_shotsLeft == 0) {
        _showGameOver();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0052),
        title: const Text("Game Over!"),
        content: Text("You earned ${UserState.coins - 200} coins in this round!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Exit"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _shotsLeft = 30;
                _initializeGame();
              });
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF48017D), Color(0xFF1E0036)],
          ),
        ),
        child: Stack(
          children: [
            // Game Grid
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            _buildStatChip(Icons.add_circle, UserState.coins.toString(), Colors.greenAccent),
                            const SizedBox(width: 10),
                            _buildStatChip(Icons.star, UserState.stars.toString(), Colors.yellowAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _grid.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final bubbleData = _grid[index];
                        if (bubbleData == null) return const SizedBox();
                        return _Bubble(
                          color: bubbleData["color"],
                          type: bubbleData["type"],
                          size: bubbleSize,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Shooter Area
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _shootBubble,
                child: _Cannon(
                  bubbleColor: _currentBubbleColor,
                ),
              ),
            ),

            // Moving Bubble
            if (_isShooting)
              Positioned(
                left: _bubblePosition.dx,
                top: _bubblePosition.dy,
                child: _Bubble(
                  color: _currentBubbleColor,
                  type: "normal",
                  size: bubbleSize,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Color color;
  final String type;
  final double size;

  const _Bubble({required this.color, required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.7),
            color,
          ],
          center: const Alignment(-0.5, -0.5),
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: type == "snowflake"
          ? const Center(child: Icon(Icons.ac_unit, color: Colors.white, size: 20))
          : null,
    );
  }
}

class _Cannon extends StatelessWidget {
  final Color bubbleColor;
  const _Cannon({required this.bubbleColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                border: Border.all(color: Colors.grey.shade600, width: 3),
              ),
            ),
          ),
          Positioned(
            top: 10,
            child: _Bubble(color: bubbleColor, type: "normal", size: 45),
          ),
        ],
      ),
    );
  }
}
