//
//  RepeatTableViewCell.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 2/1/24.
//

import UIKit

class RepeatTableViewCell: UITableViewCell {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var viewerImage: UIImageView!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var viewerLabel: UILabel!
    
    var indexPath: IndexPath? // Store the indexPath
    var tapCount = 0

    var statusBtn: (() -> ())?
     
    override func awakeFromNib() {
         super.awakeFromNib()
         print("Cell awakeFromNib called")
         bgView.setCellShadow()
         // Initialization code
     }

     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)
     }
     
    
    @IBAction func statusTapped(_ sender: Any) {
//        tapCount += 1 // Increment the tap count
        print("Status button tapped")
        statusBtn?()
     }
     
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)

         contentView.isUserInteractionEnabled = true
     }
     
     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
     }
 }
