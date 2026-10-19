import AppKit
import CoreServices
import XCTest
import Speech
@testable import Adapta_PE_Lite

final class LiteTests: XCTestCase {
    @MainActor func testInterrupcionesDeLecturaLleganAlEjecutor() {
        let actions = ActionManager.shared
        let accionAnterior = actions.appAction, salidaAnterior = actions.speechOutput
        defer { actions.callar(); actions.appAction = accionAnterior; actions.speechOutput = salidaAnterior }
        var accion: String?, hablando = true
        actions.appAction = { accion = $0 }
        actions.speechOutput = { hablando = $0 }
        for frase in ["para la lectura", "desactiva voz", "apaga el micrófono", "desactiva el micrófono", "por favor desactiva voz, pe"] {
            var entrada = VoiceInputState()
            let orden = entrada.consume("Computadora, " + frase, wakeWord: "computadora", time: 1, speaking: true).command
            XCTAssertNotNil(orden, frase)
            guard let orden else { continue }
            accion = nil; hablando = true
            actions.procesarIntencion(orden)
            XCTAssertFalse(hablando, frase)
            if frase == "para la lectura" {
                XCTAssertEqual(CommandParser.parse(orden), .silence)
                XCTAssertNil(accion, "Parar lectura conserva la escucha")
            } else { XCTAssertEqual(accion, "desactivar voz", frase) }
        }
    }

    @MainActor func testPermisoDeMicrofonoTardioNoSolicitaSpeech() async {
        let voz = VoiceManager()
        var resolverMicrofono: (@Sendable (Bool) -> Void)?
        var solicitudesSpeech = 0
        voz.solicitarMicrofono = { resolverMicrofono = $0 }
        voz.solicitarReconocimiento = { _ in solicitudesSpeech += 1 }
        voz.startListening()
        let resolverAnterior = resolverMicrofono
        XCTAssertTrue(voz.isStarting)
        voz.stopListening(remember: false)
        voz.startListening()
        resolverAnterior?(true)
        await withCheckedContinuation { continuacion in DispatchQueue.main.async { continuacion.resume() } }
        XCTAssertEqual(solicitudesSpeech, 0)
        XCTAssertTrue(voz.isStarting, "El permiso anterior no altera el nuevo inicio")
        voz.stopListening(remember: false)
        resolverMicrofono?(true)
        await withCheckedContinuation { continuacion in DispatchQueue.main.async { continuacion.resume() } }
        XCTAssertEqual(solicitudesSpeech, 0)
        XCTAssertFalse(voz.isStarting); XCTAssertFalse(voz.isListening)
        XCTAssertEqual(voz.status, "Micrófono apagado")
    }

    @MainActor func testPermisoSpeechTardioNoReiniciaLaEscucha() async {
        let voz = VoiceManager()
        var resolverSpeech: (@Sendable (SFSpeechRecognizerAuthorizationStatus) -> Void)?
        voz.solicitarMicrofono = { $0(true) }
        voz.solicitarReconocimiento = { XCTAssertTrue(Thread.isMainThread); resolverSpeech = $0 }
        voz.startListening()
        await withCheckedContinuation { continuacion in DispatchQueue.main.async { continuacion.resume() } }
        XCTAssertNotNil(resolverSpeech)
        voz.stopListening(remember: false)
        resolverSpeech?(.authorized)
        await withCheckedContinuation { continuacion in DispatchQueue.main.async { continuacion.resume() } }
        XCTAssertFalse(voz.isStarting); XCTAssertFalse(voz.isListening)
        XCTAssertEqual(voz.status, "Micrófono apagado")
    }

    func testWakeAliasesAndLiteralSuffix() {
        for word in ["Computadora", "Computadoras", "Computador"] {
            var wake = WakePhraseState()
            XCTAssertTrue(wake.consume(word + ", por favor", wakeWord: "computadora", time: 0).beep)
            XCTAssertEqual(wake.consume("Abre Safari", wakeWord: "computadora", time: 7.99).command, "Abre Safari")
            XCTAssertTrue(wake.consume(word, wakeWord: "computadora", time: 10).beep)
            XCTAssertNil(wake.consume("Abre Safari", wakeWord: "computadora", time: 18).command)
            XCTAssertEqual(wake.consume("oye   " + word + " escribe Hola,  Perú!", wakeWord: "computadora", time: 20).command, "escribe Hola,  Perú!")
        }
        for rejected in ["compu", "ordenador", "supercomputadora", "computadoramente"] {
            var wake = WakePhraseState()
            XCTAssertNil(wake.consume(rejected + " abre Safari", wakeWord: "computadora", time: 0).command)
        }
        var custom = WakePhraseState()
        var invalidTime = WakePhraseState()
        _ = invalidTime.consume("Computadora", wakeWord: "computadora", time: 0)
        XCTAssertNil(invalidTime.consume("Computadora abre Safari", wakeWord: "computadora", time: .nan).command)
        XCTAssertEqual(invalidTime.waitingUntil, 0)
        var input = VoiceInputState()
        _ = input.consume("Computadora", wakeWord: "computadora", time: 0)
        input.beginUtterance()
        XCTAssertNil(input.consume("abre Safari", wakeWord: "computadora", time: .nan, followUp: true).command)
        XCTAssertEqual(input.waitingUntil, 0)
        XCTAssertNil(input.consume("abre Safari", wakeWord: "computadora", time: 1).command)
        XCTAssertEqual(custom.consume("Asistente escribe Hola,  Perú!", wakeWord: "Asistente", time: 0).command, "escribe Hola,  Perú!")
        XCTAssertNil(custom.consume("Computadora abre Safari", wakeWord: "Asistente", time: 1).command)
    }

    func testSpanishPreparationPreservesContent() {
        for phrase in ["¿puedes abrir Safari?", "escribí Ya pe, abre YouTube.", "oye, búscame Ají de Gallina en YouTube porfa", "no abras Safari", "buscar en la página"] {
            XCTAssertEqual(CommandParser.prepare(CommandParser.prepare(phrase)), CommandParser.prepare(phrase), phrase)
        }
        XCTAssertEqual(CommandParser.parse("escribi\u{301} Hola, José!"), .dictate("Hola, José!"))
        XCTAssertEqual(CommandParser.parse("seleccione el texto Hola, José!"), .selectText("Hola, José!"))
        XCTAssertEqual(CommandParser.parse("buscar en la página"), .shortcut("buscar_texto"))
        for phrase in ["ábrame Safari", "abrí Safari", "¿puedes abrir Safari?", "podrías abrirme Safari por favor", "quiero que abras Safari", "me haces el favor de abrir Safari", "ayúdame a abrir Safari", "oye, porfa abre Safari, pe", "oye, ¿puedes abrir Safari?"] {
            XCTAssertEqual(CommandParser.parse(phrase), .open("Safari", "actual"), phrase)
        }
        XCTAssertEqual(CommandParser.parse("por favor escriba Hola, ¿cómo estás? Gracias pe"), .dictate("Hola, ¿cómo estás? Gracias pe"))
        XCTAssertEqual(CommandParser.parse("escribí Ya pe, abre YouTube."), .dictate("Ya pe, abre YouTube."))
        XCTAssertEqual(CommandParser.parse("escribe Hola,  José!"), .dictate("Hola,  José!"))
        XCTAssertEqual(CommandParser.parse("oye, búscame Ají de Gallina en YouTube porfa"), .search("Ají de Gallina", "youtube", "actual"))
        XCTAssertEqual(CommandParser.parse("quiero que cierres la pestaña"), .shortcut("cerrar_pestana"))
        XCTAssertEqual(CommandParser.parse("por favor no abras Safari"), .unknown("no abras Safari"))
        XCTAssertEqual(CommandParser.parse("busca Adapta PE"), .search("Adapta PE", nil, "actual"))
        XCTAssertEqual(CommandParser.parse("busca qué significa pues"), .search("qué significa pues", nil, "actual"))
        XCTAssertEqual(CommandParser.parse("abre Adapta PE"), .open("Adapta PE", "actual"))
        XCTAssertEqual(CommandParser.parse("buscar campos"), .listFields)
        XCTAssertEqual(CommandParser.prepare("oye, ¿puedes abrir Safari?"), CommandParser.prepare(CommandParser.prepare("oye, ¿puedes abrir Safari?")))
    }

    @MainActor func testCourtesyDispatchesFilterCommands() {
        let actions = ActionManager.shared
        let oldAction = actions.appAction
        defer { actions.appAction = oldAction }
        var action: String?
        actions.appAction = { action = $0 }
        actions.procesarIntencion("por favor quitar filtro")
        XCTAssertEqual(action, "filtro:ninguno")
        actions.procesarIntencion("oye, filtro deuteranopía")
        XCTAssertEqual(action, "filtro:deuteranopia")
    }

    func testLinkedPanelPlacementAndMascotActivity() {
        let screen = CGRect(x: -1920, y: -200, width: 1920, height: 1080)
        for corner in PanelCorner.allCases {
            for point in [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: -5, y: 7), CGPoint(x: CGFloat.nan, y: CGFloat.infinity)] {
                let frame = corner.frame(size: CGSize(width: 320, height: 600), visible: screen, free: point, reservedHeight: 164)
                XCTAssertTrue(screen.contains(frame))
                XCTAssertLessThanOrEqual(frame.maxY + 164, screen.maxY)
                let grown = corner.frame(size: CGSize(width: 320, height: 900), visible: screen, free: point, reservedHeight: 164)
                XCTAssertLessThanOrEqual(grown.maxY + 164, screen.maxY)
            }
        }
        var activity = MascotActivity(); activity.touch(10)
        XCTAssertFalse(activity.shouldSleep(99)); XCTAssertTrue(activity.shouldSleep(100))
        activity.speaking = true; XCTAssertFalse(activity.shouldSleep(200))
        activity.speaking = false; activity.touch(200); XCTAssertFalse(activity.shouldSleep(201))
        activity.manualSleep = true; XCTAssertFalse(activity.shouldSleep(300))
        XCTAssertEqual(CommandParser.parse("une mascota al panel"), .mascot("join"))
        XCTAssertEqual(CommandParser.parse("separa la mascota del panel"), .mascot("separate"))
        XCTAssertEqual(CommandParser.parse("escribe une mascota al panel"), .dictate("une mascota al panel"))
    }

    func testMascotCommandsAndPlayback() throws {
        XCTAssertEqual(CommandParser.parse("mascota Cu Chu"), .mascot("cuchu"))
        XCTAssertEqual(CommandParser.parse("elige mascota tiiinku"), .mascot("tinku"))
        XCTAssertEqual(CommandParser.parse("mascota Yaty"), .mascot("yati"))
        XCTAssertEqual(CommandParser.parse("oculta la mascota"), .mascot("ninguna"))
        XCTAssertEqual(CommandParser.parse("duerme mascota"), .mascot("sleep"))
        XCTAssertEqual(CommandParser.parse("escribe mascota Cuchu"), .dictate("mascota Cuchu"))
        XCTAssertEqual(CommandParser.parse("busca mascota Yati en Google"), .search("mascota Yati", "google", "actual"))
        for name in ["tinku", "cuchu", "yati"] {
            let url = try XCTUnwrap(Bundle.main.url(forResource: "mascota-" + name, withExtension: "json"))
            let atlas = try JSONDecoder().decode(MascotAtlas.self, from: Data(contentsOf: url))
            XCTAssertEqual(atlas.frames.count, 144)
            XCTAssertTrue(atlas.animations.allSatisfy { ($0.entry + $0.loop + $0.exit).allSatisfy(atlas.frames.indices.contains) })
            var animation = MascotPlayback(atlas: atlas)
            animation.set("wave"); for _ in 0..<100 { animation.advance() }; XCTAssertEqual(animation.state, "idle")
            animation.set("laptop"); for _ in 0..<100 { animation.advance() }; XCTAssertEqual(animation.state, "idle")
            animation.set("sleep"); for _ in 0..<100 { animation.advance() }; XCTAssertEqual(animation.state, "sleep"); XCTAssertTrue(animation.resting)
            animation.set("wake"); for _ in 0..<100 { animation.advance() }; XCTAssertEqual(animation.state, "idle")
        }
    }


    @MainActor
    func testLiteScopeAndSessionSafety() {
        let model = AppModel.shared
        let defaults = UserDefaults.standard
        let oldVoice = defaults.object(forKey: "VoiceActive")
        let oldFilter = defaults.object(forKey: "ActiveColorFilter")
        defer {
            defaults.set(oldVoice, forKey: "VoiceActive")
            defaults.set(oldFilter, forKey: "ActiveColorFilter")
            model.actions.callar()
        }
        defaults.set(true, forKey: "VoiceActive")
        defaults.set("deuteranopia", forKey: "ActiveColorFilter")
        model.stopAll(remember: false)
        XCTAssertTrue(defaults.bool(forKey: "VoiceActive"))
        XCTAssertEqual(defaults.string(forKey: "ActiveColorFilter"), "deuteranopia")
        XCTAssertFalse(model.voice.isListening)
        XCTAssertEqual(model.colorFilter.selected, .ninguno)
        model.stopAll()
        XCTAssertFalse(defaults.bool(forKey: "VoiceActive"))
        XCTAssertEqual(defaults.string(forKey: "ActiveColorFilter"), "ninguno")
        XCTAssertNil(Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription"))
        XCTAssertEqual(CommandParser.parse("Escribe Hola, José 👋"), .dictate("Hola, José 👋"))
        XCTAssertEqual(CommandParser.parse("clic derecho"), .kinetic("derecho"))
        XCTAssertEqual(ColorFilter.allCases.count, 8)
        for filter in ColorFilter.allCases {
            XCTAssertEqual(filter.matrix.count, 9)
            XCTAssertTrue(filter.matrix.allSatisfy { $0.isFinite })
        }
        let text = "Hola, José 👋 " + String(repeating: "🙂", count: 25)
        XCTAssertEqual(String(decoding: DesktopAccess.unicodeChunks(text).flatMap { $0 }, as: UTF16.self), text)
        model.actions.procesarIntencion("activar talkback")
        XCTAssertTrue(model.actions.lastResponse.contains("no está incluido"))
        model.actions.procesarIntencion("pregunta a la ia Hola")
        XCTAssertTrue(model.actions.lastResponse.contains("no está incluida"))
        let event = NSAppleEventDescriptor.appleEvent(withEventClass: kCoreEventClass,
            eventID: kAEOpenApplication, targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
        XCTAssertFalse(AppModel.isLoginLaunch(event))
        event.setParam(NSAppleEventDescriptor(enumCode: keyAELaunchedAsLogInItem), forKeyword: keyAEPropData)
        XCTAssertTrue(AppModel.isLoginLaunch(event))
        let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
        for corner in PanelCorner.allCases {
            XCTAssertTrue(screen.contains(corner.frame(size: CGSize(width: 320, height: 550), visible: screen)))
        }
    }
}
