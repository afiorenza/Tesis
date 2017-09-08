const neo4j = require('neo4j-driver').v1;
const argv = require('yargs').argv

const uri = 'bolt://localhost:7687'
const user = 'neo4j'
const password = 'root'
const {lumenes = 0, grados = 0, decibelios = 0, tipoPuesto = 'delicado'} = argv

const driver = neo4j.driver(uri, neo4j.auth.basic(user, password));
const session = driver.session();

session
 .run(`WITH {lumenes: ${lumenes}, grados: ${grados}, decibelios: ${decibelios}, tipoPuesto: '${tipoPuesto}'} as Parametros
  MATCH p = (S:Nodo:Alternativa{nivel:0,indice:0})-[:Decision*]->(T:Nodo:Terminal)
  WHERE ALL(r in relationships(p) WHERE
  (r.tipo = 'mayor' AND Parametros[r.propiedad] > r.valor) OR
  (r.tipo = 'menor' AND Parametros[r.propiedad] <= r.valor) OR
  (r.tipo = 'derecha' AND Parametros[r.propiedad] = 'delicado') OR
  (r.tipo = 'izquierda' AND Parametros[r.propiedad] <> 'delicado')
  OR (r.obligatorio = true)
 )
 RETURN T.resultado`)
  .subscribe({
   onNext: function (record) {
    console.log(record.toObject()['T.resultado']);
   },
   onCompleted: function () {
    session.close();
  }
})
