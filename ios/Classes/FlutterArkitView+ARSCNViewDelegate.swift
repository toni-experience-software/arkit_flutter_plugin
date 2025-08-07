import ARKit
import Foundation

extension FlutterArkitView: ARSCNViewDelegate {
    func session(_: ARSession, didFailWithError error: Error) {
        logPluginError("sessionDidFailWithError: \(error.localizedDescription)", toChannel: channel)
    }

    func session(_: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var params = [String: NSNumber]()

        switch camera.trackingState {
        case .notAvailable:
            params["trackingState"] = 0
        case let .limited(reason):
            params["trackingState"] = 1
            switch reason {
            case .initializing:
                params["reason"] = 1
            case .relocalizing:
                params["reason"] = 2
            case .excessiveMotion:
                params["reason"] = 3
            case .insufficientFeatures:
                params["reason"] = 4
            default:
                params["reason"] = 0
            }
        case .normal:
            params["trackingState"] = 2
        }

        sendToFlutter("onCameraDidChangeTrackingState", arguments: params)
    }

    func sessionWasInterrupted(_: ARSession) {
        sendToFlutter("onSessionWasInterrupted", arguments: nil)
    }

    func sessionInterruptionEnded(_: ARSession) {
        sendToFlutter("onSessionInterruptionEnded", arguments: nil)
    }

    func renderer(_: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if node.name == nil {
            node.name = NSUUID().uuidString
        }
        let params = prepareParamsForAnchorEvent(node, anchor)
        sendToFlutter("didAddNodeForAnchor", arguments: params)
        
        // Handle environment probe anchors
        if #available(iOS 12.0, *) {
            if let probeAnchor = anchor as? AREnvironmentProbeAnchor {
                handleEnvironmentProbeAnchor(probeAnchor)
            }
        }
    }

    func renderer(_: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let params = prepareParamsForAnchorEvent(node, anchor)
        sendToFlutter("didUpdateNodeForAnchor", arguments: params)
    }

    func renderer(_: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        let params = prepareParamsForAnchorEvent(node, anchor)
        sendToFlutter("didRemoveNodeForAnchor", arguments: params)
    }

    func renderer(_: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let params = ["time": NSNumber(floatLiteral: time)]
        sendToFlutter("updateAtTime", arguments: params)
    }

    fileprivate func prepareParamsForAnchorEvent(_ node: SCNNode, _ anchor: ARAnchor) -> [String: Any] {
        var serializedAnchor = serializeAnchor(anchor)
        serializedAnchor["nodeName"] = node.name
        return serializedAnchor
    }
    
    @available(iOS 12.0, *)
    fileprivate func handleEnvironmentProbeAnchor(_ probeAnchor: AREnvironmentProbeAnchor) {
        let transform = probeAnchor.transform
        let position = transform.columns.3
        
        var params: [String: Any] = [
            "identifier": probeAnchor.identifier.uuidString,
            "position": [position.x, position.y, position.z],
            "extent": [probeAnchor.extent.x, probeAnchor.extent.y, probeAnchor.extent.z]
        ]
        
        // Add texture name if available
        if let environmentTexture = probeAnchor.environmentTexture {
            params["textureName"] = environmentTexture.label ?? "environment_texture"
        }
        
        sendToFlutter("onEnvironmentProbeAnchor", arguments: params)
    }
}
