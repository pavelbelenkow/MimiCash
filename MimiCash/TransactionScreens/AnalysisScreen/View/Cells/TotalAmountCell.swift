import UIKit

final class TotalAmountCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "TotalAmountCell"
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(title: String, amount: String) {
        titleLabel.text = title
        amountLabel.text = amount
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        setupTitleLabel()
        setupAmountLabel()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupAmountLabel() {
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .right
        contentView.addSubview(amountLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spec.Layout.horizontalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spec.Layout.horizontalPadding),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - Spec
private enum Spec {
    enum Layout {
        static let horizontalPadding: CGFloat = 16
    }
}
