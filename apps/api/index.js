const http = require('http');
const fs   = require('fs');

const PORT = process.env.PORT || 8080;
const ENV  = process.env.APP_ENV || 'staging';
const SHA  = process.env.IMAGE_TAG || null;
const SECRET_FILE = process.env.SECRET_FILE || null;

const secretLoaded = () => Boolean(SECRET_FILE) && fs.existsSync(SECRET_FILE);

const server = http.createServer((req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.url === '/health' || req.url === '/api/health') {
    res.writeHead(200);
    res.end(JSON.stringify({ status: 'ok', env: ENV, version: '1.0.0', sha: SHA, deployedBy: 'ArgoCD', secretLoaded: secretLoaded() }));
  } else {
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'not found' }));
  }
});

server.listen(PORT, () => console.log(`API running on port ${PORT} [${ENV}]`));
