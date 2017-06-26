// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GalleryPrimaryColorNotification extends Notification {
  final Color primaryColor;

  GalleryPrimaryColorNotification(this.primaryColor);
}

class GalleryAccentColorNotification extends Notification {
  final Color accentColor;

  GalleryAccentColorNotification(this.accentColor);
}
