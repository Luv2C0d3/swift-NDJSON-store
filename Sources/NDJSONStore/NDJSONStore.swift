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

    public init(fileURL: URL, keyExtractor: @escaping (V) -> K) {
        self.fileURL = fileURL
        self.keyExtractor = keyExtractor

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }

        let reader = NDJSONFileReader(fileURL: fileURL)
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

    public func close() {
        // For now, no-op. Placeholder for future flush or locking if needed.
    }
}

// MARK: - Internal: NDJSON Encoder

struct NDJSONEncoder {
    private let encoder = JSONEncoder()

    func serialize<T: Encodable>(_ value: T) throws -> String {
        let data = try encoder.encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: [],
                debugDescription: "Failed to encode string from JSON"
            ))
        }
        return string
    }
}

// MARK: - Internal: NDJSON Decoder

struct NDJSONDecoder {
    private let decoder = JSONDecoder()

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

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func readAllToDictionary<T: Decodable, K: Hashable>(keyExtractor: (T) -> K) throws -> [K: T] {
        var result: [K: T] = [:]
        let decoder = NDJSONDecoder()

        let content = try String(contentsOf: fileURL, encoding: .utf8)
        for line in content.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let object: T = try decoder.decodeLine(String(trimmed))
            let key = keyExtractor(object)
            result[key] = object
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

    deinit {
        try? fileHandle.close()
    }

    func write<T: Encodable>(_ value: T) throws {
        let jsonLine = try encoder.serialize(value) + "\n"
        guard let data = jsonLine.data(using: .utf8) else { return }
        fileHandle.write(data)
    }
}

