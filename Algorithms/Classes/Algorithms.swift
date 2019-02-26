import Foundation

public protocol EEGDataDelegate {
    func eeg(sample: Int) -> Void
    func attention(sample: Int) -> Void
    func meditation(sample: Int) -> Void
}

public protocol AggregatedEEGDataDelegate {
    func attentionAverage(_ average: Double)
    func meditationAverage(_ average: Double)
}

public protocol EEGEventDelegate {
    func attentionSignature() -> Void
    func meditationSignature() -> Void
}
public class PrintAggregatedDataDelegate: AggregatedEEGDataDelegate {
    public func attentionAverage(_ average: Double) {
        print("attention average– \(average)")
    }
    
    public func meditationAverage(_ average: Double) {
        print("meditationAverage average– \(average)")
    }
}

public class PrintSignatureDelegate: EEGEventDelegate {
    public func attentionSignature() {
        print("attention signature!")
    }
    
    public func meditationSignature() {
        print("meditationSignature signature!")
    }
    
    public init(){
        
    }
    
}

extension CountableRange where Bound == Int {
    var random: Int {
        return lowerBound + Int(arc4random_uniform(UInt32(count)))
    }
    func random(_ n: Int) -> [Int] {
        return (0..<n).map { _ in random }
    }
}

extension CountableClosedRange where Bound == Int {
    var random: Int {
        return lowerBound + Int(arc4random_uniform(UInt32(count)))
    }
    func random(_ n: Int) -> [Int] {
        return (0..<n).map { _ in random }
    }
}

public class RandomData {
    
    static let rawRange: ClosedRange<Int> = (-10000...10000)
    static let attentionRange: ClosedRange<Int> = (0...100)
    static let meditationRange: ClosedRange<Int> = (0...100)
    
    var delegate: EEGDataDelegate?
    let rawtimer, attentionTimer, meditationTimer: Timer
    
    @available(iOS 10.0, *)
    public init(
        rawFrequency: Double,
        attentionFrequency: Double,
        meditationFrequency: Double,
        delegate: EEGDataDelegate? = nil){
        self.delegate = delegate
        let rawPeriod = 1.0/rawFrequency
        self.rawtimer = Timer.scheduledTimer(
            withTimeInterval: rawPeriod,
            repeats: true,
            block: { (timer) in
                delegate?.eeg(sample: RandomData.rawRange.random)
            }
        )
        
        let attentionPeriod = 1.0/attentionFrequency
        self.attentionTimer = Timer.scheduledTimer(
            withTimeInterval: attentionPeriod,
            repeats: true,
            block: { (timer) in
                delegate?.attention(sample: RandomData.attentionRange.random)
            }
        )
        
        let meditationPeriod = 1.0/meditationFrequency
        self.meditationTimer = Timer.scheduledTimer(
            withTimeInterval: meditationPeriod,
            repeats: true,
            block: { (timer) in
                delegate?.meditation(sample: RandomData.meditationRange.random)
            }
        )
    }
}

public class EEGEventRange: EEGDataDelegate, AggregatedEEGDataDelegate {
    
    static var aggregateCount: Int = 10
    
    let eegEventDelegate: EEGEventDelegate
    let attentionRange: ClosedRange<Double>
    let meditationRange: ClosedRange<Double>
    
    public init(
        eegEventDelegate: EEGEventDelegate,
        attentionRange: ClosedRange<Double>,
        meditationRange: ClosedRange<Double>) {
        self.eegEventDelegate = eegEventDelegate
        self.attentionRange = attentionRange
        self.meditationRange = meditationRange
    }
    
    enum EEGMetric {
        case attention
        case meditation
    }
    
    var samples: [EEGMetric: [Int]] = [
        .attention: [],
        .meditation: []
    ]
    
    func reduceBySum (result: inout Int, value: Int) {
        result += value
    }
    
    func appendAndAverage(sample: Int, bucket: inout [Int], averageDelegate: ((Double) -> Any?)?) {
        while bucket.count >= EEGEventRange.aggregateCount {
            bucket.removeFirst()
        }
        
        bucket.append(sample)
        
        if bucket.count >= EEGEventRange.aggregateCount {
            let sum = Double(bucket.reduce(into: 0, reduceBySum))
            let average = sum / Double(EEGEventRange.aggregateCount)
            _ = averageDelegate?(average)
        }
    }
    
    public func eeg(sample: Int) {
        print("eeg– \(sample)")
    }
    
    public func attention(sample: Int) {
        print("attention– \(sample)")
        appendAndAverage(
            sample: sample,
            bucket: &samples[.attention]!,
            averageDelegate: attentionAverage)
    }
    
    public func meditation(sample: Int) {
        print("meditation– \(sample)")
        appendAndAverage(
            sample: sample,
            bucket: &samples[.meditation]!,
            averageDelegate: meditationAverage)
    }
    
    public func attentionAverage(_ average: Double) {
        if attentionRange ~= average {
            eegEventDelegate.attentionSignature()
        }
    }
    
    public func meditationAverage(_ average: Double) {
        if meditationRange ~= average {
            eegEventDelegate.meditationSignature()
        }
    }
    
}
