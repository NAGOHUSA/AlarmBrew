import SwiftUI
import UIKit

/// Full-screen view shown when an alarm fires.
/// The user must take a photo of their coffee maker to dismiss it.
struct ActiveAlarmView: View {
    let alarmUserInfo: [AnyHashable: Any]?
    let onDismiss: () -> Void

    @EnvironmentObject private var viewModel: AlarmViewModel
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var analysisResult: AnalysisResult?
    @State private var isAnalyzing = false
    @State private var pulse = false

    private var matchedAlarm: Alarm? {
        guard
            let idStr = alarmUserInfo?["alarmId"] as? String,
            let id = UUID(uuidString: idStr)
        else { return nil }
        return viewModel.alarms.first { $0.id == id }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                clockSection
                Spacer()
                challengeSection
                    .padding(.horizontal, 24)
                Spacer()
            }
        }
        .onAppear {
            pulse = true
            viewModel.startAlarmSound()
        }
        .onDisappear {
            viewModel.stopAlarmSound()
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(image: $capturedImage)
        }
        .onChange(of: capturedImage) { img in
            if let img { analyzeImage(img) }
        }
    }

    // MARK: - Sub-views

    private var clockSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 52))
                .foregroundColor(.orange)
                .scaleEffect(pulse ? 1.15 : 1.0)
                .animation(
                    .easeInOut(duration: 0.65).repeatForever(autoreverses: true),
                    value: pulse)

            Text(currentTime)
                .font(.system(size: 76, weight: .thin, design: .rounded))
                .foregroundColor(.white)

            if let label = matchedAlarm?.label, !label.isEmpty {
                Text(label)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.75))
            }
        }
    }

    @ViewBuilder
    private var challengeSection: some View {
        if let image = capturedImage {
            capturedSection(image: image)
        } else {
            promptSection
        }
    }

    private var promptSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.orange)
                Text("To dismiss this alarm,")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("take a photo of your coffee maker")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            cameraButton
        }
    }

    private func capturedSection(image: UIImage) -> some View {
        VStack(spacing: 16) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 220, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(borderColor, lineWidth: 3)
                )

            if isAnalyzing {
                HStack(spacing: 8) {
                    ProgressView().tint(.white)
                    Text("Analyzing image…")
                        .foregroundColor(.white)
                }
            } else if let result = analysisResult {
                resultView(result)
            }
        }
    }

    private func resultView(_ result: AnalysisResult) -> some View {
        VStack(spacing: 12) {
            Image(systemName: result.found
                  ? "checkmark.circle.fill"
                  : "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(result.found ? .green : .red)

            Text(result.message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            if !result.found {
                Button {
                    capturedImage = nil
                    analysisResult = nil
                    showCamera = true
                } label: {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 180, height: 50)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var cameraButton: some View {
        Button { showCamera = true } label: {
            Label("Take Photo", systemImage: "camera.fill")
                .font(.headline)
                .foregroundColor(.black)
                .frame(width: 210, height: 54)
                .background(Color.orange)
                .clipShape(Capsule())
        }
    }

    // MARK: - Helpers

    private var currentTime: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: Date())
    }

    private var borderColor: Color {
        guard let r = analysisResult else { return .clear }
        return r.found ? .green : .red
    }

    private func analyzeImage(_ image: UIImage) {
        isAnalyzing = true
        analysisResult = nil
        ImageRecognitionService.shared.detectCoffeeMaker(in: image) { found, message in
            isAnalyzing = false
            analysisResult = AnalysisResult(found: found, message: message)
            if found {
                viewModel.stopAlarmSound()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Supporting type

struct AnalysisResult {
    let found: Bool
    let message: String
}
