import SwiftUI

struct AlarmListView: View {
    @EnvironmentObject private var viewModel: AlarmViewModel
    @State private var showAddAlarm = false
    @State private var alarmToEdit: Alarm?

    var body: some View {
        NavigationView {
            Group {
                if viewModel.alarms.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.alarms) { alarm in
                            AlarmRowView(alarm: alarm)
                                .contentShape(Rectangle())
                                .onTapGesture { alarmToEdit = alarm }
                        }
                        .onDelete(perform: viewModel.deleteAlarms)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("AlarmBrew")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddAlarm = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddAlarm) {
                AddAlarmView().environmentObject(viewModel)
            }
            .sheet(item: $alarmToEdit) { alarm in
                AddAlarmView(alarm: alarm).environmentObject(viewModel)
            }
        }
        .navigationViewStyle(.stack)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("No Alarms")
                .font(.title2.weight(.semibold))
            Text("Tap \(Image(systemName: "plus")) to add an alarm.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Row

struct AlarmRowView: View {
    @EnvironmentObject private var viewModel: AlarmViewModel
    let alarm: Alarm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(alarm.formattedTime)
                    .font(.system(size: 36, weight: .thin, design: .rounded))
                if !alarm.label.isEmpty {
                    Text(alarm.label)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text(alarm.repeatDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in viewModel.toggleAlarm(alarm) }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
