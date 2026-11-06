//
//  CorreoReactivo.swift
//  SwiftData_ejemplo
//
//  Created by Salvador Lopez on 06/11/26.
//

import SwiftUI
import Combine

struct CorreoReactivo: View {

    @State private var correo = ""
    @State private var esValido = false
    @State private var mostrarResultado = false

    // Publisher
    @State private var correoSubject =
        PassthroughSubject<String, Never>()

    var body: some View {
        VStack(spacing: 20) {

            TextField("Escribe tu correo", text: $correo)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: correo) { _, nuevoCorreo in
                    correoSubject.send(nuevoCorreo)
                }

            if mostrarResultado {
                Text(esValido ? "Correo válido" : "Correo inválido")
                    .foregroundStyle(esValido ? .green : .red)
            }
        }
        .padding()
        .onReceive(
            correoSubject
                .debounce(
                    for: .milliseconds(500),
                    scheduler: RunLoop.main
                )
                .map { correo in
                    let patron = #"^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\.[A-Za-z]{2,}$"#

                    return correo.range(
                        of: patron,
                        options: .regularExpression
                    ) != nil
                }
        ) { valido in
            esValido = valido
            mostrarResultado = true
        }
    }
}

#Preview {
    CorreoReactivo()
}
