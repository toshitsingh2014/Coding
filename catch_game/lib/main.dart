import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const CatchGame());
}

class CatchGame extends StatelessWidget {
  const CatchGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

// ── Block types ──────────────────────────────────────────────────────────────

enum BlockType { normal, bonus, fast }

class Block {
  double x;
  double y;
  final BlockType type;
  final Color color;

  Block({
    required this.x,
    required this.y,
    required this.type,
    required this.color,
  });

  double get width => type == BlockType.bonus ? 28.0 : 32.0;
  double get height => 18.0;
  double get speedMultiplier => type == BlockType.fast ? 1.9 : 1.0;
  int get basePoints => type == BlockType.bonus ? 50 : 10;
}

// ── Score pop-up ─────────────────────────────────────────────────────────────

class ScorePopup {
  double x;
  double y;
  final int value;
  double opacity;

  ScorePopup({
    required this.x,
    required this.y,
    required this.value,
    this.opacity = 1.0,
  });
}

// ── GameScreen ───────────────────────────────────────────────────────────────

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Sizes – given default values so they are safe before first build
  double screenWidth = 400;
  double screenHeight = 800;

  double playerX = 150;
  List<Block> blocks = [];
  List<ScorePopup> popups = [];
  int score = 0;
  int health = 3;
  int missedBlocks = 0;
  int level = 1;
  int combo = 0;
  int maxCombo = 0;

  late Timer gameTimer;
  final Random _rng = Random();
  late FocusNode focusNode;
  bool gameOver = false;
  bool isPaused = false;

  // Stars: stored as (xFraction, yFraction, size, opacity)
  late final List<(double, double, double, double)> _stars;

  // ── Difficulty helpers ───────────────────────────────────────────────────

  double get _blockSpeed => 4.5 + (level - 1) * 0.7;
  double get _spawnChance => (0.045 + (level - 1) * 0.007).clamp(0.0, 0.13);

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    _stars = List.generate(
      70,
      (_) => (
        _rng.nextDouble(),
        _rng.nextDouble(),
        _rng.nextDouble() * 2.2 + 0.4,
        _rng.nextDouble() * 0.6 + 0.3,
      ),
    );
    _startGame();
  }

  @override
  void dispose() {
    gameTimer.cancel();
    focusNode.dispose();
    super.dispose();
  }

  // ── Game logic ───────────────────────────────────────────────────────────

  void _startGame() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (isPaused || gameOver) return;
      setState(() {
        // Move blocks
        for (final b in blocks) {
          b.y += _blockSpeed * b.speedMultiplier;
        }

        // Fade out score popups
        for (final p in popups) {
          p.y -= 2.0;
          p.opacity -= 0.045;
        }
        popups.removeWhere((p) => p.opacity <= 0);

        _checkCollisions();
        blocks.removeWhere((b) => b.y > screenHeight + 20);

        // Level up every 100 pts, cap at 10
        final newLevel = (score ~/ 100) + 1;
        if (newLevel > level && level < 10) level = newLevel;

        // Spawn new blocks
        if (_rng.nextDouble() < _spawnChance) _spawnBlock();
      });
    });
  }

  void _spawnBlock() {
    final roll = _rng.nextDouble();
    late BlockType type;
    late Color color;

    if (roll < 0.08) {
      type = BlockType.bonus;
      color = Colors.amber;
    } else if (roll < 0.22) {
      type = BlockType.fast;
      color = Colors.redAccent;
    } else {
      type = BlockType.normal;
      const palette = [
        Colors.cyanAccent,
        Colors.purpleAccent,
        Colors.lightBlueAccent,
        Colors.tealAccent,
        Colors.deepPurpleAccent,
      ];
      color = palette[_rng.nextInt(palette.length)];
    }

    blocks.add(Block(
      x: _rng.nextDouble() * (screenWidth - 44),
      y: -26,
      type: type,
      color: color,
    ));
  }

  void _checkCollisions() {
    // Paddle occupies playerX … playerX+90, bottom-120 … bottom-102
    final padTop = screenHeight - 122;
    final padBot = screenHeight - 102;
    final padRight = playerX + 90;

    for (int i = blocks.length - 1; i >= 0; i--) {
      final b = blocks[i];

      final caught = b.y + b.height >= padTop &&
          b.y <= padBot &&
          b.x + b.width > playerX &&
          b.x < padRight;

      if (caught) {
        combo++;
        if (combo > maxCombo) maxCombo = combo;
        final pts = b.basePoints * (combo >= 3 ? 2 : 1);
        score += pts;
        popups.add(ScorePopup(x: b.x, y: b.y, value: pts));
        blocks.removeAt(i);
      } else if (b.y > screenHeight + 10) {
        combo = 0;
        missedBlocks++;
        blocks.removeAt(i);
        if (missedBlocks >= 5) {
          health--;
          missedBlocks = 0;
          if (health <= 0) {
            gameOver = true;
            gameTimer.cancel();
          }
        }
      }
    }
  }

  void _movePlayer(double delta) {
    setState(() {
      playerX = (playerX + delta).clamp(0, screenWidth - 90);
    });
  }

  void _resetGame() {
    gameTimer.cancel();
    setState(() {
      playerX = screenWidth / 2 - 45;
      score = 0;
      health = 3;
      missedBlocks = 0;
      level = 1;
      combo = 0;
      maxCombo = 0;
      blocks.clear();
      popups.clear();
      gameOver = false;
      isPaused = false;
    });
    _startGame();
  }

  void _togglePause() => setState(() => isPaused = !isPaused);

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    return Scaffold(
      body: Focus(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent || event is KeyRepeatEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _movePlayer(-22);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _movePlayer(22);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              if (!gameOver) _togglePause();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          // Proportional swipe – feels much smoother than fixed ±2
          onPanUpdate: (d) => _movePlayer(d.delta.dx * 1.3),
          child: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF07071A), Color(0xFF111155), Color(0xFF0C1A3D)],
              ),
            ),
            child: Stack(
              children: [
                // Stars
                ..._buildStars(),

                // Catch-zone glow line
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Colors.cyanAccent.withAlpha(60),
                        Colors.cyanAccent.withAlpha(140),
                        Colors.cyanAccent.withAlpha(60),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),

                // Falling blocks
                for (final b in blocks)
                  Positioned(
                    left: b.x,
                    top: b.y,
                    child: _buildBlock(b),
                  ),

                // Score pop-ups
                for (final p in popups)
                  Positioned(
                    left: p.x,
                    top: p.y,
                    child: Opacity(
                      opacity: p.opacity.clamp(0.0, 1.0),
                      child: Text(
                        '+${p.value}',
                        style: TextStyle(
                          color: p.value >= 50
                              ? Colors.amber
                              : Colors.greenAccent,
                          fontSize: p.value >= 50 ? 22 : 15,
                          fontWeight: FontWeight.bold,
                          shadows: const [Shadow(color: Colors.black, blurRadius: 6)],
                        ),
                      ),
                    ),
                  ),

                // Player paddle
                Positioned(
                  bottom: 102,
                  left: playerX,
                  child: _buildPaddle(),
                ),

                // HUD
                _buildHUD(),

                // On-screen move buttons
                _buildMobileButtons(),

                // Pause overlay
                if (isPaused && !gameOver) _buildPauseOverlay(),

                // Game-over overlay
                if (gameOver) _buildGameOverOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  List<Widget> _buildStars() {
    return _stars.map((s) {
      final (xF, yF, size, opacity) = s;
      return Positioned(
        left: xF * screenWidth,
        top: yF * screenHeight,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha((opacity * 255).toInt()),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBlock(Block block) {
    final isBonus = block.type == BlockType.bonus;
    final isFast = block.type == BlockType.fast;

    return Container(
      width: block.width,
      height: block.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isBonus ? 14 : 6),
        color: block.color.withAlpha(200),
        border: Border.all(color: block.color, width: 1.5),
        boxShadow: [
          BoxShadow(color: block.color.withAlpha(180), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: isBonus
          ? const Center(
              child: Text('★', style: TextStyle(fontSize: 13, color: Colors.white)),
            )
          : isFast
              ? const Center(
                  child: Text('!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                )
              : null,
    );
  }

  Widget _buildPaddle() {
    final glowColor = combo >= 3 ? Colors.amber : Colors.cyanAccent;
    return Container(
      width: 90,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: LinearGradient(
          colors: combo >= 3
              ? [Colors.amber.shade600, Colors.orange.shade300, Colors.amber.shade600]
              : [Colors.cyan.shade700, Colors.cyanAccent, Colors.cyan.shade700],
        ),
        boxShadow: [
          BoxShadow(color: glowColor.withAlpha(200), blurRadius: 18, spreadRadius: 2),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score & level
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score  $score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 6)],
                    ),
                  ),
                  Text(
                    'Level $level',
                    style: TextStyle(
                      color: Colors.cyanAccent.withAlpha(200),
                      fontSize: 14,
                    ),
                  ),
                  if (combo >= 2)
                    Text(
                      'Combo x$combo${combo >= 3 ? " 🔥 2×pts!" : ""}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),

              // Hearts + pause
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          i < health ? Icons.favorite : Icons.favorite_border,
                          color: i < health ? Colors.redAccent : Colors.white24,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: gameOver ? null : _togglePause,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white10,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        isPaused ? '▶  Resume' : '⏸  Pause',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileButtons() {
    const btnStyle = BoxDecoration(
      color: Color(0x33FFFFFF),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      border: Border.fromBorderSide(BorderSide(color: Colors.white24)),
    );

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left button
          GestureDetector(
            onTapDown: (_) => _movePlayer(-30),
            onLongPressMoveUpdate: (_) => _movePlayer(-10),
            child: Container(
              margin: const EdgeInsets.only(left: 24),
              width: 64,
              height: 56,
              decoration: btnStyle,
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 26),
            ),
          ),
          // Right button
          GestureDetector(
            onTapDown: (_) => _movePlayer(30),
            onLongPressMoveUpdate: (_) => _movePlayer(10),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              width: 64,
              height: 56,
              decoration: btnStyle,
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 32),
            _dialogButton('Resume', Colors.cyanAccent, _togglePause),
            const SizedBox(height: 14),
            _dialogButton('Restart', Colors.redAccent, _resetGame),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withAlpha(210),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 46,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                shadows: [Shadow(color: Colors.red, blurRadius: 24)],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Score: $score',
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              'Level reached: $level',
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 18),
            ),
            Text(
              'Best combo: x$maxCombo',
              style: const TextStyle(color: Colors.amber, fontSize: 18),
            ),
            const SizedBox(height: 36),
            _dialogButton('Play Again', Colors.greenAccent, _resetGame),
          ],
        ),
      ),
    );
  }

  Widget _dialogButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withAlpha(30),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withAlpha(80), blurRadius: 16)],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
