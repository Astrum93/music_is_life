import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

/// 앱 시작 시 한 번 등록하는 전역 의존성.
///
/// Firebase 인스턴스를 여기서만 등록하고, 각 기능의 Binding에서
/// `Get.find<FirebaseAuth>()`처럼 받아 Repository 생성자로 넘긴다.
/// Controller, Repository 안에서는 `Get.find`를 직접 호출하지 않는다.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);
    Get.put<FirebaseStorage>(FirebaseStorage.instance, permanent: true);
  }
}
