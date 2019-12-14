

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let skview = self.view as? SKView {
            if skview.scene == nil {
                //  创建场景
                let widthPerHeight = skview.bounds.size.height / skview.bounds.size.width
                let scene = GameScene(size:CGSize(width: 320, height: 320 * widthPerHeight))
                skview.showsFPS = true
                skview.showsNodeCount = true
                skview.showsPhysics = true
                skview.ignoresSiblingOrder = true//分别前景与后景
                
                scene.scaleMode = .AspectFill
                
                skview.presentScene(scene)
            }
        }
    }
     override func prefersStatusBarHidden() -> Bool  {
        return true
    }

   }
