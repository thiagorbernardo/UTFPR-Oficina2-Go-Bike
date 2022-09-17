var mqtt = require('mqtt')

var options = {
    host: 'b1e2a452af8e41f2b90e79c5002c812a.s2.eu.hivemq.cloud',
    port: 8883,
    protocol: 'mqtts',
    username: 'go-bike-app',
    password: 'X493XJKasd0'
}

// initialize the MQTT client
var client = mqtt.connect(options);

// setup the callbacks
client.on('connect', function () {
    console.log('Connected');
    client.publish('bike/position', 'Hello');
});

client.on('error', function (error) {
    console.log(error);
});