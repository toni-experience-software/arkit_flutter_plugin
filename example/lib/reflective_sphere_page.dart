import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';

class ReflectiveSpherePage extends StatefulWidget {
  @override
  _ReflectiveSpherePageState createState() => _ReflectiveSpherePageState();
}

class _ReflectiveSpherePageState extends State<ReflectiveSpherePage> {
  late ARKitController arkitController;
  String probeInfo = 'No environment probes detected yet';

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('HDR Environment Reflections'),
        ),
        body: Column(
          children: [
            Container(
              height: 200,
              child: ARKitSceneView(
                onARKitViewCreated: onARKitViewCreated,
                configuration: ARKitConfiguration.worldTracking,
                environmentTexturing: ARWorldTrackingConfigurationEnvironmentTexturing.automatic,
                showFeaturePoints: true,
                enableTapRecognizer: true,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HDR Environment Reflections Demo',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'This demo shows a highly reflective chrome sphere that picks up live reflections of your environment using ARKit\'s automatic environment texturing.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('• Move your device around to see reflections update'),
                    Text('• Point at bright windows or lights for best effect'),
                    Text('• Tap to place additional spheres'),
                    SizedBox(height: 16),
                    Text(
                      'Environment Probe Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(probeInfo),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    
    // Set up environment probe callback
    this.arkitController.onEnvironmentProbeAnchor = (probeData) {
      setState(() {
        final position = probeData['position'] as List<dynamic>;
        final extent = probeData['extent'] as List<dynamic>;
        probeInfo = 'Probe at (${position[0].toStringAsFixed(2)}, ${position[1].toStringAsFixed(2)}, ${position[2].toStringAsFixed(2)})\n'
                   'Extent: ${extent[0].toStringAsFixed(2)} x ${extent[1].toStringAsFixed(2)} x ${extent[2].toStringAsFixed(2)}';
      });
    };

    // Set up tap handler to place spheres
    this.arkitController.onARTap = (ar) {
      final point = ar.firstOrNull;
      if (point != null) {
        _addReflectiveSphere(point.worldTransform);
      }
    };

    // Add initial sphere
    _addReflectiveSphere(Matrix4.identity());
  }

  void _addReflectiveSphere(Matrix4 transform) {
    // Create a highly reflective chrome sphere
    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.physicallyBased,
      diffuse: ARKitMaterialProperty.color(Colors.white),
      metalness: ARKitMaterialProperty.value(1.0), // Fully metallic
      roughness: ARKitMaterialProperty.value(0.0), // Mirror-like surface
    );

    final sphere = ARKitSphere(
      radius: 0.08,
      materials: [material],
    );

    final node = ARKitNode(
      geometry: sphere,
      transformation: transform,
    );

    arkitController.add(node);
  }
}