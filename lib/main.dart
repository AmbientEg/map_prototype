import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      appBar: AppBar(title: const Text("Indoor Navigation - Floor 3")),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(31.2014, 30.0277)), // roughly center of floor3
          zoom: 20.0,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Load GeoJSON from assets
    final geojsonString = await rootBundle.loadString('assets/indoor/floor3.geojson');
    final geojson = jsonDecode(geojsonString);

    // Create GeoJSON source
    await mapboxMap.style.addSource(
      'floor3',
      GeoJsonSource(data: geojson),
    );

    // Loop through features to create FillLayers with their colors
    for (var feature in geojson['features']) {
      final id = feature['properties']['uid'];
      final color = feature['properties']['color'] ?? '#FF0000'; // default red
      final opacity = feature['properties']['opacity'] ?? 0.5;

      await mapboxMap.style.addLayer(
        FillLayer(
          id: 'layer-$id',
          sourceId: 'floor3',
          filter: ['==', ['get', 'uid'], id], // filter by feature uid
          fillColor: color,
          fillOpacity: opacity.toDouble(),
          fillOutlineColor: '#000000',
        ),
      );
    }
  }
}
