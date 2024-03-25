import UIKit

final class SettingsViewController: UIViewController {

    // MARK: - Group Size
    private lazy var groupSizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Input Group Size"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private lazy var groupSizeTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "100"
        textField.keyboardType = .numberPad
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray3.cgColor

        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.bounds.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always

        return textField
    }()


    // MARK: - Infection Factor
    private lazy var infectionFactorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Maximum Infection Factor"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private lazy var minFactorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private lazy var infectionFactorTextField: UITextField = {
        let textField = UITextField()
        infectionFactorSlider.addTarget(self, action: #selector(sliderChange), for: .valueChanged)
        textField.inputView = infectionFactorSlider
        textField.font = .systemFont(ofSize: 16, weight: .bold)
        textField.text = String(Int(infectionFactorSlider.value))
        textField.isEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var maxFactorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "8"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private lazy var infectionFactorSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.maximumValue = 8
        slider.value = 3
        slider.isContinuous = true
        return slider
    }()


    // MARK: - Timer
    private lazy var recalculationPeriodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Input Recalculation Period"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private lazy var recalculationPeriodTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "1"
        textField.keyboardType = .numberPad
        textField.layer.masksToBounds = true
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.systemGray3.cgColor
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        return textField
    }()


    // MARK: - Alert Message
    private lazy var alertMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error! You must to add something in Text Fields! And you cannot use negative number!"
        label.numberOfLines = 0
        label.textColor = .red
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.isHidden = true
        return label
    }()

    // MARK: - Start Button
    private lazy var startModulationButton: UIButton = {
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.title = "Start Modulation"
        let button = UIButton(configuration: buttonConfiguration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.layer.shadowRadius = 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.addTarget(self,
                         action: #selector(startModulationButtonDidTupped),
                         for: .touchUpInside)
        return button
    }()

    // MARK: -  View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
    }

    // MARK: - Start Button Did Tapped
    @objc
    func startModulationButtonDidTupped() {
        if let groupSize = Int(groupSizeTextField.text ?? "0"),
           let recalculationPeriod = Double(recalculationPeriodTextField.text ?? "0"),
           groupSize > 0,
           recalculationPeriod > 0 {
            let modulationVC = ModulationViewController()

            modulationVC.groupSize = groupSize
            modulationVC.infectionFactor = Int(infectionFactorSlider.value)
            modulationVC.recalculationPeriod = recalculationPeriod

            modulationVC.matrix = MatrixHelper.shared.makeMatrix(groupSize)

            self.groupSizeTextField.text = nil
            self.infectionFactorSlider.value = 3
            self.infectionFactorTextField.text = "3"
            self.recalculationPeriodTextField.text = nil

            self.alertMessage.isHidden = true
            navigationController?.pushViewController(modulationVC, animated: true)
        } else {
            startModulationButton.shake()
            alertMessage.isHidden = false
        }
    }

    @objc func sliderChange() {
        infectionFactorTextField.text = String(Int(infectionFactorSlider.value))
    }
}

// MARK: - Setup Main View
extension SettingsViewController {
    private func setupMainView() {
        view.backgroundColor = .systemGray6
        setupNavigationBar()
        view.addSubviews(groupSizeLabel,
                         groupSizeTextField,
                         infectionFactorLabel,
                         infectionFactorTextField,
                         minFactorLabel,
                         maxFactorLabel,
                         infectionFactorSlider,
                         recalculationPeriodLabel,
                         recalculationPeriodTextField,
                         startModulationButton,
                         alertMessage)
        setupConstraints()
    }

    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        title = "Settings"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            //Group Size
            groupSizeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            groupSizeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            groupSizeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            groupSizeTextField.topAnchor.constraint(equalTo: groupSizeLabel.bottomAnchor, constant: 10),
            groupSizeTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            groupSizeTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            groupSizeTextField.heightAnchor.constraint(equalToConstant: 40),

            // Factor
            infectionFactorLabel.topAnchor.constraint(equalTo: groupSizeTextField.bottomAnchor, constant: 20),
            infectionFactorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            infectionFactorTextField.topAnchor.constraint(equalTo: groupSizeTextField.bottomAnchor, constant: 20),
            infectionFactorTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            minFactorLabel.topAnchor.constraint(equalTo: infectionFactorLabel.bottomAnchor, constant: 20),
            minFactorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            maxFactorLabel.topAnchor.constraint(equalTo: infectionFactorLabel.bottomAnchor, constant: 20),
            maxFactorLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            infectionFactorSlider.topAnchor.constraint(equalTo: infectionFactorLabel.bottomAnchor, constant: 10),
            infectionFactorSlider.leadingAnchor.constraint(equalTo: minFactorLabel.trailingAnchor, constant: 8),
            infectionFactorSlider.trailingAnchor.constraint(equalTo: maxFactorLabel.leadingAnchor, constant: -8),
            infectionFactorSlider.heightAnchor.constraint(equalToConstant: 40),

            // Timer
            recalculationPeriodLabel.topAnchor.constraint(equalTo: infectionFactorSlider.bottomAnchor, constant: 20),
            recalculationPeriodLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            recalculationPeriodLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            recalculationPeriodTextField.topAnchor.constraint(equalTo: recalculationPeriodLabel.bottomAnchor, constant: 10),
            recalculationPeriodTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            recalculationPeriodTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            recalculationPeriodTextField.heightAnchor.constraint(equalToConstant: 40),

            startModulationButton.topAnchor.constraint(equalTo: recalculationPeriodTextField.bottomAnchor, constant: 30),
            startModulationButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            startModulationButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            startModulationButton.heightAnchor.constraint(equalToConstant: 40),

            // Alert Message
            alertMessage.topAnchor.constraint(equalTo: startModulationButton.bottomAnchor, constant: 10),
            alertMessage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            alertMessage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}
