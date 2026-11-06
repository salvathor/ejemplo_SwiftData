import SwiftUI
import SwiftData

// MARK: - Modelo

/// Modelo persistente de una tarea.
///
/// La macro `@Model` convierte esta clase en un modelo de SwiftData:
/// - Genera el esquema de la tabla a partir de las propiedades almacenadas
///   (aquí, una columna `titulo` de tipo `String`).
/// - Hace la clase observable: SwiftUI se actualiza cuando cambian sus propiedades.
/// - Permite que el `ModelContext` rastree sus cambios para guardarlos.
///
/// Nota: `@Model` solo funciona con clases (`class`), no con `struct`.
@Model
class Tarea {
    var titulo: String

    init(titulo: String) {
        self.titulo = titulo
    }
}

// MARK: - Vista principal de tareas

/// Vista que permite crear tareas y mostrar las que están guardadas.
struct TareasView: View{
    //ENVIRONMENT
    // `ModelContext` es el "espacio de trabajo" de SwiftData: se usa para
    // insertar, eliminar y guardar objetos. Lo recibimos del Environment
    // gracias a `.modelContainer(for:)` declarado en `MyApp`.
    @Environment(\.modelContext)
    private var context

    //QUERY
    // `@Query` obtiene automáticamente todos los objetos `Tarea` del contenedor
    // y mantiene la lista actualizada: cada vez que se inserta, modifica o
    // elimina una tarea, la vista se vuelve a dibujar.
    // También admite orden y filtros, por ejemplo:
    // @Query(sort: \Tarea.titulo) o @Query(filter: #Predicate<Tarea> { !$0.titulo.isEmpty })
    @Query private var tareas: [Tarea]

    //STATE
    // Estado local (no persistente) para el texto que escribe el usuario.
    @State private var titulo = ""

    /// Indica si el texto escrito está vacío (ignorando espacios).
    private var tituloVacio: Bool {
        titulo.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Campo de captura + botón para agregar
                HStack(spacing: 12) {
                    TextField("Nueva tarea", text: $titulo)
                        .padding(12)
                        .background(.background.secondary, in: .rect(cornerRadius: 12))
                        .submitLabel(.done)
                        .onSubmit(agregarTarea)

                    Button(action: agregarTarea) {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(tituloVacio ? Color.gray : Color.accentColor, in: .circle)
                    }
                    .disabled(tituloVacio)
                    .accessibilityLabel("Agregar tarea")
                }
                .padding(.horizontal)

                if tareas.isEmpty {
                    ContentUnavailableView(
                        "Sin tareas",
                        systemImage: "checklist",
                        description: Text("Escribe una tarea y pulsa + para agregarla.")
                    )
                } else {
                    // `Tarea` cumple `Identifiable` automáticamente gracias a `@Model`,
                    // por eso se puede usar directamente en `ForEach`.
                    List {
                        ForEach(tareas) { tarea in
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundStyle(.tint)
                                Text(tarea.titulo)
                                    .font(.body)

                                Spacer()

                                // Botón de borrado de cada fila.
                                // `.borderless` evita que el toque se active al pulsar
                                // cualquier parte de la fila.
                                Button(role: .destructive) {
                                    borrar(tarea)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Borrar \(tarea.titulo)")
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .padding(.top)
            .navigationTitle("Mis tareas")
            .animation(.default, value: tareas.count)
        }
    }

    // MARK: - Acciones

    private func agregarTarea() {
        guard !tituloVacio else { return }
        // 1. Se crea una instancia del modelo (aún solo en memoria).
        let tarea = Tarea(titulo: titulo)
        //contex guardar
        // 2. `insert` registra el objeto en el contexto. SwiftData lo
        //    guarda en disco automáticamente (autosave) y `@Query`
        //    lo refleja de inmediato en la lista.
        //    Si se requiere guardar al instante: `try? context.save()`.
        context.insert(tarea)
        titulo = ""
    }

    private func borrar(_ tarea: Tarea) {
        // `delete` elimina el objeto del contexto; con autosave el cambio se
        // persiste y `@Query` actualiza la lista automáticamente.
        context.delete(tarea)
    }
}


struct ContentView: View {
    var body: some View {
        TareasView()
    }
}

#Preview {
    ContentView()
}
