import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prueba_1/db_helper.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:prueba_1/paypal_service.dart';
import 'package:prueba_1/paypal_webview.dart';
import 'package:prueba_1/registro_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _shoppingCart = [];
  bool _isLoading = true;
  Timer? _timer;
  String? _userEmail;
  final PayPalService _payPalService = PayPalService();

  Future<void> _loadUserEmail() async {
    final email = await SQLHelper.getUserEmail(widget.userId);
    setState(() {
      _userEmail = email;
    });
  }

  void _loadProducts() async {
    final products = await SQLHelper.getAllProducts();
    setState(() {
      _allProducts = products;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadUserEmail();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 120), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserForm()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startTimer,
      onPanUpdate: (_) => _startTimer(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Productos Disponibles'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFEEE5F6),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                 onPressed: _showCartModal, // Abre el modal con el contenido del carrito
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Color(0xFF745E9E),
                  ),
                 label: const Text(
                    'Ver Carrito',
                    style: TextStyle(
                      color: Color(0xFF745E9E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _allProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No hay productos disponibles',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allProducts.length,
                    itemBuilder: (context, index) {
                      final product = _allProducts[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[200],
                                    ),
                                    child: product['imagen'] != null && product['imagen'].isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              product['imagen'],
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.shopping_bag,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['nombre_product'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Precio: \$${product['precio'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Disponible: ${product['cantida_producto']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Add to Cart Button
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => _addToCart(product),
                                  icon: const Icon(Icons.add_shopping_cart),
                                  label: const Text('Agregar al carrito'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF745E9E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) async {
    TextEditingController quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Agregar ${product['nombre_product']} al carrito',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Cantidad a comprar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Stock disponible: ${product['cantida_producto']}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    int quantityToBuy = int.tryParse(quantityController.text) ?? 0;
                    int currentStock = product['cantida_producto'];

                    if (quantityToBuy <= 0 || quantityToBuy > currentStock) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cantidad no válida')),
                      );
                    } else {
                      _shoppingCart.add({
                        'id': product['id'],
                        'nombre_product': product['nombre_product'],
                        'precio': product['precio'],
                        'cantidad': quantityToBuy,
                        'imagen': product['imagen'],
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product['nombre_product']} agregado al carrito'),
                          backgroundColor: const Color(0xFF745E9E),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF745E9E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _processCartPurchase() async {
    if (_shoppingCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    double totalAmount = 0;
    String productList = '';

    for (var item in _shoppingCart) {
      int productId = item['id'];
      String nombreProducto = item['nombre_product'];
      double precio = item['precio'];
      int cantidadComprada = item['cantidad'];
      String? imagen = item['imagen'];
      int currentStock = _allProducts.firstWhere((p) => p['id'] == productId)['cantida_producto'];

      if (cantidadComprada > currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock insuficiente para $nombreProducto')),
        );
        return;
      }

      await SQLHelper.updateProduct(
        id: productId,
        nombreProducto: nombreProducto,
        precio: precio,
        cantidadProducto: currentStock - cantidadComprada,
        imagen: imagen,
      );

      totalAmount += precio * cantidadComprada;
      productList += '<li>$cantidadComprada x $nombreProducto (\$${precio.toStringAsFixed(2)})</li>';
    }

    final selectedPaymentMethod = await _showPaymentDialog();
    if (selectedPaymentMethod == 'paypal') {
      final success = await _processPayPalPayment(totalAmount);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar el pago con PayPal')),
        );
        return;
      }
    }

    await _enviarCorreo(productList, totalAmount);
    _shoppingCart.clear();
    _loadProducts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compra procesada exitosamente'),
        backgroundColor: Color(0xFF745E9E),
      ),
    );
  }

  Future<String?> _showPaymentDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Seleccione el método de pago',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.payment, color: Color(0xFF745E9E)),
                title: const Text('Pagar con PayPal'),
                onTap: () => Navigator.pop(context, 'paypal'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.money, color: Color(0xFF745E9E)),
                title: const Text('Pago en efectivo'),
                onTap: () => Navigator.pop(context, 'cash'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _processPayPalPayment(double totalAmount) async {
  try {
    final orderData = await _payPalService.createOrder(totalAmount);
    if (orderData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la orden de PayPal')),
      );
      return false;
    }

    final approvalUrl = orderData['links']
        ?.firstWhere((link) => link['rel'] == 'approve')['href'] as String?;

    if (approvalUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener URL de aprobación')),
      );
      return false;
    }

    final completer = Completer<bool>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayPalWebView(
          approvalUrl: approvalUrl,
          onComplete: (success) async {
            if (success) {
              final captured = await _payPalService.capturePayment(orderData['id']);
              if (captured) {
                final transactionId = orderData['id']; // Aquí obtienes el ID de la transacción
                debugPrint('Pago completado con ID de transacción: $transactionId');
                completer.complete(true); // Marca la operación como exitosa
              } else {
                completer.complete(false);
              }
            } else {
              completer.complete(false);
            }
          },
        ),
      ),
    );

    return await completer.future;
  } catch (e) {
    debugPrint('Error en el proceso de pago: $e');
    return false;
  }
}


  Future<void> _enviarCorreo(String productList, double totalAmount) async {
    if (_userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el correo del usuario')),
      );
      return;
    }

    String productListHtml = '';
    for (var item in _shoppingCart) {
      String nombreProducto = item['nombre_product'];
      double precio = item['precio'];
      int cantidadComprada = item['cantidad'];
      String? imagen = item['imagen'];
      
      productListHtml += '''
        <li style="margin-bottom: 16px;">
          <strong>$cantidadComprada x $nombreProducto</strong> - \$${precio.toStringAsFixed(2)} cada uno
          <br>
          ${imagen != null && imagen.isNotEmpty ? '<img src="$imagen" alt="Imagen de $nombreProducto" width="100" height="100" style="margin-top: 8px; border-radius: 4px;">' : '<p>[Imagen no disponible]</p>'}
        </li>
      ''';
    }

    final smtpServer = gmail('luismanuelr245@gmail.com', 'ylhk sxtm fhwl pquw');

    final message = Message()
      ..from = Address('luismanuelr245@gmail.com', 'Luis Manuel')
      ..recipients.add(_userEmail!)
      ..subject = 'Confirmación de Compra'
      ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #745E9E; text-align: center;">Confirmación de Compra</h2>
          <p style="margin-bottom: 20px;">Detalles de su compra:</p>
          <ul style="list-style-type: none; padding: 0;">$productListHtml</ul>
          <p style="text-align: right; font-size: 18px; margin-top: 20px;">
            Total: <strong style="color: #745E9E;">\$${totalAmount.toStringAsFixed(2)}</strong>
          </p>
          <p style="text-align: center; margin-top: 30px; color: #666;">¡Gracias por su compra!</p>
          
        </div>
      ''';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo de confirmación enviado'),
          backgroundColor: Color(0xFF745E9E),
        ),
      );
    } on MailerException catch (e) {
      print('Error al enviar el correo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar el correo')),
      );
    }
  }

  void _showCartModal() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Carrito de Compras'),
        content: _shoppingCart.isEmpty
            ? const Text('El carrito está vacío')
            : SizedBox(
                width: double.maxFinite,
                height: 300, // Ajusta la altura si es necesario
                child: ListView.builder(
                  itemCount: _shoppingCart.length,
                  itemBuilder: (context, index) {
                    final item = _shoppingCart[index];
                    return ListTile(
                      leading: item['imagen'] != null && item['imagen'].isNotEmpty
                          ? Image.network(item['imagen'], width: 40, height: 40)
                          : const Icon(Icons.shopping_bag),
                      title: Text(item['nombre_product']),
                      subtitle: Text('Cantidad: ${item['cantidad']}'),
                      trailing: Text('\$${(item['precio'] * item['cantidad']).toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: _processCartPurchase, // Aquí puedes agregar la lógica para procesar la compra
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF745E9E),
            ),
            child: const Text('Confirmar Compra'),
          ),
        ],
      );
    },
  );
}
}