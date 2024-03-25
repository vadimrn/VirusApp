import Foundation

final class MatrixHelper {
    static let shared: MatrixHelper = .init()

    /**
     Этот метод генерирует правильную  матрицу логических значений с заданным размером.
     Матрица будет иметь указанное количество строк и столбцов, где каждый элемент изначально установлен в значение false (ложь).
     */
    func makeMatrix(_ number: Int) -> [[Bool]] {
        let rows = sqrt(Double(number))
        let columns = sqrt(Double(number))
        return Array(repeating: Array(repeating: false,
                                      count: Int(columns)),
                     count: Int(rows))
    }
}
