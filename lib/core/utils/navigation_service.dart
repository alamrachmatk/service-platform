// Service sederhana untuk komunikasi antar screen tanpa state management
// Digunakan untuk switch tab MainScreen dari screen lain
class NavigationService {
  NavigationService._();
  static int pendingTabIndex = -1;
}
