import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/services.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: Enable Mapbox logs
  MapboxOptions.setAccessToken("pk.eyJ1Ijoicm9keW5hYW1yIiwiYSI6ImNta3pyZzZhcDA0dGEzZHFzcjJpdjI5MXoifQ.9gakM7dTZU4QUy_f0Db9Qw");

  runApp(const IndoorNavigationApp());
}

class IndoorNavigationApp extends StatelessWidget {
  const IndoorNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MapScreen(),
    );
  }
}

Future<String> loadGeoJsonFromAssets(String path) async {
  return await rootBundle.loadString(path);
}


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Indoor Navigation"),
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(31.2014870, 30.0277617), // Credit building
          ),
          zoom: 18,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Move camera
    await mapboxMap.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(31.2014870, 30.0277617),
        ),
        zoom: 18.5,
        pitch: 45,
      ),
    );

    // Load GeoJSON from assets
    final geoJson = await loadGeoJsonFromAssets(
      'assets/indoor/floor3.geojson',
    );

    // Add source
    await mapboxMap.style.addSource(
      GeoJsonSource(
        id: 'floor3-source',
        data: geoJson,
      ),
    );

    // Render polygons (rooms, floor shapes, etc.)
    await mapboxMap.style.addLayer(
      FillLayer(
        id: 'floor3-fill',
        sourceId: 'floor3-source',
        fillColor: Colors.blue.withOpacity(0.4).value,
        fillOutlineColor: Colors.blue.value,
      ),
    );
  }


}
