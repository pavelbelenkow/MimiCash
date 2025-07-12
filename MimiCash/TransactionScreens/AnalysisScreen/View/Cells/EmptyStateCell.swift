import UIKit

final class EmptyStateCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "EmptyStateCell"
    
    // MARK: - UI Components
    private let messageLabel = UILabel()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        setupMessageLabel()
        setupConstraints()
    }
    
    private func setupMessageLabel() {
        messageLabel.text = Spec.Text.emptyState
        messageLabel.textAlignment = .center
        messageLabel.textColor = .systemGray
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spec.Layout.horizontalPadding),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spec.Layout.horizontalPadding),
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spec.Layout.verticalPadding),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spec.Layout.verticalPadding)
        ])
    }
}

// MARK: - Spec
private enum Spec {
    enum Text {
        static let emptyState = "Нет операций в заданном диапазоне"
    }
    
    enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 16
    }
}
