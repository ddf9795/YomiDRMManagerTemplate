// Make a new one of these for each character you add to the database

const mongoose = require('mongoose');

const advancedSchema = new mongoose.Schema({
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

const AdvancedModel = mongoose.model('Advanced', advancedSchema, 'advanced'); // First string is the model name used in app.js, the second is the name of the MongoDB collection
module.exports = AdvancedModel;