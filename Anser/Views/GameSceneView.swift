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
        // 创建锅底 - 实体半球（倒扣）
        let potRadius: CGFloat = 5.0
        
        // 锅底材质
        let potMaterial = SCNMaterial()
        potMaterial.diffuse.contents = UIColor(red: 0.35, green: 0.25, blue: 0.15, alpha: 1.0)
        potMaterial.specular.contents = UIColor(white: 0.4, alpha: 1.0)
        potMaterial.roughness.contents = 0.5
        potMaterial.metalness.contents = 0.4
        potMaterial.isDoubleSided = true
        
        // 创建半球形锅底（内部可见）
        let bowlGeometry = SCNSphere(radius: potRadius)
        bowlGeometry.segmentCount = 48
        bowlGeometry.firstMaterial = potMaterial
        
        let bowlNode = SCNNode(geometry: bowlGeometry)
        bowlNode.position = SCNVector3(0, -1.5, 0)
        bowlNode.scale = SCNVector3(1, 0.7, 1)
        // 旋转使开口朝上
        bowlNode.eulerAngles = SCNVector3(Float.pi, 0, 0)
        
        // 锅的物理体 - 静态凹面
        let bowlShape = SCNPhysicsShape(geometry: bowlGeometry, options: [
            .type: SCNPhysicsShape.ShapeType.concavePolyhedron
        ])
        bowlNode.physicsBody = SCNPhysicsBody(type: .static, shape: bowlShape)
        bowlNode.physicsBody?.friction = 0.6
        bowlNode.physicsBody?.restitution = 0.2
        bowlNode.physicsBody?.categoryBitMask = 1
        
        scene.rootNode.addChildNode(bowlNode)
        self.potNode = bowlNode
        
        // 添加锅边
        createPotRim()
        
        // 添加隐形底部平面，防止物品掉出
        createBottomPlane()
    }
    
    private func createBottomPlane() {
        // 创建一个隐形的底部，防止物品从锅底掉出去
        let plane = SCNPlane(width: 8, height: 8)
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(0, -4.5, 0)
        planeNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        planeNode.opacity = 0.0 // 完全透明
        
        let planeShape = SCNPhysicsShape(geometry: plane, options: nil)
        let planeBody = SCNPhysicsBody(type: .static, shape: planeShape)
        planeBody.friction = 0.5
        planeBody.restitution = 0.1
        planeNode.physicsBody = planeBody
        
        scene.rootNode.addChildNode(planeNode)
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
        // 选择模型方案（四选一）：
        // 1. SimpleItemFactory - 彩色球体+文字标签（最可靠，推荐）
        // 2. EmojiItemFactory - Emoji贴图（需验证渲染）
        // 3. USDZModelLoader - 真实USDZ模型（需要有模型文件）
        // 4. ItemModelFactory - 程序化几何体（复杂形状）
        
        let containerNode: SCNNode
        
        // 默认使用简化方案（彩色球体+中文标签，最可靠）
        containerNode = SimpleItemFactory.createItem(for: item.type)
        
        // 其他方案（取消注释切换）：
        // containerNode = EmojiItemFactory.createEmojiItem(for: item.type)
        // containerNode = USDZModelLoader.loadModel(for: item.type)
        // containerNode = ItemModelFactory.createModel(for: item.type)
        
        containerNode.name = item.nodeName
        containerNode.position = SCNVector3(item.position)
        containerNode.eulerAngles = SCNVector3(item.rotation)
        containerNode.scale = SCNVector3(item.scale, item.scale, item.scale)
        
        // 添加物理体 - 使用简单的球形碰撞体以获得更好的性能
        let sphereShape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.5), options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: sphereShape)
        physicsBody.mass = 1.0  // 增加质量
        physicsBody.friction = 0.6
        physicsBody.restitution = 0.4  // 弹性
        physicsBody.damping = 0.5  // 线性阻尼（减缓运动）
        physicsBody.angularDamping = 0.5  // 角阻尼
        physicsBody.isAffectedByGravity = true
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
    
    /// 颠锅效果 - 给所有物品施加巨大的爆发力
    func performShake() {
        print("[GameSceneView] Performing shake with \(itemNodes.count) items")
        
        for (_, node) in itemNodes {
            guard let physicsBody = node.physicsBody else { continue }
            
            // 通过应用微小脉冲唤醒物理体
            physicsBody.applyForce(SCNVector3(0.01, 0.01, 0.01), at: SCNVector3Zero, asImpulse: true)
            
            // 重置当前速度
            physicsBody.velocity = SCNVector3(0, 0, 0)
            physicsBody.angularVelocity = SCNVector4(0, 0, 0, 0)
            
            // 巨大的向上爆发力
            let upwardForce: Float = 25.0  // 非常大的向上力
            let randomX = Float.random(in: -10...10)
            let randomZ = Float.random(in: -10...10)
            
            // 应用冲量（impulse = 瞬间力）
            physicsBody.applyForce(
                SCNVector3(randomX, upwardForce, randomZ),
                at: SCNVector3(0, 0, 0),
                asImpulse: true
            )
            
            // 添加随机旋转
            let torqueX = Float.random(in: -5...5)
            let torqueY = Float.random(in: -5...5)
            let torqueZ = Float.random(in: -5...5)
            physicsBody.applyTorque(
                SCNVector4(torqueX, torqueY, torqueZ, 1),
                asImpulse: true
            )
            
            print("[GameSceneView] Applied force: (\(randomX), \(upwardForce), \(randomZ)) to node")
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
        
        // 调试：显示物理边界（开发时使用）
        // sceneView.debugOptions = [.showPhysicsShapes]
        
        // 确保物理模拟运行
        controller.scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        controller.scene.physicsWorld.speed = 1.0
        
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
