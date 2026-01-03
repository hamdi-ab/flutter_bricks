import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'system_theme_observer.dart';

/// Implementation of [SystemThemeObserver] using [WidgetsBindingObserver]
class SystemThemeObserverImpl
    with WidgetsBindingObserver
    implements SystemThemeObserver {
  SystemThemeObserverImpl() {
    WidgetsBinding.instance.addObserver(this);
  }

  final _controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onSystemBrightnessChanged => _controller.stream;

  @override
  bool get isSystemDark {
    // PlatformDispatcher is the modern way to check platform brightness
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }

  @override
  void didChangePlatformBrightness() {
    _controller.add(isSystemDark);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.close();
  }
}
