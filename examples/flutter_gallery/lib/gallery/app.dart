// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import 'home.dart';
import 'item.dart';
import 'package:flutter_gallery/gallery/notifications.dart';
import 'updates.dart';

final Map<String, WidgetBuilder> _kRoutes = new Map<String, WidgetBuilder>.fromIterable(
  // For a different example of how to set up an application routing table,
  // consider the Stocks example:
  // https://github.com/flutter/flutter/blob/master/examples/stocks/lib/main.dart
  kAllGalleryItems,
  key: (GalleryItem item) => item.routeName,
  value: (GalleryItem item) => item.buildRoute,
);

ThemeData _makeTheme({bool dark, Color primary, Color accent, TargetPlatform platform}) {
  return new ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    primarySwatch: Colors.blue,

    primaryColor: primary,
    accentColor: accent,
    platform: platform ?? defaultTargetPlatform,
  );
}

class GalleryApp extends StatefulWidget {
  const GalleryApp({
    this.updateUrlFetcher,
    this.enablePerformanceOverlay: true,
    this.checkerboardRasterCacheImages: true,
    this.checkerboardOffscreenLayers: true,
    this.onSendFeedback,
    Key key}
  ) : super(key: key);

  final UpdateUrlFetcher updateUrlFetcher;

  final bool enablePerformanceOverlay;

  final bool checkerboardRasterCacheImages;

  final bool checkerboardOffscreenLayers;

  final VoidCallback onSendFeedback;

  @override
  GalleryAppState createState() => new GalleryAppState();
}

class GalleryAppState extends State<GalleryApp> {
  Color _primaryColorOverride;
  Color _accentColorOverride;
  bool _useLightTheme = true;
  bool _showPerformanceOverlay = false;
  bool _checkerboardRasterCacheImages = false;
  bool _checkerboardOffscreenLayers = false;
  double _timeDilation = 1.0;
  TargetPlatform _platform;

  Timer _timeDilationTimer;

  @override
  void initState() {
    _timeDilation = timeDilation;
    super.initState();
  }

  @override
  void dispose() {
    _timeDilationTimer?.cancel();
    _timeDilationTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget home = new GalleryHome(
      useLightTheme: _useLightTheme,
      onThemeChanged: (bool value) {
        setState(() {
          _useLightTheme = value;
        });
      },
      showPerformanceOverlay: _showPerformanceOverlay,
      onShowPerformanceOverlayChanged: widget.enablePerformanceOverlay ? (bool value) {
        setState(() {
          _showPerformanceOverlay = value;
        });
      } : null,
      checkerboardRasterCacheImages: _checkerboardRasterCacheImages,
      onCheckerboardRasterCacheImagesChanged: widget.checkerboardRasterCacheImages ? (bool value) {
        setState(() {
          _checkerboardRasterCacheImages = value;
        });
      } : null,
      checkerboardOffscreenLayers: _checkerboardOffscreenLayers,
      onCheckerboardOffscreenLayersChanged: widget.checkerboardOffscreenLayers ? (bool value) {
        setState(() {
          _checkerboardOffscreenLayers = value;
        });
      } : null,
      onPlatformChanged: (TargetPlatform value) {
        setState(() {
          _platform = value == defaultTargetPlatform ? null : value;
        });
      },
      timeDilation: _timeDilation,
      onTimeDilationChanged: (double value) {
        setState(() {
          _timeDilationTimer?.cancel();
          _timeDilationTimer = null;
          _timeDilation = value;
          if (_timeDilation > 1.0) {
            // We delay the time dilation change long enough that the user can see
            // that the checkbox in the drawer has started reacting, then we slam
            // on the brakes so that they see that the time is in fact now dilated.
            _timeDilationTimer = new Timer(const Duration(milliseconds: 150), () {
              timeDilation = _timeDilation;
            });
          } else {
            timeDilation = _timeDilation;
          }
        });
      },
      onSendFeedback: widget.onSendFeedback,
    );

    if (widget.updateUrlFetcher != null) {
      home = new Updater(
        updateUrlFetcher: widget.updateUrlFetcher,
        child: home,
      );
    }

    final ThemeData theme = _makeTheme(
      dark: !_useLightTheme,
      primary: _primaryColorOverride,
      accent: _accentColorOverride,
      platform: _platform
    );

    Widget root = new MaterialApp(
      title: 'Flutter Gallery',
      color: Colors.grey,
      theme: theme,
      showPerformanceOverlay: _showPerformanceOverlay,
      checkerboardRasterCacheImages: _checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: _checkerboardOffscreenLayers,
      routes: _kRoutes,
      home: home,
    );

    root = new NotificationListener<GalleryPrimaryColorNotification>(
      onNotification: _onPrimaryColorNotification,
      child: root,
    );

    root = new NotificationListener<GalleryAccentColorNotification>(
      onNotification: _onAccentColorNotification,
      child: root,
    );

    return root;
  }

  bool _onPrimaryColorNotification(GalleryPrimaryColorNotification notification) {
    setState(() {
      _primaryColorOverride = notification.primaryColor;
    });

    return true;
  }

  bool _onAccentColorNotification(GalleryAccentColorNotification notification) {
    setState(() {
      _accentColorOverride = notification.accentColor;
    });

    return true;
  }
}
