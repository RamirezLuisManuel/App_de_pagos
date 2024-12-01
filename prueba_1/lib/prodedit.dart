import 'package:flutter/material.dart';
import 'db_helper.dart';

class EditProdScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProdScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProdScreenState createState() => _EditProdScreenState();
}

class _EditProdScreenState extends State<EditProdScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  // Carga los datos actuales del producto en los controladores
  void _loadProductData() {
    _nameController.text = widget.product['nombre_product'];
    _priceController.text = widget.product['precio'].toString();
    _quantityController.text = widget.product['cantida_producto'].toString();
    _imageController.text = widget.product['imagen'] ?? '';
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      await SQLHelper.updateProduct(
        id: widget.product['id'],
        nombreProducto: _nameController.text,
        precio: double.parse(_priceController.text),
        cantidadProducto: int.parse(_quantityController.text),
        imagen: _imageController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto actualizado exitosamente')),
      );

      Navigator.pop(context); // Cerrar la pantalla de edición
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Producto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un precio válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingresa una cantidad válida';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'URL de la Imagen'),
                onChanged: (value) {
                  setState(() {}); // Actualizar la vista previa al cambiar la URL
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProduct,
                child: Text('Actualizar Producto'),
              ),
              SizedBox(height: 20),
              // Vista previa del producto actual
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}
