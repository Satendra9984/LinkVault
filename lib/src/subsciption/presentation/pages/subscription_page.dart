// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:link_vault/core/common/constants/user_constants.dart';
import 'package:link_vault/core/common/res/colours.dart';
import 'package:link_vault/core/common/res/media.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text(
          //   'Support Us',
          //   style: TextStyle(fontWeight: FontWeight.w500),
          // ),
          ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Help Us Keeping this Platform Free',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Just watch a video and use the app for ${accountSingUpCreditLimit} days without any interruption.',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    leading: Icon(
                      Icons.video_library_rounded,
                      size: 32.0,
                      // color: ColourPallette.mountainMeadow,
                    ),
                    title: Text(
                      'Just Watch a Video',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const SizedBox(height: 16.0),
          Expanded(
            child: Image.asset(
              MediaRes.solidarityPNG,
              fit: BoxFit.contain,
              colorBlendMode: BlendMode.colorBurn,
            ),
          ),
        ],
      ),
    );
  }
}
