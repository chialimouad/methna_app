import 'package:get/get.dart';

/// Entry in the cache with expiration tracking.
class _CacheEntry {
  final dynamic data;
  final DateTime expiry;

  _CacheEntry(this.data, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// In-memory cache service for API responses.
/// Prevents redundant network requests for data that changes infrequently.
class CacheService extends GetxService {
  final Map<String, _CacheEntry> _cache = {};

  /// Default TTL: 5 minutes.
  static const Duration defaultTtl = Duration(minutes: 5);

  Future<CacheService> init() async => this;

  /// Store a value in cache with optional TTL.
  void put(String key, dynamic value, {Duration ttl = defaultTtl}) {
    _cache[key] = _CacheEntry(value, DateTime.now().add(ttl));
  }

  /// Retrieve a cached value. Returns `null` if expired or missing.
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T?;
  }

  /// Check if a valid (non-expired) cache entry exists.
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Remove a specific cache entry.
  void remove(String key) => _cache.remove(key);

  /// Invalidate all entries matching a prefix (e.g. 'users_').
  void invalidatePrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  /// Clear the entire cache.
  void clearAll() => _cache.clear();

  /// Get-or-fetch pattern: returns cached value or executes [fetcher] and caches result.
  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration ttl = defaultTtl,
  }) async {
    final cached = get<T>(key);
    if (cached != null) return cached;

    final value = await fetcher();
    put(key, value, ttl: ttl);
    return value;
  }
}
