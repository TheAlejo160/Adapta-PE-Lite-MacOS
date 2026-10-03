import AppKit
import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var voice: VoiceManager
    @ObservedObject private var filter: ColorFilterManager
    @ObservedObject private var actions: ActionManager
    @AppStorage("WakeWord") private var wakeWord = "computadora"
    @State private var section = "Voz"

    init(model: AppModel) {
        self.model = model; voice = model.voice; filter = model.colorFilter; actions = model.actions
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("FondoApp").resizable().scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height).clipped()
                    .overlay(Color.black.opacity(0.5))
            }.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    Image("LiteLogo").resizable().scaledToFit().frame(width: 76, height: 76).accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Adapta PE Lite").font(.largeTitle.bold())
                        Text("Tu voz. Tus colores.").font(.body)
                    }.foregroundStyle(.white)
                    Spacer()
                    Button("Panel flotante", systemImage: "pip") { model.showFloating() }
                }
                VStack(alignment: .leading, spacing: 18) {
                    Picker("Función", selection: $section) {
                        Text("Asistente de voz").tag("Voz")
                        Text("Daltonismo").tag("Color")
                    }.pickerStyle(.segmented).labelsHidden()
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            if section == "Voz" { voiceSettings } else { colorSettings }
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(2)
                    }
                    Divider()
                    HStack {
                        Text("Cerrar ajustes mantiene la asistencia en segundo plano.")
                            .font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Button(role: .destructive, action: { model.stopAll() }) {
                            Label("Detener todo", systemImage: "stop.circle")
                        }
                    }
                }.padding(20).background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 18))
            }.padding(22)
        }.frame(minWidth: 580, minHeight: 620).font(.system(size: 16))
            .buttonStyle(AccessibleButtonStyle()).tint(Color(red: 0.04, green: 0.26, blue: 0.60))
    }

    private var voiceSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Controla tu Mac con la voz").font(.title2.bold())
            Toggle(isOn: Binding(get: { voice.isListening || voice.isStarting }, set: { $0 ? voice.startListening() : voice.stopListening() })) {
                Label("Asistente de voz", systemImage: "mic")
                Text(voice.status).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }.toggleStyle(.switch).frame(minHeight: 44).accessibilityLabel("Control por voz").accessibilityValue(voice.status)
            Text("Di «\(wakeWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "computadora" : wakeWord), abre Zoom». Si dices sólo el nombre, espera la señal y da la orden en 8 segundos.")
                .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            if !voice.transcript.isEmpty {
                Text("Escuché: " + voice.transcript).font(.callout).lineLimit(3).textSelection(.enabled)
            }
            Text(actions.lastResponse).font(.callout).foregroundStyle(.secondary).textSelection(.enabled)
            if !model.accessibilityGranted {
                Button("Permitir control del escritorio", systemImage: "hand.raised") { model.requestAccessibility() }
                Text("Accesibilidad permite pulsar, escribir y leer elementos de otras aplicaciones.")
                    .font(.callout).foregroundStyle(.secondary)
            }
            if AVCaptureDevice.authorizationStatus(for: .audio) == .denied {
                Button("Revisar permiso del micrófono") { model.openPrivacy("Microphone") }
            }
            if SFSpeechRecognizer.authorizationStatus() == .denied {
                Button("Revisar reconocimiento de voz") { model.openPrivacy("SpeechRecognition") }
            }
            Divider()
            DisclosureGroup("Micrófono y preferencias") {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Micrófono", selection: $voice.selectedMicID) {
                        if voice.availableMics.isEmpty { Text("Sin micrófono").tag("") }
                        ForEach(voice.availableMics, id: \.uniqueID) { Text($0.localizedName).tag($0.uniqueID) }
                    }
                    TextField("Nombre para llamar al asistente", text: $wakeWord)
                        .textFieldStyle(.roundedBorder).accessibilityLabel("Palabra de activación")
                    Toggle("Permitir reconocimiento de Apple por red", isOn: $voice.allowAppleNetwork)
                    Text("Apagado: reconocimiento local. Encendido: Apple puede procesar audio por red.")
                        .font(.callout).foregroundStyle(.secondary)
                    Toggle("Iniciar al encender el Mac", isOn: Binding(get: { model.loginEnabled }, set: model.setLogin))
                    Button("Actualizar dispositivos y permisos") { model.refreshPermissions() }
                    if !model.notice.isEmpty { Text(model.notice).foregroundStyle(.secondary) }
                }.padding(.top, 12)
            }
            DisclosureGroup("Comandos y ayuda") {
                VStack(alignment: .leading, spacing: 14) {
                    Text("«Abre YouTube» / «Busca movilidad en Wikipedia»\n«Abre Chrome en nueva ventana» / «Cierra pestaña»\n«Escribe Hola, José» / «Enfoca buscar»\n«Presiona comando shift N» / «Guardar»\n«Selecciona Contacto» / «Pulsa lo seleccionado»\n«Clic derecho» / «Lee la pantalla»\n«Filtro deuteranopía» / «Quitar filtro»\n«Mostrar ajustes» / «Modo flotante» / «Detener todo»")
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Acciones de la app activa") { actions.procesarIntencion("muestra comandos") }
                    Button("Buscar campos de texto") { actions.procesarIntencion("muestra campos") }
                    Text("Ante varias opciones, responde con el número, su nombre, «siguiente» o «cancelar». La lectura depende de los elementos accesibles de cada app. Los campos protegidos quedan excluidos.")
                        .font(.callout).foregroundStyle(.secondary)
                }.padding(.top, 12)
            }
        }
    }

    private var colorSettings: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Filtros de daltonismo").font(.title2.bold())
            Picker("Filtro de pantalla", selection: Binding(get: { filter.selected }, set: { filter.apply($0) })) {
                ForEach(ColorFilter.allCases) { Text($0.title).tag($0) }
            }
            if filter.isStarting { ProgressView("Preparando filtro…") }
            Text(filter.status).foregroundStyle(.secondary)
            HStack(spacing: 0) {
                ForEach(Array([Color.red, .green, .blue, .yellow, .purple, .orange].enumerated()), id: \.offset) { _, color in
                    color.frame(height: 44)
                }
            }.clipShape(RoundedRectangle(cornerRadius: 8)).accessibilityLabel("Referencia de colores originales; la interfaz de Lite queda fuera del filtro")
            Text("Aplica las siete matrices de la extensión Lite a tus pantallas. Procesamiento local, sin guardar ni enviar imágenes.")
                .fixedSize(horizontal: false, vertical: true)
            Text("Requiere Grabación de pantalla. Adapta PE Lite queda fuera del filtro para que puedas desactivarlo. Las matrices simulan alteraciones de color; no son una corrección médica.")
                .font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            Button("Quitar filtro", systemImage: "eye") { filter.stop() }.disabled(filter.selected == .ninguno)
            Button("Permiso de Grabación de pantalla") { model.openPrivacy("ScreenCapture") }
            Text("También puedes decir «computadora, filtro protanopía» o «computadora, quitar filtro».")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
}

#Preview { ContentView(model: .shared) }
