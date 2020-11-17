const express = require('express');
const router = express.Router();
const sse = require('../sse');
require("../eventBus").init()


router.get('/', (req, res) => {
    res.render('index');
});

router.get('/sse', sse.init);

module.exports = router;
