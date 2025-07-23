import UIKit

final class AnalysisViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var tableView: AnalysisTableView = {
        let tableView = AnalysisTableView()
        tableView.analysisDelegate = self
        tableView.analysisDataSource = self
        return tableView
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .navBar
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: AnalysisViewModel
    private let diContainer: AppDIContainer
    
    // MARK: - Init
    init(viewModel: AnalysisViewModel, diContainer: AppDIContainer) {
        self.viewModel = viewModel
        self.diContainer = diContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        parent?.title = viewModel.title
        parent?.navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemGroupedBackground
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.sortSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func loadData() {
        Task {
            await viewModel.loadTransactions(
                from: viewModel.startDate,
                to: viewModel.endDate
            )
        }
    }
    
    private func updateUI() {
        switch viewModel.state {
        case .idle:
            loadingView.stopAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = true
        case .loading:
            loadingView.startAnimating()
            if tableView.isHidden {
                tableView.isHidden = true
                errorLabel.isHidden = true
            }
        case .error(let message):
            loadingView.stopAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = false
            errorLabel.text = "Ошибка: \(message)"
        case .success:
            loadingView.stopAnimating()
            tableView.isHidden = false
            errorLabel.isHidden = true
            tableView.reloadData()
        }
    }
}

// MARK: - AnalysisTableViewDataSource Methods

extension AnalysisViewController: AnalysisTableViewDataSource {
    
    var sectionsCount: Int {
        viewModel.sectionsCount
    }
    
    func numberOfRows(in section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }
    
    func cellType(for indexPath: IndexPath) -> AnalysisCellType {
        viewModel.cellType(for: indexPath)
    }
    
    func startDate() -> Date {
        viewModel.startDate
    }
    
    func endDate() -> Date {
        viewModel.endDate
    }
    
    func currentSort() -> TransactionsSort {
        viewModel.sort
    }
    
    func sortedOutput() -> TransactionsOutput? {
        viewModel.sortedOutput
    }
}

// MARK: - AnalysisTableViewDelegate Methods

extension AnalysisViewController: AnalysisTableViewDelegate {
    
    func handleDateSelection(type: DateSelectionType, date: Date) {
        viewModel.handleDateSelection(type: type, date: date)
    }
    
    func handleSortSelection(_ sort: TransactionsSort) {
        viewModel.handleSortSelection(sort)
    }
    
    func handleTransactionTap(_ transaction: Transaction) {
        let transactionFormViewController = TransactionFormModalView.createHostingController(
            transaction: transaction,
            diContainer: diContainer,
            onDismiss: { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true)
                }
            },
            onTransactionChanged: { [weak self] in
                self?.loadData()
            }
        )
        
        present(transactionFormViewController, animated: true)
    }
}
