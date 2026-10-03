<p align="center"><img src="Adapta-PE-Lite/Assets.xcassets/LiteLogo.imageset/AdaptaPELite.png" alt="Adapta PE Lite" width="128"></p>

# Adapta PE Lite para macOS

**Voz y filtros de pantalla en una aplicación independiente para macOS.** Adapta PE Lite permite controlar aplicaciones, dictar, navegar y leer contenido accesible mediante órdenes en español. Incluye siete simulaciones de daltonismo, barra de menú y panel flotante. Conserva la identidad visual de Adapta PE con su logo Lite.

Este repositorio contiene una app completa con sus propias fuentes, assets, proyecto Xcode y pruebas. No necesita el código ni la instalación de Base. No incluye cámara, cursor cinético, TalkBack automático ni IA externa. La lectura solicitada por voz sí pertenece al asistente Lite.

[Instalación](#instalación-desde-terminal) · [Uso](#primer-inicio-y-uso) · [Comandos](#comandos-de-voz) · [Código](#documentación-del-código) · [Pruebas](#compilación-y-pruebas) · [Guía detallada](docs/LITE.md)

## Funciones

| Función | Comportamiento actual |
| --- | --- |
| Asistente de voz | Palabra personalizable, señal de escucha, ventana de ocho segundos, dictado Unicode y respuestas habladas. |
| Aplicaciones y navegador | Abrir, enfocar o cerrar apps, abrir sitios, buscar, manejar pestañas y ejecutar atajos conocidos. |
| Accesibilidad | Enumerar menús/campos, enfocar, seleccionar, escribir, activar controles y leer bajo una orden explícita. |
| Filtros | Protanomalía, protanopía, deuteranomalía, deuteranopía, tritanomalía, tritanopía y acromatopsia. |
| Segundo plano | Cerrar ajustes mantiene la asistencia; barra de menú y panel flotante permiten controlarla. |
| Preferencias | Micrófono, palabra de activación, opción de reconocimiento Apple por red, filtro, monitor/esquina del panel e inicio de sesión voluntario. |

Las matrices son simulaciones visuales; no constituyen una corrección médica. Las acciones dependen de los controles accesibles que publique cada app. La lectura manual no sustituye a VoiceOver.

## Requisitos

- macOS **14 o posterior**, según `MACOSX_DEPLOYMENT_TARGET` del proyecto.
- Xcode compatible con el formato del proyecto y grupos sincronizados. Esta revisión se compiló con **Xcode 27**.
- Git para clonar; micrófono para voz y los permisos de cada módulo.
- Un reconocedor español de Apple disponible localmente. La app comprueba `es-PE`, `es-ES` y `es-MX`; no presupone que cada equipo tenga todos los modelos.

No utiliza Python, Flask, paquetes de terceros ni dependencias de Base. El código usa SwiftUI, AppKit, AVFoundation, Speech, Accessibility, CoreGraphics, ScreenCaptureKit y ServiceManagement. Los permisos y disponibilidad de reconocimiento se comprueban al activar cada función.

El proyecto conserva el equipo de firma del autor. Si vas a firmar, selecciona tu propio equipo en **Signing & Capabilities**. El deployment target y una compilación correcta no acreditan pruebas físicas en todas las versiones de macOS ni en ambas arquitecturas.

## Instalación desde terminal

Instala Xcode, ábrelo para completar sus componentes y selecciona sus herramientas si todavía no están activas:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

Clona esta app:

```sh
git clone https://github.com/TheAlejo160/Adapta-PE-Lite-MacOS.git
cd Adapta-PE-Lite-MacOS
open Adapta-PE-Lite.xcodeproj
```

En Xcode, selecciona el esquema **Adapta-PE-Lite**, destino **My Mac** y tu firma de desarrollo. Para compilar y abrir desde terminal:

```sh
./script/build_and_run.sh --verify
```

El script detiene la instancia anterior de Lite y compila Debug en una carpeta temporal. `--verify` comprueba que el proceso arranca; no prueba micrófono ni filtros. Sin argumentos compila y abre; `--debug` abre Xcode; `--logs` y `--telemetry` muestran registros locales.

Para una instalación local persistente, sal de Lite desde la barra de menú, compila Release con tu firma configurada y copia el bundle:

```sh
xcodebuild -project Adapta-PE-Lite.xcodeproj -scheme Adapta-PE-Lite \
  -configuration Release -derivedDataPath build/lite build
mkdir -p "$HOME/Applications"
ditto build/lite/Build/Products/Release/Adapta-PE-Lite.app \
  "$HOME/Applications/Adapta-PE-Lite.app"
open "$HOME/Applications/Adapta-PE-Lite.app"
```

Para actualizar, ejecuta `git pull --ff-only` con tu copia limpia, cierra Lite y repite compilación/copia. La instalación local no acredita firma y notarización para distribuir a otros equipos. Este repositorio publica fuentes; no promete un DMG ni una release binaria.

Para desinstalar, desactiva **Iniciar con macOS**, pulsa **Salir de Adapta PE Lite** y retira el bundle de `~/Applications`. Los permisos y preferencias del usuario no se eliminan al borrar la app.

## Primer inicio y uso

1. El primer inicio mantiene voz y filtro apagados. Abre la sección **Voz**, elige micrófono y activa el asistente.
2. Autoriza micrófono y reconocimiento de voz. Concede **Accesibilidad** para operar otras apps desde **Ajustes del Sistema > Privacidad y seguridad**.
3. Di **«Computadora»**, espera la señal y pronuncia una orden antes de ocho segundos; también puedes decir palabra y orden en una misma frase.
4. Usa **Daltonismo** para seleccionar un filtro. La captura de pantalla se solicita al activarlo. **Sin filtro** detiene la composición.
5. Cierra ajustes para continuar en segundo plano. La barra de menú abre ajustes, cambia filtros, activa/apaga voz, muestra el panel o detiene todo.

El panel muestra estado, transcripción temporal, respuesta y elecciones sin convertirse en el destino de la orden. Puedes anclarlo a una esquina y monitor. Las coincidencias ambiguas ofrecen opciones numeradas; **«cancelar»** retira la selección pendiente.

**Detener todo** cancela acciones, escucha y TTS, retira filtros y recuerda que los módulos están apagados. **Salir** libera recursos y conserva las preferencias para el siguiente inicio. El reposo suspende los módulos y el retorno revalida capacidades; restaurar una sesión no abre permisos nuevos.

Si usas Base al mismo tiempo, activa voz y filtros en una sola edición para evitar que ambas operen sobre el mismo escritorio.

## Comandos de voz

Los ejemplos se pronuncian después de «Computadora». No son lenguaje libre ilimitado: `CommandParser.swift` contiene las intenciones y sinónimos admitidos.

| Objetivo | Ejemplos |
| --- | --- |
| Apps y sitios | «abre Safari», «abre Google», «cierra Safari». |
| Buscar | «busca accesibilidad en Wikipedia», «busca recetas en nueva pestaña». |
| Dictar | «escribe Hola, ¿cómo estás?», «escribe Ana en el campo Nombre». |
| Controles | «muestra campos», «enfoca Buscar», «selecciona Aceptar», «dale clic». |
| Menús | «muestra acciones», «ejecuta la acción Guardar». |
| Teclado | «guardar», «copiar», «pegar», «atajo comando shift s». |
| Navegación | «nueva pestaña», «cierra pestaña», «atrás», «recarga», «baja», «aumenta zoom». |
| Lectura manual | «lee la pantalla», «lee Guardar», «silencio». |
| Elecciones | «elige dos», «cancelar». |
| Interfaz | «mostrar ajustes», «modo flotante», «detener todo». |

La normalización de intenciones no borra Unicode, signos ni mayúsculas del dictado. Las URLs y consultas se construyen desde el catálogo. Una orden no se ejecuta como shell. Los controles protegidos se excluyen de lectura y escritura. Si una app no expone un campo o menú por Accesibilidad, el asistente informa la limitación; puede usarse un atajo conocido cuando proceda.

## Permisos y privacidad

| Permiso | Uso |
| --- | --- |
| Micrófono | Captura de audio mientras el asistente está activo. |
| Reconocimiento de voz | Speech transforma audio en texto; se prefiere reconocimiento local. |
| Accesibilidad | Lectura manual y acciones sobre apps externas. |
| Grabación de pantalla | Captura/composición local necesaria para filtros; se solicita al activarlos. |
| Automatización | Control del navegador cuando la acción requiere Apple Events. |

Lite no solicita cámara. **Apple por red** sólo se admite mediante una opción explícita: si la activas, Apple puede procesar el audio para reconocimiento. La ausencia de un modelo local produce diagnóstico; no equivale a tener voz disponible en todos los Mac.

No se guardan grabaciones, capturas ni transcripciones. El texto mostrado y la selección viven en memoria. Los filtros procesan imágenes localmente. Preferencias y permisos están separados de Base por `com.thealejo.Adapta-PE-Lite`; el repositorio no contiene datos personales de sesión ni llaves de firma.

## Documentación del código

| Archivo | Responsabilidad |
| --- | --- |
| [Adapta_PE_LiteApp.swift](Adapta-PE-Lite/Adapta_PE_LiteApp.swift) | Entrada, composición `AppModel`, barra de menú, preferencias, panel, inicio de sesión, suspensión y parada. |
| [ContentView.swift](Adapta-PE-Lite/ContentView.swift) | Secciones de voz/filtros y controles nativos SwiftUI. |
| [FloatingView.swift](Adapta-PE-Lite/FloatingView.swift) | Estado temporal, respuestas, elecciones y controles del panel flotante. |
| [VoiceManager.swift](Adapta-PE-Lite/VoiceManager.swift) | Captura AVFoundation, Speech, disponibilidad local, recuperación y coordinación con TTS. |
| [VoiceInputState.swift](Adapta-PE-Lite/VoiceInputState.swift) | Palabra de activación, ventana de ocho segundos, deduplicación e interrupción de lectura. |
| [CommandParser.swift](Adapta-PE-Lite/CommandParser.swift) | Intenciones, sinónimos, sitios, atajos, destinos y elecciones. |
| [ActionManager.swift](Adapta-PE-Lite/ActionManager.swift) | Ejecuta órdenes, mantiene destino externo y coordina respuestas y opciones. |
| [ApplicationCatalog.swift](Adapta-PE-Lite/ApplicationCatalog.swift) | Catálogo local de apps y resolución de nombres/alias. |
| [DesktopAccess.swift](Adapta-PE-Lite/DesktopAccess.swift) | Árbol AX, campos, menús, selección, lectura manual y entrada CGEvent. |
| [ColorFilterManager.swift](Adapta-PE-Lite/ColorFilterManager.swift) | Siete matrices, captura/composición de pantallas y liberación del filtro. |
| [script/build_and_run.sh](script/build_and_run.sh) | Compilación/lanzamiento y modos de diagnóstico local. |
| [LiteTests.swift](Adapta-PE-LiteTests/LiteTests.swift) y [LiteUITests.swift](Adapta-PE-LiteUITests/LiteUITests.swift) | Regresiones de alcance y sesión; navegación de interfaz sin sensores. |

El recorrido de voz es **AVFoundation → Speech → VoiceInputState → CommandParser → ActionManager → AX/CGEvent/Apple Events → respuesta**. `AppModel` conecta los módulos y coordina su vida. `stopAll` invalida acciones pendientes antes de detener voz, filtros, TTS y selección. La UI mantiene separado el destino externo de sus propias ventanas.

El recorrido de filtros es **captura local de pantalla → matriz de color → composición → salida visible**. Retirar el filtro invalida la salida y libera captura/ventanas. No actúa sobre los colores del archivo original.

Los motores excluidos no forman parte de las fuentes compiladas: no hay TrackingManager, KineticState, OptionalAI ni TalkBackManager. Lite no cambia de edición mediante una condición `LITE` ni referencia archivos de Base. El proyecto y el esquema compartido se conservan; `xcuserdata`, DerivedData, `.app`, `.dmg`, builds, logs y credenciales quedan fuera de Git.

## Compilación y pruebas

Las pruebas de lógica pueden ejecutarse sin firma de distribución:

```sh
xcodebuild -project Adapta-PE-Lite.xcodeproj -scheme Adapta-PE-Lite \
  -destination 'platform=macOS' -derivedDataPath /tmp/adapta-lite-check \
  -only-testing:Adapta-PE-LiteTests CODE_SIGNING_ALLOWED=NO test
```

Para incluir las pruebas de interfaz, usa una firma de desarrollo configurada y ejecuta `test` sin restringir el target:

```sh
xcodebuild -project Adapta-PE-Lite.xcodeproj -scheme Adapta-PE-Lite \
  -destination 'platform=macOS' -derivedDataPath /tmp/adapta-lite-ui test
```

La regresión de lógica valida alcance Lite, Unicode, matrices, apagado/memoria de sesión, inicio de sesión y anclaje del panel. La prueba UI recorre ambas secciones, el panel y el cierre de ajustes sin activar sensores. Consulta [docs/LITE.md](docs/LITE.md) para las capturas y resultados de interfaz.

El **3 de octubre de 2026** pasó la prueba de lógica desde este proyecto independiente con Xcode 27. Se contrastó el mapa con el índice actualizado y sus fuentes; la configuración Xcode y el script se leyeron directamente. Esto no acredita reconocimiento español con micrófono real, permisos, filtros en múltiples pantallas ni firma/notarización de distribución. Esos escenarios requieren pruebas físicas.

## Solución de problemas

| Síntoma | Comprobación |
| --- | --- |
| Error de equipo de firma | Cambia el equipo del autor por el tuyo en Xcode. |
| `xcodebuild` apunta sólo a Command Line Tools | Selecciona el Xcode completo con `xcode-select` y completa sus componentes. |
| No hay reconocimiento local | Comprueba disponibilidad de Speech español y micrófono; Apple por red es una decisión explícita del usuario. |
| No actúa sobre otra app | Comprueba Accesibilidad y que el control exponga un patrón AX; algunos contenidos no son accesibles. |
| No se ve el filtro | Comprueba permiso de captura de pantalla, filtro seleccionado y diagnóstico del módulo. |
| Cerrar ajustes no termina Lite | Es el funcionamiento en segundo plano; usa **Salir** desde la barra de menú. |

## Proyectos de la familia Adapta PE

| Programa | Repositorio |
| --- | --- |
| Extensión Base | [Adapta-PE](https://github.com/TheAlejo160/Adapta-PE) |
| Extensión Lite | [Adapta-PE-Lite](https://github.com/TheAlejo160/Adapta-PE-Lite) |
| Windows Base | [Adapta-PE-Win](https://github.com/TheAlejo160/Adapta-PE-Win) |
| Windows Lite | [Adapta-PE-Lite-Win](https://github.com/TheAlejo160/Adapta-PE-Lite-Win) |
| macOS Base | [Adapta-PE-MacOS-Intel-Apple-Silicon-](https://github.com/TheAlejo160/Adapta-PE-MacOS-Intel-Apple-Silicon-) |
| macOS Lite | [Adapta-PE-Lite-MacOS](https://github.com/TheAlejo160/Adapta-PE-Lite-MacOS) |

Cada plataforma tiene su propio proyecto, permisos y versión. Un ZIP de extensión no instala una app de escritorio.

## Licencia

© 2026 Rodrigo Alejandro Apcho Aliaga — TheAlejo160. [LICENSE](LICENSE): **CC BY-NC-SA 4.0**. Se mantienen las atribuciones y condiciones del autor; publicar las fuentes no cambia sus condiciones de reutilización.
