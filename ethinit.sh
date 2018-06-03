mongod&
testrpc >> "testrpc.txt"&
cd /home/pietro/ethchain/ticketing/contracts;
truffle migrate;
cd /home/pietro/ethchain/ticketing/explorer;
npm run start&
cd /home/pietro/ethchain/ticketing/;
npm run dev;
