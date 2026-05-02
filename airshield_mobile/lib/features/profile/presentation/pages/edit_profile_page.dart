import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airshield_mobile/core/utils/validators.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/data/models/user.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../bloc/profile_bloc.dart';

/// Edit Profile Page
/// 
/// Allows users to edit their profile information
class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _bioController = TextEditingController(text: widget.user.bio);
    
    _nameController.addListener(() => setState(() => _hasChanges = true));
    _emailController.addListener(() => setState(() => _hasChanges = true));
    _phoneController.addListener(() => setState(() => _hasChanges = true));
    _bioController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        bio: _bioController.text,
      );
      
      context.read<ProfileBloc>().add(UpdateProfile(updatedUser));
    }
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Avatar',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                  ),
                  title: Text(
                    'Camera',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                  ),
                  title: Text(
                    'Gallery',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        context.read<ProfileBloc>().add(UploadAvatar(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(
            l10n.editProfile,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _saveProfile,
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar section
              _buildAvatarSection(),
              const SizedBox(height: 32),
              
              // Name field
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person,
                validator: Validators.name,
              ),
              const SizedBox(height: 16),
              
              // Email field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              
              // Phone field
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              
              // Bio field
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.notes,
                maxLines: 3,
              ),
            ],
          ),
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton.extended(
                onPressed: _saveProfile,
                backgroundColor: const Color(0xFF4CAF50),
                icon: const Icon(Icons.save),
                label: Text(
                  'Save Changes',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
            backgroundImage: widget.user.avatarUrl != null
                ? NetworkImage(widget.user.avatarUrl!)
                : null,
            child: widget.user.avatarUrl == null
                ? Text(
                    widget.user.name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 3,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () => _showAvatarPicker(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4CAF50),
            width: 2,
          ),
        ),
      ),
      style: GoogleFonts.poppins(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
