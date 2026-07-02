import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendas_app/src/features/cart/cart_viewmodel.dart';
import 'package:vendas_app/src/features/product/product_viewmodel.dart';
import 'package:vendas_app/src/features/cart/widgets/cart_bottom_banner.dart';
import 'package:vendas_app/src/application/helpers/currency_helper.dart';


class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.watch<ProductViewModel>();
    final cartViewModel = context.read<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context, productViewModel),
            tooltip: 'Ordenar Produtos',
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
          // Lista de Produtos
          Expanded(
            child: productViewModel.products.isEmpty
                ? const Center(child: Text('Nenhum produto cadastrado.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: productViewModel.products.length,
                      itemBuilder: (context, index) {
                        final product = productViewModel.products[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.grey[200],
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Center(
                                            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                          ),
                                        )
                                      : const Center(
                                          child: Icon(Icons.image, size: 40, color: Colors.grey),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 2.0),
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                child: Text(
                                  CurrencyHelper.format(product.price),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Tooltip(
                                      message: product.isFavorite
                                          ? 'Remover dos favoritos'
                                          : 'Adicionar aos favoritos',
                                      child: IconButton(
                                        icon: Icon(
                                          product.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: product.isFavorite ? Colors.red : null,
                                        ),
                                        onPressed: () =>
                                            productViewModel.toggleFavorite(product.id),
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Adicionar ao carrinho de compras',
                                      child: IconButton(
                                        icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                                        onPressed: () {
                                          cartViewModel.addToCart(product);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
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

  void _showSortDialog(BuildContext context, ProductViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Ordenar por:'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                viewModel.sortByName(ascending: true);
                Navigator.pop(context);
              },
              child: const Text('Nome (A-Z)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                viewModel.sortByName(ascending: false);
                Navigator.pop(context);
              },
              child: const Text('Nome (Z-A)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                viewModel.sortByPrice(ascending: true);
                Navigator.pop(context);
              },
              child: const Text('Preço (Menor para Maior)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                viewModel.sortByPrice(ascending: false);
                Navigator.pop(context);
              },
              child: const Text('Preço (Maior para Menor)'),
            ),
          ],
        );
      },
    );
  }
}
