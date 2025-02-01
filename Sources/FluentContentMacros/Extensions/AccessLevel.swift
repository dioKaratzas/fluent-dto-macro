import FluentContentMacroShared

extension AccessLevel {
    func resolvedAccessLevel(modelAccess: String) -> String {
        switch self {
        case .matchModel:
            modelAccess
        case .public:
            "public"
        case .internal:
            "internal"
        case .fileprivate:
            "fileprivate"
        case .private:
            "private"
        }
    }
}
