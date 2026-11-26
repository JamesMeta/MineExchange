import 'package:economycraft/classes/modals/market_item.dart';
import 'package:economycraft/classes/modals/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:economycraft/classes/modals/product.dart';

class SupabaseProduct {
  static final _client = Supabase.instance.client;

  //TODO
  // Migrate the following method to use MarketItem instead of individual fields
  Future<void> addProductToCompany(
    int companyId,
    String name,
    String description,
    double price,
    int quantity,
    String minecraftTag,
    String avatarUrl,
  ) async {
    try {
      await _client.from('products').insert({
        'company_id': companyId,
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'minecraft_tag': minecraftTag,
        'avatar_url': avatarUrl,
      });
    } catch (e) {
      developer.log('Error adding product to company: $e');
    }
  }

  //TODO
  // Migrate the following method to use MarketItem instead of individual fields
  Future<void> updateProduct(
    int productId,
    String name,
    String description,
    double price,
    int quantity,
    String productTag,
  ) async {
    try {
      await _client
          .from('products')
          .update({
            'name': name,
            'description': description,
            'price': price,
            'quantity': quantity,
            'minecraft_tag': productTag,
            'verified': false,
          })
          .eq('id', productId);
    } catch (e) {
      developer.log('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      developer.log('Error deleting product: $e');
    }
  }

  Future<List<Product>> getProductsByCompanyId(int companyId) async {
    try {
      final response = await _client
          .from('products')
          .select('*, valid_market_items:market_item_id(*), users:user_id(*)')
          .eq('company_id', companyId)
          .order('price', ascending: true);
      if (response.isEmpty) {
        return [];
      }
      final List<Product> products =
          response.map<Product>((product) {
            return Product(
              id: product['id'],
              name: product['name'],
              description: product['description'],
              price: product['price'],
              quantity: product['quantity'],
              marketItem: MarketItem.fromMap(product['valid_market_items']),
              player: Player.fromMap(product['users']),
              createdAt: product['created_at'],
              isSell: product['is_sell'] ?? false,
            );
          }).toList();
      return products;
    } catch (e) {
      developer.log('Error fetching products by company ID: $e');
      return [];
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('*, valid_market_items:market_item_id(*), users:user_id(*)')
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<Product> products =
          response.map<Product>((product) {
            return Product(
              id: product['id'],
              name: product['name'],
              description: product['description'],
              price: product['price'],
              quantity: product['quantity'],
              marketItem: MarketItem.fromMap(product['valid_market_items']),
              player: Player.fromMap(product['users']),
              createdAt: product['created_at'],
              isSell: product['is_sell'] ?? false,
            );
          }).toList();
      return products;
    } catch (e) {
      developer.log('Error fetching all products: $e');
      return [];
    }
  }

  Future<Product?> getProductById(int productId) async {
    try {
      final response =
          await _client
              .from('products')
              .select(
                '*, valid_market_items:market_item_id(*), users:user_id(*)',
              )
              .eq('id', productId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return null;
      }
      return Product(
        id: response['id'],
        name: response['name'],
        description: response['description'],
        price: response['price'],
        quantity: response['quantity'],
        marketItem: MarketItem.fromMap(response['valid_market_items']),
        player: Player.fromMap(response['users']),
        createdAt: response['created_at'],
        isSell: response['is_sell'] ?? false,
      );
    } catch (e) {
      developer.log('Error fetching product by ID: $e');
      return null;
    }
  }

  Future<double> getProductPrice(int productId) async {
    try {
      final response =
          await _client
              .from('products')
              .select('price')
              .eq('id', productId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return 0.0;
      }
      return response['price'];
    } catch (e) {
      developer.log('Error fetching product price: $e');
      return 0.0;
    }
  }

  Future<void> subtractProductQuantity(
    int productId,
    int orderedQuantity,
  ) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        developer.log('Error: Product not found');
        return;
      }
      final newQuantity = product.quantity - orderedQuantity;
      if (newQuantity < 0) {
        developer.log('Error: Insufficient product quantity');
        return;
      }
      await _client
          .from('products')
          .update({'quantity': newQuantity})
          .eq('id', productId);
    } catch (e) {
      developer.log('Error subtracting product quantity: $e');
    }
  }

  Future<bool> isProductOwner(int productId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final isOwner = await _client.rpc(
        'user_owns_product_company',
        params: {'product_id': productId, 'user_uuid': user.id},
      );

      return isOwner;
    } catch (e) {
      developer.log('Error checking product ownership: $e');
      return false;
    }
  }
}
