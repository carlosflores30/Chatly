//
//  VideoPlayerVC.swift
//  ChatAppiOS
//
//  Created by Roberto Flores on 30/11/24.
//

import Foundation
import UIKit
import AVKit

class VideoPlayerVC: AVPlayerViewController{
    private var videoURL: URL
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reproduciendo Video"
        view.backgroundColor = .systemGray6
        
        player = AVPlayer(url: videoURL)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent{
            try? FileManager.default.removeItem(at: videoURL)
            
        }
    }
}
