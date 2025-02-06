#if canImport(Vapor)
    import Vapor

    public typealias CodableDTO = DTO
#else
    public typealias CodableDTO = Codable
#endif
