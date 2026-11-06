import SwiftUI
import SwiftData

@Model
class Tarea {
    var titulo: String
    
    init(titulo: String) {
        self.titulo = titulo
    }
}

struct TareasView: View{
    //ENVIRONMENT
    @Environment(\.modelContext)
    private var context
    
    //QUERY
    @Query private var tareas: [Tarea]
    
    //STATE
    @State private var titulo = ""
    
    var body: some View {
        VStack{
            TextField("Nueva tarea", text:$titulo)
                .textFieldStyle(.roundedBorder)
            
            Button("Agregar") {
                let tarea = Tarea(titulo: titulo)
                //contex guardar
                context.insert(tarea)
                titulo = ""
            }
            
            List(tareas) { tarea in
                Text(tarea.titulo)
            }
        }
        .padding()
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
