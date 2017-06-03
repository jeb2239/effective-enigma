'use strict';
const express = require('express'); // eslint-disable-line node/no-missing-require
const app = express();
const dotenv = require('dotenv');
const watson = require('watson-developer-cloud');

// bundle the code
const webpackDevMiddleware = require('webpack-dev-middleware');
const webpack = require('webpack');
const webpackConfig = require('./webpack.config');

const compiler = webpack(webpackConfig);

app.use(
  webpackDevMiddleware(compiler, {
    publicPath: '/' // Same as `output.publicPath` in most cases.
  })
);

app.use(express.static('public/'));

// optional: load environment properties from a .env file
dotenv.load({ silent: true });

// For local development, specify the username and password or set env properties
const ltAuthService = new watson.AuthorizationV1({
  // username: process.env.TONE_ANALYZER_USERNAME || '<username>',
  // password: process.env.TONE_ANALYZER_PASSWORD || '<password>',
  // url: watson.ToneAnalyzerV3.URL
  username: '7e5cdf3e-63f4-4de7-8be0-2a794c3c67fd', // replace with username from service key
  password: 'LFPqmWlRfOQd', // replace with password from service key
  path: { workspace_id: '2187bd3d-1528-4831-bc39-bd5899e50612' }, // replace with workspace ID
  version_date: '2017-06-03'
});

app.get('/api/token/tone_analyzer', function(req, res) {
  ltAuthService.getToken(function(err, token) {
    if (err) {
      console.log('Error retrieving token: ', err);
      return res.status(500).send('Error retrieving token');
    }
    res.send(token);
  });
});

const port = process.env.PORT || process.env.VCAP_APP_PORT || 3000;
app.listen(port, function() {
  console.log('Watson browserify example server running at http://localhost:%s/', port);
});
