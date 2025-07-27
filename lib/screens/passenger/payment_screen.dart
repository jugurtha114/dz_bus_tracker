// lib/screens/passenger/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/widgets.dart';

/// Modern payment screen for bus fares
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? tripDetails;
  final double? fareAmount;

  const PaymentScreen({
    super.key,
    this.tripDetails,
    this.fareAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Card details controllers
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  late TextEditingController _holderNameController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
    _holderNameController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Payment',
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Trip Summary
            _buildTripSummary(context),
            
            const SizedBox(height: DesignSystem.space16),
            
            // Payment Amount
            _buildPaymentAmount(context),
            
            const SizedBox(height: DesignSystem.space24),
            
            // Payment Methods
            _buildPaymentMethods(context),
            
            const SizedBox(height: DesignSystem.space24),
            
            // Payment Form
            _buildPaymentForm(context),
            
            const SizedBox(height: DesignSystem.space32),
            
            // Pay Button
            _buildPayButton(context),
            
            const SizedBox(height: DesignSystem.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummary(BuildContext context) {
    final tripDetails = widget.tripDetails;
    
    return SectionLayout(
      title: 'Trip Summary',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: DesignSystem.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bus ${tripDetails?['busNumber'] ?? 'Unknown'}',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${tripDetails?['route'] ?? 'Route not specified'}',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: DesignSystem.space16),
              
              // Trip details
              _buildTripDetailRow('From', tripDetails?['startLocation'] ?? 'Unknown'),
              _buildTripDetailRow('To', tripDetails?['endLocation'] ?? 'Unknown'),
              _buildTripDetailRow('Date', tripDetails?['date'] ?? 'Today'),
              _buildTripDetailRow('Time', tripDetails?['time'] ?? 'Now'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentAmount(BuildContext context) {
    final amount = widget.fareAmount ?? 5.50;
    
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      child: Column(
        children: [
          Text(
            'Total Amount',
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: DesignSystem.space8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: context.textStyles.displaySmall?.copyWith(
              color: context.colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DesignSystem.space4),
          Text(
            'Including taxes and fees',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return SectionLayout(
      title: 'Payment Method',
      child: Column(
        children: [
          _buildPaymentMethodOption(
            'card',
            'Credit/Debit Card',
            Icons.credit_card,
            'Visa, Mastercard, etc.',
          ),
          const SizedBox(height: DesignSystem.space8),
          _buildPaymentMethodOption(
            'digital_wallet',
            'Digital Wallet',
            Icons.account_balance_wallet,
            'Apple Pay, Google Pay, etc.',
          ),
          const SizedBox(height: DesignSystem.space8),
          _buildPaymentMethodOption(
            'bus_pass',
            'Bus Pass',
            Icons.confirmation_number,
            'Use your monthly pass',
          ),
          const SizedBox(height: DesignSystem.space8),
          _buildPaymentMethodOption(
            'cash',
            'Cash',
            Icons.money,
            'Pay with exact change',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    
    return AppCard(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        decoration: isSelected ? BoxDecoration(
          border: Border.all(
            color: context.colors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        ) : null,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected 
                  ? context.colors.primary
                  : context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected 
                  ? context.colors.onPrimary
                  : context.colors.onSurfaceVariant,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: isSelected 
              ? Icon(
                  Icons.check_circle,
                  color: context.colors.primary,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context) {
    switch (_selectedPaymentMethod) {
      case 'card':
        return _buildCardForm(context);
      case 'digital_wallet':
        return _buildDigitalWalletForm(context);
      case 'bus_pass':
        return _buildBusPassForm(context);
      case 'cash':
        return _buildCashForm(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCardForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SectionLayout(
        title: 'Card Details',
        child: Column(
          children: [
            AppInput(
              label: 'Card Number',
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                if (value.length < 16) {
                  return 'Card number must be at least 16 digits';
                }
                return null;
              },
            ),
            
            const SizedBox(height: DesignSystem.space16),
            
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'MM/YY',
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: DesignSystem.space16),
                Expanded(
                  child: AppInput(
                    label: 'CVV',
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space16),
            
            AppInput(
              label: 'Cardholder Name',
              controller: _holderNameController,
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cardholder name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalWalletForm(BuildContext context) {
    return SectionLayout(
      title: 'Digital Wallet',
      child: Column(
        children: [
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.apple),
              title: const Text('Apple Pay'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDigitalWallet('apple_pay'),
            ),
          ),
          const SizedBox(height: DesignSystem.space8),
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.android),
              title: const Text('Google Pay'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDigitalWallet('google_pay'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusPassForm(BuildContext context) {
    return SectionLayout(
      title: 'Bus Pass',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Icon(
                Icons.confirmation_number,
                size: 48,
                color: context.colors.primary,
              ),
              const SizedBox(height: DesignSystem.space16),
              Text(
                'Monthly Pass Balance',
                style: context.textStyles.titleMedium,
              ),
              const SizedBox(height: DesignSystem.space8),
              Text(
                '\$45.50',
                style: context.textStyles.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.successColor,
                ),
              ),
              const SizedBox(height: DesignSystem.space8),
              Text(
                'Valid until March 31, 2024',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashForm(BuildContext context) {
    return SectionLayout(
      title: 'Cash Payment',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Icon(
                Icons.money,
                size: 48,
                color: context.colors.primary,
              ),
              const SizedBox(height: DesignSystem.space16),
              Text(
                'Pay Cash to Driver',
                style: context.textStyles.titleMedium,
              ),
              const SizedBox(height: DesignSystem.space8),
              Text(
                'Please have exact change ready',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.space16),
              Container(
                padding: const EdgeInsets.all(DesignSystem.space12),
                decoration: BoxDecoration(
                  color: context.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: context.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: DesignSystem.space8),
                    Expanded(
                      child: Text(
                        'Show this screen to the driver when boarding',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
      child: AppButton(
        text: _getPayButtonText(),
        onPressed: _isProcessing ? null : _processPayment,
        isLoading: _isProcessing,
        width: double.infinity,
        icon: Icons.payment,
      ),
    );
  }

  String _getPayButtonText() {
    switch (_selectedPaymentMethod) {
      case 'card':
        return 'Pay with Card';
      case 'digital_wallet':
        return 'Pay with Wallet';
      case 'bus_pass':
        return 'Use Bus Pass';
      case 'cash':
        return 'Confirm Cash Payment';
      default:
        return 'Pay Now';
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'card' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showPaymentSuccess();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _selectDigitalWallet(String walletType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected $walletType')),
    );
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: context.successColor,
            ),
            const SizedBox(height: DesignSystem.space16),
            Text(
              'Payment Successful!',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignSystem.space8),
            Text(
              'Your payment has been processed successfully.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.space24),
            AppButton(
              text: 'Continue',
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}