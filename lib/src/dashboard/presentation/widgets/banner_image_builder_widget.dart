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
    this.imageBytes,
    this.isSideWayWidget = false,
    required this.compressImage,
    super.key,
  });
  final String imageUrl;
  final Uint8List? imageBytes;
  final bool isSideWayWidget;
  final bool compressImage;

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
          return const SizedBox(
            height: 150,
            width: 600,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: ColourPallette.grey,
                color: ColourPallette.white,
              ),
            ),
          );
        } else if (imageData.loadingState == LoadingStates.errorLoading) {
          return SizedBox(
            height: 150,
            width: 600,
            child: Center(
              child: IconButton(
                onPressed: () => cacheCubit.addImage(
                  imageUrl,
                  compressImage: compressImage,
                ),
                icon: const Icon(Icons.restore_rounded),
              ),
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

        if (isSideWaysBanner && isSideWayWidget) {
          return SizedBox(
            height: 120,
            width: 150 / bannerImageAspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageData.imageBytesData!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) {
                  return SvgPicture.memory(
                    imageData!.imageBytesData!,
                    placeholderBuilder: (context) {
                      return const SizedBox(
                        height: 150,
                        width: 600,
                      );
                    },
                  );
                },
              ),
            ),
          );
        } else if (!isSideWaysBanner && !isSideWayWidget) {
          return SizedBox(
            // height: 100,
            // width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageData.imageBytesData!,
                // height: min(
                // bannerImageDim.height,
                // (size.width - widget.outerScreenHorizontalDistance) /
                //     bannerImageAspectRatio, // 50 is outer screen padding
                // ),
                // fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) {
                  return SvgPicture.memory(
                    imageData!.imageBytesData!,
                    // height: size.width / bannerImageAspectRatio,
                    placeholderBuilder: (context) {
                      return const SizedBox(
                        height: 150,
                        width: 600,
                      );
                    },
                  );
                },
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
