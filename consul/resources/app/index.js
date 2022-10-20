const express = require('express');

const SERVICE_NAME='mymicroservice';
const SCHEME='http';
const HOST='192.168.100.2';
const PORT=3000;
const PID = process.pid;

/* Inicializacion del server */
const app = express();
const consul = new Consul();

app.get('/health', function (req, res) {
  console.log('Health check!');
  res.end( "Ok." );
});

app.get('/', (req, res) => {
  console.log('GET /', Date.now());
  res.json({
    data: Math.floor(Math.random() * 89999999 + 10000000),
    data_pid: PID
  });
});

app.listen(PORT, function () {
  console.log('Servicio iniciado en:'+SCHEME+'://'+HOST+':'+PORT+'!');
});
