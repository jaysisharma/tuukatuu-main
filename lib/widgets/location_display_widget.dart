import 'package:flutter/material.dart';
import 'package:tuukatuu/services/location_service.dart';

/// A reusable widget that displays the current delivery location
/// Can be used anywhere in the app to show location information
class LocationDisplayWidget extends StatefulWidget {
  final bool showCoordinates;
  final bool showLabel;
  final TextStyle? textStyle;
  final IconData? icon;
  final VoidCallback? onTap;

  const LocationDisplayWidget({
    super.key,
    this.showCoordinates = false,
    this.showLabel = true,
    this.textStyle,
    this.icon,
    this.onTap,
  });

  @override
  State<LocationDisplayWidget> createState() => _LocationDisplayWidgetState();
}

class _LocationDisplayWidgetState extends State<LocationDisplayWidget> {
  VoidCallback? _locationListener;

  @override
  void initState() {
    super.initState();
    // Listen to location changes
    _locationListener = () {
      if (mounted) setState(() {});
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalLocationService.listenToLocationChanges(context, _locationListener!);
    });
  }

  @override
  void dispose() {
    if (_locationListener != null) {
      GlobalLocationService.removeLocationListener(context, _locationListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = context.hasDeliveryLocation;
    final address = context.currentAddress;
    final label = context.currentLocationLabel;
    final coordinates = context.coordinatesString;

    if (!hasLocation) {
      return _buildNoLocationState();
    }

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon ?? Icons.location_on,
              size: 16,
              color: Colors.orange,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showLabel && label != null && label.isNotEmpty)
                    Text(
                      label,
                      style: (widget.textStyle ?? const TextStyle()).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    address ?? 'Unknown address',
                    style: (widget.textStyle ?? const TextStyle()).copyWith(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.showCoordinates)
                    Text(
                      coordinates,
                      style: (widget.textStyle ?? const TextStyle()).copyWith(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLocationState() {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 16,
              color: Colors.orange[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Set delivery location',
              style: (widget.textStyle ?? const TextStyle()).copyWith(
                fontSize: 12,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple text widget that shows the current location
class LocationTextWidget extends StatelessWidget {
  final bool showCoordinates;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;

  const LocationTextWidget({
    super.key,
    this.showCoordinates = false,
    this.style,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = context.hasDeliveryLocation;
    
    if (!hasLocation) {
      return Text(
        'No delivery location set',
        style: style?.copyWith(color: Colors.grey[500]) ?? TextStyle(color: Colors.grey[500]),
        overflow: overflow,
        maxLines: maxLines,
      );
    }

    final address = context.currentAddress;
    final coordinates = context.coordinatesString;

    return Text(
      showCoordinates ? '$address ($coordinates)' : (address ?? 'Unknown location'),
      style: style,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

/// A widget that shows location coordinates in a compact format
class LocationCoordinatesWidget extends StatelessWidget {
  final TextStyle? style;
  final bool showPrecision;

  const LocationCoordinatesWidget({
    super.key,
    this.style,
    this.showPrecision = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = context.hasDeliveryLocation;
    
    if (!hasLocation) {
      return Text(
        'No coordinates',
        style: style?.copyWith(color: Colors.grey[500]) ?? TextStyle(color: Colors.grey[500]),
      );
    }

    final lat = context.currentLatitude;
    final lng = context.currentLongitude;

    if (lat == null || lng == null) {
      return Text(
        'Invalid coordinates',
        style: style?.copyWith(color: Colors.red[500]) ?? TextStyle(color: Colors.red[500]),
      );
    }

    final precision = showPrecision ? 6 : 4;
    return Text(
      '${lat.toStringAsFixed(precision)}, ${lng.toStringAsFixed(precision)}',
      style: style?.copyWith(fontFamily: 'monospace') ?? const TextStyle(fontFamily: 'monospace'),
    );
  }
}
