import 'package:html/parser.dart' show parse;
import 'package:timeago/timeago.dart' as timeago;

class HtmlParserHelper {
  static String? extractProfileUrl(String html) {
    var document = parse(html);
    var profileElement = document.querySelector('a');
    if (profileElement != null) {
      var src = profileElement.attributes['href'];
      if (src != null && src.startsWith('https:')) {
        return src;
      }
    }
    return null;
  }

  static String? extractProfile(String html) {
    var document = parse(html);
    var profileElement = document.querySelector('a');
    if (profileElement != null) {
      var src = profileElement.text;
      return src;
    }
    return null;
  }

  static String getTimeAgo(DateTime date) {
    return timeago.format(date, locale: 'es');
  }
}
