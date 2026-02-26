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
        // 环境光 - 提供基础照明
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 1.0, alpha: 1.0)
        ambientLight.light?.intensity = 800
        scene.rootNode.addChildNode(ambientLight)
        
        // 主光源 - 方向光（模拟阳光）
        let mainLight = SCNNode()
        mainLight.light = SCNLight()
        mainLight.light?.type = .directional
        mainLight.light?.color = UIColor(white: 1.0, alpha: 1.0)
        mainLight.light?.intensity = 1500
        mainLight.light?.castsShadow = true
        mainLight.position = SCNVector3(8, 12, 8)
        mainLight.eulerAngles = SCNVector3(-Float.pi/3, Float.pi/5, 0)
        scene.rootNode.addChildNode(mainLight)
        
        // 补光 - 填充阴影
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.light?.color = UIColor(white: 0.9, alpha: 1.0)
        fillLight.light?.intensity = 600
        fillLight.position = SCNVector3(-6, 6, -6)
        scene.rootNode.addChildNode(fillLight)
        
        // 轮廓光 - 增加立体感
        let rimLight = SCNNode()
        rimLight.light = SCNLight()
        rimLight.light?.type = .directional
        rimLight.light?.color = UIColor(white: 0.8, alpha: 1.0)
        rimLight.light?.intensity = 400
        rimLight.position = SCNVector3(-5, 3, 5)
        rimLight.eulerAngles = SCNVector3(-Float.pi/6, -Float.pi/4, 0)
        scene.rootNode.addChildNode(rimLight)
        
        // 启用环境光遮蔽（如果支持）
        scene.lightingEnvironment.intensity = 1.0
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
        // 使用模型工厂创建3D模型
        let containerNode = ItemModelFactory.createModel(for: item.type)
        containerNode.name = item.nodeName
        containerNode.position = SCNVector3(item.position)
        containerNode.eulerAngles = SCNVector3(item.rotation)
        containerNode.scale = SCNVector3(item.scale, item.scale, item.scale)
        
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
    
    /// 颠锅效果 - 给所有物品施加向上的爆发力
    func performShake() {
        guard let gameSession = gameSession else { return }
        
        // 获取需要颠锅的物品
        let itemsToShake = gameSession.getItemsForShake()
        
        for item in itemsToShake {
            guard let node = itemNodes[item.id] else { continue }
            
            // 重置物理状态
            node.physicsBody?.velocity = SCNVector3(0, 0, 0)
            node.physicsBody?.angularVelocity = SCNVector4(0, 0, 0, 0)
            
            // 向上的爆发力
            let upwardForce = Float.random(in: 8...15) // 更大的向上力
            let randomX = Float.random(in: -4...4)
            let randomZ = Float.random(in: -4...4)
            
            // 应用冲量
            node.physicsBody?.applyForce(
                SCNVector3(randomX, upwardForce, randomZ),
                at: SCNVector3(0, 0, 0),
                asImpulse: true
            )
            
            // 添加随机旋转
            let torqueX = Float.random(in: -2...2)
            let torqueY = Float.random(in: -2...2)
            let torqueZ = Float.random(in: -2...2)
            node.physicsBody?.applyTorque(
                SCNVector4(torqueX, torqueY, torqueZ, 1),
                asImpulse: true
            )
            
            // 更新物品的目标位置（用于后续同步）
            item.position = SIMD3<Float>(
                node.position.x + randomX * 0.1,
                min(node.position.y + upwardForce * 0.1, 4.0), // 限制高度
                node.position.z + randomZ * 0.1
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
            // 递归向上查找以 "item_" 开头的节点
            var currentNode: SCNNode? = result.node
            while let node = currentNode {
                if let nodeName = node.name, nodeName.hasPrefix("item_") {
                    // 找到对应的物品
                    if let item = gameSession?.sceneItems.first(where: { $0.nodeName == nodeName }) {
                        onItemSelected?(item)
                        return
                    }
                }
                currentNode = node.parent
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
