import 'package:flutter/material.dart';

final List onBoarding = [
  {
    "title": "title_1",
    "subtitle": "subtitle_1",
    "icon": "assets/lottie/onboarding_ar/onboarding_one.json"
  },
  {
    "title": "title_2",
    "subtitle": "subtitle_2",
    "icon": "assets/lottie/onboarding_ar/onboarding_two.json"
  },
  {
    "title": "title_3",
    "subtitle": "subtitle_3",
    "icon": "assets/lottie/onboarding_ar/onboarding_three.json"
  },
  {
    "title": "title_4",
    "subtitle": "subtitle_4",
    "icon": "assets/lottie/onboarding_ar/onboarding_four.json"
  },
  {
    "title": "get_started",
    "subtitle": "log_in_to_start_your_job_hunt",
    "icon": "assets/lottie/onboarding_ar/onboarding_five.json"
  },
];

final List newJobs = [
  {
    "date": "Friday",
    "PostedTime": "5 mins",
    "jobTitle": "Senior Product Manager - Digital Twin Technology",
    "jobProvider": "Dar Group",
    "applyType": "Easy Apply"
  },
  {
    "date": "Friday",
    "PostedTime": "20 mins",
    "jobTitle": "Project Manager (WMS Implementation)",
    "jobProvider": "eMagine Solutions",
    "applyType": "External"
  },
  {
    "date": "Thursday",
    "PostedTime": "45 mins",
    "jobTitle": "Digital Marketing Manager -Luxury Retail",
    "jobProvider": "Reed Recruitment Middle East",
    "applyType": "External"
  },
  {
    "date": "Friday",
    "PostedTime": "45 mins",
    "jobTitle": "Digital Marketing Manager",
    "jobProvider": "1 Marketing Dubai",
    "applyType": "External"
  },
  {
    "date": "Thursday",
    "PostedTime": "45 mins",
    "jobTitle": "Digital Marketing Manager -Luxury Retail",
    "jobProvider": "Reed Recruitment Middle East",
    "applyType": "External"
  },
  {
    "date": "Wednesday",
    "PostedTime": "45 mins",
    "jobTitle": "Digital Marketing Manager -Luxury Retail",
    "jobProvider": "Reed Recruitment Middle East",
    "applyType": "External"
  },
];

final List country = [
  {"id": 0, "countryName": "United Arab Emirates", "flag": "ae"},
  {"id": 1, "countryName": "Saudi Arabic", "flag": "sa"},
  {"id": 2, "countryName": "Egypt", "flag": "eg"},
];

final List plan = [
  {
    "title": "unlimited_alerts",
    "premium": "assets/svg/item.svg",
    "free": "assets/svg/ic_no_premium_check.svg"
  },
  {
    "title": "real_time_alerts",
    "premium": "assets/svg/item.svg",
    "free": "assets/svg/ic_free_premium_check.svg"
  },
  {
    "title": "cv_matching",
    "premium": "assets/svg/item.svg",
    "free": "assets/svg/ic_no_premium_check.svg"
  },
  {
    "title": "tailored_cvs",
    "premium": "assets/svg/item.svg",
    "free": "assets/svg/ic_no_premium_check.svg"
  },
  {
    "title": "ai_powered_cover_letters",
    "premium": "assets/svg/item.svg",
    "free": "assets/svg/ic_no_premium_check.svg"
  },
];

final languageList = [
  {"title": "English", "icon": "gb", "code": "en"},
  {"title": "العربية", "icon": "sa", "code": "ar"},
];

extension DirectionalityExtension on BuildContext {
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
}
