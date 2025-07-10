import UIKit

final class TransactionAnalysisCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "TransactionAnalysisCell"
    
    // MARK: - UI Components
    private let mainStackView = UIStackView()
    private let emojiIconView = UIView()
    private let emojiLabel = UILabel()
    private let leftStackView = UIStackView()
    private let categoryTitleLabel = UILabel()
    private let commentLabel = UILabel()
    private let rightStackView = UIStackView()
    private let percentLabel = UILabel()
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
    func configure(transaction: Transaction, total: Decimal) {
        let hasIcon = transaction.category.isIncome == .outcome
        let hasComment = !(transaction.comment?.isEmpty ?? true)
        
        configureEmojiIcon(hasIcon: hasIcon, emoji: transaction.category.emoji.description)
        configureCategoryTitle(transaction.category.name)
        configureComment(hasComment: hasComment, comment: transaction.comment)
        configureAmounts(amount: transaction.amount, total: total, formattedAmount: transaction.formattedAmount())
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        accessoryType = .disclosureIndicator
        setupMainStackView()
        setupEmojiViews()
        setupLeftStackView()
        setupRightStackView()
        setupConstraints()
    }
    
    private func setupMainStackView() {
        mainStackView.alignment = .center
        mainStackView.spacing = Spec.Layout.mainStackSpacing
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)
    }
    
    private func setupEmojiViews() {
        emojiIconView.backgroundColor = .circle
        emojiIconView.layer.cornerRadius = Spec.Layout.emojiIconCornerRadius
        emojiIconView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: Spec.Font.emojiSize)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emojiIconView.addSubview(emojiLabel)
        mainStackView.addArrangedSubview(emojiIconView)
    }
    
    private func setupLeftStackView() {
        leftStackView.axis = .vertical
        leftStackView.alignment = .leading
        leftStackView.spacing = Spec.Layout.leftStackSpacing
        leftStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        leftStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        categoryTitleLabel.font = .systemFont(ofSize: Spec.Font.titleSize)
        categoryTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        commentLabel.font = .systemFont(ofSize: Spec.Font.commentSize)
        commentLabel.textColor = .systemGray
        commentLabel.numberOfLines = 1
        commentLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        leftStackView.addArrangedSubview(categoryTitleLabel)
        leftStackView.addArrangedSubview(commentLabel)
        mainStackView.addArrangedSubview(leftStackView)
    }
    
    private func setupRightStackView() {
        rightStackView.axis = .vertical
        rightStackView.alignment = .trailing
        rightStackView.spacing = Spec.Layout.rightStackSpacing
        rightStackView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        percentLabel.textAlignment = .right
        percentLabel.font = .systemFont(ofSize: Spec.Font.titleSize)
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)
        percentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountLabel.textAlignment = .right
        amountLabel.font = .systemFont(ofSize: Spec.Font.titleSize)
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        rightStackView.addArrangedSubview(percentLabel)
        rightStackView.addArrangedSubview(amountLabel)
        mainStackView.addArrangedSubview(rightStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spec.Layout.horizontalPadding),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spec.Layout.horizontalPadding),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spec.Layout.verticalPadding),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spec.Layout.verticalPadding),
            
            emojiIconView.widthAnchor.constraint(equalToConstant: Spec.Layout.emojiIconSize),
            emojiIconView.heightAnchor.constraint(equalToConstant: Spec.Layout.emojiIconSize),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiIconView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiIconView.centerYAnchor)
        ])
    }
    
    private func configureEmojiIcon(hasIcon: Bool, emoji: String) {
        if hasIcon {
            emojiIconView.isHidden = false
            emojiLabel.text = emoji
        } else {
            emojiIconView.isHidden = true
        }
    }
    
    private func configureCategoryTitle(_ title: String) {
        categoryTitleLabel.text = title
    }
    
    private func configureComment(hasComment: Bool, comment: String?) {
        if hasComment {
            commentLabel.text = comment
            commentLabel.isHidden = false
        } else {
            commentLabel.isHidden = true
        }
    }
    
    private func configureAmounts(
        amount: Decimal,
        total: Decimal,
        formattedAmount: String
    ) {
        let percentage = amount / total
        percentLabel.text = percentage.formattedAsPercent()
        amountLabel.text = formattedAmount
    }
}

// MARK: - Spec
private enum Spec {
    enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        static let mainStackSpacing: CGFloat = 12
        static let leftStackSpacing: CGFloat = 4
        static let rightStackSpacing: CGFloat = 4
        static let emojiIconSize: CGFloat = 22
        static let emojiIconCornerRadius: CGFloat = 11
    }
    
    enum Font {
        static let emojiSize: CGFloat = 12
        static let titleSize: CGFloat = 17
        static let commentSize: CGFloat = 13
    }
}
