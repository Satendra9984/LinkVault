import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/profile_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider).value?.profile;
    _displayNameController =
        TextEditingController(text: profile?.displayName ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    await ref.read(profileNotifierProvider.notifier).updateProfile(
          displayName: _displayNameController.text.trim(),
        );

    setState(() => _isSaving = false);

    if (mounted) {
      if (ref.read(profileNotifierProvider).value?.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(ref.read(profileNotifierProvider).value!.errorMessage!)),
        );
      } else {
        context.pop();
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/temp_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Compress the image before uploading
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path,
      targetPath,
      minWidth: 500,
      minHeight: 500,
      quality: 80,
    );

    if (compressedFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to compress image')),
        );
      }
      return;
    }

    // Call the notifier to handle upload
    await ref
        .read(profileNotifierProvider.notifier)
        .uploadAvatar(File(compressedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ))
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 16),
          _buildAvatarPicker(context, ref),
          const SizedBox(height: 32),
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider).value;
    final isUploading = profileState?.isUploading ?? false;
    final profile = profileState?.profile;

    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: isUploading ? null : _pickAndUploadAvatar,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: profile?.avatarUrl != null
                  ? CachedNetworkImageProvider(profile!.avatarUrl!)
                  : null,
              child: profile?.avatarUrl == null
                  ? Icon(Icons.person,
                      size: 56, color: theme.colorScheme.onSurfaceVariant)
                  : null,
            ),
            if (isUploading)
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
