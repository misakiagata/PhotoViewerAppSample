//
//  ViewController.swift
//  PhotoViewerApp
//
//  Created by 縣美早 on 2019/04/13.
//  Copyright © 2019 縣美早. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import EAIntroView

class ViewController: UIViewController, EAIntroDelegate {
    
    @IBOutlet var photoCollectionView: UICollectionView!
    let colors = Colors()
    var photos = [URL]()
    var page: Int = 1
    var color: String!
    var url: String!
    var isSearch: Bool = false
    var loadStatus: String = "initial"
    var selectedPhoto: URL!
    let items = ["red","pink", "turquoise", "white", "black", "brown"]
    let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.refreshControl = UIRefreshControl()
        photoCollectionView.refreshControl?.addTarget(self, action: #selector(refreshControl), for: .valueChanged)
        let nib = UINib(nibName: "PhotoCollectionViewCell", bundle: .main)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        if ud.bool(forKey: "firstLaunch") == true {
            showTutorial()
        }
        
        apiRequest()
        makeSearchButton()
        
    }
    
    @objc func refreshControl() {
        DispatchQueue.main.async {
            //self.photos = []
            //ここでAPIのリクエストを送る
            self.apiRequest()
            self.photoCollectionView.refreshControl?.endRefreshing()
        }
    }
    
    func showTutorial() {
        let page1 = EAIntroPage()
        page1.title = "虫眼鏡のアイコンから\n好きな色を\n選んでみましょう"
        page1.desc = "このアプリでは花の画像を色から検索できます"
        page1.titleFont = UIFont(name: "Helvetica-Bold", size: 32)
        page1.bgColor = colors.pink1
        page1.descPositionY = self.view.bounds.size.height/2
        
        let page2 = EAIntroPage()
        page2.title = "気になる画像を\nタップしてみましょう"
        page2.desc = "詳細画面でより大きな画像を確認できます"
        page2.titleFont = UIFont(name: "Helvetica-Bold", size: 32)
        page2.bgColor = colors.pink2
        page2.descPositionY = self.view.bounds.size.height/2
        
        let page3 = EAIntroPage()
        page3.title = "気に入った画像を保存\nしてみましょう"
        page3.desc = "画像をタップし「OK」を選択すれば、画像を端末に保存できます"
        page3.titleFont = UIFont(name: "Helvetica-Bold", size: 32)
        page3.bgColor = colors.pink3
        page3.descPositionY = self.view.bounds.size.height/2
        
        let introView = EAIntroView(frame: self.view.bounds, andPages: [page1, page2, page3])
        introView?.skipButton.setTitle("スキップ", for: UIControl.State.normal)
        introView?.delegate = self
        introView?.show(in: self.view, animateDuration: 1.0)
        ud.set(false, forKey: "firstLaunch")
        
    }
    
    //APIリクエスト
    func apiRequest() {
        guard loadStatus != "fetching" && loadStatus != "full" else { return }
        loadStatus = "fetching"
        if color != nil {
            url = ""
        } else {
            url = ""
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).response
            { response in
                guard let data = response.data else { return }
                let decoder = JSONDecoder()
                do {
                    let results: PhotoModel = try decoder.decode(PhotoModel.self, from: data)
                    if self.isSearch == true {
                        //検索ワードに値が入ったら一度配列の中身を空にする
                        self.photos = []
                    }
                    
                    if results.totalHits!/50 == self.page {
                        self.loadStatus = "full"
                        return
                    }
                    
                    if results.totalHits != 0 {
                        for result in results.hits {
                            let imageUrl = result?.previewURL!
                            self.photos.append(imageUrl!)
                        }
                        
                        DispatchQueue.main.async {
                            self.photoCollectionView.reloadData()
                            self.loadStatus = "loadmore"
                            self.isSearch = false
                        }
                        
                        self.page += 1
                        
                    }
                    
                } catch {
                    print(error)
                    self.loadStatus = "error"
                    return
                }
        }
    }
    
    func makeSearchButton() {
        let dismissButton = UIButton()
        dismissButton.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        dismissButton.layer.position = CGPoint(x: self.view.frame.width-48, y: self.view.frame.height-48)
        dismissButton.backgroundColor = .white
        dismissButton.setImage(UIImage(named: "search"), for: .normal)
        dismissButton.layer.cornerRadius = dismissButton.frame.height/2
        dismissButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        dismissButton.layer.shadowOpacity = 0.4
        dismissButton.addTarget(self, action: #selector(didTapSearchButton(_:)), for: .touchUpInside)
        view.addSubview(dismissButton)
    }
    
    @objc func didTapSearchButton(_ sender: UIButton) {
        color = items[0]
        let pickerView: UIPickerView = UIPickerView()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        pickerView.frame = CGRect(x: 0, y: 72, width: view.bounds.width * 0.7, height: 150)
        pickerView.dataSource = self
        pickerView.delegate = self
        let title = "検索"
        let message = "色を選択してください\n\n\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.photoCollectionView.scrollsToTop = true
            self.isSearch = true
            self.loadStatus = "loadmore"
            self.page = 1
            self.apiRequest()
            
        })
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel) { action in
            self.color = ""
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.view.addSubview(pickerView)
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        cell.photoImageView.sd_setImage(with: photos[indexPath.row], completed: nil)
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.passedUrl = selectedPhoto
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPhoto = photos[indexPath.row]
        collectionView.deselectItem(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "toDetail", sender: nil)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        if distanceToBottom < 500 {
            apiRequest()
        }
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let itemSize = (width-4)/3
        return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        color = items[row]
    }
}


