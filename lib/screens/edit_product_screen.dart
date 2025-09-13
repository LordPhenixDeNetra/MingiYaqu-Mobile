import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  Category? _selectedCategory;
  DateTime? _purchaseDate;
  DateTime? _expirationDate;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.product.name;
    _quantityController.text = widget.product.quantity.toString();
    _notesController.text = widget.product.notes ?? '';
    _barcodeController.text = widget.product.barcode ?? '';
    _selectedCategory = ProductCategories.getCategoryById(widget.product.category);
    _purchaseDate = widget.product.purchaseDate;
    _expirationDate = widget.product.expirationDate;
    _imagePath = widget.product.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Modifier le produit'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              const SizedBox(height: AppStyles.paddingL),
              _buildBasicInfoSection(),
              const SizedBox(height: AppStyles.paddingL),
              _buildCategorySection(),
              const SizedBox(height: AppStyles.paddingL),
              _buildDatesSection(),
              const SizedBox(height: AppStyles.paddingL),
              _buildAdditionalInfoSection(),
              const SizedBox(height: AppStyles.paddingXL),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
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
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  border: Border.all(
                    color: AppColors.outline,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppStyles.radiusM - 2),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
          ),
          if (_imagePath != null) ...[
            const SizedBox(height: AppStyles.paddingM),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _imagePath = null;
                  });
                },
                icon: const Icon(Icons.delete),
                label: const Text('Supprimer l\'image'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: AppStyles.iconL,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: AppStyles.paddingS),
        Text(
          'Ajouter une photo',
          style: AppStyles.bodySmall(context).copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
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
            controller: _nameController,
            label: 'Nom du produit',
            hint: 'Ex: Lait, Pommes, Yaourt...',
            prefixIcon: Icons.shopping_basket,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom du produit est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: AppStyles.paddingM),
          CustomInputField(
            controller: _quantityController,
            label: 'Quantité',
            hint: 'Ex: 1, 2, 500g...',
            prefixIcon: Icons.numbers,
            keyboardType: TextInputType.number,
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
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
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
        ],
      ),
    );
  }

  Widget _buildDatesSection() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dates',
            style: AppStyles.titleMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppStyles.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Date d\'achat',
                  date: _purchaseDate,
                  onTap: () => _selectDate(context, true),
                  icon: Icons.shopping_cart,
                ),
              ),
              const SizedBox(width: AppStyles.paddingM),
              Expanded(
                child: _buildDateField(
                  label: 'Date d\'expiration',
                  date: _expirationDate,
                  onTap: () => _selectDate(context, false),
                  icon: Icons.event,
                  required: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
    bool required = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppStyles.paddingM),
        decoration: BoxDecoration(
          border: Border.all(
            color: required && date == null
                ? AppColors.error
                : AppColors.outline,
          ),
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: AppStyles.iconS,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppStyles.paddingS),
                Text(
                  label,
                  style: AppStyles.bodySmall(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (required)
                  Text(
                    ' *',
                    style: AppStyles.bodySmall(context).copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppStyles.paddingS),
            Text(
              date != null
                  ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
                  : 'Sélectionner une date',
              style: date != null
                  ? AppStyles.bodyMedium(context)
                  : AppStyles.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(AppStyles.paddingL),
      child: Column(
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
            controller: _barcodeController,
            label: 'Code-barres (optionnel)',
            hint: 'Scanner ou saisir manuellement',
            prefixIcon: Icons.qr_code,
            suffixIcon: Icon(Icons.qr_code_scanner),
            onSuffixIconPressed: _scanBarcode,
          ),
          const SizedBox(height: AppStyles.paddingM),
          CustomInputField(
            controller: _notesController,
            label: 'Notes (optionnel)',
            hint: 'Ajouter des notes sur ce produit...',
            prefixIcon: Icons.note,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Enregistrer les modifications',
          onPressed: _isLoading ? null : _saveProduct,
          isLoading: _isLoading,
          icon: Icons.save,
        ),
        const SizedBox(height: AppStyles.paddingM),
        SecondaryButton(
          text: 'Annuler',
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          icon: Icons.cancel,
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPurchaseDate
          ? (_purchaseDate ?? DateTime.now())
          : (_expirationDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text.trim(),
        category: _selectedCategory?.id ?? widget.product.category,
        categoryId: _selectedCategory?.id,
        purchaseDate: _purchaseDate ?? DateTime.now(),
        expirationDate: _expirationDate!,
        quantity: int.parse(_quantityController.text),
        imagePath: _imagePath,
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await context.read<ProductProvider>().updateProduct(updatedProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit modifié avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la modification: $e'),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${widget.product.name}" ?\n\n'
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct();
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    try {
      await context.read<ProductProvider>().deleteProduct(widget.product.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit supprimé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}