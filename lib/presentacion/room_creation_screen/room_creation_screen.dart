import 'package:flutter/material.dart';
import '../../core/api_service.dart'; // Importa tu ApiService

const Color _kPrimaryColor = Color(0xFF008080);
const Color _kCardColor = Colors.white;
const Color _kBlackText = Colors.black;
const Color _kDarkButton = Color(0xFF333333);

class RoomCreationScreen extends StatefulWidget {
  const RoomCreationScreen({super.key});

  @override
  State<RoomCreationScreen> createState() => _RoomCreationScreenState();
}

class _RoomCreationScreenState extends State<RoomCreationScreen> {
  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _servicioAdicionalController = TextEditingController();
  
  // Estados
  bool _servicioAlCuarto = false;
  bool _jacuzzi = false;
  bool _minibar = false;
  List<Map<String, dynamic>> _serviciosAdicionales = [];
  
  double _precio = 40.90;
  String? _imagenUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _servicioAdicionalController.dispose();
    super.dispose();
  }

  void _agregarServicioAdicional() {
    final nuevoServicio = _servicioAdicionalController.text.trim();
    
    if (nuevoServicio.isNotEmpty) {
      setState(() {
        _serviciosAdicionales.add({
          'nombre': nuevoServicio,
          'seleccionado': false,
        });
        _servicioAdicionalController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Servicio "$nuevoServicio" agregado'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _incrementarPrecio() {
    setState(() {
      _precio += 1.0;
    });
  }

  void _decrementarPrecio() {
    setState(() {
      if (_precio > 0) _precio -= 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kPrimaryColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: _kCardColor, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        'Hostel Mochileros',
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 34,
                          color: _kCardColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tarjeta blanca
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: _kCardColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Crear Habitacion',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _kBlackText,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nombre
                        const Text('Nombre de la Habitacion', style: TextStyle(color: _kBlackText)),
                        _buildTextField(
                          'Ingrese un nombre de habitacion',
                          controller: _nombreController,
                        ),

                        // Descripción
                        const Text('Descripcion', style: TextStyle(color: _kBlackText)),
                        _buildDescriptionField(),

                        // Servicios Adicionales
                        const Text('Servicios adicionales', style: TextStyle(color: _kBlackText)),
                        _buildServicioAdicionalField(),

                        const SizedBox(height: 10),

                        // Checkboxes predefinidos
                        _buildCheckboxRow('Servicio al cuarto', _servicioAlCuarto, (bool? newValue) {
                          setState(() => _servicioAlCuarto = newValue ?? false);
                        }),
                        _buildCheckboxRow('Jacuzzi', _jacuzzi, (bool? newValue) {
                          setState(() => _jacuzzi = newValue ?? false);
                        }),
                        _buildCheckboxRow('Minibar', _minibar, (bool? newValue) {
                          setState(() => _minibar = newValue ?? false);
                        }, useBorderedCheckbox: true),

                        // Servicios adicionales dinámicos
                        ..._serviciosAdicionales.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> servicio = entry.value;
                          
                          return _buildCheckboxRowConEliminar(
                            servicio['nombre'],
                            servicio['seleccionado'],
                            (bool? newValue) {
                              setState(() {
                                _serviciosAdicionales[index]['seleccionado'] = newValue ?? false;
                              });
                            },
                            () {
                              setState(() {
                                _serviciosAdicionales.removeAt(index);
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Servicio "${servicio['nombre']}" eliminado'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          );
                        }).toList(),

                        const SizedBox(height: 20),

                        // Precio e Imagen
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Precio x dia', style: TextStyle(color: _kBlackText)),
                                const SizedBox(height: 5),
                                _PriceInput(
                                  precio: _precio,
                                  onIncrement: _incrementarPrecio,
                                  onDecrement: _decrementarPrecio,
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ingrese una Imagen', style: TextStyle(color: _kBlackText)),
                                  const SizedBox(height: 5),
                                  _ImageUploader(
                                    onImageSelected: (url) {
                                      setState(() {
                                        _imagenUrl = url;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Botón Crear
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _crearHabitacion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kDarkButton,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Crear',
                                    style: TextStyle(fontSize: 18, color: _kCardColor),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _descripcionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Ingrese una descripción',
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildServicioAdicionalField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _servicioAdicionalController,
              decoration: InputDecoration(
                hintText: 'Ingrese un servicio',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _agregarServicioAdicional(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _agregarServicioAdicional,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Icon(Icons.add, color: _kCardColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String title, bool value, ValueChanged<bool?> onChanged, {bool useBorderedCheckbox = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: _kBlackText)),
          Checkbox(
            value: value,
            onChanged: onChanged,
            shape: useBorderedCheckbox ? const CircleBorder() : null,
            activeColor: _kBlackText,
            checkColor: _kCardColor,
            side: const BorderSide(color: _kBlackText, width: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRowConEliminar(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
    VoidCallback onDelete,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: _kBlackText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: _kBlackText,
                checkColor: _kCardColor,
                side: const BorderSide(color: _kBlackText, width: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _crearHabitacion() async {
    // Validaciones
    if (_nombreController.text.trim().isEmpty) {
      _mostrarError('Por favor ingrese un nombre para la habitación');
      return;
    }

    if (_descripcionController.text.trim().isEmpty) {
      _mostrarError('Por favor ingrese una descripción');
      return;
    }

    // Recopilar servicios seleccionados
    List<String> serviciosSeleccionados = [];
    
    if (_servicioAlCuarto) serviciosSeleccionados.add('Servicio al cuarto');
    if (_jacuzzi) serviciosSeleccionados.add('Jacuzzi');
    if (_minibar) serviciosSeleccionados.add('Minibar');
    
    for (var servicio in _serviciosAdicionales) {
      if (servicio['seleccionado']) {
        serviciosSeleccionados.add(servicio['nombre']);
      }
    }

    // Mostrar loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Llamar al API
      final response = await ApiService.crearHabitacion(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precio: _precio,
        servicios: serviciosSeleccionados,
        imagenUrl: _imagenUrl,
      );

      // Éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('¡Habitación creada exitosamente!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navegar hacia atrás o a otra pantalla
        Navigator.pop(context);
      }
    } catch (e) {
      // Error
      if (mounted) {
        _mostrarError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      // Ocultar loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Widget de precio actualizado
class _PriceInput extends StatelessWidget {
  final double precio;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _PriceInput({
    required this.precio,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: _kDarkButton,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'USD ${precio.toStringAsFixed(2)}',
            style: const TextStyle(color: _kCardColor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 5),
        Column(
          children: [
            _buildArrowButton(Icons.arrow_drop_up, onIncrement),
            _buildArrowButton(Icons.arrow_drop_down, onDecrement),
          ],
        )
      ],
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 15,
        width: 25,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: _kDarkButton,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(icon, color: _kCardColor, size: 18),
      ),
    );
  }
}

// Widget de imagen
class _ImageUploader extends StatelessWidget {
  final Function(String) onImageSelected;

  const _ImageUploader({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              // TODO: Implementar selección de imagen
              // Por ahora, simular con URL
              onImageSelected('https://example.com/imagen.jpg');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload, size: 20, color: _kBlackText),
                  SizedBox(width: 5),
                  Text('Browse', style: TextStyle(color: _kBlackText)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        const Icon(Icons.link, color: _kDarkButton, size: 30),
      ],
    );
  }
}