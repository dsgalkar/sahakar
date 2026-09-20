import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sahakar_logo.dart';

class LiveTrackingScreen extends ConsumerWidget {
  final String ticketId;

  const LiveTrackingScreen({
    super.key,
    required this.ticketId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = ref.watch(activeTicketsProvider);
    final ticket = tickets.firstWhere(
      (t) => t.id == ticketId,
      orElse: () => tickets.isNotEmpty ? tickets.first : null as dynamic,
    );

    final worker = ticket.assignedWorker;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'tracking_logo',
              child: SahakarLogo(size: 28, showBadgeBorder: false, isCompact: true),
            ),
            const SizedBox(width: 8),
            const Text(
              'Live Worker Wayfinding',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sos_rounded, color: AppColors.emergencyRedLight),
            tooltip: 'Emergency SOS',
            onPressed: () => _showSosDialog(context, ref, ticket.id),
          ),
        ],
      ),
      body: Column(
        children: [
          // Simulated Visual Map with real route animation
          Expanded(
            flex: 5,
            child: Container(
              color: isDark ? const Color(0xFF0F1A30) : const Color(0xFFE2E8F0),
              child: Stack(
                children: [
                  // Map Background Canvas
                  CustomPaint(
                    size: Size.infinite,
                    painter: _MapCanvasPainter(
                      isDark: isDark,
                      workerProgress: (ticket.estimatedArrivalMinutes / 8).clamp(0.1, 0.9),
                    ),
                  ),

                  // ETA Float Banner
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkCard : Colors.white).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.successGreenLight.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.electric_moped_rounded,
                              color: AppColors.successGreenLight,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ticket.status == TicketStatus.arrived
                                      ? 'Worker has arrived outside!'
                                      : 'Arriving in ~${ticket.estimatedArrivalMinutes} mins',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ticket.status == TicketStatus.arrived
                                      ? 'Please verify OTP to initiate service'
                                      : 'Worker en-route • ${(ticket.estimatedArrivalMinutes * 0.28).toStringAsFixed(1)} km away',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueLight.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: AppColors.primaryBlueLight,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Start OTP Floater at bottom of map
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.accentGoldLight : Colors.transparent,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SERVICE START OTP',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                'Share with worker upon arrival',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ticket.startOtp,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.0,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Worker Details & Ticket Bottom Sheet
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Worker Profile Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryBlueLight.withOpacity(0.2),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: AppColors.primaryBlueLight,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    worker?.name ?? 'Assigned Worker',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: AppColors.successGreenLight,
                                  ),
                                ],
                              ),
                              Text(
                                '${worker?.trade ?? ticket.serviceName} • NSQF Level ${worker?.nsqfLevel ?? 4}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                                  Text(
                                    ' ${worker?.rating ?? 4.9} (${worker?.completedJobs ?? 300}+ gigs)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Call & Chat Actions
                        IconButton.filledTonal(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Dialing ${worker?.phone ?? "worker"}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Cooperative Society & e-Shram credentials
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkSurface : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.apartment_rounded,
                                size: 16,
                                color: AppColors.primaryBlueLight,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  worker?.societyName ?? 'Shramik Kalyan Sahakari Mandali',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.successGreenLight.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Co-op Verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.successGreenLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.badge_rounded,
                                size: 16,
                                color: AppColors.accentGoldLight,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'e-Shram UAN: ${worker?.eShramUan ?? "1009-4428-9912"}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Destination Address Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: AppColors.emergencyRedLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DESTINATION (PHYSICAL LOCATION)',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.emergencyRedLight,
                                  ),
                                ),
                                Text(
                                  ticket.customerAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'GPS: ${ticket.customerLat.toStringAsFixed(4)}, ${ticket.customerLng.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Transparent Fair Price Box
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Total (Co-op Fair Bill)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹${ticket.fairPrice.total.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.accentGoldLight : AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Direct Worker Wage: ₹${ticket.fairPrice.workerWage.toStringAsFixed(0)} (88%) • Statutory Social Security: ₹${ticket.fairPrice.socialSecurityFund.toStringAsFixed(0)} • Ops: ₹${ticket.fairPrice.operationsFee.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSosDialog(BuildContext context, WidgetRef ref, String ticketId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed),
            SizedBox(width: 8),
            Text('Cooperative SOS Alert'),
          ],
        ),
        content: const Text(
          'Emergency SOS will broadcast your current physical coordinates and active gig ticket to the local police control room, cooperative society safety monitor, and emergency contacts.\n\nThis incident will also be recorded in your Activity History.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergencyRed,
            ),
            onPressed: () {
              ref.read(activeTicketsProvider.notifier).logSosAlert(
                    ticketId: ticketId,
                    note: 'User broadcasted SOS beacon from Live Wayfinding screen',
                  );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.emergencyRed,
                  content: Text('🚨 SOS Alert Dispatched & Recorded in Activity History'),
                ),
              );
            },
            child: const Text('Trigger SOS'),
          ),
        ],
      ),
    );
  }
}

// Custom Painter drawing interactive road grid, user pin, worker pin, and path
class _MapCanvasPainter extends CustomPainter {
  final bool isDark;
  final double workerProgress;

  _MapCanvasPainter({
    required this.isDark,
    required this.workerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = (isDark ? const Color(0xFF1E2D4A) : Colors.white)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadBorderPaint = Paint()
      ..color = (isDark ? const Color(0xFF2B3F66) : const Color(0xFFCBD5E1))
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeRoutePaint = Paint()
      ..color = AppColors.primaryBlueLight
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw stylized road grid
    final path = Path();
    // Start at bottom left (worker start)
    final start = Offset(size.width * 0.2, size.height * 0.75);
    final mid = Offset(size.width * 0.45, size.height * 0.45);
    final end = Offset(size.width * 0.78, size.height * 0.25); // User home

    path.moveTo(start.dx, start.dy);
    path.lineTo(mid.dx, mid.dy);
    path.lineTo(end.dx, end.dy);

    // Cross roads
    final cross1 = Path()
      ..moveTo(0, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.45);

    final cross2 = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.45, size.height);

    canvas.drawPath(cross1, roadBorderPaint);
    canvas.drawPath(cross1, roadPaint);
    canvas.drawPath(cross2, roadBorderPaint);
    canvas.drawPath(cross2, roadPaint);

    canvas.drawPath(path, roadBorderPaint);
    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, activeRoutePaint);

    // Calculate current worker position interpolated along route
    final t = (1.0 - workerProgress).clamp(0.0, 1.0);
    final workerPos = Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t,
    );

    // User home pin
    final userPinPaint = Paint()..color = AppColors.emergencyRedLight;
    canvas.drawCircle(end, 12, userPinPaint);
    final userInnerPin = Paint()..color = Colors.white;
    canvas.drawCircle(end, 5, userInnerPin);

    // Worker moving pin
    final workerRadiusPulse = Paint()
      ..color = AppColors.successGreenLight.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(workerPos, 22, workerRadiusPulse);

    final workerPinPaint = Paint()..color = AppColors.successGreenLight;
    canvas.drawCircle(workerPos, 14, workerPinPaint);
    final workerInnerPin = Paint()..color = Colors.white;
    canvas.drawCircle(workerPos, 6, workerInnerPin);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.workerProgress != workerProgress || oldDelegate.isDark != isDark;
  }
}
