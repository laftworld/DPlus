// generate data
var ratio = 0.2;
var country = ['Seoul', 'Pusan', 'Kwangju', 'Daejeon', 'Namhae', 'Cheongju', 'Daegu', 'Ulsan', 'Incheon', 'Jeju'];
var users = [];
for (i = 0; i < 10; i++) {
    phone = Math.random();
    phone = (phone < 0.1) ? phone + 0.1 : phone;
    phone = "010" + String((phone > 0.6) ? parseInt((phone - 0.5) * 100000000) : parseInt(phone * 100000000));
    msi = Math.random();
    msi = (msi < 0.5) ? String(parseInt((msi + 0.5) * 1000000)) : String(parseInt(msi * 1000000));
    users[i] = [phone, msi, country[parseInt(Math.random() * 10)]]
}

// connection string
var connStr = 'Endpoint=sb://dplus001-eh.servicebus.windows.net/;SharedAccessKeyName=stream;SharedAccessKey=bj9fQvtpmI3HF3uUopkQV8tjr8cJg3R7jft2LteSCzM=;EntityPath=spark-stream';


// make connection
var EventHubClient = require('azure-event-hubs').Client;
var client = EventHubClient.fromConnectionString(connStr);

// read
client.createSender()
    .then(function(tx) {
        setInterval(function() {
            current = new Date();
            hh = current.getHours().toString();
            ii = current.getMinutes().toString();
            ss = current.getSeconds().toString();
            val01 = current.getFullYear() + '-' + (current.getMonth() + 1) + '-' + current.getDate() + 'T'
                    + (hh[1] ? hh : "0" + hh[0]) + ':'
                    + (ii[1] ? ii : "0" + ii[0]) + ':'
                    + (ss[1] ? ss : "0" + ss[0]);

            from = parseInt(Math.random() * 10);
            do {
                to = parseInt(Math.random() * 10);
            } while (to == from);

            loc = (Math.random() < ratio) ? country[parseInt(Math.random() * 10)] : users[from][2];
            data_for_send = {
                CallrecTime: val01,
                SwitchNum: loc,
                CallingNum: users[from][0],
                CallingIMSI: users[from][1],
                CalledNum: users[to][0],
                CalledIMSI: users[to][1]
            }
            console.log(data_for_send);

            tx.on('errorReceived', function(err) {
                console.log(err);
            });
            tx.send(data_for_send);
        }, 1000);
    })
