import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [heartRateType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: completion)
    }

    func startHeartRateQuery(completion: @escaping (HKQuantitySample) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, newAnchor, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            samples?.forEach { sample in
                if let quantitySample = sample as? HKQuantitySample {
                    completion(quantitySample)
                }
            }
        }
        healthStore.execute(query)
    }
}
