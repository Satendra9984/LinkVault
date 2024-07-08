import 'package:flutter/material.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class UrlPreviewWidget extends StatelessWidget {
  const UrlPreviewWidget({
    required this.urlMetaData,
    super.key,
  });

  final UrlMetaData urlMetaData;

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        
        //  urlMetaData.bannerImage != null ?
        //   Image.memory(urlMetaData.bannerImage!,),
        //   : Image.a,

      ],
    ) ;
  }
}
