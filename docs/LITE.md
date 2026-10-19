# Adapta PE Lite para macOS

Edición reducida con dos funciones: asistente de voz completo y siete filtros de daltonismo. Mantiene la estructura visual de la aplicación base y el alcance de la extensión Lite. Usa el logo `AdaptaPELite.png` proporcionado por el autor, con todos los tamaños del icono macOS y una imagen independiente para la cabecera.

## Abrir y ejecutar

Abre `Adapta-PE-Lite.xcodeproj` y selecciona el esquema **Adapta-PE-Lite**. Requiere macOS 14 o posterior y Xcode compatible con grupos sincronizados. La firma usa el equipo ya configurado en el proyecto base; puedes cambiarlo en Signing & Capabilities.

```sh
./script/build_and_run.sh --verify
```

El script compila y abre esta aplicación independiente. Para compilar y ejecutar las pruebas sin firma de distribución:

```sh
xcodebuild -project Adapta-PE-Lite.xcodeproj -scheme Adapta-PE-Lite \
  -destination 'platform=macOS' -derivedDataPath /tmp/adapta-pelite-build \
  CODE_SIGNING_ALLOWED=NO test
```

## Instalación local desde terminal

Desde la carpeta de este proyecto, configura tu firma en Xcode y cierra Lite antes de reemplazar su bundle:

```sh
xcodebuild -project Adapta-PE-Lite.xcodeproj -scheme Adapta-PE-Lite \
  -configuration Release -derivedDataPath build/lite build
mkdir -p "$HOME/Applications"
ditto build/lite/Build/Products/Release/Adapta-PE-Lite.app "$HOME/Applications/Adapta-PE-Lite.app"
open "$HOME/Applications/Adapta-PE-Lite.app"
```

El proyecto incluye un equipo de firma del autor: cámbialo por el tuyo si no tienes acceso. Instalar localmente no acredita firma/notarización para distribución. `build/`, bundles, DMG y estado personal de Xcode se excluyen de Git; fuentes, iconos y pruebas se conservan. Es una aplicación independiente con sus propias fuentes.

## Funciones

- **Asistente de voz:** palabra de activación personalizable, señal de escucha, dictado Unicode, apps, sitios, búsqueda, pestañas, ventanas, monitores, teclado, menús, campos, selección, clic y clic derecho. Mantiene respuestas habladas, lectura bajo una orden explícita y elecciones numeradas del asistente base.
- **Daltonismo:** protanomalía, protanopía, deuteranomalía, deuteranopía, tritanomalía, tritanopía y acromatopsia. Comparte las matrices de las versiones web y base. Son simulaciones de color; no una corrección médica.
- **Segundo plano:** cerrar ajustes no termina la app. Barra de menú para abrir ajustes, activar voz, cambiar filtros, detener todo o salir. Panel flotante sin robar foco, con arrastre libre o anclaje a esquina/monitor, posición recordada y mascota opcional unida arriba; conserva transcripción, respuesta y elecciones. Inicio de sesión opcional, recuperación después del reposo y preferencias propias de Lite.

No incluye cámara, cursor cinético, lectura automática bajo el cursor ni IA externa. Esos motores no se compilan en Lite. La lectura solicitada por voz pertenece al asistente; no activa TalkBack automático.

## Permisos y privacidad

Micrófono y reconocimiento de voz se solicitan al activar el asistente. Accesibilidad permite controlar y leer otras apps. Grabación de pantalla se solicita sólo al activar un filtro. Automatización se solicita cuando el control del navegador la necesita. Lite no solicita acceso a cámara.

El reconocimiento local es el valor predeterminado; Apple por red sólo se permite mediante una opción explícita. Los filtros se procesan localmente, sin guardar ni enviar imágenes. No se guardan grabaciones ni transcripciones. El primer inicio deja la asistencia apagada. Los inicios posteriores restauran los módulos recordados sólo con permisos ya concedidos. **Detener todo** apaga ambos módulos y recuerda ese estado; **Salir** conserva la configuración para el próximo inicio.

El identificador `com.thealejo.Adapta-PE-Lite` separa sus preferencias y permisos de la aplicación base. Conviene evitar activar simultáneamente filtros o asistentes en ambas ediciones.

## Código local y comprobaciones

Este proyecto incluye sus propias fuentes de voz, parser, acciones, catálogo de apps, Accesibilidad y filtros. No referencia archivos, bundles ni proyectos de Adapta PE Base. No contiene TrackingManager, KineticState, OptionalAI ni TalkBackManager. No usa condiciones de compilación para cambiar entre Base y Lite.

Las pruebas comprueban alcance Lite, dictado Unicode, matrices, apagado y memoria de sesión, lanzamiento al iniciar sesión y anclaje del panel. La prueba de interfaz comprueba ambas secciones, panel flotante y continuidad al cerrar ajustes, sin activar micrófono ni filtros. También guarda capturas de las dos secciones.

El micrófono real, español local, permisos, filtros sobre varias pantallas e inicio de sesión requieren validación en el equipo. Compilar y pasar las pruebas sin sensores no acredita esas condiciones físicas. Firma y notarización de distribución se realizan desde Xcode.

## Vista previa y validación de esta revisión

[Asistente de voz](lite/voz.png) · [Daltonismo](lite/daltonismo.png)

El 3 de octubre de 2026, la Lite independiente pasó las pruebas de lógica e interfaz con firma de desarrollo y Xcode 27, desde esta raíz. Se comprobó el cierre de ajustes, el panel flotante y las dos secciones, sin activar micrófono ni captura de pantalla. Base también pasó sus regresiones tras retirar los archivos Lite. Las capturas muestran la interfaz real; el diseño se conserva durante la separación.

El repositorio conserva su historia inicial y publica el proyecto independiente, sus fuentes, iconos, pruebas y documentación. Los respaldos temporales y productos generados quedan fuera de la distribución.

## Mascota opcional y pantalla completa · 11 de octubre de 2026

La tercera sección, Mascota, permite elegir Tinku, Cuchu o Yati, ocultarla, saludar, dormir y despertar. Se carga sólo el atlas elegido, con entrada/salida y tiempos originales; la suspensión y movimiento reducido detienen el temporizador. Voz y lectura manual cambian su animación durante la salida TTS real. Nombre, monitor y posición relativa se guardan en preferencias propias. Arrastra su nombre o usa las flechas. Los sprites dejan pasar clics.

Filtros y mascota se unen a otros Spaces y apps en pantalla completa; los filtros se reconstruyen al cambiar pantallas. Contenido protegido o presentación exclusiva puede impedir composición. Consulte el README para comandos, límites y pruebas. El proyecto sigue sin importar cámara, cinética, IA o TalkBack automático de la edición completa.

## Panel y mascota · 11 de octubre de 2026

Opciones reúne compañía, unión/separación, filtros, esquina y monitor. El título admite arrastre o flechas; se guarda posición relativa. La mascota unida se mueve con PiP; independiente recupera su ubicación propia. Descansa tras 90 segundos sin interacción; lectura/habla impiden descanso automático. El sueño manual exige despertar. Teléfono/laptop terminan en reposo; TTS real activa lectura/habla. Contenido sobre fondo sólido; Ajustes utiliza Liquid Glass en macOS 26 y estilo sencillo en versiones anteriores o al reducir transparencia. Tres pruebas de lógica cubren el alcance independiente, recursos/comandos y posiciones/actividad, sin activar sensores.
