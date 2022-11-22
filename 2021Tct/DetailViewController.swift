//
//  DetailViewController.swift
//  2021Tct
//
//  Created by suheekang on 2022/11/15.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var itemPrice: UILabel!
    @IBOutlet var itemCompany: UILabel!
    @IBOutlet var itemModel: UILabel!
    
    var itemId = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callDetailItemAPI()
    }
    
    func callDetailItemAPI() {
        let url = "https://1b228c5f-b9b2-4ed8-96ca-8c0bfded127d.mock.pstmn.io/v1/item/" + "\(itemId)"
        guard let apiURI = URL(string: url) else {
            return
        }
        
        let urlRequest = URLRequest(url: apiURI)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else { return }
            
            guard let apidata = data else { return }
            let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue) ?? ""
            
            NSLog("Detail API Result=\(log)")
            do {
                if let apiDic = try JSONSerialization.jsonObject(with: apidata, options: []) as? [String: Any] {
                    if let infoList = apiDic["item"] as? [String: Any] {
                        DispatchQueue.main.async {
                            self.itemName.text = infoList["title"] as? String
                            self.itemPrice.text = (infoList["price"] as? Int)?.withComma ?? "0"
                            self.itemCompany.text = infoList["company"] as? String
                            self.itemModel.text = infoList["model"] as? String
                            
                            let imageFile = infoList["imageFile"] as? String
                            self.itemImage.image = UIImage(named: imageFile ?? "airpods.jpg")
                        }
                    }
                } else {
                    // TODO: - 에러처리
                }
            }
            catch {
                
            }
        }.resume()
    }
}
