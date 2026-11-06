# SwiftData_ejemplo

Ejemplo mínimo de **SwiftData** con SwiftUI: una lista de tareas en la que el usuario escribe un título, pulsa **+** y la tarea se guarda de forma persistente (sigue ahí al cerrar y volver a abrir la app). Cada tarea tiene un botón 🗑 para borrarla.

## Estructura

| Archivo | Contenido |
| --- | --- |
| `SwiftData_ejemplo/MyApp.swift` | Punto de entrada. Configura el `ModelContainer`. |
| `SwiftData_ejemplo/ContentView.swift` | Modelo `Tarea`, la vista `TareasView` y sus acciones `agregarTarea()` / `borrar(_:)`. |

## Las 4 piezas de SwiftData en este proyecto

### 1. `@Model`: definir qué se guarda

```swift
@Model
class Tarea {
    var titulo: String
    init(titulo: String) { self.titulo = titulo }
}
```

- La macro `@Model` convierte la clase en una entidad persistente; cada propiedad almacenada se vuelve un campo.
- Debe ser una `class`, no un `struct`.
- La clase queda observable y cumple `Identifiable`, así que se puede usar directamente en `List`.

### 2. `.modelContainer(for:)`: crear la base de datos

```swift
WindowGroup { ContentView() }
    .modelContainer(for: Tarea.self)
```

- Crea el `ModelContainer` (el almacén, SQLite por defecto) con el esquema de `Tarea`.
- Crea un `ModelContext` principal y lo inyecta en el Environment para todas las vistas de la escena.

### 3. `@Environment(\.modelContext)`: escribir datos

```swift
@Environment(\.modelContext) private var context

private func agregarTarea() {
    guard !tituloVacio else { return }
    context.insert(Tarea(titulo: titulo))   // Crear
    titulo = ""
}

private func borrar(_ tarea: Tarea) {
    context.delete(tarea)                   // Eliminar
}
```

- El `ModelContext` sirve para **insertar** (`insert`), **eliminar** (`delete`) y **guardar** (`save`).
- Con autosave activado (lo predeterminado) no hace falta llamar a `save()`; los cambios se guardan solos.

### 4. `@Query`: leer datos

```swift
@Query private var tareas: [Tarea]
```

- Lee todas las `Tarea` del contenedor y **mantiene la vista actualizada** cuando los datos cambian.
- Admite orden y filtro:

```swift
@Query(sort: \Tarea.titulo) private var tareas: [Tarea]
@Query(filter: #Predicate<Tarea> { $0.titulo.contains("compra") }) private var compras: [Tarea]
```

## Flujo de datos

```
Usuario escribe → @State titulo
      │
      ▼  botón "+" o tecla "Listo"  → agregarTarea()
Tarea(titulo:)  ──context.insert──▶  ModelContext  ──autosave──▶  ModelContainer (SQLite)
                                          ▲                            │
             botón 🗑 → borrar(_:) ──context.delete                    │
                                                                       ▼
                                     List  ◀── @Query tareas ◀─────────┘
```

Nunca se modifica el arreglo `tareas` directamente: se cambia el **contexto** y `@Query` se encarga de refrescar la vista.

## Cómo se relaciona la interfaz con SwiftData

| Elemento de la UI | Qué hace con SwiftData |
| --- | --- |
| `TextField` + `@State titulo` | Nada todavía: es estado local, no persistente. |
| Botón **+** (deshabilitado si el texto está vacío) | `context.insert(...)` crea la tarea. |
| `List` / `ForEach(tareas)` | Muestra el resultado de `@Query`. |
| Botón 🗑 de cada fila | `context.delete(tarea)` elimina la tarea. |
| `ContentUnavailableView` | Se muestra cuando `@Query` devuelve un arreglo vacío. |
| `.animation(.default, value: tareas.count)` | Anima la lista cuando cambia el número de tareas. |

> El botón de borrar usa `.buttonStyle(.borderless)` para que, dentro de una `List`, solo se active al tocar el ícono y no toda la fila.

## Operaciones CRUD (referencia rápida)

| Operación | Código |
| --- | --- |
| Crear | `context.insert(Tarea(titulo: "Hola"))` |
| Leer | `@Query private var tareas: [Tarea]` |
| Actualizar | `tarea.titulo = "Nuevo"` (basta con modificar la propiedad) |
| Eliminar | `context.delete(tarea)` |
| Guardar explícito | `try context.save()` |

Alternativa para eliminar deslizando la fila (además del botón 🗑):

```swift
List {
    ForEach(tareas) { tarea in
        Text(tarea.titulo)
    }
    .onDelete { indices in
        for i in indices { context.delete(tareas[i]) }
    }
}
```

## Previews

El `#Preview` actual no declara un contenedor, por lo que la vista previa puede fallar. Para que funcione con SwiftData conviene usar uno en memoria:

```swift
#Preview {
    ContentView()
        .modelContainer(for: Tarea.self, inMemory: true)
}
```

## Requisitos

- Xcode 15 o posterior
- iOS 17 / macOS 14 o posterior (versión mínima de SwiftData)
