'use strict';

// connection string
var connStr = 'Endpoint=sb://dplus001-eh.servicebus.windows.net/;SharedAccessKeyName=stream;SharedAccessKey=bj9fQvtpmI3HF3uUopkQV8tjr8cJg3R7jft2LteSCzM=;EntityPath=spark-stream';

// make connection
var EventHubClient = require('azure-event-hubs').Client;
var client = EventHubClient.fromConnectionString(connStr);

client.open()
    .then(client.getPartitionIds.bind(client))
    .then(function(partitionIds) {
        return partitionIds.map(function(partitionId) {
            return client.createReceiver('$Default', partitionId, {
                'startAfterTime': Date.now()
            }).then(function(receiver) {
                console.log('Create partition receiver: ' + partitionId);
                receiver.on('errorReceived', function(err) {
                    console.log(err.message);
                });
                receiver.on('message', function(msg) {
                    console.log("message received: ");
                    console.log(JSON.stringify(msg.body));
                    console.log('');
                });
            })
        });
    })
    .catch(function(err) {
        console.log(err.message);
    });
