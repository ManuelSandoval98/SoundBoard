//
//  ViewController.swift
//  SandovalSoundBoard
//
//  Created by Manuel Sandoval on 09/10/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
    }
    
    // Número de filas en la tabla basado en el número de grabaciones
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }
    
    // Configuración de cada celda
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil) // Cambiamos el estilo a "subtitle"
        let grabacion = grabaciones[indexPath.row]
        
        // Mostramos el nombre de la grabación
        cell.textLabel?.text = grabacion.nombre
        
        // Determinar la duración del audio
        do {
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            let duracion = reproducirAudio?.duration ?? 0 // Obtener la duración en segundos
            
            // Mostrar la duración en el subtítulo de la celda
            cell.detailTextLabel?.text = "Duración: \(String(format: "%.2f", duracion)) segundos"
        } catch {
            print("Error al intentar reproducir el audio: \(error)")
        }
        
        return cell
    }
    
    // Cargar las grabaciones al aparecer la vista
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            grabaciones = try context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        } catch {
            print("Error al obtener las grabaciones de CoreData")
        }
    }
    
    // Reproducir el audio cuando se selecciona una fila
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do {
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            reproducirAudio?.play()
        } catch {
            print("Error al reproducir audio")
        }
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    
    // Permitir eliminar grabaciones con un swipe
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            } catch {
                print("Error al eliminar grabación")
            }
        }
    }

}
