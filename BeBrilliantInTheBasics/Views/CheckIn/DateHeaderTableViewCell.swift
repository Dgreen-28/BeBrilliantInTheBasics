//
//  DateHeaderTableViewCell.swift
//  BeBrilliantInTheBasics
//
//  Created by Decoreyon Green on 3/11/24.
//

import UIKit


protocol DateHeaderTableViewCellDelegate: AnyObject {
    func didTapPreviousDay()
    func didTapReturnToToday()
    func didTapNextDay()
}

class DateHeaderTableViewCell: UITableViewCell {

    var dateLabel: UILabel!
    var previousDayButton: UIButton!
    var nextDayButton: UIButton!
    weak var delegate: DateHeaderTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear // Set cell background to clear

        // Create and configure the date label
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)

        // Create constraints for the date label
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        // Create and configure the previous day button
        previousDayButton = UIButton(type: .system)
        previousDayButton.setImage(UIImage(systemName: "arrowshape.backward.fill"), for: .normal)
        previousDayButton.addTarget(self, action: #selector(previousDayButtonTapped(_:)), for: .touchUpInside)
        previousDayButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previousDayButton)

        // Create constraints for the previous day button
        NSLayoutConstraint.activate([
            previousDayButton.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8),
            previousDayButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        // Create and configure the next day button (right arrow)
        nextDayButton = UIButton(type: .system)
        nextDayButton.setImage(UIImage(systemName: "arrowshape.forward.fill"), for: .normal)
        nextDayButton.addTarget(self, action: #selector(nextDayButtonTapped(_:)), for: .touchUpInside)
        nextDayButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nextDayButton)

        // Create constraints for the next day button
        NSLayoutConstraint.activate([
            nextDayButton.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8),
            nextDayButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        dateLabel.text = dateFormatter.string(from: date)
    }

    @objc func previousDayButtonTapped(_ sender: UIButton) {
        delegate?.didTapPreviousDay()
    }

    @objc func nextDayButtonTapped(_ sender: UIButton) {
        delegate?.didTapNextDay()
    }
}
