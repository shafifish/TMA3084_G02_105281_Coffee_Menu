import 'package:flutter/material.dart';

void main() {
  runApp(const CoffeeShopApp());
}

class DrinkItem {
  const DrinkItem({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  final String name;
  final String description;
  final double price;
  final String image;
}

const List<DrinkItem> drinks = [
  DrinkItem(
    name: 'Espresso',
    description: 'Short, strong and bold. A pure shot of our house roast.',
    price: 6.00,
    image: 'assets/images/espresso.jpg',
  ),
  DrinkItem(
    name: 'Latte',
    description: 'Smooth espresso with steamed milk and a light layer of foam.',
    price: 9.50,
    image: 'assets/images/latte.jpg',
  ),
  DrinkItem(
    name: 'Cappuccino',
    description: 'Equal parts espresso, steamed milk and thick creamy foam.',
    price: 9.00,
    image: 'assets/images/cappuccino.jpg',
  ),
  DrinkItem(
    name: 'Iced Americano',
    description: 'Espresso over cold water and ice. Crisp and refreshing.',
    price: 8.00,
    image: 'assets/images/iced_americano.jpg',
  ),
  DrinkItem(
    name: 'Caramel Macchiato',
    description: 'Vanilla, steamed milk, espresso and a caramel drizzle.',
    price: 11.00,
    image: 'assets/images/caramel_macchiato.jpg',
  ),
];

class CoffeeShopApp extends StatelessWidget {
  const CoffeeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brew & Bean Cafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Map<String, int> _cart = <String, int>{};

  int get _itemCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  double get _cartTotal {
    var total = 0.0;
    for (final entry in _cart.entries) {
      final drink = drinks.firstWhere((d) => d.name == entry.key);
      total += drink.price * entry.value;
    }
    return total;
  }

  void _increment(DrinkItem item) {
    setState(() {
      _cart.update(item.name, (qty) => qty + 1, ifAbsent: () => 1);
    });
  }

  void _decrement(DrinkItem item) {
    setState(() {
      final qty = _cart[item.name] ?? 0;
      if (qty <= 1) {
        _cart.remove(item.name);
      } else {
        _cart[item.name] = qty - 1;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  void _addToCart(DrinkItem item) {
    _increment(item);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _openCart() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return CartSheet(
              cart: _cart,
              total: _cartTotal,
              onAdd: (item) {
                _increment(item);
                setSheetState(() {});
              },
              onRemove: (item) {
                _decrement(item);
                setSheetState(() {});
              },
              onClear: () {
                _clearCart();
                setSheetState(() {});
              },
              onCheckout: () {
                final messenger = ScaffoldMessenger.of(context);
                final amount = _cartTotal;
                Navigator.of(sheetContext).pop();
                _clearCart();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order placed! Total RM ${amount.toStringAsFixed(2)}',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('Brew & Bean Cafe'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _openCart,
              icon: Icon(Icons.shopping_cart, color: colors.onPrimary),
              label: Text(
                '$_itemCount',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: colors.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.local_cafe,
                  size: 40,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Freshly brewed for you',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to add a drink to your order',
                        style: TextStyle(color: colors.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: drinks.length,
              itemBuilder: (context, index) {
                final item = drinks[index];
                return DrinkCard(
                  item: item,
                  quantity: _cart[item.name] ?? 0,
                  onAdd: () => _addToCart(item),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _itemCount == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: _openCart,
                  icon: const Icon(Icons.receipt_long),
                  label: Text(
                    'View order  ($_itemCount items)  '
                    'RM ${_cartTotal.toStringAsFixed(2)}',
                  ),
                ),
              ),
            ),
    );
  }
}

class DrinkCard extends StatelessWidget {
  const DrinkCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onAdd,
  });

  final DrinkItem item;
  final int quantity;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Image.asset(
            item.image,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 110,
              height: 110,
              color: colors.secondaryContainer,
              child: Icon(
                Icons.local_cafe,
                size: 40,
                color: colors.onSecondaryContainer,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      if (quantity > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'x$quantity in cart',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle),
            color: colors.primary,
            iconSize: 32,
            tooltip: 'Add to cart',
          ),
        ],
      ),
    );
  }
}

class CartSheet extends StatelessWidget {
  const CartSheet({
    super.key,
    required this.cart,
    required this.total,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
    required this.onCheckout,
  });

  final Map<String, int> cart;
  final double total;
  final void Function(DrinkItem item) onAdd;
  final void Function(DrinkItem item) onRemove;
  final VoidCallback onClear;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = cart.entries.toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Your order',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Your cart is empty.\nTap + on a drink to add it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final drink = drinks.firstWhere((d) => d.name == entry.key);
                    final qty = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              drink.image,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 48,
                                    height: 48,
                                    color: colors.secondaryContainer,
                                    child: Icon(
                                      Icons.local_cafe,
                                      color: colors.onSecondaryContainer,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drink.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'RM ${(drink.price * qty).toStringAsFixed(2)}',
                                  style: TextStyle(color: colors.primary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => onRemove(drink),
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Remove one',
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => onAdd(drink),
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add one',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'RM ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: entries.isEmpty ? null : onClear,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: entries.isEmpty ? null : onCheckout,
                    icon: const Icon(Icons.check),
                    label: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
