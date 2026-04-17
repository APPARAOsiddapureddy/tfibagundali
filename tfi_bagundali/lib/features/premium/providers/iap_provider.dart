import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';
import '../constants/iap_products.dart';

@immutable
class IapState {
  const IapState({
    required this.isAvailable,
    required this.products,
    this.purchaseStatus,
    required this.isPurchasing,
    this.errorMessage,
  });

  final bool isAvailable;
  final List<ProductDetails> products;
  final PurchaseStatus? purchaseStatus;
  final bool isPurchasing;
  final String? errorMessage;

  IapState copyWith({
    bool? isAvailable,
    List<ProductDetails>? products,
    PurchaseStatus? purchaseStatus,
    bool? isPurchasing,
    String? errorMessage,
  }) {
    return IapState(
      isAvailable: isAvailable ?? this.isAvailable,
      products: products ?? this.products,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      errorMessage: errorMessage,
    );
  }
}

class IapNotifier extends StateNotifier<IapState> {
  IapNotifier(this._api) : super(const IapState(isAvailable: false, products: [], isPurchasing: false)) {
    _init();
  }

  final ApiClient _api;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> _init() async {
    final available = await _iap.isAvailable();
    if (!available) {
      state = state.copyWith(
        isAvailable: false,
        errorMessage: 'Store not available',
      );
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) {
        state = state.copyWith(errorMessage: 'Purchase stream error: $e');
      },
    );

    final response = await _iap.queryProductDetails(IapProducts.allIds);
    if (response.error != null) {
      state = state.copyWith(errorMessage: response.error!.message);
      return;
    }

    await _iap.restorePurchases();

    final sorted = [...response.productDetails]..sort((a, b) {
        final ra = _rank(a.id);
        final rb = _rank(b.id);
        return ra.compareTo(rb);
      });

    state = state.copyWith(
      isAvailable: true,
      products: sorted,
    );
  }

  int _rank(String id) {
    if (id == IapProducts.basic1Month) return 0;
    if (id == IapProducts.superFan3Month) return 1;
    if (id == IapProducts.massRaj1Year) return 2;
    return 99;
  }

  Future<void> purchase(ProductDetails product) async {
    state = state.copyWith(isPurchasing: true, errorMessage: null);
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndActivate(purchase);
          break;
        case PurchaseStatus.error:
          state = state.copyWith(
            isPurchasing: false,
            errorMessage: purchase.error?.message ?? 'Purchase failed',
          );
          break;
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.canceled:
          state = state.copyWith(isPurchasing: false);
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyAndActivate(PurchaseDetails purchase) async {
    try {
      await _api.post(ApiEndpoints.premiumVerify, body: {
        'product_id': purchase.productID,
        'purchase_token': purchase.verificationData.serverVerificationData,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'transaction_id': purchase.purchaseID,
      });
      state = state.copyWith(
        isPurchasing: false,
        purchaseStatus: PurchaseStatus.purchased,
      );
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'Verification failed. Contact support.',
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final iapProvider = StateNotifierProvider<IapNotifier, IapState>((ref) {
  return IapNotifier(ref.watch(apiClientProvider));
});
