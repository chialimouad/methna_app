class UserModel {
  final String id;
  final String? username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String role;
  final String status;
  final bool emailVerified;
  final bool phoneVerified;
  final bool selfieVerified;
  final bool isShadowBanned;
  final int trustScore;
  final int flagCount;
  final int deviceCount;
  final bool notificationsEnabled;
  final String? lastKnownIp;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileModel? profile;
  final List<PhotoModel>? photos;
  final SubscriptionModel? subscription;

  UserModel({
    required this.id,
    this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.role = 'user',
    this.status = 'active',
    this.emailVerified = false,
    this.phoneVerified = false,
    this.selfieVerified = false,
    this.isShadowBanned = false,
    this.trustScore = 100,
    this.flagCount = 0,
    this.deviceCount = 0,
    this.notificationsEnabled = true,
    this.lastKnownIp,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
    this.photos,
    this.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      selfieVerified: json['selfieVerified'] ?? false,
      isShadowBanned: json['isShadowBanned'] ?? false,
      trustScore: json['trustScore'] ?? 100,
      flagCount: json['flagCount'] ?? 0,
      deviceCount: json['deviceCount'] ?? 0,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      lastKnownIp: json['lastKnownIp'],
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      profile: json['profile'] != null ? ProfileModel.fromJson(json['profile']) : null,
      photos: json['photos'] != null
          ? (json['photos'] as List).map((p) => PhotoModel.fromJson(p)).toList()
          : null,
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': role,
        'status': status,
        'emailVerified': emailVerified,
        'phoneVerified': phoneVerified,
        'selfieVerified': selfieVerified,
      };

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get displayName => username ?? fullName;
  String? get mainPhotoUrl => photos?.isNotEmpty == true
      ? (photos!.firstWhere((p) => p.isMain, orElse: () => photos!.first)).url
      : null;
  bool get isOnline => status == 'active' && lastLoginAt != null &&
      DateTime.now().difference(lastLoginAt!).inMinutes < 5;
  bool get isPremium => subscription?.plan != 'free' && subscription?.status == 'active';
}

class ProfileModel {
  final String? id;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? bio;
  final String? ethnicity;
  final String? nationality;
  final List<String>? nationalities;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  // Religious & Cultural
  final String? religiousLevel;
  final String? sect;
  final String? prayerFrequency;
  final String? marriageIntention;
  final String? maritalStatus;
  final String? secondWifePreference;

  // Education & Career
  final String? education;
  final String? educationDetails;
  final String? jobTitle;
  final String? company;

  // Physical
  final int? height;
  final int? weight;

  // Lifestyle
  final String? livingSituation;
  final String? communicationStyle;
  final String? dietary;
  final String? alcohol;
  final String? hijabStatus;
  final String? workoutFrequency;
  final String? sleepSchedule;
  final String? socialMediaUsage;
  final bool? hasPets;
  final String? petPreference;

  // Health
  final bool? vaccinationStatus;
  final String? bloodType;
  final String? healthNotes;

  // Family
  final String? familyPlans;
  final List<String>? familyValues;
  final bool? hasChildren;
  final int? numberOfChildren;
  final bool? wantsChildren;
  final bool? willingToRelocate;

  // Preferences & Hobbies
  final List<String>? interests;
  final List<String>? languages;
  final List<String>? favoriteMusic;
  final List<String>? favoriteMovies;
  final List<String>? favoriteBooks;
  final List<String>? travelPreferences;

  // About Partner
  final String? aboutPartner;

  // Privacy
  final bool showAge;
  final bool showDistance;
  final bool showOnlineStatus;
  final bool showLastSeen;

  // Scoring
  final int profileCompletionPercentage;
  final int activityScore;
  final bool isComplete;

  ProfileModel({
    this.id,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.ethnicity,
    this.nationality,
    this.nationalities,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.religiousLevel,
    this.sect,
    this.prayerFrequency,
    this.marriageIntention,
    this.maritalStatus,
    this.secondWifePreference,
    this.education,
    this.educationDetails,
    this.jobTitle,
    this.company,
    this.height,
    this.weight,
    this.livingSituation,
    this.communicationStyle,
    this.dietary,
    this.alcohol,
    this.hijabStatus,
    this.workoutFrequency,
    this.sleepSchedule,
    this.socialMediaUsage,
    this.hasPets,
    this.petPreference,
    this.vaccinationStatus,
    this.bloodType,
    this.healthNotes,
    this.familyPlans,
    this.familyValues,
    this.hasChildren,
    this.numberOfChildren,
    this.wantsChildren,
    this.willingToRelocate,
    this.interests,
    this.languages,
    this.favoriteMusic,
    this.favoriteMovies,
    this.favoriteBooks,
    this.travelPreferences,
    this.aboutPartner,
    this.showAge = true,
    this.showDistance = true,
    this.showOnlineStatus = true,
    this.showLastSeen = true,
    this.profileCompletionPercentage = 0,
    this.activityScore = 0,
    this.isComplete = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      bio: json['bio'],
      ethnicity: json['ethnicity'],
      nationality: json['nationality'],
      nationalities: json['nationalities'] != null ? List<String>.from(json['nationalities']) : null,
      city: json['city'],
      country: json['country'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      religiousLevel: json['religiousLevel'],
      sect: json['sect'],
      prayerFrequency: json['prayerFrequency'],
      marriageIntention: json['marriageIntention'],
      maritalStatus: json['maritalStatus'],
      secondWifePreference: json['secondWifePreference'],
      education: json['education'],
      educationDetails: json['educationDetails'],
      jobTitle: json['jobTitle'],
      company: json['company'],
      height: json['height'],
      weight: json['weight'],
      livingSituation: json['livingSituation'],
      communicationStyle: json['communicationStyle'],
      dietary: json['dietary'],
      alcohol: json['alcohol'],
      hijabStatus: json['hijabStatus'],
      workoutFrequency: json['workoutFrequency'],
      sleepSchedule: json['sleepSchedule'],
      socialMediaUsage: json['socialMediaUsage'],
      hasPets: json['hasPets'],
      petPreference: json['petPreference'],
      vaccinationStatus: json['vaccinationStatus'],
      bloodType: json['bloodType'],
      healthNotes: json['healthNotes'],
      familyPlans: json['familyPlans'],
      familyValues: json['familyValues'] != null ? List<String>.from(json['familyValues']) : null,
      hasChildren: json['hasChildren'],
      numberOfChildren: json['numberOfChildren'],
      wantsChildren: json['wantsChildren'],
      willingToRelocate: json['willingToRelocate'],
      interests: json['interests'] != null ? List<String>.from(json['interests']) : null,
      languages: json['languages'] != null ? List<String>.from(json['languages']) : null,
      favoriteMusic: json['favoriteMusic'] != null ? List<String>.from(json['favoriteMusic']) : null,
      favoriteMovies: json['favoriteMovies'] != null ? List<String>.from(json['favoriteMovies']) : null,
      favoriteBooks: json['favoriteBooks'] != null ? List<String>.from(json['favoriteBooks']) : null,
      travelPreferences: json['travelPreferences'] != null ? List<String>.from(json['travelPreferences']) : null,
      aboutPartner: json['aboutPartner'],
      showAge: json['showAge'] ?? true,
      showDistance: json['showDistance'] ?? true,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      showLastSeen: json['showLastSeen'] ?? true,
      profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
      activityScore: json['activityScore'] ?? 0,
      isComplete: json['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (gender != null) map['gender'] = gender;
    if (dateOfBirth != null) map['dateOfBirth'] = dateOfBirth!.toIso8601String().split('T')[0];
    if (bio != null) map['bio'] = bio;
    if (ethnicity != null) map['ethnicity'] = ethnicity;
    if (nationality != null) map['nationality'] = nationality;
    if (nationalities != null) map['nationalities'] = nationalities;
    if (city != null) map['city'] = city;
    if (country != null) map['country'] = country;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (religiousLevel != null) map['religiousLevel'] = religiousLevel;
    if (sect != null) map['sect'] = sect;
    if (prayerFrequency != null) map['prayerFrequency'] = prayerFrequency;
    if (marriageIntention != null) map['marriageIntention'] = marriageIntention;
    if (maritalStatus != null) map['maritalStatus'] = maritalStatus;
    if (secondWifePreference != null) map['secondWifePreference'] = secondWifePreference;
    if (education != null) map['education'] = education;
    if (educationDetails != null) map['educationDetails'] = educationDetails;
    if (jobTitle != null) map['jobTitle'] = jobTitle;
    if (company != null) map['company'] = company;
    if (height != null) map['height'] = height;
    if (weight != null) map['weight'] = weight;
    if (livingSituation != null) map['livingSituation'] = livingSituation;
    if (communicationStyle != null) map['communicationStyle'] = communicationStyle;
    if (dietary != null) map['dietary'] = dietary;
    if (alcohol != null) map['alcohol'] = alcohol;
    if (hijabStatus != null) map['hijabStatus'] = hijabStatus;
    if (workoutFrequency != null) map['workoutFrequency'] = workoutFrequency;
    if (sleepSchedule != null) map['sleepSchedule'] = sleepSchedule;
    if (socialMediaUsage != null) map['socialMediaUsage'] = socialMediaUsage;
    if (hasPets != null) map['hasPets'] = hasPets;
    if (petPreference != null) map['petPreference'] = petPreference;
    if (vaccinationStatus != null) map['vaccinationStatus'] = vaccinationStatus;
    if (bloodType != null) map['bloodType'] = bloodType;
    if (healthNotes != null) map['healthNotes'] = healthNotes;
    if (familyPlans != null) map['familyPlans'] = familyPlans;
    if (familyValues != null) map['familyValues'] = familyValues;
    if (hasChildren != null) map['hasChildren'] = hasChildren;
    if (numberOfChildren != null) map['numberOfChildren'] = numberOfChildren;
    if (wantsChildren != null) map['wantsChildren'] = wantsChildren;
    if (willingToRelocate != null) map['willingToRelocate'] = willingToRelocate;
    if (interests != null) map['interests'] = interests;
    if (languages != null) map['languages'] = languages;
    if (favoriteMusic != null) map['favoriteMusic'] = favoriteMusic;
    if (favoriteMovies != null) map['favoriteMovies'] = favoriteMovies;
    if (favoriteBooks != null) map['favoriteBooks'] = favoriteBooks;
    if (travelPreferences != null) map['travelPreferences'] = travelPreferences;
    if (aboutPartner != null) map['aboutPartner'] = aboutPartner;
    return map;
  }

  int get age => dateOfBirth != null
      ? DateTime.now().difference(dateOfBirth!).inDays ~/ 365
      : 0;
}

class PhotoModel {
  final String id;
  final String url;
  final String? publicId;
  final bool isMain;
  final bool isSelfieVerification;
  final int order;
  final String moderationStatus;
  final String? moderationNote;
  final DateTime? createdAt;

  PhotoModel({
    required this.id,
    required this.url,
    this.publicId,
    this.isMain = false,
    this.isSelfieVerification = false,
    this.order = 0,
    this.moderationStatus = 'approved',
    this.moderationNote,
    this.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      publicId: json['publicId'],
      isMain: json['isMain'] ?? false,
      isSelfieVerification: json['isSelfieVerification'] ?? false,
      order: json['order'] ?? 0,
      moderationStatus: json['moderationStatus'] ?? 'approved',
      moderationNote: json['moderationNote'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'isMain': isMain,
        'order': order,
      };
}

class SubscriptionModel {
  final String id;
  final String plan;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentReference;

  SubscriptionModel({
    required this.id,
    required this.plan,
    required this.status,
    this.startDate,
    this.endDate,
    this.paymentReference,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      plan: json['plan'] ?? 'free',
      status: json['status'] ?? 'active',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      paymentReference: json['paymentReference'],
    );
  }

  bool get isActive => status == 'active';
  bool get isPremium => plan != 'free' && isActive;
  bool get isGold => plan == 'gold' && isActive;
}
