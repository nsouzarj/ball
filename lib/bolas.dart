import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Classe que representa uma bolinha no jogo.
class Bolinhas {
  /// Posição horizontal da bolinha.
  double x;

  /// Posição vertical da bolinha.
  double y;

  /// Tamanho da bolinha.
  double size;

  /// Indica se a bolinha está colidindo com a barra.
  bool isColliding = false;

  /// Indica se a bolinha deve ser removida da tela.
  bool isToRemove = false;

  /// Controlador de animação para a explosão da bolinha.
  AnimationController? explosionController;

  /// Animação de escala para a explosão da bolinha.
  Animation<double>? explosionAnimation;

  /// Cor da bolinha.
  Color color;

  /// Construtor da classe Bolinhas.
  Bolinhas({
    required this.x,
    required this.y,
    this.size = 30,
    required this.color, // Inicialize a cor na construção
  });
}

/// Classe que representa a tela do jogo.
class JogoScreen extends StatefulWidget {
  /// Método construtor da classe JogoScreen.
  const JogoScreen({Key? key}) : super(key: key);

  @override
  _JogoScreenState createState() => _JogoScreenState();
}

/// Classe que gerencia o estado da tela do jogo.
class _JogoScreenState extends State<JogoScreen> with TickerProviderStateMixin {
  /// Posição horizontal da barra.
  double _playerPosition = 0;

  /// Lista de bolinhas no jogo.
  List<Bolinhas> _bolinhas = [];

  /// Controlador de animação para mover as bolinhas.
  late AnimationController _animationController;

  /// Contador do escore do jogador.
  double _contadorEscore = 0.0;

  /// Contador do número de vezes que o jogador perdeu.
  double _contadorPerda = 0.0;

  /// Flag que indica se a geração de bolinhas está ativa.
  bool _gerandoBolinhas = false;

  /// Método para gerar bolinhas aleatoriamente com cores aleatórias.
  void _generateBolinhas() {
    if (!_gerandoBolinhas) {
      // Iniciar a geração
      setState(() {
        _gerandoBolinhas = true;
      });
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 50),
        vsync: this,
      )..addListener(() {
          _moveBolinhas();
        });
      _animationController.repeat();
    } else {
      // Parar a geração
      setState(() {
        _gerandoBolinhas = false;
      });
      _animationController.stop();
      _animationController.dispose();
    }
  }

  /// Método para mover as bolinhas para baixo na tela.
  void _moveBolinhas() {
    setState(() {
      // Gerar uma nova bolinha a cada 1 segundo
      if (_gerandoBolinhas && math.Random().nextInt(30) == 0) {
        // 1 em 30 chances
        _bolinhas.add(Bolinhas(
          x: math.Random().nextDouble() *
              (MediaQuery.of(context).size.width - 70),
          y: -50,
          color: Color.fromARGB(
            255,
            math.Random().nextInt(256), // Gera R aleatório
            math.Random().nextInt(256), // Gera G aleatório
            math.Random().nextInt(256), // Gera B aleatório
          ),
        ));
      }
      for (var i = _bolinhas.length - 1; i >= 0; i--) {
        var bolinha = _bolinhas[i];

        // Verificar colisão antes de mover a bolinha
        if (bolinha.x >= _playerPosition &&
            bolinha.x <= _playerPosition + 50 &&
            bolinha.y + bolinha.size >= // Use a borda inferior da bola
                MediaQuery.of(context).size.height - 150) {
          // Colisão detectada com a barra

          print("Colissao !!!");
          // Adicione esta verificação
          if (!bolinha.isColliding) {
            _triggerExplosion(bolinha);
            _contadorEscore++; // Incrementa o score em caso de colisão
            bolinha.isColliding = true; // Marque a bolinha como colidida
          }
          // _animationController.stop(); // Não pare a animação aqui
          // _animationController.repeat(); // Não reinicie a animação aqui
          continue;
        } else if (bolinha.y > MediaQuery.of(context).size.height) {
          // Perdeu se a bolinha passou
          _contadorPerda++;
          bolinha.isToRemove = true;
        }
        // Move the ball down only if it's NOT colliding with the bar
        bolinha.y += 5;
      }
      // Remove as bolinhas que passaram
      _bolinhas.removeWhere((bolinha) => bolinha.isToRemove);
    });
  }

  /// Método para iniciar a animação de explosão quando a bolinha colide com a barra.
  void _triggerExplosion(Bolinhas bolinha) {
    // Iniciar a animação de explosão
    bolinha.explosionController ??= AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // Garantir que a animação está sendo executada chamando forward()
    bolinha.explosionController!.forward();
    bolinha.explosionAnimation =
        Tween<double>(begin: 1.0, end: 5.0).animate(CurvedAnimation(
      parent: bolinha.explosionController!,
      curve: Curves.easeInOut,
    ));
    // Remover a bolinha após a explosão terminar
    bolinha.explosionController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _bolinhas.remove(bolinha);
        });
      }
    });
  }

  /// Método para mover a barra horizontalmente com base no toque do usuário.
  void _movePlayer(DragUpdateDetails details) {
    setState(() {
      _playerPosition = details.globalPosition.dx;
    });
  }

  /// Método chamado quando o estado do widget é inicializado.
  @override
  void initState() {
    super.initState();
  }

  /// Método chamado quando o estado do widget é descartado.
  @override
  void dispose() {
    _animationController?.dispose();
    for (var bolinha in _bolinhas) {
      bolinha.explosionController?.dispose();
    }
    super.dispose();
  }

  /// Método que constrói o widget da tela do jogo.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jogo das Bolinhas',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        // Adicionando o botão no AppBar
        actions: [
          IconButton(
            icon: const Icon(
              Icons.play_arrow,
              size: 50,
            ),
            onPressed: _generateBolinhas,
          ),
          IconButton(
            icon: const Icon(
              Icons.stop_circle,
              size: 50,
            ),
            onPressed: () {
              _generateBolinhas(); // Chamar a mesma função para parar
            },
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: _movePlayer,
        child: Stack(
          children: [
            // Fundo do jogo
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
              ),
            ),
            // Barra
            Positioned(
              left: _playerPosition,
              bottom: 40,
              child: Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Exibir score e perda
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                "Score: $_contadorEscore | Perdas: $_contadorPerda",
                style: TextStyle(fontSize: 20),
              ),
            ),
            // Bolinhas Verdes
            ..._bolinhas
                .where((bolinha) => !bolinha.isToRemove)
                .map((bolinha) => Positioned(
                      left: bolinha.x,
                      top: bolinha.y,
                      child: AnimatedBuilder(
                        // Referenciar corretamente bolinha.explosionAnimation
                        animation: bolinha.explosionAnimation ??
                            AlwaysStoppedAnimation<double>(1.0),
                        builder: (context, child) {
                          return Stack(
                            alignment:
                                Alignment.center, // Centraliza a explosão
                            children: [
                              // Renderizar a bolinha
                              Opacity(
                                opacity: bolinha.isColliding
                                    ? 0.0
                                    : 1.0, // Fade out the ball
                                child: Container(
                                  key: ValueKey(bolinha),
                                  width: bolinha.size,
                                  height: bolinha.size,
                                  decoration: BoxDecoration(
                                    // Use a cor da bolinha aqui
                                    color: bolinha.color,
                                    borderRadius:
                                        BorderRadius.circular(bolinha.size / 2),
                                  ),
                                ),
                              ),
                              // Renderizar a explosão usando CustomPaint
                              if (bolinha.isColliding)
                                Transform.scale(
                                  scale: bolinha.explosionAnimation!.value,
                                  child: Container(
                                    width: bolinha.size,
                                    height: bolinha.size,
                                    decoration: BoxDecoration(
                                      color: bolinha.color,
                                      borderRadius: BorderRadius.circular(
                                        bolinha.size / 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}