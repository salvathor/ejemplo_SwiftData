//
//  CorreoReactivo.swift
//  SwiftData_ejemplo
//
//  Created by Salvador Lopez on 06/11/26.
//

import SwiftUI
import Combine

/// Ejemplo de programación reactiva con Combine: valida un correo electrónico
/// mientras el usuario escribe.
///
/// Flujo:
/// ```
/// TextField → onChange → correoSubject.send(texto)
///          → debounce(500 ms) → map(regex) → onReceive → esValido / mostrarResultado
/// ```
///
/// El `debounce` evita validar en cada tecla: solo se valida cuando el usuario
/// deja de escribir durante medio segundo.
struct CorreoReactivo: View {

    /// Texto escrito en el `TextField`.
    @State private var correo = ""
    /// Resultado de la última validación.
    @State private var esValido = false
    /// Se activa tras la primera validación para no mostrar "inválido" al inicio.
    @State private var mostrarResultado = false

    // Publisher
    // `PassthroughSubject` es un publisher al que se le "empujan" valores con
    // `send(_:)` y los reenvía a sus suscriptores. No guarda un valor actual
    // (a diferencia de `CurrentValueSubject`).
    // - `String`: tipo de valor que emite.
    // - `Never`: nunca termina con error.
    // Se guarda en `@State` para que la vista conserve la misma instancia
    // entre redibujados.
    @State private var correoSubject =
        PassthroughSubject<String, Never>()

    var body: some View {
        VStack(spacing: 20) {

            TextField("Escribe tu correo", text: $correo)
                .textFieldStyle(.roundedBorder)
                // Teclado con "@" y "." a la mano.
                .keyboardType(.emailAddress)
                // Evita mayúsculas y autocorrección, que estropean los correos.
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                // Cada cambio del texto se envía al publisher.
                .onChange(of: correo) { _, nuevoCorreo in
                    correoSubject.send(nuevoCorreo)
                }

            if mostrarResultado {
                Text(esValido ? "Correo válido" : "Correo inválido")
                    .foregroundStyle(esValido ? .green : .red)
            }
        }
        .padding()
        // `onReceive` suscribe la vista a un publisher y ejecuta el closure con
        // cada valor emitido. SwiftUI cancela la suscripción al desaparecer la vista.
        .onReceive(
            correoSubject
                // Espera 500 ms sin nuevos valores antes de emitir el último.
                // `RunLoop.main` asegura que el resultado llegue en el hilo principal.
                .debounce(
                    for: .milliseconds(500),
                    scheduler: RunLoop.main
                )
                // Transforma el texto (`String`) en un `Bool` usando una expresión regular:
                // usuario@dominio.ext, con extensión de al menos 2 letras.
                // `#"..."#` es un raw string: las `\` no necesitan escaparse.
                .map { correo in
                    let patron = #"^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\.[A-Za-z]{2,}$"#

                    return correo.range(
                        of: patron,
                        options: .regularExpression
                    ) != nil
                }
        ) { valido in
            // Actualizar el estado redibuja la vista con el nuevo mensaje.
            esValido = valido
            mostrarResultado = true
        }
    }
}

#Preview {
    CorreoReactivo()
}
