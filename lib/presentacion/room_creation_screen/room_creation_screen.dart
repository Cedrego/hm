import 'package:flutter/material.dart';

// Constante de color de fondo (similar al azul/verde oscuro)
const Color _kPrimaryColor = Color(0xFF008080); // Un teal oscuro para el fondo
const Color _kCardColor = Colors.white; // Fondo blanco para la tarjeta
const Color _kBlackText = Colors.black;
const Color _kDarkButton = Color(0xFF333333); // Color del botón 'Crear'

class RoomCreationScreen extends StatefulWidget {
  const RoomCreationScreen({super.key});

  @override
  State<RoomCreationScreen> createState() => _RoomCreationScreenState();
}

class _RoomCreationScreenState extends State<RoomCreationScreen> {
  // Estados para los Checkbox
  bool _servicioAlCuarto = false;
  bool _jacuzzi = false;
  bool _minibar = false;

  @override
  Widget build(BuildContext context) {
    // El 'Container' con color principal simula el fondo de tu diseño.
    return Container(
      color: _kPrimaryColor,
      // SafeArea para evitar la barra de estado y el notch
      child: SafeArea(
        child: Scaffold(
          // Establecer el color del fondo de la tarjeta (blanco)
          backgroundColor: Colors.transparent, 
          // El menú y el título "Hostel Mochileros" se manejan en el cuerpo
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Simulación del icono de menú y el título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      // Icono de menú (simulando el diseño)
                      const Icon(Icons.menu, color: _kCardColor, size: 30), 
                      const Spacer(),
                      // Título "Hostel Mochileros"
                      const Text(
                        'Hostel Mochileros',
                        style: TextStyle(
                          fontFamily: 'Serif', // Usa una fuente similar a la del diseño
                          fontSize: 34,
                          color: _kCardColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Espacio para centrar el título con el menú
                      const SizedBox(width: 30), 
                    ],
                  ),
                ),

                // Separación del título a la tarjeta
                const SizedBox(height: 20), 
                
                // La "Tarjeta" blanca de creación de habitación
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
                        // Título "Crear Habitacion"
                        const Text(
                          'Crear Habitacion',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _kBlackText,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nombre de la Habitación
                        const Text('Nombre de la Habitacion', style: TextStyle(color: _kBlackText)),
                        _buildTextField('Ingrese un nombre de habitacion'),
                        
                        // Descripción
                        const Text('Descripcion', style: TextStyle(color: _kBlackText)),
                        _buildDescriptionField(),

                        // Servicios Adicionales
                        const Text('Servicios adicionales', style: TextStyle(color: _kBlackText)),
                        _buildTextField(''), // Campo opcional de texto libre

                        const SizedBox(height: 10),

                        // Checkboxes de Servicios
                        _buildCheckboxRow('Servicio al cuarto', _servicioAlCuarto, (bool? newValue) {
                          setState(() => _servicioAlCuarto = newValue ?? false);
                        }),
                        _buildCheckboxRow('Jacuzzi', _jacuzzi, (bool? newValue) {
                          setState(() => _jacuzzi = newValue ?? false);
                        }),
                        // Notar el Checkbox con borde/círculo para Minibar
                        _buildCheckboxRow('Minibar', _minibar, (bool? newValue) {
                          setState(() => _minibar = newValue ?? false);
                        }, useBorderedCheckbox: true),
                        
                        const SizedBox(height: 20),

                        // Fila de Precio e Imagen
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Sección de Precio x día
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Precio x dia', style: TextStyle(color: _kBlackText)),
                                SizedBox(height: 5),
                                _PriceInput(),
                              ],
                            ),
                            const SizedBox(width: 20),

                            // Sección de Ingresar Imagen
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ingrese una Imagen', style: TextStyle(color: _kBlackText)),
                                  const SizedBox(height: 5),
                                  _ImageUploader(),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Botón "Crear"
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Lógica para crear la habitación
                              print('Habitación Creada');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kDarkButton, 
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
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

  // Widget helper para campos de texto estándar
  Widget _buildTextField(String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
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

  // Widget helper para el campo de descripción multi-línea
  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Ingrese una descripcíon',
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

  // Widget helper para la fila de Checkbox
  Widget _buildCheckboxRow(String title, bool value, ValueChanged<bool?> onChanged, {bool useBorderedCheckbox = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: _kBlackText)),
          // Personalización del Checkbox
          Checkbox(
            value: value,
            onChanged: onChanged,
            // Si es 'Minibar', usa el checkbox con borde/círculo (por el diseño)
            shape: useBorderedCheckbox ? const CircleBorder() : null, 
            activeColor: _kBlackText, // Color de marca del check
            checkColor: _kCardColor, // Color del checkmark (palomita)
            side: const BorderSide(color: _kBlackText, width: 2), // Borde negro
          ),
        ],
      ),
    );
  }
}

// Sub-widget para la sección de ingreso de precio (con botones de flecha)
class _PriceInput extends StatelessWidget {
  const _PriceInput();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Indicador de Moneda USD y Valor
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: _kDarkButton, // Fondo oscuro
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            'USD 40.90',
            style: TextStyle(color: _kCardColor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 5),
        // Botones de flecha
        Column(
          children: [
            _buildArrowButton(Icons.arrow_drop_up),
            _buildArrowButton(Icons.arrow_drop_down),
          ],
        )
      ],
    );
  }

  Widget _buildArrowButton(IconData icon) {
    return Container(
      height: 15, // Ajusta la altura para que sean pequeños
      width: 25, // Ajusta el ancho
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: _kDarkButton,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Icon(icon, color: _kCardColor, size: 18),
    );
  }
}

// Sub-widget para la sección de subir imagen
class _ImageUploader extends StatelessWidget {
  const _ImageUploader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón "Browse"
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0), // Gris claro de fondo
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
        const SizedBox(width: 5),
        // Icono de Link
        const Icon(Icons.link, color: _kDarkButton, size: 30),
      ],
    );
  }
}

// Ejemplo de cómo llamar esta pantalla en tu 'main.dart'
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RoomCreationScreen(),
    );
  }
}
*/