//
//  Untitled.swift
//  SwiftData_ejemplo
//
//  Created by Salvador Lopez on 06/11/26.
//

import Foundation


// MARK: - Modelo de red

/// Representa a un usuario devuelto por la API de jsonplaceholder.
///
/// `Decodable` permite crear un `Usuario` a partir de JSON con `JSONDecoder`.
/// Solo se declaran las propiedades que interesan; las demás claves del JSON
/// (`address`, `phone`, `company`, …) se ignoran.
///
/// Nota: este `struct` NO es un modelo de SwiftData (no tiene `@Model`),
/// por lo que no se guarda en disco: solo vive en memoria.
struct Usuario: Decodable {
    let id: Int
    let name: String
    let username: String
    let email: String

    /// Relaciona cada propiedad con su clave en el JSON.
    ///
    /// El valor después del `=` debe ser el nombre EXACTO de la clave en el JSON,
    /// por ejemplo `case nombre = "name"`. Como aquí las propiedades se llaman
    /// igual que las claves, este `enum` es opcional: Swift lo genera solo.
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case email
    }
}


// MARK: - Petición HTTP

/// Descarga el usuario con id 1 de jsonplaceholder e imprime sus datos en la consola.
///
/// Usa `async/await`: la función se suspende mientras espera la respuesta de la
/// red sin bloquear la interfaz. Se llama desde `ContentView` con `.task { }`.
///
/// Pasos:
/// 1. Construir la `URL` y el `URLRequest`.
/// 2. Ejecutar la petición con `URLSession.shared.data(for:)`.
/// 3. Validar que el código HTTP sea 200.
/// 4. Convertir los bytes (`Data`) a texto y a un objeto `Usuario`.
func obtenerUsuario() async {
    // Definir la URL
    // `URL(string:)` devuelve un opcional; si la URL no es válida, salimos.
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/users/1") else { return }

    // Crear petición
    // GET es el método por defecto; se declara explícitamente con fines didácticos.
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    do {
        // Ejecutar la petición

        // `try`: la llamada puede lanzar un error (sin conexión, timeout, …).
        // `await`: la función se suspende hasta que llega la respuesta.
        // Devuelve una tupla: los bytes del cuerpo (`data`) y los metadatos (`response`).
        let (data,response) = try await URLSession.shared.data(for: request)

        // Validar el código HTTP
        // `response` es un `URLResponse` genérico; se convierte a `HTTPURLResponse`
        // para leer el `statusCode`. Cualquier valor distinto de 200 se trata como error.
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Error en la respuesta HTTP")
            return
        }

        // Convertir los datos

        // String
        // Útil para depurar: muestra el JSON tal como llegó del servidor.
        let resultado = String(data: data, encoding: .utf8)
        print(resultado ?? "Sin contenido")

        // JSON a Objeto [Usuario]

        // `JSONDecoder` mapea las claves del JSON a las propiedades de `Usuario`
        // usando `CodingKeys`. Si falta una clave o el tipo no coincide, lanza
        // un error y la ejecución salta al `catch`.
        let usuario = try JSONDecoder().decode(Usuario.self, from: data)

        print("ID: \(usuario.id)")
        print("Nombre: \(usuario.name)")
        print("Correo: \(usuario.email)")



    } catch {
        // Captura errores de red y de decodificación.
        // Tip: `print(error)` muestra el detalle completo (p. ej. qué clave faltó).
        print("Error: \(error.localizedDescription)")
    }
}
