import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../custom_app_bar.dart'; 
import '../app_drawer.dart'; 
import '../../core/auth_service.dart'; 
import '../../core/app_export.dart';

// Constantes de Color Simplificadas
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _servicioAdicionalController = TextEditingController();
   final TextEditingController _precioController = TextEditingController(); 
  // Estados de la habitación
  bool _servicioAlCuarto = false;
  bool _jacuzzi = false;
  bool _minibar = false;
  List<Map<String, dynamic>> _serviciosAdicionales = [];
  
  double _precio = 40.90;
  
  // 🆕 Variables para manejo de imagen
  final ImagePicker _picker = ImagePicker();
  File? _imagenFile;
  String? _imagenBase64;

  // Estados de carga y datos de usuario
  bool _isLoadingCreation = false; 
  bool _isLoadingUserData = true; 
  Map<String, dynamic>? _userData;

  bool get _isAdmin => _userData?['rol'] == 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
    _precioController.text = _precio.toStringAsFixed(2); // 🆕 Inicializar el texto del precio
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getUserData();
      if (!mounted) return;
      setState(() {
        _userData = userData;
        _isLoadingUserData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingUserData = false;
      });
      _mostrarError('Error al cargar datos de usuario.');
    }
  }

  // 🆕 Método para seleccionar imagen
  Future<void> _seleccionarImagen() async {
    try {
      print('📷 Seleccionando imagen de habitación...');
      
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          _imagenFile = File(pickedFile.path);
          _imagenBase64 = base64Encode(bytes);
        });
        
        print('✅ Imagen de habitación seleccionada: ${bytes.length} bytes');
      } else {
        print('⚠️ No se seleccionó ninguna imagen');
      }
    } catch (e) {
      print('❌ Error al seleccionar imagen: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _servicioAdicionalController.dispose();
    _precioController.dispose(); // 🆕
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

  Future<void> _onLogoutPressed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Está seguro de cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService.logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (!_isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarError('Acceso denegado: solo administradores pueden crear habitaciones.');
        if (Navigator.canPop(context)) {
          Navigator.pop(context); 
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.mainPage); 
        }
      });
      return const SizedBox.shrink(); 
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kPrimaryColor,
      
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: () => _onLogoutPressed(context),
        userData: _userData,
        isAdmin: _isAdmin,
      ),
      
      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: _onLogoutPressed,
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _kCardColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalles de la Habitación',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _kBlackText,
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre
                const Text('Nombre de la Habitación', style: TextStyle(color: _kBlackText, fontWeight: FontWeight.w600)),
                _buildTextField(
                  'Ej: Habitación Deluxe 1',
                  controller: _nombreController,
                ),

                // Descripción
                const Text('Descripción', style: TextStyle(color: _kBlackText, fontWeight: FontWeight.w600)),
                _buildDescriptionField(),

                // Servicios Adicionales Dinámicos
                const Text('Agregar Servicio (Opcional)', style: TextStyle(color: _kBlackText, fontWeight: FontWeight.w600)),
                _buildServicioAdicionalField(),

                const SizedBox(height: 10),
                const Text('Servicios Incluidos', style: TextStyle(color: _kBlackText, fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.grey),

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

                // 🆕 Precio mejorado (editable)
                const Text('Precio x día', style: TextStyle(color: _kBlackText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                _buildPriceInput(),

                const SizedBox(height: 20),

                // 🆕 Sección de Imagen
                const Text('Imagen de la Habitación', style: TextStyle(color: _kBlackText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildImageSelector(),

                const SizedBox(height: 30),

                // Botón Crear
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingCreation ? null : _crearHabitacion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kDarkButton,
                      foregroundColor: _kCardColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: _isLoadingCreation
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Crear Habitación',
                            style: TextStyle(fontSize: 18, color: _kCardColor, fontWeight: FontWeight.bold),
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
 // 🆕 Widget de precio editable
  Widget _buildPriceInput() {
    return Row(
      children: [
        // Input editable
        SizedBox(
          width: 150,
          child: TextField(
            controller: _precioController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: 'USD ',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _kPrimaryColor, width: 2.0),
              ),
            ),
            onChanged: (value) {
              final newPrice = double.tryParse(value);
              if (newPrice != null && newPrice >= 0) {
                _precio = newPrice;
              }
            },
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 20,
        width: 30,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: _kDarkButton,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(icon, color: _kCardColor, size: 20),
      ),
    );
  }
  // 🆕 Widget para seleccionar imagen con preview
  Widget _buildImageSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Preview de la imagen
          if (_imagenFile != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(_imagenFile!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.image,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),
          
          // Botón para seleccionar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _seleccionarImagen,
              icon: const Icon(Icons.upload_file),
              label: Text(_imagenFile != null ? 'Cambiar imagen' : 'Seleccionar imagen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
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
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _kPrimaryColor, width: 2.0),
          ),
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
          hintText: 'Ingrese una descripción detallada de la habitación',
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _kPrimaryColor, width: 2.0),
          ),
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
                hintText: 'Ej: Desayuno Buffet',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _kPrimaryColor, width: 2.0),
                ),
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
            shape: useBorderedCheckbox ? const CircleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: _kDarkButton,
            checkColor: _kCardColor,
            side: const BorderSide(color: _kDarkButton, width: 1.5),
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
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: _kDarkButton,
                checkColor: _kCardColor,
                side: const BorderSide(color: _kDarkButton, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
      _isLoadingCreation = true;
    });

    try {
      // 🆕 Llamar al API con la imagen en base64
      await ApiService.crearHabitacion(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precio: _precio,
        servicios: serviciosSeleccionados,
        imagenBase64: _imagenBase64 ?? 'vacio', // ← Enviar base64 en lugar de URL
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

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _mostrarError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCreation = false;
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

// ignore: unused_element
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