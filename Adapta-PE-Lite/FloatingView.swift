import SwiftUI
import AppKit

struct FloatingView: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var filter: ColorFilterManager
    @ObservedObject private var mascot: MascotManager
    @ObservedObject private var voice: VoiceManager
    @ObservedObject private var actions: ActionManager
    init(model: AppModel) { self.model = model; mascot = model.mascot; filter = model.colorFilter; voice = model.voice; actions = model.actions }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                PanelDragHandle(title: "Adapta PE Lite", move: { mascot.touch(); model.moveFloating($0) }, save: model.saveFloatingPosition).frame(height: 44)
                Spacer()
                Menu {
                    Toggle("Mover mascota y panel juntos", isOn: Binding(get: { mascot.linked }, set: { mascot.linked = $0 })).disabled(mascot.name == "ninguna")
                    Menu("Elegir mascota") {
                        ForEach(MascotManager.names, id: \.self) { name in
                            Button(MascotManager.titles[MascotManager.names.firstIndex(of: name)!]) { mascot.choose(name) }
                        }
                    }
                    Menu("Filtro de pantalla") {
                        ForEach(ColorFilter.allCases) { filter in Button { mascot.react("laptop"); model.colorFilter.apply(filter) } label: { Label(filter.title, systemImage: self.filter.selected == filter ? "checkmark" : "circle") } }
                    }
                    Divider()
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
                } label: { Text("Opciones").frame(minWidth: 44, minHeight: 44) }
                    .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize().accessibilityLabel("Opciones del panel").help("Mascota, filtros, posición y monitor")
                Button(action: model.showSettings) { Image(systemName: "gearshape").frame(width: 44, height: 44) }
                    .modifier(FloatingSettingsStyle()).accessibilityLabel("Abrir ajustes").help("Abrir ajustes")
            }
            HStack {
                Toggle("Voz", isOn: Binding(get: { voice.isListening || voice.isStarting }, set: { _ in model.toggleVoice() })).toggleStyle(.switch)
            }.frame(minHeight: 44)
            Text(voice.status + "\n" + (filter.selected == .ninguno ? filter.status : filter.selected.title + " · " + filter.status))
                .font(.callout).foregroundStyle(.primary).lineLimit(2).frame(height: 40, alignment: .leading).help(filter.status)
            Text(voice.transcript.isEmpty ? "Aquí verás lo que escuché" : "Escuché: " + voice.transcript)
                .font(.callout).lineLimit(2).frame(maxWidth: .infinity, minHeight: 32, alignment: .leading).accessibilityLabel("Último comando escuchado: " + voice.transcript)
            if actions.choices.isEmpty {
                Text(actions.lastResponse).font(.callout).foregroundStyle(.primary).lineLimit(2).frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
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
    @Environment(\.isFocused) private var isFocused
    func makeBody(configuration: Configuration) -> some View {
        let fill = configuration.role == .destructive ? Color(red: 0.65, green: 0.10, blue: 0.13) : Color(red: 0.04, green: 0.26, blue: 0.60)
        configuration.label.font(.system(size: 16, weight: .semibold))
            .padding(.horizontal, 12).frame(minWidth: 44, minHeight: 44)
            .foregroundStyle(isEnabled ? Color.white : Color(red: 0.32, green: 0.34, blue: 0.37))
            .background(isEnabled ? fill : Color(red: 0.86, green: 0.88, blue: 0.90), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).inset(by: 3).strokeBorder(Color.white, lineWidth: isFocused ? 2 : 0))
            .contentShape(RoundedRectangle(cornerRadius: 8)).opacity(configuration.isPressed ? 0.85 : 1)
    }
}


private struct FloatingSettingsStyle: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ViewBuilder func body(content: Content) -> some View {
        if #available(macOS 26, *), !reduceTransparency { content.buttonStyle(.glass) }
        else { content.buttonStyle(.plain) }
    }
}

private struct PanelDragHandle: NSViewRepresentable {
    let title: String
    let move: (CGPoint) -> Void
    let save: () -> Void
    func makeNSView(context: Context) -> PanelDragButton {
        let button = PanelDragButton(title: title, target: nil, action: nil)
        button.isBordered = false; button.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setAccessibilityLabel(title + ": arrastra para mover el panel; enfoca y usa las flechas")
        button.toolTip = "Arrastra para mover. Con teclado: flechas."
        button.move = move; button.save = save; return button
    }
    func updateNSView(_ button: PanelDragButton, context: Context) { button.move = move; button.save = save }
}

private final class PanelDragButton: NSButton {
    override var needsPanelToBecomeKey: Bool { true }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .openHand) }
    var move: ((CGPoint) -> Void)?
    var save: (() -> Void)?
    override func mouseDown(with event: NSEvent) { window?.makeKey(); window?.makeFirstResponder(self) }
    override func mouseDragged(with event: NSEvent) { move?(CGPoint(x: event.deltaX, y: -event.deltaY)) }
    override func mouseUp(with event: NSEvent) { save?() }
    override func keyDown(with event: NSEvent) {
        let moves: [UInt16: CGPoint] = [123: CGPoint(x: -24, y: 0), 124: CGPoint(x: 24, y: 0), 125: CGPoint(x: 0, y: -24), 126: CGPoint(x: 0, y: 24)]
        if let delta = moves[event.keyCode] { move?(delta); save?() } else { super.keyDown(with: event) }
    }
}
