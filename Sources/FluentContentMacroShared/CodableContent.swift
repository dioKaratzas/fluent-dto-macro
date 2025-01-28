#if canImport(Vapor)
    import Vapor

    public typealias CodableContent = Content
#else
    public typealias CodableContent = Codable
#endif
