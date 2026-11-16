/// 화면 이동에 사용하는 라우트 이름.
///
/// 기능을 클린 아키텍처로 옮길 때마다 여기에 라우트를 추가하고
/// [AppPages]에 GetPage와 Binding을 등록한다.
abstract final class Routes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const join = '/join';
  static const home = '/home';
  static const myPage = '/my-page';
}
