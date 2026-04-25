import Vision
import UIKit

/// Uses Apple's on-device Vision classifier to detect whether an image
/// contains a coffee maker / coffee pot.
final class ImageRecognitionService {
    static let shared = ImageRecognitionService()
    private init() {}

    // MARK: - Public

    /// Asynchronously analyses `image` and returns `(success, message)` on
    /// the **main** thread.
    func detectCoffeeMaker(
        in image: UIImage,
        completion: @escaping (_ found: Bool, _ message: String) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                completion(false, "Could not read image data. Please try again.")
            }
            return
        }

        let request = VNClassifyImageRequest { [weak self] req, error in
            guard let self else { return }
            if let error {
                DispatchQueue.main.async {
                    completion(false, "Recognition error: \(error.localizedDescription)")
                }
                return
            }
            guard let obs = req.results as? [VNClassificationObservation],
                  !obs.isEmpty else {
                DispatchQueue.main.async {
                    completion(false, "No results from analyser. Please try again.")
                }
                return
            }
            let result = self.evaluate(observations: obs)
            DispatchQueue.main.async { completion(result.found, result.message) }
        }

        let orientation = cgImageOrientation(from: image)
        let handler = VNImageRequestHandler(
            cgImage: cgImage, orientation: orientation, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(false, "Analysis failed. Please try again.")
                }
            }
        }
    }

    // MARK: - Private

    private let coffeeTerms: Set<String> = [
        "coffee", "espresso", "cappuccino", "latte", "mocha",
        "coffeemaker", "coffee maker", "coffee machine", "coffee pot",
        "coffeepot", "percolator", "french press", "french_press",
        "moka pot", "moka", "drip coffee", "pour over", "aeropress",
        "keurig", "nespresso", "barista", "carafe",
        "kettle", "hot drink", "hot beverage", "beverage maker"
    ]

    private func evaluate(
        observations: [VNClassificationObservation]
    ) -> (found: Bool, message: String) {
        for obs in observations.prefix(20) {
            guard obs.confidence > 0.05 else { break }
            let id = obs.identifier.lowercased()
            for term in coffeeTerms where id.contains(term) {
                let pct = Int(obs.confidence * 100)
                return (true, "☕ Coffee maker detected! (\(pct)% confidence)")
            }
        }
        let topLabel = observations.first?.identifier ?? "unknown"
        return (
            false,
            "No coffee maker detected.\nI see: \(topLabel)\nPlease point at your coffee maker."
        )
    }

    private func cgImageOrientation(from image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up:           return .up
        case .down:         return .down
        case .left:         return .left
        case .right:        return .right
        case .upMirrored:   return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:   return .up
        }
    }
}
