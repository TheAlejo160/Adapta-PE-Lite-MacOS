# Adapta PE Lite para macOS

![Logo de Adapta PE Lite](Adapta-PE-Lite/Assets.xcassets/LiteLogo.imageset/AdaptaPELite.png)

**Control por voz, siete filtros de color y una mascota opcional, en una app nativa para Mac.** Lite está pensada para quien necesita abrir aplicaciones, dictar, activar controles y pedir lecturas sin usar cámara. También es la opción a considerar en Macs modestos si no necesitas seguimiento corporal: no carga motores de visión. El consumo real depende del reconocimiento de voz, las pantallas y los filtros activos; no hay una medición de rendimiento universal.

Es una aplicación SwiftUI independiente, con sus propias fuentes, recursos, proyecto Xcode y pruebas. No necesitas instalar Base. Incluye lectura solicitada por voz y clic por voz; no incluye cámara, cursor cinético, TalkBack automático ni IA externa.

[Instalar desde el repo](#instalar-desde-el-repositorio) · [Permisos](#permisos-que-pide-lite) · [Primer uso](#tu-primera-orden) · [Tutoriales](#trabajar-con-la-voz) · [Problemas](#solución-de-problemas) · [Desarrollo](#desarrollo-y-pruebas)

## Instalar desde el repositorio

### Qué necesitas

- Un Mac con **macOS 14 o posterior**, el mínimo declarado en el proyecto.
- Xcode completo con un SDK que incluya las APIs de macOS 26 usadas en la interfaz, y soporte para grupos de archivos sincronizados. Las revisiones anteriores del repo documentan uso de Xcode 27. Tener macOS 14 como destino mínimo no significa que cualquier Xcode antiguo pueda compilar las fuentes actuales.
- Git, un micrófono para las órdenes habladas y un equipo de firma disponible en Xcode.
- Reconocimiento español de Apple disponible en el dispositivo, o autorización voluntaria para usar su reconocimiento por red. La app busca modelos locales `es-PE`, `es-ES` y `es-MX`.

El proyecto no fija `ARCHS` ni `EXCLUDED_ARCHS`: utiliza las arquitecturas predeterminadas de Xcode. Puedes trabajar con el destino **My Mac** en Intel o Apple Silicon, pero compilar para tu Mac no demuestra que hayas generado o probado un binario universal.

No requiere Python, Flask, npm ni paquetes de terceros. La documentación de este repo describe instalación desde fuentes; no acredita un paquete DMG publicado, firmado y notarizado.

### Abrir y ejecutar en Xcode

```sh
git clone https://github.com/TheAlejo160/Adapta-PE-Lite-MacOS.git
cd Adapta-PE-Lite-MacOS
open Adapta-PE-Lite.xcodeproj
```

1. Abre Xcode al menos una vez para completar sus componentes.
2. Selecciona el esquema **Adapta-PE-Lite** y el destino **My Mac**.
3. En el target **Adapta-PE-Lite > Signing & Capabilities**, cambia el equipo del autor por tu propio **Team**. Revisa también los targets de pruebas si vas a ejecutarlos. El proyecto usa firma automática.
4. Ejecuta **Product > Run**. La primera apertura deja voz y filtros apagados.

Si Terminal está usando sólo Command Line Tools, selecciona el Xcode completo instalado en esta ruta:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

Con la firma configurada también puedes ejecutar:

```sh
./script/build_and_run.sh --verify
```

El script cierra la instancia anterior de Lite, compila Debug en una carpeta temporal y abre la app. `--verify` sólo comprueba que el proceso arranca. Sin argumentos compila y abre; `--debug` también compila antes de abrir el proyecto en Xcode. `--logs` muestra registros del proceso y `--telemetry` los del subsistema local `pe.adapta.desktop`.

### Dejar una copia en Aplicaciones

Sal de Lite antes de sustituir su bundle. Desde la raíz del repo, con tu firma ya configurada:

```sh
xcodebuild -project Adapta-PE-Lite.xcodeproj -scheme Adapta-PE-Lite \
  -configuration Release -derivedDataPath build/lite build
mkdir -p "$HOME/Applications"
ditto build/lite/Build/Products/Release/Adapta-PE-Lite.app \
  "$HOME/Applications/Adapta-PE-Lite.app"
open "$HOME/Applications/Adapta-PE-Lite.app"
```

Esta instalación local no acredita firma Developer ID ni notarización para distribuir la app a otras personas. Usa una ubicación estable para la copia que autorizas en los permisos de macOS.

Para actualizar una copia de trabajo limpia, ejecuta `git pull --ff-only`, cierra Lite y repite la compilación y copia. Para desinstalar, desmarca **Iniciar al encender el Mac**, elige **Salir de Adapta PE Lite** en la barra de menú y retira la app de `~/Applications`. Borrarla no elimina sus preferencias ni los permisos registrados por macOS.

## Permisos que pide Lite

Abre **Ajustes del Sistema > Privacidad y seguridad**. Los permisos son de **Adapta PE Lite**, separados de los de Base por su identificador `com.thealejo.Adapta-PE-Lite`.

| Permiso | Cuándo y para qué |
| --- | --- |
| Micrófono | Al encender **Asistente de voz**; captura audio mientras permanece activo. |
| Reconocimiento de voz | Al encender el asistente; convierte audio en texto mediante Speech de Apple. Concederlo no activa por sí solo la opción de red de Lite. |
| Accesibilidad | Al pulsar **Permitir control del escritorio**; permite escribir, leer y activar controles de otras apps, enviar atajos y hacer clic. |
| Grabación de pantalla | Al activar un filtro; ScreenCaptureKit necesita capturar las pantallas para componer el color. En algunas versiones aparece como **Grabación de pantalla y audio del sistema**; el filtro no captura audio. |
| Automatización | Cuando una orden del navegador usa Apple Events. Autoriza el navegador solicitado dentro de la entrada de Lite. |

**Lite no pide cámara.** Puedes usar mascotas sin activar voz ni captura de pantalla. Para usar sólo filtros, no necesitas encender el micrófono. Si macOS pide reiniciar la app después de cambiar un permiso, sal y abre de nuevo la misma copia instalada.

## Tu primera orden

1. En **Asistente de voz**, despliega **Micrófono y preferencias**, selecciona el **Micrófono** y deja desmarcado **Permitir reconocimiento de Apple por red** si quieres reconocimiento local.
2. Enciende **Asistente de voz** y acepta los avisos de micrófono y reconocimiento. El estado indica si está listo o qué falta.
3. Pulsa **Permitir control del escritorio** para las acciones sobre otras aplicaciones y habilita Lite en **Accesibilidad**.
4. Di **«Computadora, abre Safari»**. También puedes decir sólo **«Computadora»**, esperar la señal y dar la orden dentro de ocho segundos.
5. Revisa **Escuché:** y la respuesta. Pulsa **Usar panel** para conservar ese feedback mientras trabajas en otra app.

En **Nombre para llamar al asistente** puedes cambiar la palabra de activación, por ejemplo a «Máquina Azul». Se comparan acentos y espacios equivalentes. La palabra predeterminada admite «Computadora», «Computadoras» y «Computador»; una palabra personal no hereda esos alias.

Se aceptan variantes como «por favor abre Safari», «quiero que abras Safari», «ábrame Safari» y «abrí Safari». Esto es un catálogo de intenciones y reglas en español, no conversación libre ni reconocimiento acústico en seis idiomas.

## Trabajar con la voz

En los ejemplos siguientes, llama primero al asistente o antepone **«Computadora,»** a la orden. Activa la aplicación sobre la que quieras actuar antes de dictar, leer o pulsar controles.

### Aplicaciones, sitios y navegación

- **«Abre Safari»**, **«abre Zoom»**, **«abre Chrome en nueva ventana»**: resuelve aplicaciones instaladas por nombre o alias. Si no encuentra una coincidencia única, pide el nombre completo.
- **«Abre YouTube»**, **«abre Google»**, **«abre github.com»**: abre sitios conocidos o direcciones HTTP/HTTPS.
- **«Busca movilidad en Wikipedia»**, **«busca recetas en nueva pestaña»**: construye la búsqueda para el sitio o destino indicado.
- **«Nueva pestaña»**, **«cierra pestaña»**, **«atrás»**, **«recarga»**, **«siguiente pestaña»**, **«baja»**, **«aumenta zoom»**: ejecuta acciones y atajos de navegación.
- **«Abre Safari en el segundo monitor»**: intenta colocar su ventana en una pantalla conectada mediante Accesibilidad.
- **«Cierra Safari»**: solicita el cierre de la aplicación. Guarda antes tu trabajo; cada app decide cómo tratar documentos pendientes.

Safari, Google Chrome, Brave Browser y Microsoft Edge tienen manejo específico de URLs y pestañas mediante AppleScript. Sin uno de esos navegadores como destino, las URLs se abren con el navegador predeterminado; no se garantiza el mismo control del destino de pestaña o ventana.

El catálogo incluye Google, YouTube, Mercado Libre, Amazon, Wikipedia, Facebook, Instagram, X/Twitter, Reddit, Netflix, Twitch, GitHub, ChatGPT, Claude, Gemini, Canvas, Gmail, Outlook, WhatsApp, Telegram, Drive, Documentos de Google, Mapas, LinkedIn, TikTok, Spotify, Bing y DuckDuckGo. Abrir las webs de ChatGPT, Claude o Gemini no integra IA en Lite. En sitios sin búsqueda propia configurada, la consulta usa Google con el dominio del sitio.

### Dictado, campos y teclado

1. Enfoca un campo de texto no protegido en la app de destino.
2. Di **«Escribe Hola, José. ¿Cómo estás?»**. El parser conserva mayúsculas, acentos, puntuación y espacios interiores del texto reconocido; el resultado acústico depende de Speech y del micrófono.
3. Si necesitas localizar el campo, di **«muestra campos»** y elige uno. También puedes decir **«enfoca Buscar»** o **«escribe Ana en el campo Nombre»**, usando la etiqueta real del formulario.
4. Para trabajar con el texto, prueba **«selecciona el texto Hola»**, **«copiar»**, **«pegar»**, **«deshacer»**, **«guardar»** o **«atajo comando shift s»**.

**«Borra el campo»** selecciona y borra el contenido del campo editable enfocado. Los campos de contraseña quedan excluidos del dictado y del borrado. El dictado envía eventos Unicode y no sustituye el portapapeles.

Las órdenes son completas: mencionar «mascota Cuchu» dentro de un dictado o una búsqueda conserva esas palabras. Las partículas finales ambiguas «pe», «pues», «ya pe» y «ya pues» sólo se retiran como cortesía si van precedidas de coma; «busca Adapta PE» conserva el nombre.

### Elecciones, menús y clic por voz

En **Comandos y ayuda**, los botones **Acciones de la app activa** y **Buscar campos de texto** enumeran opciones. Por voz puedes pedir **«muestra comandos»** o **«muestra campos»**.

Cuando aparecen varias coincidencias, el panel muestra **Elige en…** y una lista numerada. Responde **«elige dos»**, el nombre de la opción, **«siguiente»** para otra página o **«cancelar»**. También puedes pulsar sus botones. La elección caduca a los 45 segundos y se cancela al cambiar de aplicación; antes de ejecutarla se vuelve a comprobar la ventana de destino.

Para un control accesible, usa **«selecciona Aceptar»** y después **«dale clic»**, o directamente **«pulsa Aceptar»**. Para un menú, **«ejecuta la acción Guardar»**. Los nombres deben corresponder a los que publique la app.

**«Clic»** y **«clic derecho»** pulsan en la posición actual del puntero. Lite no mueve el cursor con cámara; coloca el puntero con tu ratón, trackpad u otro dispositivo. Una app puede rechazar eventos o no publicar controles accesibles.

### Lectura explícita y parada

Di **«lee la pantalla»** para leer el texto accesible de la ventana activa, o **«lee Guardar»** para un elemento concreto. La lectura no hace OCR de imágenes y depende del árbol de Accesibilidad; está acotada y no equivale a leer todo un documento largo ni sustituye a VoiceOver.

Durante una lectura, di **«Computadora, silencio»** para interrumpir la voz o **«Computadora, detén todo»** para apagar la asistencia. El botón **Detener todo** y el atajo **Comando + Mayúsculas + punto** también están disponibles. La parada cancela acciones pendientes, escucha y síntesis, quita filtros y recuerda voz y filtros apagados; no cierra la app ni oculta necesariamente la mascota.

## Filtros sin cámara

1. Abre **Filtros de color** y selecciona **Protanomalía**, **Protanopía**, **Deuteranomalía**, **Deuteranopía**, **Tritanomalía**, **Tritanopía** o **Acromatopsia**.
2. Concede **Grabación de pantalla** si se solicita y vuelve a activar el filtro. El botón **Permiso de Grabación de pantalla** abre su ajuste.
3. Comprueba el estado: **Preparando filtro local…** indica arranque; **Filtro local · … pantalla(s)** se anuncia cuando llega una primera imagen procesada. La selección por sí sola no acredita captura activa.
4. Pulsa **Quitar filtro**, elige **Sin filtro** o di **«Computadora, quitar filtro»** para detenerlo. **«Computadora, filtro deuteranopía»** activa uno por voz.

Las siete matrices simulan alteraciones de color; no son una corrección médica. El filtro deja pasar clics y excluye la propia interfaz de Lite para que puedas desactivarlo. Se reconstruye al cambiar las pantallas conectadas o su disposición. La ventana se muestra tras recibir una imagen y se invalida al detener, para que una imagen tardía no vuelva a cubrir el escritorio.

La composición local por pantalla consume GPU y memoria. Se solicitan hasta 30 imágenes por segundo, sin garantía de alcanzar esa tasa. Contenido protegido, pantallas del sistema y juegos con presentación exclusiva pueden impedir captura o capas; prueba el modo ventana o pantalla completa de escritorio si la aplicación lo ofrece.

## Mascota y panel para seguir trabajando

En **Mascota > Tu mascota** elige **Tinku · gallito**, **Cuchu · cuy**, **Yati · llama** o **Sin mascota**, el valor inicial. Usa **Saludar**, **Dormir** y **Despertar**; por voz, **«mascota Cuchu»**, **«saluda mascota»**, **«duerme mascota»**, **«despierta mascota»** y **«oculta mascota»**. También admite variantes como «Cu Chu», «Yaty» y «elige mascota tiiinku».

El dibujo deja pasar los clics. Arrastra su nombre para moverla, o pulsa **Mover con teclas**, usa las flechas y sal con **Escape**. **Otro monitor** cambia de pantalla. Se recuerdan selección, monitor y posición relativa. Sólo se carga el atlas elegido, con sus secuencias y tiempos; las animaciones se pausan con movimiento reducido y suspensión. Tras 90 segundos sin interacción descansa; una acción despierta ese descanso automático. Después de **Dormir**, hace falta **Despertar**. La lectura y las respuestas habladas acompañan la salida de voz real, sin provocar descanso automático mientras habla.

Pulsa **Usar panel** para mostrar el panel flotante. Su menú **Opciones** reúne **Elegir mascota**, **Filtro de pantalla**, las esquinas y, si hay varias pantallas, los monitores. **Abrir ajustes** regresa a la ventana principal. El panel conserva estado de voz/filtro, transcripción, respuesta, elecciones y **Detener todo**, sobre fondo sólido.

Activa **Mover mascota y panel juntos** para colocarla encima del panel. Arrastra el título de cualquiera para mover ambos; también puedes enfocar el título del panel y usar las flechas. Al separarlos, la mascota recupera su ubicación propia. Se recuerda la posición relativa; elegir esquina vuelve al anclaje. Por voz: **«une mascota al panel»**, **«separa mascota del panel»** o **«panel esquina superior izquierda»**.

Cerrar ajustes mantiene Lite en segundo plano. Desde su icono de la barra de menú puedes **Abrir ajustes**, **Mostrar panel flotante** / **Ocultar panel flotante**, cambiar el filtro, **Activar voz** / **Apagar voz**, **Detener todo** o **Salir de Adapta PE Lite**.

En **Micrófono y preferencias > Iniciar al encender el Mac** puedes registrar el inicio de sesión voluntario. Los siguientes arranques restauran los módulos recordados sólo con permisos ya concedidos; el primer inicio los mantiene apagados. **Salir** conserva las preferencias de sesión; **Detener todo** recuerda los módulos apagados. Al volver del reposo, se intenta recuperar la sesión y se revisa la disponibilidad de sus recursos.

## Qué ocurre dentro del Mac

| Pieza | Responsabilidad |
| --- | --- |
| [VoiceManager.swift](Adapta-PE-Lite/VoiceManager.swift) y [VoiceInputState.swift](Adapta-PE-Lite/VoiceInputState.swift) | Captura de audio con AVFoundation, reconocimiento con Speech, llamada personal, espera de ocho segundos, recuperación de escucha y protección frente al eco de la síntesis. |
| [CommandParser.swift](Adapta-PE-Lite/CommandParser.swift) | Prepara cortesías y verbos, conserva el contenido del dictado y convierte órdenes en intenciones. Contiene atajos, elecciones y catálogo de sitios. |
| [ActionManager.swift](Adapta-PE-Lite/ActionManager.swift) y [ApplicationCatalog.swift](Adapta-PE-Lite/ApplicationCatalog.swift) | Resuelven apps, URLs, navegador, elecciones y respuestas de AVSpeechSynthesizer. Las acciones del navegador usan `/usr/bin/osascript` con argumentos preparados por la app; una frase no se ejecuta como shell. |
| [DesktopAccess.swift](Adapta-PE-Lite/DesktopAccess.swift) | Consulta AX para menús, campos y lectura manual; activa controles y envía teclado/clic mediante CoreGraphics. Comprueba destino y cancelación antes de actuar. |
| [ColorFilterManager.swift](Adapta-PE-Lite/ColorFilterManager.swift) | Captura con ScreenCaptureKit, aplica matrices con Core Image y presenta capas por pantalla, sin capturar el audio del sistema. |
| [Adapta_PE_LiteApp.swift](Adapta-PE-Lite/Adapta_PE_LiteApp.swift), [ContentView.swift](Adapta-PE-Lite/ContentView.swift), [FloatingView.swift](Adapta-PE-Lite/FloatingView.swift) y [Mascot.swift](Adapta-PE-Lite/Mascot.swift) | Coordinan sesión, permisos, inicio con ServiceManagement, ajustes, barra de menú, panel y sprites locales. |

## Privacidad y límites

El reconocimiento local es el valor predeterminado. Activar **Permitir reconocimiento de Apple por red** permite que Apple procese audio por red cuando no haya reconocimiento local adecuado. Lite no incorpora un proveedor de IA externo ni solicita claves API.

Los filtros procesan imágenes en memoria dentro del Mac, sin guardarlas ni enviarlas. La app no implementa almacenamiento de grabaciones o transcripciones; la transcripción visible es temporal. Se guardan preferencias de dispositivos, activación, filtros, inicio y posición de ventanas/mascotas. Los registros locales contienen estados y errores técnicos, no un historial de dictados implementado por Lite.

Abrir sitios y hacer búsquedas utiliza el navegador y los servicios correspondientes. El reconocimiento local no hace privadas las consultas enviadas a esas webs. Los sprites se incluyen en [Mascotas](Adapta-PE-Lite/Mascotas/README.md).

El proyecto habilita hardened runtime, desactiva App Sandbox y no referencia un archivo `.entitlements` propio. Declara usos de micrófono, reconocimiento y Apple Events; el acceso al micrófono está habilitado y el de cámara deshabilitado. Estos ajustes no prueban que una distribución esté notarizada.

## Solución de problemas

| Qué pasa | Qué revisar en macOS Lite |
| --- | --- |
| Xcode pide el equipo de firma del autor | Selecciona tu Team en Signing & Capabilities del target y, si corresponde, de pruebas. No necesitas acceso al equipo original. |
| Terminal dice que `xcodebuild` necesita Xcode | Abre Xcode completo, termina sus componentes y revisa `xcode-select`; usa el cambio de ruta indicado en instalación si coincide con tu instalación. |
| Xcode no reconoce grupos o APIs de interfaz | Usa una versión con soporte para los grupos sincronizados y el SDK de macOS 26. El destino mínimo macOS 14 no es el SDK de compilación. |
| macOS bloquea una copia descargada por desarrollador no identificado | Comprueba su procedencia. Si confías en ella y el sistema ofrece **Abrir igualmente** en Privacidad y seguridad, usa esa excepción para la app. No desactives Gatekeeper globalmente. Un aviso de malware, archivo dañado o política de administración requiere revisar ese problema concreto. |
| «Micrófono sin permiso» o «Reconocimiento de voz sin permiso» | Habilita Lite en la categoría correspondiente de Privacidad y seguridad. La interfaz ofrece **Revisar permiso del micrófono** o **Revisar reconocimiento de voz** cuando están denegados. |
| «Español local no disponible» | Comprueba recursos españoles de dictado de macOS. Lite intenta `es-PE`, `es-ES` y `es-MX`; la alternativa de Apple por red requiere que actives su opción voluntariamente. |
| «Dispositivo no disponible» o no entra audio | Revisa el micrófono conectado y la entrada de sonido de macOS. Pulsa **Actualizar dispositivos y permisos**, selecciona el dispositivo y vuelve a activar voz; comprueba si otra app lo está usando. |
| No reacciona después de la llamada | Mira el estado y **Escuché:**, espera la señal si llamaste sin orden y habla dentro de ocho segundos. Comprueba la palabra personal y el idioma del reconocedor. |
| No escribe, pulsa ni lee otra app | Autoriza Accesibilidad para la copia que ejecutas y activa la ventana de destino. La app debe exponer controles AX; imágenes, juegos y campos protegidos pueden quedar fuera. |
| El navegador rechaza la acción | Repite la orden y revisa Automatización para el navegador solicitado. Para control específico, comprueba que sea Safari, Chrome, Brave o Edge. |
| Se cancela una elección | Caduca a los 45 segundos y no se ejecuta sobre otra app o ventana. Vuelve a listar los campos o acciones en el destino correcto. |
| El filtro no aparece o se interrumpe | Revisa Grabación de pantalla y el estado del módulo; vuelve a activarlo después de conceder permiso. Prueba contenido no protegido. Si necesitas quitarlo, usa **Quitar filtro** o **Detener todo**. |
| No ves el cambio de color en los ajustes de Lite | Es intencional: la app se excluye de su propia captura para mantener accesible el control de parada. Comprueba otra ventana. |
| El filtro consume demasiado en varias pantallas | Desactívalo cuando no lo necesites. La composición depende de resolución, cantidad de monitores y GPU; el repo no acredita una tasa de FPS en tu equipo. |
| La mascota se queda quieta | Revisa movimiento reducido, reposo automático o **Dormir** manual; pulsa **Despertar** para salir del sueño manual. |
| Cerrar la ventana no termina el proceso | Lite sigue en la barra de menú. Usa **Salir de Adapta PE Lite** para terminarla. |
| Voz o filtros responden por duplicado | Actívalos en una sola edición si también tienes Base abierta. |

## Desarrollo y pruebas

Desde la raíz del repo, el esquema compartido incluye **Adapta-PE-LiteTests** y **Adapta-PE-LiteUITests**. Para ejecutar sólo las pruebas de lógica:

```sh
xcodebuild test -project Adapta-PE-Lite.xcodeproj -scheme Adapta-PE-Lite \
  -destination 'platform=macOS' -derivedDataPath /tmp/adapta-pelite-tests \
  -only-testing:Adapta-PE-LiteTests
```

Configura antes la firma de los targets. Para una comprobación local sin firma, la guía existente documenta `CODE_SIGNING_ALLOWED=NO`; eso no valida distribución ni permisos de una app firmada. Las pruebas UI se ejecutan por separado desde Xcode y pueden necesitar autorización de automatización del entorno de pruebas.

La suite de lógica contiene comprobaciones del alcance Lite, parser/dictado Unicode, activación personal, parada global, filtros/presentación, sesión, micrófonos sintéticos, mascotas y posiciones del panel. Las pruebas UI recorren ajustes y panel sin acreditar micrófono ni captura real. No confundas una prueba textual o sintética con funcionamiento acústico o con permisos reales.

Consulta [la guía específica de Lite y sus capturas](docs/LITE.md), [la captura del asistente](docs/lite/voz.png), [la captura de filtros](docs/lite/daltonismo.png) y [la guía de evolución entre plataformas](AdaptaPE.md). Esta última también contiene objetivos y brechas: no todas sus propuestas están implementadas aquí.

Esta reescritura del README se contrastó con las fuentes, el script y la configuración Xcode; **no ejecutó builds ni tests**. Las comprobaciones históricas de interfaz están fechadas en `docs/LITE.md`. Quedan por validar en cada equipo el micrófono, disponibilidad local de español, permisos, monitores, filtros sobre contenido real, inicio de sesión, consumo, Intel/Apple Silicon y distribución firmada/notarizada.

## Cuándo elegir macOS Base

Si necesitas cámara, movimiento cinético del puntero o lectura automática bajo el cursor, consulta [Adapta PE Base para macOS](https://github.com/TheAlejo160/Adapta-PE-MacOS-Intel-Apple-Silicon-). Lite mantiene el alcance de voz, lectura explícita, filtros, mascotas y panel, con un proyecto y permisos propios.

También existen la [extensión Lite para Chromium](https://github.com/TheAlejo160/Adapta-PE-Lite), la [extensión Base](https://github.com/TheAlejo160/Adapta-PE), [Windows Lite](https://github.com/TheAlejo160/Adapta-PE-Lite-Win) y [Windows Base](https://github.com/TheAlejo160/Adapta-PE-Win). Cada una tiene su instalación y límites; un ZIP de extensión no instala esta app. Información del proyecto en el [sitio oficial de Adapta PE](https://www.adaptape.cc).

## Autoría y licencia

© 2026 Rodrigo Alejandro Apcho Aliaga, TheAlejo160. El logo Lite y los recursos de mascotas se conservan con sus atribuciones en el repositorio. Consulta [LICENSE](LICENSE): **Creative Commons Atribución-NoComercial-CompartirIgual 4.0 Internacional (CC BY-NC-SA 4.0)**. Publicar las fuentes no modifica esas condiciones de reutilización.
