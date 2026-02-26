class TagUtils {
  static String getTrafficLabel(int count) {
    if (count < 100) {
      return "<100 posts";
    } else if (count >= 100 && count < 1000) {
      return "+100 posts";
    } else if (count >= 1000 && count < 5000) {
      return "+1k posts";
    } else {
      return "+5k posts";
    }
  }
}
