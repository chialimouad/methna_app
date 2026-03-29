import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/app/data/services/storage_service.dart';
import 'package:methna_app/core/constants/api_constants.dart';

class ContentService extends GetxService {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  // Cached content
  final RxList<Map<String, dynamic>> faqs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> jobs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> partners = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> termsContent = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> privacyContent = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> accessibilityContent = Rx<Map<String, dynamic>?>(null);

  final RxBool isLoading = false.obs;

  Future<ContentService> init() async {
    return this;
  }

  String get _locale => _storage.getString('app_language')?.split('_').first ?? 'en';

  // ─── FAQ ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchFaqs({String? category}) async {
    isLoading.value = true;
    try {
      final queryParams = <String, dynamic>{'locale': _locale};
      if (category != null) queryParams['category'] = category;

      final response = await _api.get(
        ApiConstants.faqs,
        queryParameters: queryParams,
      );

      final data = response.data;
      List<dynamic> list = data is List ? data : [];
      faqs.value = list.cast<Map<String, dynamic>>();
      return faqs;
    } catch (e) {
      debugPrint('[ContentService] fetchFaqs error: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Jobs ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchJobs() async {
    isLoading.value = true;
    try {
      final response = await _api.get(
        ApiConstants.jobs,
        queryParameters: {'locale': _locale},
      );

      final data = response.data;
      List<dynamic> list = data is List ? data : [];
      jobs.value = list.cast<Map<String, dynamic>>();
      return jobs;
    } catch (e) {
      debugPrint('[ContentService] fetchJobs error: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Partners ────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchPartners() async {
    isLoading.value = true;
    try {
      final response = await _api.get(ApiConstants.partners);

      final data = response.data;
      List<dynamic> list = data is List ? data : [];
      partners.value = list.cast<Map<String, dynamic>>();
      return partners;
    } catch (e) {
      debugPrint('[ContentService] fetchPartners error: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // ─── App Content (Terms, Privacy, etc.) ──────────────────

  Future<Map<String, dynamic>?> fetchContent(String type) async {
    isLoading.value = true;
    try {
      final response = await _api.get(
        ApiConstants.appContent(type),
        queryParameters: {'locale': _locale},
      );

      final data = response.data as Map<String, dynamic>?;
      
      // Cache based on type
      switch (type) {
        case 'terms':
          termsContent.value = data;
          break;
        case 'privacy':
          privacyContent.value = data;
          break;
        case 'accessibility':
          accessibilityContent.value = data;
          break;
      }
      
      return data;
    } catch (e) {
      debugPrint('[ContentService] fetchContent($type) error: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Terms ───────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchTerms() => fetchContent('terms');

  // ─── Privacy ─────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchPrivacy() => fetchContent('privacy');

  // ─── Accessibility ───────────────────────────────────────

  Future<Map<String, dynamic>?> fetchAccessibility() => fetchContent('accessibility');

  // ─── Community Guidelines ────────────────────────────────

  Future<Map<String, dynamic>?> fetchCommunityGuidelines() => fetchContent('community_guidelines');

  // ─── Safety Tips ─────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchSafetyTips() => fetchContent('safety_tips');

  // ─── Contact Us ──────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchContactUs() => fetchContent('contact_us');
}
