import Foundation

// MARK: - Network Error

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case encodingError(Error)
    case decodingError(Error)
    case httpError(Int)
    case serverError(Int)
    case unauthorized
    case notFound
    case conflict
    case networkUnavailable
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный адрес сервера"
        case .invalidResponse:
            return "Получен некорректный ответ от сервера"
        case .encodingError:
            return "Ошибка подготовки данных"
        case .decodingError:
            return "Ошибка обработки ответа сервера"
        case .httpError(let code):
            return userFriendlyMessage(for: code)
        case .serverError:
            return "Сервер временно недоступен. Попробуйте позже"
        case .unauthorized:
            return "Необходима авторизация"
        case .notFound:
            return "Запрашиваемые данные не найдены"
        case .conflict:
            return "Данные уже существуют"
        case .networkUnavailable:
            return "Нет подключения к интернету"
        case .timeout:
            return "Превышено время ожидания ответа"
        case .unknown:
            return "Произошла неизвестная ошибка"
        }
    }
    
    private func userFriendlyMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "Некорректный запрос"
        case 403:
            return "Доступ запрещен"
        case 404:
            return "Данные не найдены"
        case 409:
            return "Конфликт данных"
        case 422:
            return "Данные не прошли проверку"
        case 429:
            return "Слишком много запросов. Попробуйте позже"
        default:
            return "Ошибка при выполнении запроса"
        }
    }
}
