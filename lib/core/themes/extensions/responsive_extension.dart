import 'dart:ui';

/// The default width of the design used for responsive calculations.
// ignore: constant_identifier_names
const double WIDTH_DEFAULT_DESIGN = 430;

/// The default height of the design used for responsive calculations.
/// ignore: constant_identifier_names
const double HEIGHT_DEFAULT_DESIGN = 932;

/// This extension provides methods to calculate responsive values based on the device's physical size and pixel ratio.
/// It contains constants for the default design width and height, and methods to calculate responsive values for width, height, and padding.
/// The `_calculation` method is used internally to calculate the responsive values based on the device's physical size and the default design values.
/// The `DeviceDirection` enum is used to specify whether the calculation should be based on the device's width or height.
extension ResponsiveExtension on num {
  /// Returns the device pixel ratio of the first view in the platform dispatcher.
  double get _devicePixelRatio =>
      PlatformDispatcher.instance.views.first.devicePixelRatio;

  /// Returns the physical size of the first view in the platform dispatcher.
  Size get _physicalSize =>
      PlatformDispatcher.instance.views.first.physicalSize;

  /// Returns the device size based on the physical size and device pixel ratio.
  Size get _deviceSize => Size(
        _physicalSize.width / _devicePixelRatio,
        _physicalSize.height / _devicePixelRatio,
      );

  /// Calculates the responsive value for width based on the device's physical size and the default design width.
  double get w {
    return _calculation(
      value: this,
      direction: DeviceDirection.width,
    );
  }

  /// Calculates the responsive value for height based on the device's physical size and the default design height.
  double get h {
    return _calculation(
      value: this,
      direction: DeviceDirection.height,
    );
  }

  /// Calculates the responsive value for padding based on the device's physical size and the default design height.
  double get p {
    return _calculation(
      value: this,
      direction: DeviceDirection.height,
    );
  }

  /// Calculates the responsive value based on the device's physical size, the default design values, and the specified direction.
  double _calculation({
    required num value,
    required DeviceDirection direction,
  }) {
    final orientation = direction == DeviceDirection.width
        ? _deviceSize.width
        : _deviceSize.height;

    final valueDefault = direction == DeviceDirection.width
        ? WIDTH_DEFAULT_DESIGN
        : HEIGHT_DEFAULT_DESIGN;

    final percent = value * 100 / valueDefault;
    return (orientation * percent) / 100;
  }
}

/// Enum used to specify whether the responsive calculation should be based on the device's width or height.
enum DeviceDirection {
  height,
  width,
}
