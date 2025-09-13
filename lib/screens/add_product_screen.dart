import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:io';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/category_icon.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'barcode_scanner_screen.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _locationController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Category? _selectedCategory;
  DateTime? _purchaseDate;
  DateTime? _expirationDate;
  String? _imagePath;
  bool _isLoading = false;
  int _currentStep = 0;
  final int _totalSteps = 4;

  final List<String> _stepTitles = [
    'Informations de base',
    'Catégorie',
    'Dates importantes',
    'Détails supplémentaires',
  ];

  final List<IconData> _stepIcons = [
    Icons.info_outline,
    Icons.category_outlined,
    Icons.calendar_today_outlined,
    Icons.more_horiz_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.name;
      _quantityController.text = product.quantity.toString();
      _notesController.text = product.notes ?? '';
      _barcodeController.text = product.barcode ?? '';
      _locationController.text = product.location ?? '';
      _selectedCategory = ProductCategories.getById(product.category);
      _purchaseDate = product.purchaseDate;
      _expirationDate = product.expirationDate;
      _imagePath = product.imagePath;
    } else {
      _purchaseDate = DateTime.now();
      _quantityController.text = '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isEditing),
            _buildProgressIndicator(),
            Expanded(
              child: Form(
                key: _formKey,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentStep = index;
                            });
                            _animationController.reset();
                            _animationController.forward();
                          },
                          children: [
                            _buildBasicInfoStep(),
                            _buildCategoryStep(),
                            _buildDatesStep(),
                            _buildAdditionalInfoStep(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildBottomNavigation(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppStyles.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Modifier le produit' : 'Nouveau produit',
                  style: AppStyles.headingM(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppStyles.paddingXS),
                Text(
                  _stepTitles[_currentStep],
                  style: AppStyles.bodyMedium(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Icon(
              _stepIcons[_currentStep],
              color: Theme.of(context).colorScheme.primary,
              size: AppStyles.iconM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.paddingL,
        vertical: AppStyles.paddingM,
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isActive = index <= _currentStep;
              final isCurrent = index == _currentStep;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < _totalSteps - 1 ? AppStyles.paddingS : 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (index < _totalSteps - 1)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: AppStyles.paddingS),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: isCurrent
                              ? Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppStyles.paddingS),
          Text(
            'Étape ${_currentStep + 1} sur $_totalSteps',
            style: AppStyles.bodySmall(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Informations de base',
            'Ajoutez les informations essentielles de votre produit',
            Icons.info_outline,
          ),
          const SizedBox(height: AppStyles.paddingXL),
          _buildImageSection(),
          const SizedBox(height: AppStyles.paddingXL),
          _buildBasicInfoSection(),
        ],
      ),
    );
  }

  Widget _buildCategoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Catégorie',
            'Sélectionnez la catégorie appropriée pour votre produit',
            Icons.category_outlined,
          ),
          const SizedBox(height: AppStyles.paddingXL),
          _buildCategorySection(),
        ],
      ),
    );
  }

  Widget _buildDatesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Dates importantes',
            'Définissez les dates d\'achat et d\'expiration',
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: AppStyles.paddingXL),
          _buildDatesSection(),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Informations supplémentaires',
            'Ajoutez des détails optionnels pour mieux organiser vos produits',
            Icons.note_add_outlined,
          ),
          const SizedBox(height: AppStyles.paddingXL),
          _buildAdditionalInfoSection(),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: AppStyles.iconL,
            ),
          ),
          const SizedBox(width: AppStyles.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.headingS(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppStyles.paddingXS),
                Text(
                  subtitle,
                  style: AppStyles.bodySmall(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo du produit',
          style: AppStyles.titleMedium(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppStyles.paddingM),
        Center(
          child: GestureDetector(
            onTap: _imagePath != null ? _showImagePreview : _pickImage,
            child: Container(
              width: _imagePath != null ? 180 : 120,
              height: _imagePath != null ? 180 : 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                border: Border.all(
                  color: _imagePath != null ? Theme.of(context).colorScheme.primary : AppColors.outline,
                  width: _imagePath != null ? 3 : 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: _imagePath != null ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: _imagePath != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppStyles.borderRadiusL),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _imagePath = null;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              onPressed: _showImagePreview,
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
        ),
        const SizedBox(height: AppStyles.paddingM),
        if (_imagePath != null)
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppStyles.paddingS),
                Expanded(
                  child: Text(
                    'Photo sélectionnée - Appuyez pour voir en grand',
                    style: AppStyles.bodySmall(context).copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppStyles.paddingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(_imagePath != null ? Icons.edit : Icons.camera_alt),
                label: Text(_imagePath != null ? 'Changer' : 'Ajouter une photo'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (_imagePath != null) ...[
              const SizedBox(width: AppStyles.paddingS),
              Expanded(
                child: TextButton.icon(
                  onPressed: _showImagePreview,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Aperçu'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: AppStyles.iconXL,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: AppStyles.paddingS),
        Text(
          'Photo',
          style: AppStyles.labelMedium(context).copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de base',
          style: AppStyles.titleMedium(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppStyles.paddingM),
        CustomInputField(
          label: 'Nom du produit',
          hint: 'Ex: Lait demi-écrémé',
          controller: _nameController,
          required: true,
          prefixIcon: Icons.shopping_basket,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom du produit est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: AppStyles.paddingL),
        CustomInputField(
          label: 'Quantité',
          hint: 'Ex: 1',
          controller: _quantityController,
          type: InputFieldType.number,
          required: true,
          prefixIcon: Icons.numbers,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La quantité est requise';
            }
            final quantity = int.tryParse(value);
            if (quantity == null || quantity <= 0) {
              return 'Veuillez entrer une quantité valide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: AppStyles.titleMedium(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppStyles.paddingM),
        CategoryIconGrid(
          categories: ProductCategories.all,
          selectedCategoryId: _selectedCategory?.id,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
        if (_selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: AppStyles.paddingS),
            child: Text(
              'Veuillez sélectionner une catégorie',
              style: AppStyles.labelSmall(context).copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dates',
          style: AppStyles.titleMedium(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppStyles.paddingM),
        CustomInputField(
          label: 'Date d\'achat',
          hint: 'Sélectionner la date',
          controller: TextEditingController(
            text: _purchaseDate != null
                ? Jiffy.parseFromDateTime(_purchaseDate!).format(pattern: 'dd/MM/yyyy')
                : '',
          ),
          readOnly: true,
          prefixIcon: Icons.calendar_today,
          onTap: () => _selectDate(context, true),
        ),
        const SizedBox(height: AppStyles.paddingL),
        CustomInputField(
          label: 'Date d\'expiration',
          hint: 'Sélectionner la date',
          controller: TextEditingController(
            text: _expirationDate != null
                ? Jiffy.parseFromDateTime(_expirationDate!).format(pattern: 'dd/MM/yyyy')
                : '',
          ),
          readOnly: true,
          required: true,
          prefixIcon: Icons.event_busy,
          onTap: () => _selectDate(context, false),
        ),
        if (_expirationDate == null)
          Padding(
            padding: const EdgeInsets.only(top: AppStyles.paddingS),
            child: Text(
              'La date d\'expiration est requise',
              style: AppStyles.labelSmall(context).copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations supplémentaires',
          style: AppStyles.titleMedium(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppStyles.paddingM),
        CustomInputField(
          label: 'Code-barres',
          hint: 'Scanner ou saisir manuellement',
          controller: _barcodeController,
          prefixIcon: Icons.qr_code,
          suffixIcon: IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
        ),
        const SizedBox(height: AppStyles.paddingL),
        CustomInputField(
          label: 'Notes',
          hint: 'Informations supplémentaires...',
          controller: _notesController,
          type: InputFieldType.multiline,
          maxLines: 3,
          prefixIcon: Icons.note,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingL),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
             Expanded(
               child: ElevatedButton.icon(
                 onPressed: () {
                   _pageController.previousPage(
                     duration: const Duration(milliseconds: 300),
                     curve: Curves.easeInOut,
                   );
                 },
                 icon: const Icon(Icons.arrow_back),
                 label: const Text('Précédent'),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Theme.of(context).colorScheme.surface,
                   foregroundColor: Theme.of(context).colorScheme.onSurface,
                   elevation: 2,
                   padding: const EdgeInsets.symmetric(
                     vertical: AppStyles.paddingM,
                     horizontal: AppStyles.paddingL,
                   ),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(AppStyles.radiusM),
                     side: BorderSide(
                       color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                     ),
                   ),
                 ),
               ),
             ),
           if (_currentStep > 0) const SizedBox(width: AppStyles.paddingM),
           Expanded(
             flex: _currentStep == 0 ? 1 : 2,
             child: ElevatedButton.icon(
               onPressed: _isLoading
                   ? null
                   : (_currentStep == _totalSteps - 1
                       ? _saveProduct
                       : () {
                           if (_validateCurrentStep()) {
                             _pageController.nextPage(
                               duration: const Duration(milliseconds: 300),
                               curve: Curves.easeInOut,
                             );
                           }
                         }),
               icon: _isLoading
                   ? const SizedBox(
                       width: 16,
                       height: 16,
                       child: CircularProgressIndicator(
                         strokeWidth: 2,
                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                       ),
                     )
                   : Icon(_currentStep == _totalSteps - 1
                       ? (isEditing ? Icons.edit : Icons.add)
                       : Icons.arrow_forward),
               label: Text(_currentStep == _totalSteps - 1
                   ? (isEditing ? 'Modifier' : 'Ajouter')
                   : 'Suivant'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Theme.of(context).colorScheme.primary,
                 foregroundColor: Theme.of(context).colorScheme.onPrimary,
                 elevation: 4,
                 padding: const EdgeInsets.symmetric(
                   vertical: AppStyles.paddingM,
                   horizontal: AppStyles.paddingL,
                 ),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(AppStyles.radiusM),
                 ),
               ),
             ),
           ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic info
        if (_nameController.text.trim().isEmpty) {
          _showValidationError('Le nom du produit est requis');
          return false;
        }
        if (_quantityController.text.trim().isEmpty ||
            int.tryParse(_quantityController.text) == null ||
            int.parse(_quantityController.text) <= 0) {
          _showValidationError('Veuillez entrer une quantité valide');
          return false;
        }
        return true;
      case 1: // Category
        if (_selectedCategory == null) {
          _showValidationError('Veuillez sélectionner une catégorie');
          return false;
        }
        return true;
      case 2: // Dates
        if (_expirationDate == null) {
          _showValidationError('Veuillez sélectionner une date d\'expiration');
          return false;
        }
        return true;
      case 3: // Additional info
        return true;
      default:
        return true;
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImagePreview() {
    if (_imagePath == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppStyles.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppStyles.radiusL),
                  child: Image.file(
                    File(_imagePath!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(AppStyles.paddingXL),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppStyles.radiusL),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: AppStyles.paddingM),
                            Text(
                              'Impossible d\'afficher l\'image',
                              style: AppStyles.titleMedium(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 50,
                    minHeight: 50,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.paddingL,
                  vertical: AppStyles.paddingM,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppStyles.radiusL),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _pickImage();
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Changer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _imagePath = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.radiusL)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppStyles.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppStyles.paddingL),
              Text(
                'Sélectionner une photo',
                style: AppStyles.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppStyles.paddingL),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppStyles.paddingS),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text('Prendre une photo'),
                subtitle: const Text('Utiliser l\'appareil photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1200,
                    maxHeight: 1200,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _imagePath = image.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppStyles.paddingS),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                title: const Text('Choisir depuis la galerie'),
                subtitle: const Text('Sélectionner une image existante'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1200,
                    maxHeight: 1200,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _imagePath = image.path;
                    });
                  }
                },
              ),
              if (_imagePath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppStyles.paddingS),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  title: const Text('Supprimer la photo'),
                  subtitle: const Text('Retirer l\'image sélectionnée'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imagePath = null;
                    });
                  },
                ),
              const SizedBox(height: AppStyles.paddingM),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPurchaseDate
          ? (_purchaseDate ?? DateTime.now())
          : (_expirationDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: isPurchaseDate
          ? DateTime.now().subtract(const Duration(days: 365))
          : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _expirationDate = picked;
        }
      });
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerScreen(),
        ),
      );
      
      if (result != null && result.isNotEmpty) {
        setState(() {
          _barcodeController.text = result;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Code-barres scanné: $result'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date d\'expiration'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory!.id,
        purchaseDate: _purchaseDate ?? DateTime.now(),
        expirationDate: _expirationDate!,
        quantity: int.parse(_quantityController.text),
        imagePath: _imagePath,
        barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final productProvider = context.read<ProductProvider>();
      
      if (widget.product != null) {
        await productProvider.updateProduct(product);
      } else {
        await productProvider.addProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product != null
                  ? 'Produit modifié avec succès'
                  : 'Produit ajouté avec succès',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}