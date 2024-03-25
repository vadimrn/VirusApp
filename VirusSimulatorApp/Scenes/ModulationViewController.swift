import UIKit

final class ModulationViewController: UIViewController {

    // MARK: - Properties
    var groupSize = 0
    var infectionFactor = 0
    var recalculationPeriod = 0.0
    var matrix: [[Bool]] = [[]]

    // MARK: - Private Properties
    private var timer: Timer?
    private var seconds = 0
    private var cellScaleFactor = 1.0
    private var scale: CGFloat = 1.0

    // MARK: - Computed Properties
    private var matrixElements: Int {
        let rowCount = matrix.count
        let columnCount = matrix.first?.count ?? 0

        let totalCount = rowCount * columnCount
        return totalCount
    }

    private var greenElements: Int {
        var count = 0
        for row in matrix {
            for element in row {
                if !element {
                    count += 1
                }
            }
        }
        return count
    }

    private var redElements: Int {
        var count = 0
        for row in matrix {
            for element in row {
                if element {
                    count += 1
                }
            }
        }
        return count
    }

    // MARK: - UI Elements
    // MARK: - Header
    private lazy var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()

    private lazy var greenImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "figure.walk.circle")
        imageView.tintColor = .systemGreen
        return imageView
    }()

    private lazy var greenLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ": \(matrixElements)"
        return label
    }()

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text =  "Pass Time: 00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var redImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "figure.fall.circle")
        imageView.tintColor = .systemRed
        return imageView
    }()

    private lazy var redLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ": \(redElements)"
        return label
    }()

    // MARK: - Scroll View
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: 0,
                                                    height: 0))
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 2,
                                        height: UIScreen.main.bounds.height * 2)
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    // MARK: - Collection View
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: CGRect(x: 0,
                                                            y: 0,
                                                            width: UIScreen.main.bounds.width * 2,
                                                            height: UIScreen.main.bounds.height * 2),
                                              collectionViewLayout: layout)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(HumanCollectionViewCell.self,
                                forCellWithReuseIdentifier: HumanCollectionViewCell.identifier)

        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = true

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.contentSize = CGSize(width: UIScreen.main.bounds.width * 3,
                                            height: UIScreen.main.bounds.height * 2)

        return collectionView
    }()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        collectionView.addGestureRecognizer(pinchGesture)
        self.collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private Methods
    /**
     Этот метод отвечает за обновление элементов представления на основе текущего состояния симуляции. Он проверяет количество зеленых элементов и останавливает таймер, если не осталось больше зеленых элементов. В противном случае, он заменяет случайных соседей в матрице заданным коэффициентом заражения. После обновления необходимых элементов, он перезагружает коллекцию для отражения изменений.
     */
    private func updateView() {
        if greenElements <= 0 {
            timer?.invalidate()
            timer = nil
        }

        greenLabel.text = ": \(greenElements)"
        updateTimerLabel()
        redLabel.text = ": \(redElements)"

        collectionView.reloadData()
    }

    /**
     Этот метод заменяет случайных соседей в матрице на основе заданного фактора.
     Parameters:
     matrix: Матрица типа [[Bool]], в которой происходит замена соседей.
     factor: Фактор, определяющий количество замен соседей для каждой ячейки матрицы.
     */
    private func replaceRandomNeighborsInMatrix(_ matrix: [[Bool]], withFactor factor: Int) {
        let numRows = matrix.count
        let numColumns = matrix[0].count

        for row in 0..<numRows {
            for column in 0..<numColumns {
                if matrix[row][column] {
                    for _ in 0..<Int.random(in: 0...factor) {
                        let randomRow = Int.random(in: max(row-1, 0)...min(row+1, numRows-1))
                        let randomColumn = Int.random(in: max(column-1, 0)...min(column+1, numColumns-1))

                        if !matrix[randomRow][randomColumn] {
                            self.matrix[randomRow][randomColumn] = true
                        }
                    }
                }
            }
        }
    }

    /**
     Этот метод обновляет label таймера.
     */
    private func updateTimerLabel() {
        let minutes = seconds / 60 * Int(recalculationPeriod)
        let seconds = seconds % 60 * Int(recalculationPeriod)
        timerLabel.text = "Pass Time: \(String(format: "%02d:%02d", minutes, seconds))"
    }

    /**
     Метод для запуска таймера при нажатии на зеленую клетку.
     */
    private func selectCell() {
        if timer == nil {
            timer = Timer(fire: Date(), interval: recalculationPeriod, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                self.seconds += 1
                self.replaceRandomNeighborsInMatrix(self.matrix, withFactor: self.infectionFactor)
                DispatchQueue.main.async {
                    self.updateView()
                }
            }
            if let timer = timer {
                RunLoop.current.add(timer, forMode: .default)
                RunLoop.current.run()
            }
        }
    }

}

// MARK: - Setup View
extension ModulationViewController {
    private func setupMainView() {
        view.backgroundColor = .white
        setupNavigationBar()
        view.addSubviews(header)
        header.addSubviews(greenImageView, greenLabel, redLabel, redImageView, timerLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(collectionView)
        setConstraints()
    }

    /// Метод для установки констрейнтов
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // Header
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 50),

            greenImageView.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            greenImageView.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            greenImageView.widthAnchor.constraint(equalToConstant: 30),
            greenImageView.heightAnchor.constraint(equalToConstant: 30),

            greenLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            greenLabel.leadingAnchor.constraint(equalTo: greenImageView.trailingAnchor, constant: 8),

            timerLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),


            redLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            redLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),

            redImageView.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            redImageView.trailingAnchor.constraint(equalTo: redLabel.leadingAnchor, constant: -8),
            redImageView.widthAnchor.constraint(equalToConstant: 30),
            redImageView.heightAnchor.constraint(equalToConstant: 30),

            // Collection view
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /// Метод для установки панели навигации
    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        title = "Modulation"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(plusDidTapped))
        let minusButton = UIBarButtonItem(image: UIImage(systemName: "minus"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(minusDidTapped))
        navigationItem.rightBarButtonItems = [plusButton, minusButton]
    }

    // MARK: - Scale Methods
    /// Увеличение размера клеток
    @objc
    func plusDidTapped() {
        self.cellScaleFactor += 0.1
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }

    /// Уменьшение размера клеток
    @objc
    func minusDidTapped() {
        if cellScaleFactor > 0.2 {
            self.cellScaleFactor -= 0.1
        }
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }
}

// MARK: - Collection View Delegate And DataSource
extension ModulationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return matrix.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return matrix.first?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HumanCollectionViewCell.identifier,
                                                      for: indexPath) as! HumanCollectionViewCell
        let item = matrix[indexPath.section][indexPath.row]
        cell.setupCellWith(item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.matrix[indexPath.section][indexPath.row] = true
        self.selectCell()
        collectionView.reloadItems(at: [indexPath])
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}

// MARK: - Collection View Delegate Flow Layout
extension ModulationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch matrixElements {
        case 0...100:
            let width = 40 * cellScaleFactor
            let height = 40 * cellScaleFactor
            return CGSize(width: width, height: height)
        case 100...300:
            let width = 23 * cellScaleFactor
            let height = 23 * cellScaleFactor
            return CGSize(width: width, height: height)
        case 300...600:
            let width = 15 * cellScaleFactor
            let height = 15 * cellScaleFactor
            return CGSize(width: width, height: height)
        case 600...900:
            let width = 11 * cellScaleFactor
            let height = 11 * cellScaleFactor
            return CGSize(width: width, height: height)
        default:
            let width = 20 * cellScaleFactor
            let height = 20 * cellScaleFactor
            return CGSize(width: width, height: height)
        }
    }
}

// MARK: - UIGesture Recognizer Delegate
extension ModulationViewController: UIGestureRecognizerDelegate {
    @objc
    func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            scale *= gestureRecognizer.scale
            gestureRecognizer.scale = 1.0

            collectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
