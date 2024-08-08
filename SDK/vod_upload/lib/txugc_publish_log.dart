enum _LogLevel { info, debug, warn, error }

class TXUGCPublishLog {
  static _LogLevel _level = _LogLevel.debug;

  static useDebug() {
    _level = _LogLevel.debug;
  }

  static useInfo() {
    _level = _LogLevel.info;
  }

  static useWarn() {
    _level = _LogLevel.warn;
  }

  static useError() {
    _level = _LogLevel.error;
  }

  static debug(String tag, String msg) {
    if (_level == _LogLevel.debug) {
      _printConsole(tag, "DEBUG", msg);
    }
  }

  static info(String tag, String msg) {
    if (_level == _LogLevel.debug || _level == _LogLevel.info) {
      _printConsole(tag, "INFO", msg);
    }
  }

  static warn(String tag, String msg) {
    if (_level == _LogLevel.debug ||
        _level == _LogLevel.info ||
        _level == _LogLevel.warn) {
      _printConsole(tag, "WARN", msg);
    }
  }

  static error(String tag, String msg) {
    if (_level == _LogLevel.debug ||
        _level == _LogLevel.info ||
        _level == _LogLevel.warn ||
        _level == _LogLevel.error) {
      _printConsole(tag, "ERROR", msg);
    }
  }

  static _printConsole(String tag, String level, String msg) {
    DateTime now = DateTime.now();
    String formattedDate = _formatTime(now);
    print("$formattedDate [$level] --- $tag : $msg");
  }

  static String _formatTime(DateTime time) {
    return "${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}.${time.millisecond}";
  }
}
