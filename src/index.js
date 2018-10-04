// index.js
var ticketAddr='0xafd62a85038a89e3d8c0e4243fe42945f0d88011';
var userAddr='0xada79a6a421750feaae356e6fadc35a217441124';
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
    //console.log(web3.version.api)
    web3.eth.getAccounts(function(error, accounts) {
      web3.eth.defaultAccount = accounts[0];
      console.log(web3.eth.defaultAccount);
      //ContractUsers.methods.getUserHash(address).call().then(function(result){
    //    console.log(web3.utils.hexToUtf8(result));
    //  });

    });

    var fs = require('fs');
    var obj = JSON.parse(fs.readFileSync('src/ABI/Events.json', 'utf8'));
    var abiTickets=JSON.stringify(obj.abi);
    obj = JSON.parse(fs.readFileSync('src/ABI/ValidatedAddresses.json', 'utf8'));
    var abiUsers=JSON.stringify(obj.abi);
    ContractTickets = new web3.eth.Contract(JSON.parse(abiTickets), ticketAddr);
    ContractUsers = new web3.eth.Contract(JSON.parse(abiUsers), userAddr);
    //console.log(ContractUsers);
  })
});

app.use(bodyParser.urlencoded({extended: true}))
app.use(express.static('src'));

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
  //ContractTickets.methods.buy(req.body.id[0], req.body.type[0], req.type.quantity[0]).send({from:web3.eth.defaultAccount, to:'0x2ffe4f0e841655d2711449dfc5a756faaaf84482', value:"100000"});
  //res.render('main');
})
app.get('/reseller1', (req, res) => {
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
      res.render('reseller1', {
        events:eventsi.reverse()
      })

  })

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
        events:eventsi.reverse()
      })

  })

})
app.get('/trading', (req, res) => {
  dbo.collection("events").find().toArray(function(err, data) {
    if (err) throw err;
  res.render('trade', {
    events:data
  })

})

})
app.get('/user', (req, res) => {
  res.render('user')
})
app.post('/user', (req, res) => {
  var ad = req.body.addr;
  var nam= req.body.name;
  var nounce = req.body.nounce;
  var idEven=req.body.idEvent;
  var hashstr = web3.utils.sha3(nam+""+ad+""+nounce, {encoding: 'hex'})
  /*ContractTickets.methods.getEventTicketBought(idEven).call().then(function(result){
    console.log("Biglietti: "+result);
  });
  ContractUsers.methods.getUserHash(ad).call().then(function(result){
    if(result==hashstr){
      console.log("Utente verificato")
    }else{
      console.log("Utente non verificato")
  }*/

  res.render('user')

})
app.post('/addEvents',(req, res) => {
  var myobj = {name: req.body.name, date: req.body.date, desc: req.body.description, place: req.body.place, ticketstype:req.body.ticketstype, ticketsprice:req.body.ticketsprice, maxticket:req.body.maxticket, image:req.body.image, bought:[]  }
  dbo.collection("events").insertOne(myobj, function(err, res2) {
    if (err) throw err;
    console.log(res2);
    var lowsec=[];
    var upsec=[];
    var ticktype=myobj.ticketstype.split(",");
    var tickprices=myobj.ticketsprice.split(",");
    var i;
    for(i=0;i<ticktype.length;i++){
      ticktype[i]=web3.utils.asciiToHex(ticktype[i]);
    }
    for(i=0;i<tickprices.length;i++){
      tickprices[i]=web3.utils.toWei(tickprices[i].replace(/\s/g, ''), 'ether');
      console.log("price: "+tickprices[i]);
      lowsec[i]=web3.utils.toWei(tickprices[i].replace(/\s/g, ''), 'ether');
      upsec[i]=web3.utils.toWei(tickprices[i].replace(/\s/g, ''), 'ether');
    }
    //hextoasciii sull'id?
    var id="0x"+res2.insertedId
    console.log("ID:"+id)
    console.log("add: "+ web3.eth.defaultAccount)
    console.log(id, web3.utils.asciiToHex(myobj.name), parseInt(myobj.date), parseInt(myobj.date)+10000, ticktype, myobj.maxticket, tickprices, [100,100])
    ContractTickets.methods.addEvent( id, web3.utils.asciiToHex(myobj.name), ticktype, myobj.maxticket, tickprices, [100,100],1538660908,2538660908,lowsec,upsec ).send({from: web3.eth.defaultAccount , gas: 6000000 }).then(function(error, accounts) {console.log(error)});
    //ContractTickets.methods.addEvent( web3.utils.asciiToHex(myobj.name), web3.utils.asciiToHex(myobj.name),  myobj.maxticket).send({from: web3.eth.defaultAccount, gas: 6000000 }).then(function(error, accounts) {console.log(error)});

    res.render('addEvent',{saved:true})
  });

}
)
app.get('/addEvents', (req, res) => {
  res.render('addEvent', {saved:false})
})
app.get('/addUser', (req, res) => {
  res.render('addUser',{saved:false})
})
app.post('/addUser', (req, res) => {
  console.log(req);
  var myobj = { name: req.body.name, address: req.body.address, password: web3.utils.sha3(req.body.password, {encoding: 'hex'}), hash: makeNounce() , documento: "ASPOEODJIA£" , approved:0};
  console.log(myobj);
  dbo.collection("users").insertOne(myobj, function(err, res) {
    if (err) {
      res.render('addUser', {saved:"false"})
      return;
    }
  });
  res.render('addUser', {saved:"true"})
})
app.get('/validateUsers', (req, res) => {
      var query = { approved: 0 };
      var saved=false;
      dbo.collection("users").find(query).toArray(function(err, data) {
        if (err) throw err;

        if(req.query.id){
          data.forEach(function(item, index){
            if(item._id==req.query.id){

              dbo.collection("users").updateOne(
               { _id: item._id },
               {
                 $set: { approved:1, hash:item.hash },
                 $currentDate: { lastModified: true }
               }
            )

            console.log("from: "+web3.eth.defaultAccount);
            console.log("address: "+ item.address);
            ContractUsers.methods.setNewUser(item.address).send({from: web3.eth.defaultAccount}).then(function(error, accounts) {console.log(error)});
            saved=true;
            }

          });
        }
        res.render('approveUser', { data:data, query:req.query, saved:saved });
        });
    });
app.post('/bought', (req, res) => {
  console.log(req.data);
  dbo.collection("events").update({'_id':req.data._id}, {$push:{'bought':res.data}},
  function (err, result) {
      if (err) throw err;
      console.log(result);
   });
});
//test net
app.post('/checkValidity', (req, res) => {
  var item=req.body;
  ContractUsers.methods.getUserChallange(item.address).call({from: web3.eth.defaultAccount}).then(function(resWeb3) {
    console.log(web3.utils.hexToUtf8(resWeb3)+""+item.challenge);
    if(web3.utils.hexToUtf8(resWeb3)==item.challenge){
      console.log("match");
      ContractUsers.methods.setNewUser(item.address).send({from: web3.eth.defaultAccount , gas: 6000000 }).then(function(resWeb31) {
        console.log(resWeb31);
        res.send("valid");
      });
    }

  });


});
function makeNounce() {
  var text = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  for (var i = 0; i < 9; i++)
    text += possible.charAt(Math.floor(Math.random() * possible.length));

  return text;

}
