import 'package:flutter/material.dart';

/// Tipos de animaciones
enum AnimationType { defauld, fadeIn }

/// Main class, [context] es el BuildContext de la aplicación en ese momento
/// [page] es el widget a navegar, [animation] es el tipo de animación
/// [duration] ducracion de la animacion es opcional
/// [replacement] es opcional se usa para borrar el estac de navegacion
class PageRouteTransition {
  final BuildContext context;
  final Widget page;
  final AnimationType animation;
  final Duration duration;
  final bool replacement;

  PageRouteTransition(
      {required this.context,
      required this.page,
      this.replacement = false,
      this.animation = AnimationType.defauld,
      this.duration = const Duration(milliseconds: 300)}) {
    switch (this.animation) {
      case AnimationType.defauld:
        this._defauldTransition();
        break;
      case AnimationType.fadeIn:
        this._fadeInTransition();
        break;
    }
  }

  /// Push defauld de la página
  void _pushPage(Route route) => Navigator.push(context, route);

  /// Push replacement de la página
  void _pushReplacementPage(Route route) =>
      Navigator.pushReplacement(context, route);

  // Código de una transición defauld
  void _defauldTransition() {
    final route = MaterialPageRoute(builder: (_) => this.page);

    (this.replacement)
        ? this._pushReplacementPage(route)
        : this._pushPage(route);
  }

  /// Controlador de la transición con fadeIn
  void _fadeInTransition() {
    final route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => this.page,
        transitionDuration: this.duration,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            child: child,
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          );
        });

    (this.replacement)
        ? this._pushReplacementPage(route)
        : this._pushPage(route);
  }
}
