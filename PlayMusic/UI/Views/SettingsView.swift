import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var sleepTimer = SleepTimerManager.shared
    @ObservedObject var cacheService = AudioCacheService.shared
    @ObservedObject var player = AudioPlayerManager.shared
    @ObservedObject var eqManager = EqualizerManager.shared
    
    @AppStorage("audio_quality_preference") private var audioQuality: String = "High"
    @AppStorage("crossfade_seconds") private var crossfadeSeconds: Double = 4.0
    @State private var showClearCacheAlert: Bool = false

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Pengaturan")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 16)

                    // Appearance Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TAMPILAN")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        HStack(spacing: 10) {
                            ForEach(AppTheme.allCases) { theme in
                                let isSelected = themeManager.selectedTheme == theme
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        themeManager.selectedTheme = theme
                                    }
                                }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: themeIcon(theme))
                                            .font(.system(size: 20))
                                        Text(theme.rawValue)
                                            .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                                    }
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                                    )
                                }
                            }
                        }
                    }

                    // Automix & Crossfade
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("AUTOMIX & CROSSFADE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .tracking(1.2)
                            Spacer()
                            Text(crossfadeSeconds == 0 ? "Nonaktif" : "\(Int(crossfadeSeconds)) detik")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.blue)
                        }

                        VStack(spacing: 8) {
                            Slider(value: $crossfadeSeconds, in: 0...12, step: 1) { _ in
                                player.crossfadeDuration = crossfadeSeconds
                            }
                            .accentColor(.blue)

                            HStack {
                                Text("0s (Cut)")
                                Spacer()
                                Text("6s (Seimbang)")
                                Spacer()
                                Text("12s (Maks)")
                            }
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }

                    // Sleep Timer Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PENGATUR WAKTU TIDUR")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        if sleepTimer.isTimerActive {
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(.blue)
                                Text("Musik berhenti dalam \(sleepTimer.formattedTime)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                                Button("Batalkan") {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    sleepTimer.cancelTimer()
                                }
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                        } else {
                            HStack(spacing: 8) {
                                ForEach([15, 30, 45, 60], id: \.self) { minutes in
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        sleepTimer.startTimer(minutes: minutes)
                                    }) {
                                        Text("\(minutes)m")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(Color(UIColor.secondarySystemBackground))
                                            )
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }

                    // Audio Quality
                    VStack(alignment: .leading, spacing: 10) {
                        Text("KUALITAS AUDIO")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        HStack(spacing: 10) {
                            ForEach(["Low", "Normal", "High"], id: \.self) { quality in
                                let isSelected = audioQuality == quality
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        audioQuality = quality
                                    }
                                }) {
                                    Text(quality)
                                        .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                                        )
                                }
                            }
                        }
                    }

                    // Equalizer Presets
                    VStack(alignment: .leading, spacing: 10) {
                        Text("EQUALIZER (PRESET SUARA)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        VStack(spacing: 8) {
                            ForEach(AudioEqualizerPreset.allCases) { preset in
                                let isSelected = eqManager.selectedPreset == preset
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        eqManager.selectedPreset = preset
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(preset.rawValue)
                                                .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                                                .foregroundColor(.primary)
                                            Text(preset.description)
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if isSelected {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(isSelected ? Color.blue.opacity(0.12) : Color(UIColor.secondarySystemBackground))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                    // Storage & Cache
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PENYIMPANAN")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        Button(action: {
                            showClearCacheAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 15))
                                Text("Hapus Cache Audio Offline")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                Spacer()
                                Text(cacheService.getCacheSizeString())
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                        }
                        .alert("Hapus Cache Audio?", isPresented: $showClearCacheAlert) {
                            Button("Batal", role: .cancel) {}
                            Button("Hapus", role: .destructive) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                cacheService.clearCache()
                            }
                        } message: {
                            Text("Semua file audio lagu yang tersimpan di disk lokal akan dihapus.")
                        }
                    }

                    // App Info
                    VStack(alignment: .center, spacing: 4) {
                        Text("PlayMusic v1.0.0")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("Pure Swift & Apple Music Native HIG")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
    }

    private func themeIcon(_ theme: AppTheme) -> String {
        switch theme {
        case .system: return "iphone"
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        }
    }
}
