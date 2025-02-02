const path = require('path')
const restify = require('restify');
const mongoose = require('mongoose')

const Simple = require('./models/Simple.js')
const Advanced = require('./models/Advanced.js')

const dbURI = process.env.MONGODB_URI || 'mongodb://127.0.0.1/drm'; // Connect to either the Heroku-provided database, or a local one.

const adminUsername = process.env.ADMIN_USERNAME || 'admin'; // Use the Heroku-provided username and password, or default to 'admin'
const adminPassword = process.env.ADMIN_PASSWORD || 'admin';

mongoose.connect(dbURI).catch((err) => {
  if (err) {
    console.log('Could not connect to database');
    throw err;
  }
});

function tryLogin(req, res, next) {
  try {
    switch (req.body.user === adminUsername && req.body.pass === adminPassword) {
      case true:
        return res.send(200, {"context":req.body})
        break
      case false:
        res.send(403, {message: 'Incorrect username or password'})
        break
    
    next()
    
    }
  } catch (err) {}
}

async function checkWhitelist(req, res) {
  try {
    const docs = await getModel(req.params.char).findOne({ steamid: req.params.steamid })
    .select('access')
    .lean()
    .exec();
    res.json({ received: { character: req.params.char, steamid: req.params.steamid }, access: docs['access'] });
  } catch (err) {
    res.json({ received: { character: req.params.char, steamid: req.params.steamid }, access: [] });
  }
}

function createModel(charname, data) {
  switch (charname) {
    case 'AlchemistV3':
      return new AlchemistV3(data)
    case 'Quantum':
      return new Quantum(data)
    case 'Seashanty':
      return new Seashanty(data)
    case 'Astrologian':
      return new Astrologian(data)
    case 'Shieldbearer':
      return new Shieldbearer(data)
    case 'Vandal':
      return new Vandal(data)
  }
}

function getModel(charname) {
  switch (charname) {
    // You'll need to add a new case for every model you add to the models/ folder
    case 'Simple':
      return Simple
    case 'Advanced':
      return Advanced
  }
}

async function addToWhitelist(req, res) {
  let json = JSON.parse(req.body.options)
  let security = JSON.parse(req.body.security)
  if (security.username !== adminUsername || security.password !== adminPassword) {
    res.send(403, {"message":"Access Forbidden"})
  }
  else {
    const docs = await getModel(req.body.char).find({})
    .select('steamid')
    .lean()
    .exec();
    let existing = false;
    for (item of docs) {
      if (item.steamid === req.body.steamid) {
        existing = true;
      }
    }
    if (existing) {
      res.send(400, {message:'User already exists, try a different Steam ID'})
    }
    else {
      let params = json
      const data = {
        steamid: req.body.steamid,
        access: params,
      }
      if (req.body.nickname) {
        data['nickname'] = req.body.nickname
      }
    
      try {
        const newUser = createModel(req.body.char, data)
        console.log(newUser)
        await newUser.save();
        res.send(201)
      } catch (err) {}
    }
  }
}

async function getUsersOfWhitelist(req, res) {
  const docs = await getModel(req.params.char).find({})
  .select('_id steamid nickname access')
  .lean()
  .exec();
  res.send(200, { users: docs });
}

async function updateUserOfWhitelist(req, res) {
  let security = JSON.parse(req.body.security)
  if (security.username !== adminUsername || security.password !== adminPassword) {
    res.send(403, {"message":"Access Forbidden"})
  }
  else {
    try {
      let newData = JSON.parse(req.body.data)
      console.log(newData)
      await getModel(req.body.context.char).findByIdAndUpdate(req.body.context._id, newData)
      res.send(202)
    } catch (err) {}
  }
}

async function deleteUser(req, res) {
  let security = JSON.parse(req.body.security)
  if (security.username !== adminUsername || security.password !== adminPassword) {
    res.send(403, {"message":"Access Forbidden"})
  }
  else {
    try {
      await getModel(req.body.context.char).findByIdAndDelete(req.body.context._id)
      res.send(202)
    } catch (err) {}
  }
}

const server = restify.createServer();
server.use(restify.plugins.queryParser())
server.use(restify.plugins.bodyParser())
server.post('/login', tryLogin);
server.get('/:char/:steamid', checkWhitelist);
server.post('/add', addToWhitelist);
server.get('/getAll/:char', getUsersOfWhitelist)
server.post('/update', updateUserOfWhitelist)
server.post('/delete', deleteUser)

server.listen(process.env.PORT || 8080, function() {
  console.log('%s listening at %s', server.name, server.url);
});
