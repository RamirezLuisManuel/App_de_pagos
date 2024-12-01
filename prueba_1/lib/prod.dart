import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'prodedit.dart';
import 'agregarprod.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF2F0FF), // Fondo claro
        borderRadius: BorderRadius.circular(30), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Sombra suave
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding del botón
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Bordes redondeados
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF7E57C2), // Color del texto en tono morado
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  List<Map<String, dynamic>> _productList = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Método para cargar productos
  Future<void> _loadProducts() async {
    final data = await SQLHelper.getAllProducts();
    setState(() {
      _productList = data;
    });
  }

  // Método para eliminar productos
  Future<void> _deleteProduct(int id) async {
    await SQLHelper.deleteProduct(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Producto eliminado')),
    );
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Productos'),
        actions: [
          // Botón personalizado para añadir producto
          CustomButton(
            text: "Añadir Producto",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgrProdScreen(),
                ),
              ).then((_) => _loadProducts()); // Recargar productos al regresar
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _productList.isEmpty
                  ? Center(child: Text('No hay productos disponibles'))
                  : ListView.builder(
                      itemCount: _productList.length,
                      itemBuilder: (context, index) {
                        final product = _productList[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: ListTile(
                            leading: product['imagen'] != null && product['imagen'].isNotEmpty
                                ? Image.network(
                                    product['imagen'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.shopping_bag),
                            title: Text(
                              product['nombre_product'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Precio: \$${product['precio']}'),
                                Text('Cantidad: ${product['cantida_producto']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.amberAccent),
                                  onPressed: () {
                                    // Navega a la pantalla de edición con los datos del producto
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProdScreen(product: product),
                                      ),
                                    ).then((_) => _loadProducts()); // Recargar productos al regresar
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteProduct(product['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
