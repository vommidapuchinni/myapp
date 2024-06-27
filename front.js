const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the front-end!');
});

app.listen(4000, () => {
    console.log('Front-end server running on port 4000');
});

