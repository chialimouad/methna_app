import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/constants/api_constants.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:methna_app/core/widgets/animated_empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = Get.find<ApiService>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late TabController _tabCtrl;
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingTickets = false.obs;
  final RxList<Map<String, dynamic>> myTickets = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _fetchMyTickets();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    isSubmitting.value = true;
    try {
      await _api.post(ApiConstants.supportTickets, data: {
        'subject': _subjectCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
      });
      _subjectCtrl.clear();
      _messageCtrl.clear();
      Helpers.showSnackbar(message: 'Support ticket submitted successfully');
      _tabCtrl.animateTo(1);
      _fetchMyTickets();
    } catch (e) {
      Helpers.showSnackbar(message: Helpers.extractErrorMessage(e), isError: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _fetchMyTickets() async {
    isLoadingTickets.value = true;
    try {
      final response = await _api.get(ApiConstants.myTickets);
      final data = response.data;
      final list = data is Map ? (data['tickets'] ?? []) : (data is List ? data : []);
      myTickets.value = List<Map<String, dynamic>>.from(list);
    } catch (_) {}
    finally {
      isLoadingTickets.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(LucideIcons.chevronLeft, size: 16, color: textColor),
                    ),
                  ),
                  const Spacer(),
                  Text('Contact Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab bar ──
            TabBar(
              controller: _tabCtrl,
              labelColor: AppColors.primary,
              unselectedLabelColor: secondaryColor,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'New Ticket'),
                Tab(text: 'My Tickets'),
              ],
            ),

            // ── Tab views ──
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // ── New Ticket Form ──
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.headphones, size: 20, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'We typically respond within 24 hours.',
                                    style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text('Subject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _subjectCtrl,
                            decoration: _inputDecoration(isDark, 'What do you need help with?'),
                            validator: (v) => (v == null || v.trim().length < 3) ? 'Subject must be at least 3 characters' : null,
                            maxLength: 200,
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 16),

                          Text('Message', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _messageCtrl,
                            decoration: _inputDecoration(isDark, 'Describe your issue in detail...'),
                            validator: (v) => (v == null || v.trim().length < 10) ? 'Message must be at least 10 characters' : null,
                            maxLines: 6,
                            maxLength: 2000,
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 24),

                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isSubmitting.value ? null : _submitTicket,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              child: isSubmitting.value
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Submit Ticket', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),

                  // ── My Tickets ──
                  Obx(() {
                    if (isLoadingTickets.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (myTickets.isEmpty) {
                      return const AnimatedEmptyState(
                        lottieAsset: 'assets/animations/no_support_tickets.json',
                        title: 'No tickets yet',
                        subtitle: 'Submit a ticket and we\'ll get back to you.',
                        fallbackIcon: LucideIcons.ticket,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _fetchMyTickets,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: myTickets.length,
                        itemBuilder: (context, index) {
                          final t = myTickets[index];
                          return _TicketCard(ticket: t, isDark: isDark, textColor: textColor, secondaryColor: secondaryColor);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
      filled: true,
      fillColor: isDark ? AppColors.cardDark : Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  const _TicketCard({required this.ticket, required this.isDark, required this.textColor, required this.secondaryColor});

  Color _statusColor(String status) {
    switch (status) {
      case 'open': return const Color(0xFFFF9800);
      case 'in_progress': return const Color(0xFF2196F3);
      case 'resolved': return const Color(0xFF4CAF50);
      case 'closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open': return 'Open';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      case 'closed': return 'Closed';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] ?? 'open';
    final created = ticket['createdAt'] != null ? DateTime.tryParse(ticket['createdAt']) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket['subject'] ?? '',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ticket['message'] ?? '',
            style: TextStyle(fontSize: 13, color: secondaryColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (ticket['adminReply'] != null && (ticket['adminReply'] as String).isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.messageSquare, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ticket['adminReply'],
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (created != null) ...[
            const SizedBox(height: 8),
            Text(
              Helpers.timeAgo(created),
              style: TextStyle(fontSize: 11, color: secondaryColor),
            ),
          ],
        ],
      ),
    );
  }
}
