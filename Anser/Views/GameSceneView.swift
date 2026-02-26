//
//  GameSceneView.swift
//  Anser
//
//  3D游戏场景视图（SceneKit集成）
//

import SwiftUI
import SceneKit

/// 游戏场景控制器
@Observable
class GameSceneController: NSObject {
    /// SceneKit场景
    let scene: SCNScene
    
    /// 大锅节点
    private var potNode: SCNNode?
    
    /// 物品节点映射
    private var itemNodes: [UUID: SCNNode] = [:]
    
    /// 选中回调
    var onItemSelected: ((GameItem) -> Void)?
    
    /// 当前游戏会话
    var gameSession: GameSession?
    
    override init() {
        self.scene = SCNScene()
        super.init()
        setupScene()
    }
    
    // MARK: - 场景设置
    
    private func setupScene() {
        // 设置背景
        scene.background.contents = UIColor.systemBackground
        
        // 添加相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 8, 12)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/4, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // 添加灯光
        setupLighting()
        
        // 创建大锅
        createPot()
    }
    
    private func setupLighting() {
        // 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 500
        scene.rootNode.addChildNode(ambientLight)
        
        // 方向光（主光源）
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.position = SCNVector3(5, 10, 5)
        directionalLight.eulerAngles = SCNVector3(-Float.pi/3, Float.pi/4, 0)
        directionalLight.light?.intensity = 1000
        scene.rootNode.addChildNode(directionalLight)
        
        // 补光
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.position = SCNVector3(-5, 5, -5)
        fillLight.light?.intensity = 300
        scene.rootNode.addChildNode(fillLight)
    }
    
    private func createPot() {
        // 创建大锅（使用球体内部作为容器）
        let potGeometry = SCNSphere(radius: 5)
        potGeometry.segmentCount = 48
        
        // 设置材质 - 使用明显的锅颜色
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0) // 铜锅色
        material.specular.contents = UIColor(white: 0.3, alpha: 1.0)
        material.roughness.contents = 0.6
        material.metalness.contents = 0.3
        material.isDoubleSided = true // 渲染双面
        potGeometry.firstMaterial = material
        
        let potNode = SCNNode(geometry: potGeometry)
        potNode.position = SCNVector3(0, -2, 0)
        potNode.scale = SCNVector3(1, 0.6, 1)
        
        // 旋转使半球开口朝上（球体的下半部分）
        potNode.eulerAngles = SCNVector3(Float.pi, 0, 0)
        
        // 添加物理体 - 使用凹面形状作为容器
        let physicsShape = SCNPhysicsShape(geometry: potGeometry, options: [
            .type: SCNPhysicsShape.ShapeType.concavePolyhedron
        ])
        potNode.physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        potNode.physicsBody?.friction = 0.5
        potNode.physicsBody?.restitution = 0.3
        
        scene.rootNode.addChildNode(potNode)
        self.potNode = potNode
        
        // 添加锅边（可见的锅沿）
        createPotRim()
    }
    
    private func createPotRim() {
        // 创建锅边圆环
        let rimRadius: CGFloat = 5.0
        let rimThickness: CGFloat = 0.3
        
        let rimGeometry = SCNTorus(ringRadius: rimRadius, pipeRadius: rimThickness)
        let rimMaterial = SCNMaterial()
        rimMaterial.diffuse.contents = UIColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
        rimMaterial.metalness.contents = 0.5
        rimMaterial.roughness.contents = 0.4
        rimGeometry.firstMaterial = rimMaterial
        
        let rimNode = SCNNode(geometry: rimGeometry)
        rimNode.position = SCNVector3(0, 1, 0) // 锅的顶部边缘
        rimNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0) // 水平放置
        
        scene.rootNode.addChildNode(rimNode)
    }
    
    // MARK: - 物品管理
    
    /// 生成物品节点
    func spawnItems(_ items: [GameItem]) {
        // 清除旧物品
        clearItems()
        
        // 创建新物品
        for item in items {
            createItemNode(for: item)
        }
    }
    
    /// 创建物品节点
    private func createItemNode(for item: GameItem) {
        // 创建几何体（根据类型）
        let geometry = createGeometry(for: item.type)
        
        // 设置材质 - 更鲜艳的颜色和更好的视觉效果
        let material = SCNMaterial()
        let baseColor = UIColor(item.type.color)
        material.diffuse.contents = baseColor
        material.specular.contents = UIColor.white
        material.roughness.contents = 0.3
        material.metalness.contents = 0.1
        material.shininess = 0.4
        geometry.firstMaterial = material
        
        // 创建容器节点
        let containerNode = SCNNode()
        containerNode.name = item.nodeName
        containerNode.position = SCNVector3(item.position)
        containerNode.eulerAngles = SCNVector3(item.rotation)
        
        // 物品几何体节点
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.scale = SCNVector3(item.scale, item.scale, item.scale)
        containerNode.addChildNode(geometryNode)
        
        // 添加文字标签（便于识别）
        let textGeometry = SCNText(string: String(describing: item.type).prefix(1).uppercased(), extrusionDepth: 0.1)
        textGeometry.font = UIFont.boldSystemFont(ofSize: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        textGeometry.firstMaterial?.specular.contents = UIColor.white
        
        let textNode = SCNNode(geometry: textGeometry)
        // 计算文字中心点使其居中
        let (min, max) = textGeometry.boundingBox
        let textWidth = max.x - min.x
        let textHeight = max.y - min.y
        textNode.position = SCNVector3(-textWidth/2, -textHeight/2, 0.6)
        textNode.scale = SCNVector3(0.3, 0.3, 0.3)
        containerNode.addChildNode(textNode)
        
        // 添加物理体
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = 0.5
        physicsBody.friction = 0.5
        physicsBody.restitution = 0.3
        containerNode.physicsBody = physicsBody
        
        // 添加入场动画
        containerNode.scale = SCNVector3(0, 0, 0)
        let scaleAction = SCNAction.scale(to: 1.0, duration: 0.3)
        scaleAction.timingMode = .easeOut
        containerNode.runAction(scaleAction)
        
        scene.rootNode.addChildNode(containerNode)
        itemNodes[item.id] = containerNode
    }
    
    /// 根据类型创建几何体
    private func createGeometry(for type: ItemType) -> SCNGeometry {
        switch type {
        case .apple, .donut, .grape, .lemon:
            return SCNSphere(radius: 0.6)
        case .banana:
            let capsule = SCNCapsule(capRadius: 0.3, height: 1.5)
            return capsule
        case .carrot:
            let cone = SCNCone(topRadius: 0.1, bottomRadius: 0.4, height: 1.2)
            return cone
        case .donut:
            let torus = SCNTorus(ringRadius: 0.5, pipeRadius: 0.2)
            return torus
        case .egg:
            return SCNSphere(radius: 0.5)
        case .fish:
            let box = SCNBox(width: 1.2, height: 0.3, length: 0.6, chamferRadius: 0.1)
            return box
        case .kiwi:
            let sphere = SCNSphere(radius: 0.55)
            return sphere
        case .hamburger:
            let cylinder = SCNCylinder(radius: 0.6, height: 0.8)
            return cylinder
        case .icecream:
            let cone = SCNCone(topRadius: 0.4, bottomRadius: 0.1, height: 1.0)
            return cone
        case .juice:
            let cylinder = SCNCylinder(radius: 0.35, height: 1.2)
            return cylinder
        }
    }
    
    /// 清除所有物品
    func clearItems() {
        itemNodes.values.forEach { $0.removeFromParentNode() }
        itemNodes.removeAll()
    }
    
    /// 更新物品状态
    func updateItem(_ item: GameItem) {
        guard let node = itemNodes[item.id] else { return }
        
        if item.isEliminated {
            // 消除动画
            let scaleDown = SCNAction.scale(to: 0, duration: 0.2)
            let remove = SCNAction.removeFromParentNode()
            node.runAction(SCNAction.sequence([scaleDown, remove]))
            itemNodes.removeValue(forKey: item.id)
        } else if item.isSelected {
            // 选中高亮
            node.runAction(SCNAction.scale(to: 1.1, duration: 0.1))
        } else {
            node.runAction(SCNAction.scale(to: CGFloat(item.scale), duration: 0.1))
        }
        
        // 更新位置（颠锅后）
        let moveAction = SCNAction.move(to: SCNVector3(item.position), duration: 0.3)
        moveAction.timingMode = .easeOut
        node.runAction(moveAction)
        
        // 更新旋转
        node.eulerAngles = SCNVector3(item.rotation)
    }
    
    /// 颠锅效果
    func performShake() {
        // 给所有物品施加随机冲量
        for (_, node) in itemNodes {
            let randomX = Float.random(in: -3...3)
            let randomY = Float.random(in: 2...5)
            let randomZ = Float.random(in: -3...3)
            
            node.physicsBody?.applyForce(
                SCNVector3(randomX, randomY, randomZ),
                at: SCNVector3(0, 0, 0),
                asImpulse: true
            )
            
            // 添加随机旋转
            let torqueX = Float.random(in: -1...1)
            let torqueY = Float.random(in: -1...1)
            let torqueZ = Float.random(in: -1...1)
            node.physicsBody?.applyTorque(
                SCNVector4(torqueX, torqueY, torqueZ, 1),
                asImpulse: true
            )
        }
        
        // 相机震动效果
        shakeCamera()
    }
    
    /// 相机震动
    private func shakeCamera() {
        guard let cameraNode = scene.rootNode.childNodes.first(where: { $0.camera != nil }) else { return }
        
        let originalPosition = cameraNode.position
        
        var actions: [SCNAction] = []
        for _ in 0..<5 {
            let offsetX = Float.random(in: -0.1...0.1)
            let offsetY = Float.random(in: -0.1...0.1)
            let move = SCNAction.moveBy(x: CGFloat(offsetX), y: CGFloat(offsetY), z: 0, duration: 0.02)
            actions.append(move)
        }
        
        let returnAction = SCNAction.move(to: originalPosition, duration: 0.1)
        actions.append(returnAction)
        
        cameraNode.runAction(SCNAction.sequence(actions))
    }
    
    /// 处理点击
    func handleTap(at point: CGPoint, in view: SCNView) {
        let hitResults = view.hitTest(point, options: [.boundingBoxOnly: false])
        
        for result in hitResults {
            if let nodeName = result.node.name,
               nodeName.hasPrefix("item_") {
                // 找到对应的物品
                if let item = gameSession?.sceneItems.first(where: { $0.nodeName == nodeName }) {
                    onItemSelected?(item)
                    break
                }
            }
        }
    }
}

// MARK: - SwiftUI 包装

struct GameSceneView: UIViewRepresentable {
    var controller: GameSceneController
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = controller.scene
        sceneView.delegate = context.coordinator
        sceneView.allowsCameraControl = false
        sceneView.backgroundColor = .clear
        sceneView.antialiasingMode = .multisampling4X
        sceneView.preferredFramesPerSecond = 60
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // 响应状态变化
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }
    
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        let controller: GameSceneController
        weak var sceneView: SCNView?
        
        init(controller: GameSceneController) {
            self.controller = controller
            super.init()
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view as? SCNView else { return }
            let point = gesture.location(in: view)
            controller.handleTap(at: point, in: view)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            // 每帧更新回调
        }
    }
}

// MARK: - SCNVector3 扩展

extension SCNVector3 {
    init(_ simd: SIMD3<Float>) {
        self.init(x: simd.x, y: simd.y, z: simd.z)
    }
}
