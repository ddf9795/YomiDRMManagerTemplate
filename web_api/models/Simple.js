// Make a new one of these for each character you add to the database

const mongoose = require('mongoose');

const simpleSchema = new mongoose.Schema({
    nickname: {
        type: String,
    },
    steamid: {
        type: String,
        required: true,
    },
    access: {
        type: Array,
        required: true,
    }
})

const SimpleModel = mongoose.model('Simple', simpleSchema, 'simple'); // First string is the model name used in app.js, the second is the name of the MongoDB collection
module.exports = SimpleModel;