const express = require('express');
const path = require('path');
const config = require('../config.json');

const app = express();
const STATIC_DIR = path.join(__dirname, '..', 'public');
const PORT = config.server.port;
const HOST = config.server.host;

// Serve static files from the "public" directory
app.use(express.static(STATIC_DIR));

// Route for the root path to serve index.html
app.get('/', (req, res) => {
  res.sendFile(path.join(STATIC_DIR, 'index.html'));
});

// Start the server
app.listen(PORT, HOST, () => {
  console.log(`Server running on http://${HOST}:${PORT}`);
}); 