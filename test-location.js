var mqtt = require('mqtt')

var options = {
    host: 'broker.mqttdashboard.com',
    port: 1883,
    // protocol: 'mqtts',
    // username: 'go-bike-app',
    // password: 'X493XJKasd0'
}

// initialize the MQTT client
var client = mqtt.connect(options);

// setup the callbacks
client.on('connect', function () {
    console.log('Connected');
    const positions = ['LT:-25.4398,LN:-49.2697,V:1.61',
    'LT:-25.4402,LN:-49.2696,V:1.61',
    'LT:-25.4403,LN:-49.2695,V:1.61',
    'LT:-25.4405,LN:-49.2699,V:1.61',
    'LT:-25.4406,LN:-49.2703,V:1.61',
    'LT:-25.4408,LN:-49.2708,V:1.61',
    'LT:-25.4410,LN:-49.2711,V:1.61',
    'LT:-25.4409,LN:-49.2716,V:1.61',
    'LT:-25.4403,LN:-49.2716,V:1.61',
    'LT:-25.4402,LN:-49.2719,V:1.61',
    'LT:-25.4398,LN:-49.2721,V:1.61',
    'LT:-25.4397,LN:-49.2717,V:1.61',
    'LT:-25.4396,LN:-49.2714,V:1.61',
    'LT:-25.4393,LN:-49.2707,V:1.61',
    'LT:-25.4392,LN:-49.2703,V:1.61',
    'LT:-25.4392,LN:-49.2700,V:1.61',
        'LT:-25.4395,LN:-49.2698,V:1.61']
    
    for (let i = 0; i < positions.length; i++) {
        setTimeout(() => {
            client.publish('bike/location', positions[i]);
        }, 3000 * i);
    }
});

client.on('error', function (error) {
    console.log(error);
});