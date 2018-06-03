// index.js
const path = require('path')
const express = require('express')
const exphbs = require('express-handlebars')
const bodyParser= require('body-parser')
const crypto = require("crypto")
const TextEncoder = require('text-encoding').TextEncoder;
const Web3 = require('web3');
const app = express()
var web3provider;
var MongoClient = require('mongodb').MongoClient;
var url = "mongodb://localhost:27017/ticksell";
var dbo;
var ContractUsers;
const address='0xd49186534cac094b040306f316aa11e20cd51e58';
MongoClient.connect(url, function(err, db) {
  if (err) throw err;
  dbo = db.db("ticksell");
  app.listen(3000, function () {
    console.log('App listening on port 3000!')

    if (typeof web3 !== 'undefined') {
      console.log("siiii");
      web3Provider = web3.currentProvider;
    } else {
      console.log("ganache");
      // If no injected web3 instance is detected, fall back to Ganache
      web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(web3Provider);
    web3.eth.getAccounts(function(error, accounts) {
      web3.eth.defaultAccount = accounts[0];
      console.log(web3.eth.defaultAccount);
      ContractUsers.methods.getUserHash(address).call().then(function(result){
        console.log(web3.utils.hexToUtf8(result));
      });

    });


    var abiTickets= '[\
    {\
      "inputs": [\
        {\
          "name": "_userContract",\
          "type": "address"\
        }\
      ],\
      "payable": false,\
      "stateMutability": "nonpayable",\
      "type": "constructor"\
    },\
    {\
      "constant": false,\
      "inputs": [\
        {\
          "name": "i",\
          "type": "uint256"\
        }\
      ],\
      "name": "getEventsSize",\
      "outputs": [\
        {\
          "name": "",\
          "type": "uint256"\
        }\
      ],\
      "payable": false,\
      "stateMutability": "nonpayable",\
      "type": "function"\
    },\
    {\
      "constant": false,\
      "inputs": [\
        {\
          "name": "i",\
          "type": "uint256"\
        }\
      ],\
      "name": "getEventName",\
      "outputs": [\
        {\
          "name": "",\
          "type": "bytes32"\
        }\
      ],\
      "payable": false,\
      "stateMutability": "nonpayable",\
      "type": "function"\
    },\
    {\
      "constant": false,\
      "inputs": [\
        {\
          "name": "_id",\
          "type": "bytes32"\
        },\
        {\
          "name": "_nome",\
          "type": "bytes32"\
        },\
        {\
          "name": "_ticketsType",\
          "type": "bytes32[]"\
        },\
        {\
          "name": "_maxTicketPerson",\
          "type": "uint256"\
        },\
        {\
          "name": "_ticketPrices",\
          "type": "uint256[]"\
        },\
        {\
          "name": "_ticketLeft",\
          "type": "uint256[]"\
        }\
      ],\
      "name": "addEvent",\
      "outputs": [],\
      "payable": false,\
      "stateMutability": "nonpayable",\
      "type": "function"\
    },\
    {\
      "constant": false,\
      "inputs": [\
        {\
          "name": "idEvent",\
          "type": "bytes32"\
        },\
        {\
          "name": "typeTicket",\
          "type": "bytes32"\
        },\
        {\
          "name": "quantity",\
          "type": "uint256"\
        }\
      ],\
      "name": "buy",\
      "outputs": [\
        {\
          "name": "",\
          "type": "uint256"\
        }\
      ],\
      "payable": true,\
      "stateMutability": "payable",\
      "type": "function"\
    }\
  ]';
    var abiUsers = '[\
    {\
      "constant": true,\
      "inputs": [\
        {\
          "name": "",\
          "type": "address"\
        }\
      ],\
      "name": "UserHash",\
      "outputs": [\
        {\
          "name": "",\
          "type": "bytes32"\
        }\
      ],\
      "payable": false,\
      "stateMutability": "view",\
      "type": "function"\
    },\
    {\
      "constant": true,\
      "inputs": [],\
      "name": "owner",\
      "outputs": [\
        {\
          "name": "",\
          "type": "address"\
        }\
      ],\
      "payable": false,\
      "stateMutability": "view",\
      "type": "function"\
    },\
    {\
      "inputs": [],\
      "payable": false,\
      "stateMutability": "nonpayable",\
      "type": "constructor"\
    },\
    {\
      "constant": false,\
      "inputs": [\
        {\
          "name": "_account",\
          "type": "address"\
        }\
      ],\
      "name": "getUserHash",\
      "outputs": [\
        {\
          "name": "",\
          "type": "bytes32"\
        }\
      ],\
      "payable": false,\
      "stateMutability": "nonpayable",\
      "type": "function"\
    },\
    {\
      "constant": false,\
      "inputs": [\
        {\
          "name": "who",\
          "type": "address"\
        },\
        {\
          "name": "hash",\
          "type": "bytes32"\
        }\
      ],\
      "name": "setNewUser",\
      "outputs": [],\
      "payable": false,\
      "stateMutability": "nonpayable",\
      "type": "function"\
    }\
  ]';

  ContractUsers = new web3.eth.Contract(JSON.parse(abiUsers), '0x3a2d0473907595d640d5730a270733caac1b4325');
  ContractTickets = new web3.eth.Contract(JSON.parse(abiTickets), '0xd72145b684a4add805885fb9a17814bff79787ff');

  //console.log(ContractUsers);
  /*ContractUsers.methods.setNewUser(address, web3.utils.asciiToHex('121212'), {gas: 999999}).call().then(function(err,result){
    console.log(err);
  });*/




  })
});

app.use(bodyParser.urlencoded({extended: true}))

app.engine('.hbs', exphbs({
  defaultLayout: 'home',
  extname: '.hbs',
  layoutsDir: path.join(__dirname, 'views/layouts'),
  helpers: {
    toJSON : function(object) {
      return JSON.stringify(object).replace(/[\/\(\)\']/g, "\\$&");
    }
  }
}))
app.set('view engine', '.hbs')
app.set('views', path.join(__dirname, 'views'))
app.post('/', (req, res) => {
  console.log("ok")
  //console.log(req.body);
  ContractTickets.methods.buy(req.body.id[0], req.body.type[0], req.type.quantity[0]).send({from:web3.eth.defaultAccount, to:'0x2ffe4f0e841655d2711449dfc5a756faaaf84482', value:"100000"});
  //res.render('main');
})
app.get('/', (req, res) => {

  dbo.collection("events").find().toArray(function(err, data) {
    if (err) throw err;
      let eventsi=[];

      data.forEach(function(item, index){
          let dict={}
          item.ticketstype=item.ticketstype.split(", ");
          item.ticketsprice=item.ticketsprice.split(", ");
          for(i=0;i<item.ticketstype.length;i++){
            dict[item.ticketstype[i]]=item.ticketsprice[i];
          }
          item.ticketsdict=dict;
          eventsi.push(item);
      })
      //console.log(eventsi);
      res.render('main', {
        events:eventsi
      })

  })

})
app.post('/addEvents',(req, res) => {
  var myobj = {name: req.body.name, date: req.body.date, desc: req.body.description, place: req.body.place, ticketstype:req.body.ticketstype, ticketsprice:req.body.ticketsprice, maxticket:req.body.maxticket  }
  dbo.collection("events").insertOne(myobj, function(err, res2) {
    if (err) throw err;
    console.log(res2);
    var ticktype=myobj.ticketstype.split(",");
    var tickprices=myobj.ticketsprice.split(",");
    var i;
    for(i=0;i<ticktype.length;i++){
      ticktype[i]=web3.utils.asciiToHex(ticktype[i]);
    }
    for(i=0;i<tickprices.length;i++){
      tickprices[i]=parseInt(tickprices[i]);
    }
    //hextoasciii sull'id?
    var id="0x"+res2.insertedId
    console.log("ID:"+id)
    console.log("add: "+ web3.eth.defaultAccount)
    console.log(id, web3.utils.asciiToHex(myobj.name), parseInt(myobj.date), parseInt(myobj.date)+10000, ticktype, myobj.maxticket, tickprices, [100,100])
    ContractTickets.methods.addEvent( id, web3.utils.asciiToHex(myobj.name), ticktype, myobj.maxticket, tickprices, [100,100] ).send({from: web3.eth.defaultAccount , gas: 6000000 }).then(function(error, accounts) {console.log(error)});
    //ContractTickets.methods.addEvent( web3.utils.asciiToHex(myobj.name), web3.utils.asciiToHex(myobj.name),  myobj.maxticket).send({from: web3.eth.defaultAccount, gas: 6000000 }).then(function(error, accounts) {console.log(error)});

    res.render('addEvent')
  });

}
)
app.get('/addEvents', (req, res) => {
  res.render('addEvent')
})
app.get('/addUser', (req, res) => {
  res.render('addUser')
})
app.post('/addUser', (req, res) => {
  console.log(req.body);
  var myobj = { name: req.body.name, address: req.body.address, documento: "ASPOEODJIA£" , nounce:makeNounce(), approved:0};
  console.log(myobj);
  dbo.collection("users").insertOne(myobj, function(err, res) {
    if (err) throw err;
    console.log("1 document inserted");
  });
  res.render('addUser')
})
app.get('/validateUsers', (req, res) => {
      var query = { approved: 0 };

      dbo.collection("users").find(query).toArray(function(err, data) {
        if (err) throw err;

        if(req.query.id){
          data.forEach(function(item, index){
            if(item._id==req.query.id){
              var hashstr = web3.utils.sha3(item.name+""+item.address+""+item.nounce, {encoding: 'hex'})
              dbo.collection("users").updateOne(
               { _id: item._id },
               {
                 $set: { approved:1, hash:hashstr },
                 $currentDate: { lastModified: true }
               }
            )

            console.log("from: "+web3.eth.defaultAccount);
            console.log("hash:"+hashstr);
            console.log("address: "+ item.address);
            ContractUsers.methods.setNewUser(item.address,hashstr).send({from: web3.eth.defaultAccount}).then(function(error, accounts) {console.log(error)});


            }

          });
        }
        res.render('approveUser', { data:data, query:req.query });
        });
    });

function makeNounce() {
  var text = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  for (var i = 0; i < 9; i++)
    text += possible.charAt(Math.floor(Math.random() * possible.length));

  return text;
}
