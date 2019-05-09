//
//  DetailViewController.swift
//  PhotoViewerApp
//
//  Created by 縣美早 on 2019/04/14.
//  Copyright © 2019 縣美早. All rights reserved.
//

import UIKit
import SDWebImage

class DetailViewController: UIViewController {
    
    @IBOutlet var photoImageView: UIImageView!
    var passedUrl: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panView(sender:)))
        self.view.addGestureRecognizer(panGesture)
        
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.saveImage(_:))))
        photoImageView.sd_setImage(with: passedUrl, completed: nil)
        makeDismissButton()
    }
    @objc func panView(sender: UIPanGestureRecognizer) {
        //let location: CGPoint = sender.translation(in: self.view)
        self.dismiss(animated: true, completion: nil)
    }
    @objc func saveImage(_ sender: UITapGestureRecognizer) {
        let targetImageView = sender.view! as! UIImageView
        let targetImage = targetImageView.image!
        let alertController = UIAlertController(title: "保存", message: "この画像を保存しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            UIImageWriteToSavedPhotosAlbum(targetImage, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default) { (cancel) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        var title = "保存完了"
        var message = "カメラロールに保存しました"
        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeDismissButton() {
        let dismissButton = UIButton()
        dismissButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        let positionHeight = (self.view.frame.height)-(self.view.frame.height-60)
        dismissButton.layer.position = CGPoint(x: self.view.frame.width-32, y:positionHeight)
        let gray = UIColor(red: 235/255, green: 235/255, blue: 242/255, alpha: 1.0)
        dismissButton.backgroundColor = gray
        dismissButton.setImage(UIImage(named: "dismiss"), for: .normal)
        dismissButton.layer.cornerRadius = dismissButton.frame.height/2
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        view.addSubview(dismissButton)
    }
    
    @objc func didTapDismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
