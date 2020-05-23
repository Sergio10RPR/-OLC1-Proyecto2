package main
import ("fmt"; "io/ioutil")

type Pagina struct{
  Titulo string
  Cuerpo []byte
}
func main(){
  
  pag1 := &Pagina{Titulo: "Prueba 1", Cuerpo: []byte("Este es el cuerpo")}
  pag1.guardar()
  
  pag2, _ := cargarPagina("Prueba 1")
  fmt.Println(string(pag2.Cuerpo))
}
//Método de registros Pagina, almacena el cuerpo
func ( p* Pagina ) guardar() error {
  nombre := p.Titulo + ".html"
  return ioutil.WriteFile( nombre, p.Cuerpo, 0600)
}
//Función que carga una página desde disco
func cargarPagina( titulo string ) (*Pagina, error) {
  nombre_archivo := titulo + ".html"
  cuerpo, err := ioutil.ReadFile( nombre_archivo )
  if err != nil {
    return nil, err
  }
  return &Pagina{Titulo: titulo, Cuerpo: cuerpo}, nil
