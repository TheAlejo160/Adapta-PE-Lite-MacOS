import AppKit
import CoreServices
import XCTest
@testable import Adapta_PE_Lite

final class LiteTests: XCTestCase {
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
