var moment = require('moment');
var randomjs = require("random-js")();
var schedule = require('node-schedule');
var cassandra = require('cassandra-driver');

// cassandra parameters
var client = new cassandra.Client({contactPoints: ['127.0.0.1'], keyspace: 'tesis'});
var query = 'INSERT INTO sensores (fechahoralectura, area, puesto, datos,tipodepuesto) VALUES (?, ?, ?, ?, ?)';

// scheduler parameters
var start =  moment();
var end = moment().add(7, 'days');
var rule = new schedule.RecurrenceRule();
rule.second = [0, 10, 20, 30, 40, 50];

// quantity of nodes
const AREASQTY = 4;
const NODESQTY = 20;

// randomjs parameters
const MAXTEMPERATURA = 20;
const MINTEMPERATURA = 35;
const MAXLUMINOSIDAD = 1050;
const MINLUMINOSIDAD = 450;
const MAXDECIBELIOS = 150;
const MINDECIBELIOS = 100;
const TYPEOFWORK = ['delicado', 'caldera'];

var j = schedule.scheduleJob({start, end, rule}, function() {
  for (var areaIndex = 1; areaIndex <= AREASQTY; areaIndex++) {
    for (var nodeIndex = 1; nodeIndex <= NODESQTY; nodeIndex++) {
      console.log(`Area ${areaIndex}, Puesto ${nodeIndex}`);
      let timestamp = new Date();
      let temperatura = randomjs.real(MINTEMPERATURA, MAXTEMPERATURA);
      let luminosidad = randomjs.real(MINLUMINOSIDAD, MAXLUMINOSIDAD);
      let decibelios = randomjs.real(MINDECIBELIOS, MAXDECIBELIOS);
      let tipoDeTrabajo = (nodeIndex % 2 === 1) ? TYPEOFWORK[0] : TYPEOFWORK[1];

      client.execute(query, [moment(), areaIndex, nodeIndex, {temperatura, luminosidad, decibelios}, tipoDeTrabajo]);
    }
  }
});
