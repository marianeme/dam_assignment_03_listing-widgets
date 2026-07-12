import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendas_app/src/features/cart/cart_viewmodel.dart';
import 'package:vendas_app/src/features/product/product_viewmodel.dart';
import 'package:vendas_app/src/features/cart/widgets/cart_bottom_banner.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.watch<ProductViewModel>();
    final cartViewModel = context.read<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/products/form'),
            tooltip: 'Adicionar Produto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros de Categoria (Chips horizontais)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 8.0),
              itemCount: productViewModel.categories.length,
              itemBuilder: (context, index) {
                final category = productViewModel.categories[index];
                final isSelected = productViewModel.currentCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      productViewModel.filterByCategory(category);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: productViewModel.products.isEmpty
                ? const Center(child: Text('Nenhum produto cadastrado.'))
                : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 0.75,
              ),
              itemCount: productViewModel.products.length,
              itemBuilder: (context, index) {
                final product = productViewModel.products[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey[200],
                          width: double.infinity,
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                          )
                              : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'R\$ ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              product.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: product.isFavorite ? Colors.red : null,
                            ),
                            tooltip: 'Adicionar aos favoritos',
                            onPressed: () => productViewModel.toggleFavorite(product.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                            tooltip: 'Adicionar ao carrinho de compras',
                            onPressed: () {
                              cartViewModel.addToCart(product);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CartBottomBanner(),
    );
  }
}