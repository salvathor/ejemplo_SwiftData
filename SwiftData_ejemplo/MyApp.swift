import SwiftUI
import SwiftData

/// Punto de entrada de la aplicación.
///
/// Aquí se configura SwiftData para toda la app mediante el modificador
/// `.modelContainer(for:)`.
@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // MODEL CONTAINER
        // `.modelContainer(for: Tarea.self)` hace tres cosas:
        // 1. Crea un `ModelContainer`: la "base de datos" que conoce el esquema
        //    (en este caso, el modelo `Tarea`) y dónde se guardan los datos
        //    (por defecto, en un archivo SQLite dentro del sandbox de la app).
        // 2. Crea un `ModelContext` principal asociado a ese contenedor.
        // 3. Inyecta ese contexto en el Environment (`\.modelContext`), de modo
        //    que cualquier vista dentro del `WindowGroup` puede usar
        //    `@Environment(\.modelContext)` y `@Query`.
        // Para registrar varios modelos: `.modelContainer(for: [Tarea.self, Otro.self])`.
        .modelContainer(for: Tarea.self)
    }
}
