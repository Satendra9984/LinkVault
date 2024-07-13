// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/core/utils/image_utils.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:link_vault/src/dashboard/data/models/network_image_cache_model.dart';
import 'package:link_vault/src/dashboard/presentation/cubits/network_image_cache_cubit/network_image_cache_cubit.dart';

class NetworkImageBuilderWidget extends StatelessWidget {
  const NetworkImageBuilderWidget({
    required this.imageUrl,
    required this.compressImage,
    this.imageBytes,
    this.isSideWayWidget = false,
    this.errorWidgetBuilder,
    this.loadingWidgetBuilder,
    this.successWidgetBuilder,
    super.key,
  });
  final String imageUrl;
  final Uint8List? imageBytes;
  final bool isSideWayWidget;
  final bool compressImage;

  final Widget Function()? errorWidgetBuilder;
  final Widget Function(Uint8List)? successWidgetBuilder;
  final Widget Function()? loadingWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkImageCacheCubit, NetworkImageCacheState>(
      builder: (ctx, state) {
        final cacheCubit = context.read<NetworkImageCacheCubit>();

        var imageData = cacheCubit.getImageData(imageUrl);

        if (imageBytes != null) {
          imageData = NetworkImageCacheModel(
            loadingState: LoadingStates.loaded,
            imageUrl: imageUrl,
            imageBytesData: imageBytes,
          );
        }

        if (imageData == null) {
          cacheCubit.addImage(
            imageUrl,
            compressImage: compressImage,
          );
          imageData = cacheCubit.getImageData(
            imageUrl,
          )!; // guaranteed non null after [cacheCubit.addImage(imageUrl);]
        }

        if (imageData.loadingState != LoadingStates.loaded && isSideWayWidget) {
          return Container();
        }

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
        final size = MediaQuery.of(context).size;

        final bannerImageDim = imageData.imageBytesData != null
            ? ImageUtils.getImageDimFromUintData(
                  imageData.imageBytesData!,
                ) ??
                Size(size.width, 150)
            : Size(size.width, 150);

        final bannerImageAspectRatio =
            bannerImageDim.height / bannerImageDim.width;

        final isSideWaysBanner = bannerImageAspectRatio >= 1.5;

        final width = isSideWaysBanner ? 100.0 / bannerImageAspectRatio : null;
        final height = isSideWaysBanner ? 100 : null;

        // Logger.printLog(
        //   '[dim] imageUrl ${imageUrl}, dim: ${bannerImageDim} aspectratio $bannerImageAspectRatio',
        // );

        return successWidgetBuilder != null
            ? successWidgetBuilder!(imageData.imageBytesData!)
            : Container();
      },
    );
  }
}
