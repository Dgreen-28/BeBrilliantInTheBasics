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
    
    var isCheckboxChecked: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        print("Cell awakeFromNib called")
        bgView.setCellShadow()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add custom initialization code here
        // For example:
        // contentView.addSubview(UIView())
        contentView.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
