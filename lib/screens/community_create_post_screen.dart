import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../design_system/app_colors.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../widgets/app_button.dart';
import '../services/community_service.dart';

class CommunityCreatePostScreen extends StatefulWidget {
  final String userId;
  const CommunityCreatePostScreen({super.key, required this.userId});

  @override
  State<CommunityCreatePostScreen> createState() =>
      _CommunityCreatePostScreenState();
}

class _CommunityCreatePostScreenState extends State<CommunityCreatePostScreen> {
  final _contentController = TextEditingController();
  final _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (files.isNotEmpty) {
      setState(() => _selectedImages.addAll(files.map((f) => File(f.path))));
    }
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload images first
      final imagePaths = <String>[];
      for (final img in _selectedImages) {
        final uploadedPath =
            await CommunityService.uploadImage(img.path);
        if (uploadedPath != null) {
          imagePaths.add(uploadedPath);
        }
      }

      // Create post
      final result = await CommunityService.createPost(
        userId: widget.userId,
        content: _contentController.text.trim(),
        images: imagePaths,
      );

      if (result['status'] == 'success') {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result['message'] ?? 'Failed to post'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Network error. Please try again.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: Text(
              'Post',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tc.primarySurface,
                    borderRadius: BorderRadius.circular(AppSpacing.xxl),
                  ),
                  child: Icon(Icons.person, color: tc.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Sharing with Community',
                    style: AppTypography.titleMedium
                        .copyWith(color: tc.neutral70)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _contentController,
              maxLines: 6,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
                hintStyle: AppTypography.bodyLarge.copyWith(color: tc.neutral60),
              ),
              style: AppTypography.bodyLarge
                  .copyWith(color: tc.neutral100),
              cursorColor: tc.primary,
            ),
            const SizedBox(height: AppSpacing.md),

            // Selected images preview
            if (_selectedImages.isNotEmpty)
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _selectedImages.map((img) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.file(
                          img,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _selectedImages.remove(img)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

            if (_selectedImages.isNotEmpty)
              const SizedBox(height: AppSpacing.md),

            // Add image button
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _pickImages,
              icon:
                  Icon(Icons.add_photo_alternate_outlined, size: 20, color: tc.primary),
              label: Text(
                  _selectedImages.isEmpty ? 'Add Images' : 'Add More',
                  style: AppTypography.labelLarge.copyWith(color: tc.primary)),
              style: OutlinedButton.styleFrom(
                foregroundColor: tc.primary,
                side:
                    BorderSide(color: tc.primary.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'POST TO COMMUNITY',
              onPressed: _isSubmitting ? null : _submit,
              isLoading: _isSubmitting,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }
}