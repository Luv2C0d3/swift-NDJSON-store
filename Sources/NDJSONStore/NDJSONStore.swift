import Foundation

// MARK: - Public Protocol

public protocol NDJSONIdentifiable {
    var ndjsonKey: String { get }
}

// MARK: - Public Store Class

public final class NDJSONStore<K: Hashable, V: Codable & NDJSONIdentifiable> {
    private var fileURL: URL
    private var keyExtractor: (V) -> K
    private var map: [K: V] = [:]
    private let writer: NDJSONFileWriter
    private let useDefaultDecodingStrategy: Bool  // <-- Add flag here

    public init(fileURL: URL, keyExtractor: @escaping (V) -> K, useDefaultDecodingStrategy: Bool = true) {
        self.fileURL = fileURL
        self.keyExtractor = keyExtractor
        self.useDefaultDecodingStrategy = useDefaultDecodingStrategy

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }

        // Pass the flag down to the reader
        let reader = NDJSONFileReader(fileURL: fileURL, useDefaultDecodingStrategy: useDefaultDecodingStrategy)
        self.map = (try? reader.readAllToDictionary(keyExtractor: keyExtractor)) ?? [:]
        self.writer = NDJSONFileWriter(fileURL: fileURL)
    }

    public func get(_ key: K) -> V? {
        return map[key]
    }

    public func set(_ value: V) {
        let key = keyExtractor(value)
        map[key] = value
        try? writer.write(value)
    }

    public func flush() throws {
        try writer.flush()
    }

    public func close() throws {
        try writer.close()
    }

    deinit {
        try? close()
    }
}

// MARK: - Internal: NDJSON Encoder

struct NDJSONEncoder {
    private let encoder: JSONEncoder

    init() {
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func serialize<T: Encodable>(_ value: T) throws -> String {
        let data = try encoder.encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Failed to encode string from JSON"
                ))
        }
        return string
    }
}

// MARK: - Internal: NDJSON Decoder

struct NDJSONDecoder {
    private let decoder: JSONDecoder

    init(useDefaultDecodingStrategy: Bool = true) {
        decoder = JSONDecoder()
        if useDefaultDecodingStrategy {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        } else {
            decoder.keyDecodingStrategy = .useDefaultKeys
        }
    }

    func decodeLine<T: Decodable>(_ line: String) throws -> T {
        guard let data = line.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Invalid UTF-8 line")
            )
        }
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - Internal: File Reader

final class NDJSONFileReader {
    private let fileURL: URL
    private let useDefaultDecodingStrategy: Bool  // <-- add flag

    init(fileURL: URL, useDefaultDecodingStrategy: Bool = true) {
        self.fileURL = fileURL
        self.useDefaultDecodingStrategy = useDefaultDecodingStrategy
    }

    func readAllToDictionary<T: Decodable, K: Hashable>(keyExtractor: (T) -> K) throws -> [K: T] {
        var result: [K: T] = [:]
        let decoder = NDJSONDecoder(useDefaultDecodingStrategy: useDefaultDecodingStrategy) // pass flag here

        let content = try String(contentsOf: fileURL, encoding: .utf8)
        for (index, line) in content.split(separator: "\n").enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            do {
                let object: T = try decoder.decodeLine(String(trimmed))
                let key = keyExtractor(object)
                result[key] = object
            } catch {
                throw NSError(
                    domain: "NDJSONFileReader", code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Failed to decode line \(index + 1): \(error)\nLine content: \(trimmed)"
                    ])
            }
        }

        return result
    }
}

// MARK: - Internal: File Writer

final class NDJSONFileWriter {
    private let fileHandle: FileHandle
    private let encoder = NDJSONEncoder()

    init(fileURL: URL) {
        guard let handle = try? FileHandle(forWritingTo: fileURL) else {
            fatalError("Could not open file at \(fileURL)")
        }
        self.fileHandle = handle
        fileHandle.seekToEndOfFile()
    }

    func flush() throws {
        try fileHandle.synchronize()  // flush OS buffers to disk
    }

    func close() throws {
        try fileHandle.synchronize()  // flush OS buffers to disk
        try fileHandle.close()  // close the file handle
    }

    deinit {
        try? close()
    }

    func write<T: Encodable>(_ value: T) throws {
        let jsonLine = try encoder.serialize(value) + "\n"
        guard let data = jsonLine.data(using: .utf8) else { return }
        fileHandle.write(data)
    }
}
