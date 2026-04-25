import SwiftUI

struct AddAlarmView: View {
    @EnvironmentObject private var viewModel: AlarmViewModel
    @Environment(\.dismiss) private var dismiss

    // Existing alarm being edited (nil = new alarm)
    private let existingAlarm: Alarm?

    @State private var time: Date
    @State private var label: String
    @State private var selectedDays: Set<Int>

    private let dayLetters    = ["S", "M", "T", "W", "T", "F", "S"]

    init(alarm: Alarm? = nil) {
        existingAlarm = alarm
        _time         = State(initialValue: alarm?.time ?? Alarm.defaultWakeTime())
        _label        = State(initialValue: alarm?.label ?? "")
        _selectedDays = State(initialValue: Set(alarm?.repeatDays ?? []))
    }

    var body: some View {
        NavigationView {
            Form {
                // Time picker
                Section {
                    DatePicker(
                        "Wake Time",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                }

                // Label
                Section("Label") {
                    TextField("Alarm label (optional)", text: $label)
                }

                // Repeat days
                Section("Repeat") {
                    HStack(spacing: 6) {
                        ForEach(0..<7) { i in
                            let day = i + 1      // 1 = Sun … 7 = Sat
                            Button {
                                if selectedDays.contains(day) {
                                    selectedDays.remove(day)
                                } else {
                                    selectedDays.insert(day)
                                }
                            } label: {
                                Text(dayLetters[i])
                                    .font(.system(size: 13, weight: .semibold))
                                    .frame(width: 38, height: 38)
                                    .background(
                                        selectedDays.contains(day)
                                            ? Color.accentColor
                                            : Color(.systemGray5)
                                    )
                                    .foregroundColor(
                                        selectedDays.contains(day) ? .white : .primary
                                    )
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Coffee-maker challenge info
                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Coffee Maker Challenge")
                                .font(.subheadline.weight(.medium))
                            Text("Take a photo of your coffee maker to dismiss.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.accentColor)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(existingAlarm == nil ? "New Alarm" : "Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        var alarm = existingAlarm ?? Alarm()
        alarm.time = time
        alarm.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
        alarm.repeatDays = Array(selectedDays).sorted()
        alarm.isEnabled = true
        if existingAlarm != nil {
            viewModel.updateAlarm(alarm)
        } else {
            viewModel.addAlarm(alarm)
        }
        dismiss()
    }
}
