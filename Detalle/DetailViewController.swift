//
//  DetailViewController.swift
//  Detalle
//
//  Created by olver on 1/1/16.
//  Copyright (c) 2016 olver. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UISearchBarDelegate, NSURLConnectionDelegate{

    @IBOutlet weak var portada: UILabel!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var buscado: UILabel!
    @IBOutlet weak var autores: UITextView!
    var isbn: String = ""
    lazy var data = NSMutableData()
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                //label.text = detail.valueForKey("timeStamp")!.description
                label.text = isbn as String
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.buscado.text = isbn as String
        print(isbn)
        self.status.text = "Buscando...."
        startConnection(isbn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func startConnection(ISBN: String){
        let urlPath: String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        
        var url: NSURL = NSURL(string: urlPath+ISBN)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        status.text = "Encontrado..."
        var err: NSError
        // throwing an error on the line below (can't figure out where the error message is)
        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
        //println(jsonResult)
        let resultadoJson = jsonResult as NSDictionary
        //Definimos la estructura
        let dico1 = resultadoJson["ISBN:"+isbn]
        if (dico1 != nil && dico1 is NSDictionary) {
            
            let resultado = dico1 as! NSDictionary
            
            //obtenemos los autores Autores
            let autores = resultado["authors"]
            
            var cadenaAutores : String = ""
            
            if (autores != nil && autores is NSArray) {
                let a_autores = autores as! NSArray
                for (var i : Int = 0 ; i < a_autores.count; i++) {
                    let dicAutor = a_autores[i]
                    if (dicAutor is NSDictionary) {
                        let autor = dicAutor as! NSDictionary
                        cadenaAutores += dicAutor["name"] as! String + "\n"
                    }
                    
                }
                self.autores.text = cadenaAutores
                
            }
            let titulo = resultado.valueForKey("title")
            if (titulo != nil ) {
                if (titulo is NSString) {
                    let t_titulo = titulo as! String
                    self.titulo.text = t_titulo
                }
            }
            let portada = resultado.valueForKey("cover")
            if (portada != nil){
                if (portada is NSDictionary) {
                    let d_portada = portada as! NSDictionary
                    let m_portada = d_portada["medium"]
                    if (m_portada != nil) {
                        print (m_portada)
                        if let url = NSURL(string: m_portada as! String) {
                            if let data = NSData(contentsOfURL: url) {
                                self.portada.text = ""
                                self.imagen.image = UIImage(data: data)
                            }
                        }
                    }
                }
                
                print (portada)
            } else {
                imagen.image = nil
                self.portada.text = "Sin portada"
            }
            data = NSMutableData()
        }else{
            self.status.text = "ISBN no encontrado"
            self.autores.text = ""
            self.titulo.text = ""
            self.portada.text = ""
            self.imagen.image = nil
        }
    }
    

}

