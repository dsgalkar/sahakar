import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/creative_avatar.dart';
import '../../../core/widgets/futuristic_widgets.dart';
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
              child: SahakarLogo(size: 26, showBadgeBorder: false, isCompact: true),
            ),
            const SizedBox(width: 8),
            const Text(
              'LIVE WAYFINDING RADAR',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.neonCoral.withOpacity(0.2),
                foregroundColor: AppColors.neonCoral,
                side: const BorderSide(color: AppColors.neonCoral, width: 1.2),
              ),
              icon: const Icon(Icons.sos_rounded, size: 20),
              tooltip: 'Emergency SOS',
              onPressed: () => _showSosDialog(context, ref, ticket.id),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Simulated Visual Map with real futuristic neon route animation
          Expanded(
            flex: 5,
            child: Container(
              color: isDark ? const Color(0xFF04060A) : const Color(0xFFE2E8F0),
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

                  // ETA Float Banner with Neon Glow
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: GlassNeonCard(
                      neonGlowColor: ticket.status == TicketStatus.arrived
                          ? AppColors.neonGreen
                          : AppColors.neonCyan,
                      glowSpread: 0.15,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (ticket.status == TicketStatus.arrived
                                      ? AppColors.neonGreen
                                      : AppColors.neonCyan)
                                  .withOpacity(0.18),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (ticket.status == TicketStatus.arrived
                                          ? AppColors.neonGreen
                                          : AppColors.neonCyan)
                                      .withOpacity(0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.electric_moped_rounded,
                              color: ticket.status == TicketStatus.arrived
                                  ? AppColors.neonGreen
                                  : AppColors.neonCyan,
                              size: 22,
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
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                Text(
                                  ticket.status == TicketStatus.arrived
                                      ? 'Verify OTP to start work ledger'
                                      : 'Radar track active • ${(ticket.estimatedArrivalMinutes * 0.28).toStringAsFixed(1)} km away',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NeonPill(
                            label: 'LIVE RADAR',
                            color: ticket.status == TicketStatus.arrived
                                ? AppColors.neonGreen
                                : AppColors.neonCyan,
                            isFilled: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Start OTP Floater at bottom of map
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF0F172A), const Color(0xFF1E1035)]
                              : [AppColors.primaryBlue, const Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.neonCyan.withOpacity(0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.25),
                            blurRadius: 14,
                            spreadRadius: 1,
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
                              Row(
                                children: [
                                  Icon(Icons.key_rounded, size: 12, color: AppColors.neonCyan),
                                  SizedBox(width: 4),
                                  Text(
                                    'SERVICE START OTP',
                                    style: TextStyle(
                                      color: AppColors.neonCyan,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Share with worker upon physical arrival',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF07090E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.neonGold, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonGold.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              ticket.startOtp,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.5,
                                color: AppColors.neonGold,
                                fontFamily: 'monospace',
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
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.neonCyan.withOpacity(0.3) : AppColors.lightBorder,
                    width: 1.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Worker Profile Row with CreativeAvatar
                    Row(
                      children: [
                        CreativeAvatar(
                          tradeName: worker?.trade ?? ticket.serviceName,
                          role: UserRole.gigWorker,
                          radius: 28,
                          showGlow: true,
                          nsqfLevel: worker?.nsqfLevel ?? 4,
                          isLiveOnline: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    worker?.name ?? 'Assigned KarmaYogi',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: AppColors.neonGreen,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  NeonPill(
                                    label: (worker?.trade ?? ticket.serviceName).toUpperCase(),
                                    color: AppColors.neonCyan,
                                  ),
                                  const SizedBox(width: 6),
                                  NeonPill(
                                    label: 'NSQF L-${worker?.nsqfLevel ?? 4}',
                                    color: AppColors.neonGreen,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 15, color: AppColors.neonGold),
                                  Text(
                                    ' ${worker?.rating ?? 4.9} (${worker?.completedJobs ?? 300}+ cooperative gigs)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Call Action Button
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.neonCyan.withOpacity(0.15),
                            foregroundColor: AppColors.neonCyan,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.darkSurface,
                                content: Text('Dialing ${worker?.phone ?? "worker"}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

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
                                color: AppColors.neonCyan,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  worker?.societyName ?? 'Shramik Kalyan Sahakari Mandali',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const NeonPill(
                                label: 'CO-OP VERIFIED',
                                color: AppColors.neonGreen,
                                isFilled: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.badge_rounded,
                                size: 16,
                                color: AppColors.neonGold,
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
                    const SizedBox(height: 12),

                    // Destination Address Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: AppColors.neonCoral,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DESTINATION COORDINATES',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: AppColors.neonCoral,
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.neonGold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonGold.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cooperative Fair Fare',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '₹${ticket.fairPrice.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.neonGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Direct KarmaYogi Wage: ₹${ticket.fairPrice.workerWage.toStringAsFixed(0)} (88%) • Statutory Sec 114: ₹${ticket.fairPrice.socialSecurityFund.toStringAsFixed(0)} • Ops: ₹${ticket.fairPrice.operationsFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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
            Icon(Icons.warning_amber_rounded, color: AppColors.neonCoral),
            SizedBox(width: 8),
            Text('Cooperative SOS Alert', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'Emergency SOS broadcasts your live telemetry coordinates and active gig ticket to local police, cooperative safety response team, and designated emergency contacts.\n\nThis incident is logged immutably into your Activity History ledger.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCoral,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(activeTicketsProvider.notifier).logSosAlert(
                    ticketId: ticketId,
                    note: 'User broadcasted SOS beacon from Live Wayfinding screen',
                  );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.neonCoral,
                  content: Row(
                    children: [
                      Icon(Icons.sos_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('🚨 SOS Alert Dispatched & Recorded in Activity History', style: TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Broadcast SOS', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

// Custom Painter drawing interactive cyber road grid, user pin, worker pin, and glowing neon path
class _MapCanvasPainter extends CustomPainter {
  final bool isDark;
  final double workerProgress;

  _MapCanvasPainter({
    required this.isDark,
    required this.workerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Cyber road backgrounds
    final roadBorderPaint = Paint()
      ..color = (isDark ? const Color(0xFF131D33) : const Color(0xFFCBD5E1))
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPaint = Paint()
      ..color = (isDark ? const Color(0xFF0B101D) : Colors.white)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Glowing Neon Cyan Route
    final routeGlowPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.45)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final activeRoutePaint = Paint()
      ..color = AppColors.neonCyan
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Road Grid Lines
    final start = Offset(size.width * 0.2, size.height * 0.75);
    final mid = Offset(size.width * 0.45, size.height * 0.45);
    final end = Offset(size.width * 0.78, size.height * 0.25); // User home

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(mid.dx, mid.dy)
      ..lineTo(end.dx, end.dy);

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

    // Glowing route
    canvas.drawPath(path, routeGlowPaint);
    canvas.drawPath(path, activeRoutePaint);

    // Calculate current worker position interpolated along route
    final t = (1.0 - workerProgress).clamp(0.0, 1.0);
    final workerPos = Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t,
    );

    // User home pin with Coral Glow
    final userGlow = Paint()
      ..color = AppColors.neonCoral.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(end, 20, userGlow);

    final userPinPaint = Paint()..color = AppColors.neonCoral;
    canvas.drawCircle(end, 12, userPinPaint);
    final userInnerPin = Paint()..color = Colors.white;
    canvas.drawCircle(end, 5, userInnerPin);

    // Worker moving pin with Pulsing Neon Green & Radar Rings
    final radarRing1 = Paint()
      ..color = AppColors.neonGreen.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(workerPos, 32, radarRing1);

    final radarRing2 = Paint()
      ..color = AppColors.neonGreen.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(workerPos, 22, radarRing2);

    final workerPinGlow = Paint()
      ..color = AppColors.neonGreen.withOpacity(0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(workerPos, 14, workerPinGlow);

    final workerPinPaint = Paint()..color = AppColors.neonGreen;
    canvas.drawCircle(workerPos, 12, workerPinPaint);
    final workerInnerPin = Paint()..color = const Color(0xFF07090E);
    canvas.drawCircle(workerPos, 5, workerInnerPin);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.workerProgress != workerProgress || oldDelegate.isDark != isDark;
  }
}
