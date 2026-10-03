import XCTest

final class LiteUITests: XCTestCase {
    @MainActor
    func testOnlyVoiceAndColorAndBackground() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        let window = app.windows["Adapta PE Lite"]
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        XCTAssertTrue(window.staticTexts["Controla tu Mac con la voz"].exists)
        XCTAssertFalse(window.staticTexts["Cursor con cámara"].exists)
        XCTAssertFalse(window.staticTexts["IA opcional"].exists)
        let voice = XCTAttachment(screenshot: window.screenshot())
        voice.name = "Adapta PE Lite - Voz"; voice.lifetime = .keepAlways; add(voice)
        window.radioButtons["Daltonismo"].click()
        XCTAssertTrue(window.staticTexts["Filtros de daltonismo"].waitForExistence(timeout: 3))
        let color = XCTAttachment(screenshot: window.screenshot())
        color.name = "Adapta PE Lite - Daltonismo"; color.lifetime = .keepAlways; add(color)
        window.buttons["Panel flotante"].click()
        XCTAssertTrue(app.buttons["Abrir ajustes"].waitForExistence(timeout: 3))
        app.buttons["Abrir ajustes"].click()
        XCTAssertTrue(window.waitForExistence(timeout: 3))
        window.buttons[XCUIIdentifierCloseWindow].click()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 3))
        app.terminate()
    }
}
