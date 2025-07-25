// lib/screens/passenger/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/date_utils.dart';
import '../../services/payment_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/error_states.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';
import '../../utils/responsive_utils.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? tripDetails;
  final double? fareAmount;
  
  const PaymentScreen({
    Key? key,
    this.tripDetails,
    this.fareAmount,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();
  
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'card';
  
  // Card payment controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  // Wallet balance
  double _walletBalance = 2450;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWalletBalance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final balance = await _paymentService.getWalletBalance();
      setState(() {
        _walletBalance = balance;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final fareAmount = widget.fareAmount ?? 150;

    return AppLayout(
      title: 'Payment',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip summary
            _buildTripSummary(localizations, fareAmount),
            const SizedBox(height: 16),
            
            // Payment methods
            _buildPaymentMethods(localizations),
            const SizedBox(height: 16),
            
            // Payment form
            _buildPaymentForm(localizations),
            const SizedBox(height: 16),
            
            // Payment button
            _buildPaymentButton(localizations, fareAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummary(AppLocalizations localizations, double fareAmount) {
    final trip = widget.tripDetails;
    
    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (trip != null) ...[
            _buildSummaryRow('Line', trip['lineName'] ?? 'Unknown Line'),
            _buildSummaryRow('From', trip['originStop'] ?? 'Unknown'),
            _buildSummaryRow('To', trip['destinationStop'] ?? 'Unknown'),
            _buildSummaryRow('Date', DzDateUtils.formatDate(DateTime.now())),
            _buildSummaryRow('Time', DzDateUtils.formatTime(DateTime.now())),
            const Divider(),
          ],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$fareAmount DA',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(AppLocalizations localizations) {
    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Payment method options
          _buildPaymentOption(
            'wallet',
            'Wallet',
            Icons.account_balance_wallet,
            'Balance: $_walletBalance DA',
            Theme.of(context).colorScheme.primary,
          ),
          _buildPaymentOption(
            'card',
            'Credit/Debit Card',
            Icons.credit_card,
            'Visa, Mastercard, CIB',
            Theme.of(context).colorScheme.primary,
          ),
          _buildPaymentOption(
            'mobile',
            'Mobile Payment',
            Icons.smartphone,
            'CIB Mobile, Baridi Mob',
            Theme.of(context).colorScheme.primary,
          ),
          _buildPaymentOption(
            'cash',
            'Cash Payment',
            Icons.money,
            'Pay driver directly',
            Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, String title, IconData icon, String subtitle, Color color) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.primary,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(AppLocalizations localizations) {
    switch (_selectedPaymentMethod) {
      case 'card':
        return _buildCardForm();
      case 'mobile':
        return _buildMobileForm();
      case 'wallet':
        return _buildWalletForm();
      case 'cash':
        return _buildCashForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCardForm() {
    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Card number
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Expiry and CVV row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    hintText: '12/25',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Cardholder name
          TextFormField(
            controller: _cardHolderController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileForm() {
    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile Payment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mobile payment providers
          _buildMobileProvider('CIB Mobile', 'assets/images/cib_logo.png'),
          _buildMobileProvider('Baridi Mob', 'assets/images/baridi_logo.png'),
          _buildMobileProvider('Mobilis Money', 'assets/images/mobilis_logo.png'),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You will be redirected to your mobile payment app to complete the transaction.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProvider(String name, String logoPath) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.smartphone, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Handle mobile payment provider selection
      },
    );
  }

  Widget _buildWalletForm() {
    final fareAmount = widget.fareAmount ?? 150;
    final canPay = _walletBalance >= fareAmount;
    
    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Payment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Wallet balance display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                        ),
                      ),
                      Text(
                        '$_walletBalance DA',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (!canPay) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Insufficient balance. Please top up your wallet or choose another payment method.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
        text: 'Top Up Wallet',
        onPressed: _showTopUpDialog,
        type: ButtonType.outline,
        color: Theme.of(context).colorScheme.primary,
      ),
          ],
        ],
      ),
    );
  }

  Widget _buildCashForm() {
    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Payment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.money, color: Theme.of(context).colorScheme.primary, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Pay the driver directly',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Show this QR code to the driver when boarding the bus. The driver will confirm your payment.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // QR Code placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, size: 60, color: Theme.of(context).colorScheme.primary),
                      Text(
                        'QR Code',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(AppLocalizations localizations, double fareAmount) {
    final canPay = _selectedPaymentMethod != 'wallet' || _walletBalance >= fareAmount;
    
    return CustomButton(
        text: _isProcessing ? 'Processing...' : 'Pay $fareAmount DA',
        onPressed: canPay ? _processPayment : null,
        type: ButtonType.primary,
        size: ButtonSize.large,
        isLoading: _isProcessing,
        isDisabled: !canPay,
        fullWidth: true,
        );
  }

  void _showTopUpDialog() {
    final amountController = TextEditingController();
    
    DialogHelper.showGlassyDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Top Up Wallet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (DA)',
              hintText: '500',
              prefixIcon: const Icon(Icons.money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _topUpWallet(double.tryParse(amountController.text) ?? 0);
                  },
                  child: const Text('Top Up'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _topUpWallet(double amount) async {
    if (amount <= 0) return;
    
    setState(() => _isProcessing = true);
    
    try {
      await _paymentService.topUpWallet(amount);
      setState(() {
        _walletBalance += amount;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallet topped up with $amount DA'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to top up wallet: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    try {
      final success = await _paymentService.processPayment(
        method: _selectedPaymentMethod,
        amount: widget.fareAmount ?? 150,
        tripDetails: widget.tripDetails,
        cardDetails: _selectedPaymentMethod == 'card' ? {
          'number': _cardNumberController.text,
          'expiry': _expiryController.text,
          'cvv': _cvvController.text,
          'holder': _cardHolderController.text,
        } : null,
      );
      
      if (success) {
        // Show success dialog
        DialogHelper.showSuccessDialog(
          context,
          title: 'Payment Successful',
          message: 'Your payment has been processed successfully. Your ticket is ready!',
        ).then((_) {
          Navigator.pop(context, true);
        });
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0),
      child: const Center(
        child: LoadingIndicator(),
      ),
    );
  }
}