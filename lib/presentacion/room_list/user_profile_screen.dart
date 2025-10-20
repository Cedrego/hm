import 'package:flutter/material.dart';
import '../../core/firebase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const UserProfileScreen({required this.user, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;
  final FirebaseService firebaseService = FirebaseService.instance;
  
  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    // 1. La lógica asíncrona y el await deben ir AQUÍ, fuera de setState.
    await Future.delayed(const Duration(seconds: 1)); // Simulación (await fuera)

    try {
      // Usamos .first para obtener el primer valor del Stream como un Future.
      final dataStream = firebaseService.getReservasPorUsuario(widget.user['id']);
      
      // Esperamos (await) el primer resultado del stream.
      final List<Map<String, dynamic>> data = await dataStream.first;

      // 2. La llamada a setState es AHORA SÍNCRONA.
      if (mounted) {
        setState(() {
          reservations = data;
          isLoading = false;
        });
      }
    } catch (e) {
      // Manejo de errores de carga
      debugPrint('Error al cargar reservas: $e');
      if (mounted) {
          setState(() {
            isLoading = false;
            reservations = [];
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // El acceso a los datos del widget.user ya era seguro y se mantiene.
    final String nick =
        widget.user['nick'] ?? widget.user['nombre'] ?? 'Usuario';
    final String nombre = widget.user['nombre'] ?? 'Sin nombre';
    final String email = widget.user['email'] ?? 'Sin email';
    final String di =
        widget.user['documento'] ?? widget.user['cedula'] ?? 'Sin documento';
    final String contacto =
        widget.user['telefono'] ?? widget.user['contacto'] ?? 'Sin contacto';
    final String avatarUrl =
        widget.user['avatarUrl'] ?? widget.user['imagenUrl'] ?? '';

    return Scaffold(
      body: Container(
        color: const Color(0xFF00897B),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Perfil de Usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Avatar (CORRECCIÓN APLICADA AQUÍ)
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: avatarUrl.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage( // <-- Cambio de Image.network
                                    imageUrl: avatarUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    // Muestra un cargador mientras se descarga la imagen
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF00897B)),
                                    ),
                                    // Fallback a las iniciales si la imagen falla en cargar
                                    errorWidget: (context, url, error) => Text(
                                      nombre[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        color: Color(0xFF00897B),
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  // Fallback si avatarUrl está vacío desde el inicio
                                  nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Color(0xFF00897B),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Info Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildInfoRow('Nick', nick),
                                const Divider(),
                                _buildInfoRow('Nombre', nombre),
                                const Divider(),
                                _buildInfoRow('Email', email),
                                const Divider(),
                                _buildInfoRow('Documento', di),
                                const Divider(),
                                _buildInfoRow('Contacto', contacto),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        const Text(
                          'Mis Reservas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reservas
                        if (isLoading)
                          const CircularProgressIndicator(color: Colors.white)
                        else if (reservations.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text('No hay reservas registradas'),
                                ],
                              ),
                            ),
                          )
                        else
                          ...reservations.map(
                            (res) => _buildReservationCard(res),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // FUNCIÓN CORREGIDA: Usa FutureBuilder para cargar la imagen de la habitación.
  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    // 1. Obtener el ID de la habitación de la reserva.
    final String? habitacionId = reservation['idHabitacion'] as String?;

    // Si no hay ID de habitación, solo mostramos el card con el icono por defecto.
    if (habitacionId == null) {
      return _buildReservationCardContent(reservation, isFallback: true);
    }

    // 2. Usar FutureBuilder para obtener la URL de la imagen de la habitación.
    return FutureBuilder<String?>(
      // Llama a la función asíncrona para obtener la URL de la imagen.
      future: firebaseService.getHabitacionImg(habitacionId),
      builder: (context, snapshot) {
        // Determina si se debe usar el fallback (cargando, error o URL vacía/nula)
        final bool useFallback = snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError ||
            snapshot.data == null ||
            (snapshot.data?.isEmpty ?? true) ||
            snapshot.data == 'vacio';

        final String? imageUrl = useFallback ? null : snapshot.data;

        // Si está cargando, pasamos el estado a _buildReservationCardContent.
        final bool isLoadingImage = snapshot.connectionState == ConnectionState.waiting;

        return _buildReservationCardContent(
          reservation,
          isFallback: useFallback,
          isLoading: isLoadingImage,
          imageUrl: imageUrl,
        );
      },
    );
  }


  // Función de ayuda para construir el contenido del Card (imagen + info).
  Widget _buildReservationCardContent(
    Map<String, dynamic> reservation, {
    required bool isFallback,
    bool isLoading = false,
    String? imageUrl,
  }) {
    // Definición del widget de imagen
    final Widget imageWidget;

    if (isLoading) {
      // Estado de carga
      imageWidget = Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else if (isFallback || imageUrl == null) {
      // Fallback: Contenedor con icono de hotel
      imageWidget = Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: const Icon(Icons.hotel, size: 40, color: Colors.grey),
      );
    } else {
      // Imagen de red
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl, // Usamos la URL que ya sabemos que no es null
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.hotel, size: 40, color: Colors.red),
          ),
        ),
      );
    }

    // Retorna el Card completo
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            imageWidget,
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation['nombreHabitacion'] ?? 'Habitación',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Check-in: ${reservation['fechaCheckIn'] ?? 'N/A'}'),
                  Text('Check-out: ${reservation['fechaCheckOut'] ?? 'N/A'}'),
                  Text('Total: USD \$${reservation['precioTotal'] ?? '0.00'}'),
                  Text('Estado: ${reservation['estado'] ?? 'Activa'}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}