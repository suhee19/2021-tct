//
//  ListViewController.swift
//  2021Tct
//
//  Created by suheekang on 2022/11/10.
//

import UIKit

extension Int {
    var withComma: String {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = NumberFormatter.Style.decimal
        decimalFormatter.groupingSeparator = ","
        decimalFormatter.groupingSize = 3
         
        return decimalFormatter.string(from: self as NSNumber)!
    }
}

class ListViewController: UITableViewController {
    
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblDeliverFee: UILabel!
    @IBOutlet var lblFinalPrice: UILabel!
    
    var totalPrice = 0
    var deliveryFee = 0
    
    lazy var list: [CartVO] = {
        var cartlist = [CartVO]()
        return cartlist
    }()
    
    var selectedId: Int! = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callCartListAPI()
    }
    
    func callCartListAPI() {
        let url = "https://1b228c5f-b9b2-4ed8-96ca-8c0bfded127d.mock.pstmn.io/v1/cartList"
        guard let apiURI = URL(string: url) else {
            return
        }
        let urlRequest = URLRequest(url: apiURI)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else { return }
            
            guard let apidata = data else { return }
            
            let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue) ?? ""
            
            NSLog("API Result=\(log)")
            
            do {
                if let apiDic = try JSONSerialization.jsonObject(with: apidata, options: []) as? [String: Any] {
                    let cartList = apiDic["cartList"] as! NSArray
                    
                    for cart in cartList {
                        if let c = cart as? [String: Any] {
                            let cvo = CartVO()
                            
                            cvo.id = c["id"] as? Int
                            cvo.title = c["title"] as? String
                            cvo.imageFile = c["imageFile"] as? String
                            cvo.price = c["price"] as? Int
                            
                            self.totalPrice += cvo.price ?? 0
                            
                            self.list.append(cvo)
                        }
                    }
                } else {
                    // TODO: Error 처리
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    self.lblTotalPrice.text = self.totalPrice.withComma
                    if self.totalPrice >= 50000 {
                        self.deliveryFee = 0
                    } else {
                        self.deliveryFee = 3000
                    }
                    self.lblDeliverFee.text = self.deliveryFee.withComma
                    self.lblFinalPrice.text = "(\(self.list.count)개) " + (self.totalPrice + self.deliveryFee).withComma
                }
            } catch {
                
            }
        }.resume()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! CartCell

        cell.title.text = row.title
        cell.price.text = row.price!.withComma
        cell.imageFile.image = UIImage(named: row.imageFile!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let row = self.list[indexPath.row]
        selectedId = row.id!
        return indexPath
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let detailVC = segue.destination as! DetailViewController
        detailVC.itemId = self.selectedId
    }
    

}
