


enum UrlPreloadMethods {

  // FOR RESOLVING ONLY `DNS`
  httpHead,  

   // FULL `http.get` FOR DNS, TLS, TCP ALL
  httpGet,  

  // SAME AS `httpGet` BUT WITHOUT ANY SERVER REQUEST
  // BY THE FLUTTER_CUSTOM_TABS
  mayLaunchUrl,  

  // IF NOTHING IS NEEDED
  none,
}
