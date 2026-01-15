// lib/features/auth/presentation/profile_edit_sheet.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_provider.dart';
import '../../wallet/models/profile_model.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  final ProfileModel profile;

  const ProfileEditSheet({super.key, required this.profile});

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  late TextEditingController _nameController;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile.fullName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Preset avatar options
  static const List<Map<String, dynamic>> _presetAvatars = [
    {'emoji': '😀', 'color': 0xFF4CAF50},
    {'emoji': '😎', 'color': 0xFF2196F3},
    {'emoji': '🤓', 'color': 0xFF9C27B0},
    {'emoji': '😊', 'color': 0xFFFF9800},
    {'emoji': '🦊', 'color': 0xFFFF5722},
    {'emoji': '🐱', 'color': 0xFFE91E63},
    {'emoji': '🐶', 'color': 0xFF795548},
    {'emoji': '🦁', 'color': 0xFFFFC107},
    {'emoji': '🐼', 'color': 0xFF607D8B},
    {'emoji': '🦄', 'color': 0xFF673AB7},
    {'emoji': '🎮', 'color': 0xFF00BCD4},
    {'emoji': '💼', 'color': 0xFF3F51B5},
    {'emoji': '🎨', 'color': 0xFFE91E63},
    {'emoji': '🚀', 'color': 0xFF009688},
    {'emoji': '⭐', 'color': 0xFFFFEB3B},
    {'emoji': '💎', 'color': 0xFF03A9F4},
  ];

  String? _selectedPresetAvatar; // Format: "emoji:color" e.g. "😀:0xFF4CAF50"

  void _showAvatarOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.read(currentColorThemeProvider);
    final l = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? colorTheme.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    l.changePhoto,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[500]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Gallery option
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGallery();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorTheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Galeriden Seç',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Kendi fotoğrafını yükle',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Preset avatars title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'veya bir avatar seç',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Avatar grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _presetAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _presetAvatars[index];
                  final avatarKey = '${avatar['emoji']}:${avatar['color']}';
                  final isSelected = _selectedPresetAvatar == avatarKey;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPresetAvatar = avatarKey;
                        _selectedImage = null; // Clear gallery image
                      });
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Color(avatar['color'] as int),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: colorTheme.primary, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Color(
                              avatar['color'] as int,
                            ).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          avatar['emoji'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent(ColorTheme colorTheme, bool isDark) {
    // Check for preset avatar selection
    if (_selectedPresetAvatar != null) {
      final parts = _selectedPresetAvatar!.split(':');
      if (parts.length >= 2) {
        final emoji = parts[0];
        final colorValue = int.tryParse(parts[1]) ?? 0xFF2196F3;
        return CircleAvatar(
          radius: 56,
          backgroundColor: Color(colorValue),
          child: Text(emoji, style: const TextStyle(fontSize: 48)),
        );
      }
    }

    // Check for gallery image
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 56,
        backgroundColor: isDark ? colorTheme.surfaceDark : Colors.white,
        backgroundImage: FileImage(_selectedImage!),
      );
    }

    // Check for existing avatar URL (could be preset or uploaded image)
    final avatarUrl = widget.profile.avatarUrl;
    if (avatarUrl != null) {
      if (avatarUrl.startsWith('preset:')) {
        final presetData = avatarUrl.substring(7); // Remove 'preset:' prefix
        final parts = presetData.split(':');
        if (parts.length >= 2) {
          final emoji = parts[0];
          final colorValue = int.tryParse(parts[1]) ?? 0xFF2196F3;
          return CircleAvatar(
            radius: 56,
            backgroundColor: Color(colorValue),
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          );
        }
      } else {
        // Regular image URL
        return CircleAvatar(
          radius: 56,
          backgroundColor: isDark ? colorTheme.surfaceDark : Colors.white,
          backgroundImage: NetworkImage(avatarUrl),
        );
      }
    }

    // Default: show initial letter
    return CircleAvatar(
      radius: 56,
      backgroundColor: isDark ? colorTheme.surfaceDark : Colors.white,
      child: Text(
        widget.profile.fullName?.substring(0, 1).toUpperCase() ?? 'U',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: colorTheme.primary,
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedPresetAvatar = null; // Clear preset selection
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final authRepo = ref.read(authRepositoryProvider);
    String? newAvatarUrl = widget.profile.avatarUrl;

    // Avatar yükleme (galeri resmi)
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      final uploadedUrl = await authRepo.uploadAvatar(
        widget.profile.id,
        bytes.toList(),
      );
      if (uploadedUrl != null) {
        newAvatarUrl = uploadedUrl;
      }
    }
    // Preset avatar seçildiyse, avatar_url olarak emoji:color formatında kaydet
    else if (_selectedPresetAvatar != null) {
      newAvatarUrl = 'preset:$_selectedPresetAvatar';
    }

    // Profil güncelleme
    final updatedProfile = widget.profile.copyWith(
      fullName: _nameController.text.trim(),
      avatarUrl: newAvatarUrl,
    );

    final success = await authRepo.updateProfile(updatedProfile);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        ref.invalidate(userProfileProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saved),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? colorTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  l.editProfile ?? 'Profili Düzenle',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Avatar Section
                  GestureDetector(
                    onTap: _showAvatarOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorTheme.primaryLight,
                                colorTheme.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorTheme.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: _buildAvatarContent(colorTheme, isDark),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? colorTheme.surfaceDark
                                    : Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    l.changePhoto ?? 'Fotoğrafı Değiştir',
                    style: TextStyle(
                      color: colorTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Name Field
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: l.displayName ?? 'Görünen İsim',
                      labelStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.person, color: colorTheme.primary),
                      filled: true,
                      fillColor: isDark
                          ? colorTheme.surfaceDark
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colorTheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email (Read-only)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? colorTheme.surfaceDark : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email, color: Colors.grey[500]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'E-posta',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                currentUser?.email ?? '-',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.lock, color: Colors.grey[400], size: 18),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? colorTheme.surfaceDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        l.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
