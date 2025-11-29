import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        useMaterial3: true,
        fontFamily: 'Segoe UI', // خط مناسب
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
        '/scratch': (context) => const ScratchCardScreen(),
        '/daily': (context) => const DailyRewardScreen(),
        '/wallet': (context) => const WalletScreen(),
      },
    );
  }
}

// --- State Management (Simple Global State for Demo) ---
class UserState {
  static double balance = 10.00; // رصيد افتراضي
  static int score = 0;
}

// --- Home Screen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "مرحباً بك!",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          "Bubble Cash",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black45,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/wallet').then((_) => setState(() {}));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              "\$${UserState.balance.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Main Game Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMenuCard(
                        context,
                        "العب واربح",
                        "فجر الفقاعات واكسب المال!",
                        Icons.videogame_asset,
                        Colors.pinkAccent,
                        () => Navigator.pushNamed(context, '/game').then((_) => setState(() {})),
                        isLarge: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMenuCard(
                              context,
                              "بطاقات الخدش",
                              "جرب حظك",
                              Icons.style,
                              Colors.orangeAccent,
                              () => Navigator.pushNamed(context, '/scratch').then((_) => setState(() {})),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildMenuCard(
                              context,
                              "المكافآت اليومية",
                              "جوائز كل يوم",
                              Icons.calendar_today,
                              Colors.blueAccent,
                              () => Navigator.pushNamed(context, '/daily').then((_) => setState(() {})),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap, {bool isLarge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 200 : 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(icon, size: isLarge ? 150 : 100, color: color.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isLarge ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
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

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // Game Configuration
  static const int rows = 8;
  static const int cols = 8;
  static const double bubbleSize = 40.0;
  
  List<Color> bubbleColors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
  List<Color?> grid = [];
  
  Color nextBubbleColor = Colors.red;
  Color currentBubbleColor = Colors.blue;
  
  // Shooting logic
  bool isShooting = false;
  Offset bubblePosition = const Offset(0, 0);
  double shootAngle = -pi / 2; // Straight up
  
  int score = 0;
  int shotsLeft = 20;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    grid = List.generate(rows * cols, (index) {
      // Fill top half with bubbles
      if (index < (rows * cols) / 2) {
        return bubbleColors[Random().nextInt(bubbleColors.length)];
      }
      return null;
    });
    _loadNextBubble();
  }

  void _loadNextBubble() {
    currentBubbleColor = nextBubbleColor;
    nextBubbleColor = bubbleColors[Random().nextInt(bubbleColors.length)];
  }

  void _shootBubble() {
    if (isShooting || shotsLeft <= 0) return;

    setState(() {
      isShooting = true;
      shotsLeft--;
      // Start position (bottom center)
      bubblePosition = Offset(MediaQuery.of(context).size.width / 2 - bubbleSize / 2, MediaQuery.of(context).size.height - 150);
    });

    // Simple animation loop
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        // Move bubble up
        bubblePosition = Offset(bubblePosition.dx, bubblePosition.dy - 15);
      });

      // Collision Check (Simplified for demo)
      // 1. Hit Top
      if (bubblePosition.dy <= 50) { // Top offset
        timer.cancel();
        _settleBubble();
      }
      // 2. Hit other bubbles (Simple grid check based on Y position)
      // In a real game, you'd do circle collision detection
    });
  }

  void _settleBubble() {
    setState(() {
      isShooting = false;
      score += 100;
      UserState.score += 100;
      _loadNextBubble();
      
      if (shotsLeft == 0) {
        _showGameOver();
      }
    });
  }

  void _showGameOver() {
    double reward = score / 1000; // Convert score to cash
    UserState.balance += reward;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("انتهت اللعبة!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("النقاط: $score"),
            Text("المكافأة: \$${reward.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("خروج"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                shotsLeft = 20;
                _initializeGame();
              });
            },
            child: const Text("العب مجدداً"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("النقاط: $score", style: const TextStyle(color: Colors.white)),
            Text("الكرات: $shotsLeft", style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Grid
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: grid.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (grid[index] == null) return const SizedBox();
                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: grid[index],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(0.3), offset: const Offset(-2, -2), blurRadius: 5),
                      BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(2, 2), blurRadius: 5),
                    ],
                  ),
                );
              },
            ),
          ),

          // Shooter Area
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _shootBubble,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: currentBubbleColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.white54, blurRadius: 10)],
                    ),
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("اضغط للإطلاق", style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),

          // Next Bubble Indicator
          Positioned(
            bottom: 30,
            right: 30,
            child: Column(
              children: [
                const Text("التالي", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 5),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: nextBubbleColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Moving Bubble
          if (isShooting)
            Positioned(
              left: bubblePosition.dx,
              top: bubblePosition.dy,
              child: Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: BoxDecoration(
                  color: currentBubbleColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Scratch Card Screen ---
class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({super.key});

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> {
  bool isScratched = false;
  double rewardAmount = 0.0;

  @override
  void initState() {
    super.initState();
    rewardAmount = (Random().nextInt(500) / 100) + 0.10; // Random reward $0.10 - $5.00
  }

  void _claimReward() {
    setState(() {
      UserState.balance += rewardAmount;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تمت إضافة \$${rewardAmount.toStringAsFixed(2)} إلى محفظتك!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("بطاقة الحظ")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "اخمش البطاقة لتربح!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                if (!isScratched) {
                  setState(() {
                    isScratched = true;
                  });
                }
              },
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The Prize
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                        const SizedBox(height: 10),
                        Text(
                          "\$${rewardAmount.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    // The Cover (Scratch Layer)
                    if (!isScratched)
                      Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(15),
                          image: const DecorationImage(
                            image: NetworkImage("https://www.transparenttextures.com/patterns/cubes.png"), // Pattern
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.touch_app, size: 50, color: Colors.white),
                              Text("اضغط للكشف", style: TextStyle(color: Colors.white, fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (isScratched)
              ElevatedButton.icon(
                onPressed: _claimReward,
                icon: const Icon(Icons.check),
                label: const Text("استلام الجائزة"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Daily Reward Screen ---
class DailyRewardScreen extends StatelessWidget {
  const DailyRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المكافآت اليومية")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (context, index) {
          int day = index + 1;
          bool isToday = index == 0; // Mocking today as day 1
          
          return Card(
            color: isToday ? Colors.amber[100] : Colors.white,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isToday ? Colors.amber : Colors.grey[300],
                child: Text("$day", style: const TextStyle(color: Colors.white)),
              ),
              title: Text("اليوم $day"),
              subtitle: Text("مكافأة: \$${(day * 0.5).toStringAsFixed(2)}"),
              trailing: isToday
                  ? ElevatedButton(
                      onPressed: () {
                        UserState.balance += day * 0.5;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم استلام المكافأة!")));
                        Navigator.pop(context);
                      },
                      child: const Text("استلام"),
                    )
                  : const Icon(Icons.lock, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

// --- Wallet Screen ---
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("محفظتي")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text("الرصيد الحالي", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    "\$${UserState.balance.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("سجل العمليات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.arrow_downward, color: Colors.green),
                    title: Text("مكافأة لعبة الفقاعات"),
                    subtitle: Text("اليوم, 10:30 AM"),
                    trailing: Text("+\$0.10", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: Icon(Icons.arrow_downward, color: Colors.green),
                    title: Text("بطاقة خدش"),
                    subtitle: Text("أمس, 05:15 PM"),
                    trailing: Text("+\$1.50", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: Icon(Icons.arrow_upward, color: Colors.red),
                    title: Text("سحب رصيد (PayPal)"),
                    subtitle: Text("01/01/2024"),
                    trailing: Text("-\$5.00", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("طلب سحب الرصيد"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
