import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    private var queryAnchor: HKQueryAnchor?

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [heartRateType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: completion)
    }

    func startHeartRateQuery(completion: @escaping (HKQuantitySample) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        // Observer Query to trigger updates
        let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("ObserverQuery error: \(error.localizedDescription)")
                return
            }
            
            self.fetchLatestHeartRateSample(completion: completion)
            completionHandler()
        }

        healthStore.execute(observerQuery)
        fetchLatestHeartRateSample(completion: completion)
    }
    
    private func fetchLatestHeartRateSample(completion: @escaping (HKQuantitySample) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let anchoredQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: queryAnchor, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, newAnchor, error in
            if let error = error {
                print("AnchoredObjectQuery error: \(error.localizedDescription)")
                return
            }
            
            self.queryAnchor = newAnchor
            guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
            if let latestSample = heartRateSamples.last {
                completion(latestSample)
            }
        }
        
        healthStore.execute(anchoredQuery)
    }
}
