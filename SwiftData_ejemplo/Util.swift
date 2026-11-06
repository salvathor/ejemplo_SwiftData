//
//  Untitled.swift
//  SwiftData_ejemplo
//
//  Created by Salvador Lopez on 06/11/26.
//

import Foundation


struct Usuario: Decodable {
    let id: Int
    let name: String
    let username: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case email
    }
}


func obtenerUsuario() async {
    // Definir la URL
    // `URL(string:)` devuelve un opcional; si la URL no es válida, salimos.
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/users/1") else { return }
    
    // Crear petición
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    do {
        // Ejecutar la petición
        
        let (data,response) = try await URLSession.shared.data(for: request)
        
        // Validar el código HTTP
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Error en la respuesta HTTP")
            return
        }
        
        // Convertir los datos
        
        // String
        let resultado = String(data: data, encoding: .utf8)
        print(resultado ?? "Sin contenido")
        
        // JSON a Objeto [Usuario]
        
        let usuario = try JSONDecoder().decode(Usuario.self, from: data)
        
        print("ID: \(usuario.id)")
        print("Nombre: \(usuario.name)")
        print("Correo: \(usuario.email)")
        
        
        
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
