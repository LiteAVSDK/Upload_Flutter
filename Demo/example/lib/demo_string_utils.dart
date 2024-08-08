class StringUtils {
  static bool isEmpty(String? str) {
    return str?.isEmpty ?? true;
  }

  static bool isNotEmpty(String? str) {
    return !isEmpty(str);
  }
}

