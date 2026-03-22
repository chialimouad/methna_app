import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:methna_app/app/data/services/api_service.dart';
import 'package:methna_app/core/constants/api_constants.dart';

class VerificationService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  // Reactive state
  final RxBool emailVerified = false.obs;
  final RxBool selfieVerified = false.obs;
  final RxBool selfieUploaded = false.obs;
  final RxBool idDocUploaded = false.obs;
  final RxString idDocStatus = 'not_uploaded'.obs;
  final RxBool marriageCertUploaded = false.obs;
  final RxString marriageCertStatus = 'not_uploaded'.obs;
  final RxInt trustScore = 100.obs;

  // ─── Fetch Status ───────────────────────────────────────
  Future<void> fetchVerificationStatus() async {
    try {
      final response = await _api.get(ApiConstants.verificationStatus);
      final data = response.data;
      emailVerified.value = data['emailVerified'] ?? false;
      selfieVerified.value = data['selfieVerified'] ?? false;
      selfieUploaded.value = data['selfieUploaded'] ?? false;
      idDocUploaded.value = data['idDocumentUploaded'] ?? false;
      idDocStatus.value = data['idDocumentStatus'] ?? 'not_uploaded';
      marriageCertUploaded.value = data['marriageCertUploaded'] ?? false;
      marriageCertStatus.value = data['marriageCertStatus'] ?? 'not_uploaded';
      trustScore.value = (data['trustScore'] ?? 100).toInt();
    } catch (_) {}
  }

  // ─── Upload Selfie ─────────────────────────────────────
  Future<Map<String, dynamic>?> uploadSelfie(File file) async {
    try {
      final formData = FormData.fromMap({
        'selfie': await MultipartFile.fromFile(file.path, filename: 'selfie.jpg'),
      });
      final response = await _api.upload(ApiConstants.selfieUpload, formData);
      selfieUploaded.value = true;
      return response.data;
    } catch (_) {
      return null;
    }
  }

  // ─── Trigger Selfie Verification ───────────────────────
  Future<Map<String, dynamic>?> verifySelfie() async {
    try {
      final response = await _api.post(ApiConstants.selfieVerify);
      final data = response.data;
      selfieVerified.value = data['match'] ?? false;
      return data;
    } catch (_) {
      return null;
    }
  }

  // ─── Upload ID Document ────────────────────────────────
  Future<Map<String, dynamic>?> uploadIdDocument(File file) async {
    try {
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(file.path, filename: 'id_document.jpg'),
      });
      final response = await _api.upload(ApiConstants.idUpload, formData);
      idDocUploaded.value = true;
      idDocStatus.value = 'pending_review';
      return response.data;
    } catch (_) {
      return null;
    }
  }

  // ─── Upload Marriage Certificate ───────────────────────
  Future<Map<String, dynamic>?> uploadMarriageCert(File file) async {
    try {
      final formData = FormData.fromMap({
        'certificate': await MultipartFile.fromFile(file.path, filename: 'marriage_cert.jpg'),
      });
      final response = await _api.upload(ApiConstants.marriageCertUpload, formData);
      marriageCertUploaded.value = true;
      marriageCertStatus.value = 'pending_review';
      return response.data;
    } catch (_) {
      return null;
    }
  }

  // ─── Trust Score ───────────────────────────────────────
  Future<int> fetchTrustScore() async {
    try {
      final response = await _api.get(ApiConstants.trustScore);
      trustScore.value = (response.data['trustScore'] ?? 100).toInt();
      return trustScore.value;
    } catch (_) {
      return trustScore.value;
    }
  }

  // ─── Computed ──────────────────────────────────────────
  bool get isFullyVerified => emailVerified.value && selfieVerified.value;
  double get verificationProgress {
    int total = 0;
    if (emailVerified.value) total++;
    if (selfieVerified.value) total++;
    if (idDocUploaded.value) total++;
    return total / 3;
  }
}
