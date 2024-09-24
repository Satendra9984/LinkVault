import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/core/utils/string_utils.dart';
import 'package:link_vault/src/app_home/services/url_parsing_service.dart';

void main() async {
  const url = 'https://www.nytimes.com/international/';
  
  final urlMetaData = await UrlParsingService.getWebsiteMetaData(url);

  Logger.printLog(StringUtils.getJsonFormat(urlMetaData.$2?.toJson() ?? {}));
}
