// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/presentation_layer/providers/network_image_cache_cubit/network_image_cache_cubit.dart';
import 'package:link_vault/core/common/repository_layer/models/network_image_cache_model.dart';
import 'package:link_vault/core/res/colours.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';

class NetworkImageBuilderWidget extends StatelessWidget {
  const NetworkImageBuilderWidget({
    required this.imageUrl,
    required this.compressImage,
    this.imageBytes,
    this.errorWidgetBuilder,
    this.loadingWidgetBuilder,
    this.successWidgetBuilder,
    super.key,
  });

  final String imageUrl;
  final Uint8List? imageBytes;
  final bool compressImage;

  final Widget Function()? errorWidgetBuilder;
  final Widget Function(NetworkImageCacheModel)?
      successWidgetBuilder;
  final Widget Function()? loadingWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkImageCacheCubit, NetworkImageCacheState>(
      builder: (ctx, state) {
        final cacheCubit = context.read<NetworkImageCacheCubit>();

        var imageData = cacheCubit.getImageData(imageUrl);

        if (imageData == null) {
          cacheCubit.addImage(
            imageUrl,
            compressImage: compressImage,
          );
        }

        imageData = cacheCubit.getImageData(imageUrl);
        return ValueListenableBuilder<NetworkImageCacheModel>(
          valueListenable: imageData!,
          builder: (ctx, imageData, _) {
            if (imageData.loadingState == LoadingStates.loading) {
              return loadingWidgetBuilder != null
                  ? loadingWidgetBuilder!()
                  : const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: ColourPallette.grey,
                        color: ColourPallette.white,
                      ),
                    );
            } else if (imageData.loadingState == LoadingStates.errorLoading) {
              return errorWidgetBuilder != null
                  ? errorWidgetBuilder!()
                  : Center(
                      child: IconButton(
                        onPressed: () => cacheCubit.addImage(
                          imageUrl,
                          compressImage: compressImage,
                        ),
                        icon: const Icon(Icons.restore_rounded),
                      ),
                    );
            }

            return successWidgetBuilder != null
                ? successWidgetBuilder!(imageData)
                : Container();
          },
        );
      },
    );
  }
}
