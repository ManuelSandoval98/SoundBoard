//
//  SoundViewController.swift
//  SandovalSoundBoard
//
//  Created by Manuel Sandoval on 09/10/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    @IBOutlet weak var tiempoLabel: UILabel!
    @IBOutlet weak var volumenSlider: UISlider!

    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    
    var timer: Timer? // Temporizador para actualizar el tiempo de grabación
    var tiempoGrabacion: TimeInterval = 0.0 // Almacena el tiempo transcurrido de la grabación
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            
            // Detener el temporizador cuando se detiene la grabación
            timer?.invalidate()
            tiempoLabel.text = "Tiempo de grabación: \(String(format: "%.2f", grabarAudio!.currentTime)) segundos"
            
        } else {
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            
            // Iniciar el temporizador cuando comienza la grabación
            tiempoGrabacion = 0.0
            tiempoLabel.text = "Tiempo de grabación: 0.00 segundos"
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempo), userInfo: nil, repeats: true)
        }
    }
    
    // Método que actualiza el tiempo de grabación cada segundo
    @objc func actualizarTiempo() {
        tiempoGrabacion += 1.0
        tiempoLabel.text = "Tiempo de grabación: \(String(format: "%.2f", tiempoGrabacion)) segundos"
    }

    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
            reproducirAudio!.volume = volumenSlider.value
        } catch {
            print("Error al reproducir audio")
        }
    }

    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        // Guarda la grabación en CoreData
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        tiempoLabel.text = "Tiempo de grabación: 0.00 segundos" // Inicializa el label
        
        // Configura el slider para cambiar el volumen
        volumenSlider.minimumValue = 0.0
        volumenSlider.maximumValue = 1.0
        volumenSlider.value = 0.5 // Valor inicial
    }
    
    func configurarGrabacion() {
        do {
            // Crear sesión de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            // Crear URL para el archivo de audio
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("Ruta de archivo de audio: \(audioURL!)")
            
            // Configurar opciones de grabación
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            // Crear el objeto grabarAudio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
            
        } catch let error as NSError {
            print("Error al configurar grabación: \(error)")
        }
    }
    
    @IBAction func cambiarVolumen(_ sender: UISlider) {
            // Ajustar el volumen del audio mientras se está reproduciendo
            if let audioPlayer = reproducirAudio {
                audioPlayer.volume = sender.value
            }
        }
    
}
