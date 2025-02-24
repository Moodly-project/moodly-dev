import 'package:flutter/material.dart';

void main() {
  runApp(const MoodlyApp());
}

class MoodlyApp extends StatelessWidget {
  const MoodlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configura o controlador da animação
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duração da animação
      vsync: this,
    );

    // Define a animação de escala (a logo vai crescer e depois encolher)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Inicia a animação automaticamente
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        // Após a animação terminar, navega para a próxima tela (ainda não implementada)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NextScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera o controlador ao sair da tela
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Cor de fundo da tela
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value, // Aplica a animação de escala
              child: child,
            );
          },
          child: Image.asset(
            'assets/logo.png', // Substitua pelo caminho da sua logo
            width: 150, // Tamanho base da logo
            height: 150,
          ),
        ),
      ),
    );
  }
}

// Placeholder para a próxima tela (será substituído depois)
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Próxima tela do Moodly'),
      ),
    );
  }
}