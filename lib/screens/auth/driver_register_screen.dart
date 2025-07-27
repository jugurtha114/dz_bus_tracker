// lib/screens/auth/driver_register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';
import '../../helpers/validation_helper.dart';

/// Modern driver registration screen with step-by-step process
class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idCardNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _experienceController = TextEditingController();
  final _addressController = TextEditingController();

  // Image handling
  File? _idCardPhoto;
  File? _licensePhoto;
  Uint8List? _webIdCardImage;
  Uint8List? _webLicenseImage;

  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idCardNumberController.dispose();
    _licenseNumberController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Driver Registration',
      showBackButton: true,
      child: Column(
        children: [
          // Progress Header
          _buildProgressHeader(),
          
          // Tab Bar
          AppTabBar(
            controller: _tabController,
            tabs: const [
              AppTab(label: 'Personal Info', icon: Icons.person),
              AppTab(label: 'Driver Details', icon: Icons.drive_eta),
            ],
          ),
          
          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildDriverDetailsStep(),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Column(
        children: [
          Text(
            'Complete your driver profile',
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignSystem.space8),
          Text(
            'Step ${_currentStep + 1} of 2',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: DesignSystem.space16),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 2,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Column(
        children: [
          SectionLayout(
            title: 'Personal Information',
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppInput(
                            label: 'First Name',
                            controller: _firstNameController,
                            validator: (value) => ValidationHelper.validateRequired(value, 'First name'),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: DesignSystem.space12),
                        Expanded(
                          child: AppInput(
                            label: 'Last Name',
                            controller: _lastNameController,
                            validator: (value) => ValidationHelper.validateRequired(value, 'Last name'),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    AppInput(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined),
                      validator: ValidationHelper.validateEmail,
                      textInputAction: TextInputAction.next,
                    ),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    AppInput(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(Icons.phone_outlined),
                      validator: ValidationHelper.validatePhone,
                      textInputAction: TextInputAction.next,
                    ),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    AppInput(
                      label: 'Address',
                      controller: _addressController,
                      prefixIcon: Icon(Icons.location_on_outlined),
                      validator: (value) => ValidationHelper.validateRequired(value, 'Address'),
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          SectionLayout(
            title: 'Account Security',
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Column(
                  children: [
                    AppInput(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icon(Icons.lock_outline),
                      validator: ValidationHelper.validatePassword,
                      textInputAction: TextInputAction.next,
                    ),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    AppInput(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Icon(Icons.lock_outline),
                      validator: (value) => ValidationHelper.validateConfirmPassword(
                        _passwordController.text,
                        value,
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Column(
        children: [
          SectionLayout(
            title: 'Driver Information',
            child: AppCard(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.space16),
                child: Column(
                  children: [
                    AppInput(
                      label: 'ID Card Number',
                      controller: _idCardNumberController,
                      validator: (value) => ValidationHelper.validateRequired(value, 'ID card number'),
                      textInputAction: TextInputAction.next,
                    ),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    AppInput(
                      label: 'Driver License Number',
                      controller: _licenseNumberController,
                      validator: (value) => ValidationHelper.validateRequired(value, 'License number'),
                      textInputAction: TextInputAction.next,
                    ),
                    
                    const SizedBox(height: DesignSystem.space16),
                    
                    AppInput(
                      label: 'Years of Experience',
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      validator: (value) => ValidationHelper.validateRequired(value, 'Experience'),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
          
          SectionLayout(
            title: 'Document Upload',
            child: Column(
              children: [
                _buildDocumentUpload(
                  title: 'ID Card Photo',
                  subtitle: 'Take a clear photo of your ID card',
                  hasImage: _hasIdCardImage(),
                  onTap: () => _pickImage(true),
                ),
                
                const SizedBox(height: DesignSystem.space12),
                
                _buildDocumentUpload(
                  title: 'Driver License Photo',
                  subtitle: 'Take a clear photo of your driver license',
                  hasImage: _hasLicenseImage(),
                  onTap: () => _pickImage(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String subtitle,
    required bool hasImage,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: hasImage 
                    ? context.successColor.withValues(alpha: 0.1)
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              child: Icon(
                hasImage ? Icons.check_circle : Icons.camera_alt,
                color: hasImage ? context.successColor : context.colors.onSurfaceVariant,
                size: 24,
              ),
            ),
            
            const SizedBox(width: DesignSystem.space16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              hasImage ? Icons.edit : Icons.camera_alt,
              color: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: AppButton.outlined(
                text: 'Back',
                onPressed: _previousStep,
                icon: Icons.arrow_back,
              ),
            ),
          
          if (_currentStep > 0)
            const SizedBox(width: DesignSystem.space12),
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: AppButton(
              text: _currentStep == 0 ? 'Next' : 'Register',
              onPressed: _currentStep == 0 ? _nextStep : _register,
              isLoading: _isLoading,
              icon: _currentStep == 0 ? Icons.arrow_forward : Icons.check,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _hasIdCardImage() {
    return _idCardPhoto != null || _webIdCardImage != null;
  }

  bool _hasLicenseImage() {
    return _licensePhoto != null || _webLicenseImage != null;
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          ValidationHelper.validateEmail(_emailController.text) == null &&
          ValidationHelper.validatePhone(_phoneController.text) == null &&
          _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text &&
          _addressController.text.isNotEmpty;
    } else {
      return _idCardNumberController.text.isNotEmpty &&
          _licenseNumberController.text.isNotEmpty &&
          _experienceController.text.isNotEmpty &&
          _hasIdCardImage() &&
          _hasLicenseImage();
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep = 1;
      });
      _tabController.animateTo(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
        ),
      );
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
    _tabController.animateTo(0);
  }

  Future<void> _pickImage(bool isIdCard) async {
    try {
      final picker = ImagePicker();
      final source = kIsWeb ? ImageSource.gallery : ImageSource.camera;
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            if (isIdCard) {
              _webIdCardImage = bytes;
            } else {
              _webLicenseImage = bytes;
            }
          });
        } else {
          setState(() {
            if (isIdCard) {
              _idCardPhoto = File(pickedFile.path);
            } else {
              _licensePhoto = File(pickedFile.path);
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_validateCurrentStep()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      // Prepare image data
      dynamic idCardData;
      dynamic licenseData;
      
      if (kIsWeb) {
        idCardData = _webIdCardImage;
        licenseData = _webLicenseImage;
      } else {
        idCardData = _idCardPhoto;
        licenseData = _licensePhoto;
      }

      final success = await authProvider.registerDriver(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        // address: _addressController.text.trim(), // Remove if not supported
        idCardNumber: _idCardNumberController.text.trim(),
        idCardPhoto: idCardData,
        driverLicenseNumber: _licenseNumberController.text.trim(),
        driverLicensePhoto: licenseData,
        yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Registration submitted! Your application will be reviewed.',
              ),
              backgroundColor: context.successColor,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error ?? 'Registration failed. Please try again.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}