import UIKit

final class AnalysisTableView: UITableView {
    
    // MARK: - Properties
    weak var analysisDelegate: AnalysisTableViewDelegate?
    weak var analysisDataSource: AnalysisTableViewDataSource?
    
    // MARK: - Init
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: .insetGrouped)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetupUI
    private func setupTableView() {
        delegate = self
        dataSource = self
        translatesAutoresizingMaskIntoConstraints = false
        
        register(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.identifier)
        register(SortPickerCell.self, forCellReuseIdentifier: SortPickerCell.identifier)
        register(TotalAmountCell.self, forCellReuseIdentifier: TotalAmountCell.identifier)
        register(PieChartCell.self, forCellReuseIdentifier: PieChartCell.identifier)
        register(TransactionAnalysisCell.self, forCellReuseIdentifier: TransactionAnalysisCell.identifier)
        register(EmptyStateCell.self, forCellReuseIdentifier: EmptyStateCell.identifier)
        register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
    }
}

// MARK: - UITableViewDataSource Methods

extension AnalysisTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        analysisDataSource?.sectionsCount ?? .zero
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        analysisDataSource?.numberOfRows(in: section) ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let dataSource = analysisDataSource
        else { return UITableViewCell() }
        
        let cellType = dataSource.cellType(for: indexPath)
        
        switch cellType {
        case .startDatePicker:
            return configureStartDatePickerCell(
                at: indexPath,
                with: dataSource
            )
        case .endDatePicker:
            return configureEndDatePickerCell(
                at: indexPath,
                with: dataSource
            )
        case .sortPicker:
            return configureSortPickerCell(
                at: indexPath,
                with: dataSource
            )
        case .totalAmount:
            return configureTotalAmountCell(
                at: indexPath,
                with: dataSource
            )
        case .pieChart:
            return configurePieChartCell(
                at: indexPath,
                with: dataSource
            )
        case let .transaction(transaction):
            return configureTransactionCell(
                at: indexPath,
                with: dataSource,
                transaction: transaction
            )
        case .emptyState:
            return configureEmptyStateCell(at: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate Methods

extension AnalysisTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return Spec.RowHeight.regular
        case 1:
            return Spec.RowHeight.chart
        default:
            return Spec.RowHeight.large
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            let cellType = analysisDataSource?.cellType(for: indexPath)
            if case let .transaction(transaction) = cellType {
                analysisDelegate?.handleTransactionTap(transaction)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == .zero ? Spec.HeaderHeight.first : Spec.HeaderHeight.other
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 2 else { return nil }
        
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SectionHeaderView.identifier
        ) as? SectionHeaderView else { return nil }
        
        header.configure(with: Spec.Text.transactions)
        return header
    }
}

// MARK: Configure Cells Methods

private extension AnalysisTableView {
    
    func configureStartDatePickerCell(
        at indexPath: IndexPath,
        with dataSource: AnalysisTableViewDataSource
    ) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: DatePickerCell.identifier,
            for: indexPath
        ) as? DatePickerCell else { return UITableViewCell() }
        
        cell.configure(
            title: Spec.Text.startDatePicker,
            date: dataSource.startDate()
        ) { [weak self] date in
            self?.analysisDelegate?.handleDateSelection(
                type: .start,
                date: date
            )
        }
        
        return cell
    }
    
    func configureEndDatePickerCell(
        at indexPath: IndexPath,
        with dataSource: AnalysisTableViewDataSource
    ) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: DatePickerCell.identifier,
            for: indexPath
        ) as? DatePickerCell else { return UITableViewCell() }
        
        cell.configure(
            title: Spec.Text.endDatePicker,
            date: dataSource.endDate()
        ) { [weak self] date in
            self?.analysisDelegate?.handleDateSelection(
                type: .end,
                date: date
            )
        }
        
        return cell
    }
    
    func configureSortPickerCell(
        at indexPath: IndexPath,
        with dataSource: AnalysisTableViewDataSource
    ) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: SortPickerCell.identifier,
            for: indexPath
        ) as? SortPickerCell else { return UITableViewCell() }
        
        cell.configure(sort: dataSource.currentSort()) { [weak self] sort in
            self?.analysisDelegate?.handleSortSelection(sort)
        }
        
        return cell
    }
    
    func configureTotalAmountCell(
        at indexPath: IndexPath,
        with dataSource: AnalysisTableViewDataSource
    ) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: TotalAmountCell.identifier,
            for: indexPath
        ) as? TotalAmountCell else { return UITableViewCell() }
        
        if let output = dataSource.sortedOutput() {
            cell.configure(
                title: Spec.Text.totalAmount,
                amount: output.totalAmountFormatted()
            )
        }
        
        return cell
    }
    
    func configurePieChartCell(
        at indexPath: IndexPath,
        with dataSource: AnalysisTableViewDataSource
    ) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: PieChartCell.identifier,
            for: indexPath
        ) as? PieChartCell else { return UITableViewCell() }
        
        let entities = dataSource.pieChartEntities()
        cell.configure(with: entities)
        
        return cell
    }
    
    func configureTransactionCell(
        at indexPath: IndexPath,
        with dataSource: AnalysisTableViewDataSource,
        transaction: Transaction
    ) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: TransactionAnalysisCell.identifier,
            for: indexPath
        ) as? TransactionAnalysisCell else { return UITableViewCell() }
        
        if let output = dataSource.sortedOutput() {
            cell.configure(transaction: transaction, total: output.total)
        }
        return cell
    }
    
    func configureEmptyStateCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: EmptyStateCell.identifier,
            for: indexPath
        ) as? EmptyStateCell else { return UITableViewCell() }
        
        return cell
    }
}

// MARK: - Spec

private enum Spec {
    
    enum Text {
        static let startDatePicker = "Период: начало"
        static let endDatePicker = "Период: конец"
        static let totalAmount = "Сумма"
        static let transactions = "Операции"
    }
    
    enum RowHeight {
        static let regular: CGFloat = 44
        static let large: CGFloat = 60
        static let chart: CGFloat = 150
    }
    
    enum HeaderHeight {
        static let first: CGFloat = 16
        static let other: CGFloat = 22
    }
}
