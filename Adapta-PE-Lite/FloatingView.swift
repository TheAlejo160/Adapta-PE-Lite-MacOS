import SwiftUI
import AppKit

struct FloatingView: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var voice: VoiceManager
    @ObservedObject private var actions: ActionManager
    init(model: AppModel) { self.model = model; voice = model.voice; actions = model.actions }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("Adapta PE Lite").font(.headline)
                Spacer()
                Menu {
                    ForEach(PanelCorner.allCases, id: \.self) { corner in
                        Button { model.floatingCorner = corner } label: {
                            Label(corner.title, systemImage: model.floatingCorner == corner ? "checkmark" : "square")
                        }
                    }
                    if model.screens.count > 1 {
                        Divider()
                        ForEach(Array(model.screens.enumerated()), id: \.offset) { index, screen in
                            Button("Monitor \(index + 1) · \(screen.localizedName)") { model.floatingScreenID = AppModel.screenID(screen) }
                        }
                    }
                } label: { Image(systemName: "arrow.up.left.and.arrow.down.right").frame(width: 44, height: 44) }
                    .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize().accessibilityLabel("Cambiar esquina del panel").help("Elegir esquina y monitor")
                Button(action: model.showSettings) { Image(systemName: "gearshape").frame(width: 44, height: 44) }
                    .buttonStyle(.plain).accessibilityLabel("Abrir ajustes").help("Abrir ajustes")
            }
            Text(voice.status)
                .font(.callout).foregroundStyle(.secondary).lineLimit(1).frame(height: 24, alignment: .leading)
            Text(voice.transcript.isEmpty ? "Aquí verás lo que escuché" : "Escuché: " + voice.transcript)
                .font(.callout).lineLimit(2).frame(maxWidth: .infinity, minHeight: 32, alignment: .leading).accessibilityLabel("Último comando escuchado: " + voice.transcript)
            if actions.choices.isEmpty {
                Text(actions.lastResponse).font(.callout).foregroundStyle(.secondary).lineLimit(2).frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Elige en " + actions.choiceContext).font(.headline).lineLimit(1)
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(actions.choices.enumerated()), id: \.offset) { index, label in
                                Button { actions.choose(String(index + 1)) } label: {
                                    Text("\(index + 1). \(label)").lineLimit(1).frame(maxWidth: .infinity, minHeight: 44, alignment: .leading).contentShape(Rectangle())
                                }.buttonStyle(.plain)
                            }
                        }
                    }.frame(minHeight: 44, maxHeight: CGFloat(actions.choices.count * 44))
                    HStack {
                        Button("Siguiente") { actions.choose("siguiente") }
                        Button("Cancelar") { actions.procesarIntencion("cancelar") }
                    }.frame(minHeight: 44)
                }
            }
            Button(role: .destructive, action: { model.stopAll() }) { Label("Detener todo", systemImage: "stop.circle").frame(maxWidth: .infinity) }.buttonStyle(AccessibleButtonStyle())
        }.padding(.horizontal, 16).padding(.vertical, 10).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 16))
            .font(.system(size: 16))
    }
}

// Superficie sólida y objetivo mínimo de 44 pt para ratón, cámara y navegación por teclado.
struct AccessibleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        let fill = configuration.role == .destructive ? Color(red: 0.65, green: 0.10, blue: 0.13) : Color(red: 0.04, green: 0.26, blue: 0.60)
        configuration.label.font(.system(size: 16, weight: .semibold))
            .padding(.horizontal, 12).frame(minWidth: 44, minHeight: 44)
            .foregroundStyle(isEnabled ? Color.white : Color(red: 0.32, green: 0.34, blue: 0.37))
            .background(isEnabled ? fill : Color(red: 0.86, green: 0.88, blue: 0.90), in: RoundedRectangle(cornerRadius: 8))
            .contentShape(RoundedRectangle(cornerRadius: 8)).opacity(configuration.isPressed ? 0.85 : 1)
    }
}
