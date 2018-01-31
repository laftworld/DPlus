var connStr = 'Endpoint=sb://dplus001-eh.servicebus.windows.net/;SharedAccessKeyName=stream;SharedAccessKey=bj9fQvtpmI3HF3uUopkQV8tjr8cJg3R7jft2LteSCzM=;EntityPath=spark-stream';

var EventHubClient = require('azure-event-hubs').Client;
var client = EventHubClient.fromConnectionString(connStr);

client.createSender()
    .then(function(tx) {
        setInterval(function() {
            dev = 'dev' + String(Math.floor((Math.random() * 10) + 1));
            val = String(Math.random());
            console.log(dev + ": " + val);
            tx.on('errorReceived', function(err) {
                console.log(err);
            });
            tx.send({
                device: dev,
                reading: val
            });
        }, 1000);
    })
