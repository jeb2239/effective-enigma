var ConversationV1 = require('watson-developer-cloud/conversation/v1');
// var ToneAnalyzerV3 = require('watson-developer-cloud/tone-analyzer/v3');

var btn = document.getElementById('analyze-btn');
var input = document.getElementById('input');
var output = document.getElementById('output');
var conversation = new ConversationV1({
  username: '7e5cdf3e-63f4-4de7-8be0-2a794c3c67fd',  // replace with username
                                                     // from service key
  password: 'LFPqmWlRfOQd',  // replace with password from service key
  path: {
    workspace_id: '2187bd3d-1528-4831-bc39-bd5899e50612'
  },  // replace with workspace ID
  version_date: '2017-03-06'
});
// conversation.setHeader("Access-Control-Allow-Origin", "*");
// conversation.setHeader("Access-Control-Allow-Credentials", "true");
// conversation.setHeader("Access-Control-Allow-Methods",
// "GET,HEAD,OPTIONS,POST,PUT");
// conversation.setHeader("Access-Control-Allow-Headers",
// "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type,
// Access-Control-Request-Method, Access-Control-Request-Headers");
/**
 * @return {Promise<String>} returns a promise that resolves to a string token
 */
function getToken() {
  return fetch('/api/token/tone_analyzer').then(function(response) {
    return response.text();
  });
}

function analyze(token) {
  const toneAnalyzer =
      new ToneAnalyzerV3({token: token, version_date: '2016-05-19'});
  toneAnalyzer.tone({text: input.value}, function(err, result) {
    if (err) {
      output.innerHTML = err;
      return console.log(err);
    }
    output.innerHTML = JSON.stringify(result, null, 2);
  });
}
function Hello() {
  //   conversation.message({
  //   input: { text: 'What\'s the weather?' },
  //   workspace_id: '<workspace id>'
  //  }, function(err, response) {
  //      if (err) {
  //        console.error(err);
  //      } else {
  //        console.log(JSON.stringify(response, null, 2));
  //      }
  // });
  console.log(getWatson('where am I?'));
}


const messageCB = function(text, context) {
  const payload = {
    username: '7e5cdf3e-63f4-4de7-8be0-2a794c3c67fd',  // replace with username
                                                     // from service key
  password: 'LFPqmWlRfOQd',  // replace with password from service key
    workspace_id: process.env.WORKSPACE_ID || '2187bd3d-1528-4831-bc39-bd5899e50612',
    input: {text: text},
    context: context
  };
  return new Promise(
      (resolve, reject) => conversation.message(payload, function(err, data) {
        if (err) {
          reject(err);
        } else {
          resolve(data);
        }
      }));
};

// message('first message', undefined)
//   .then(response1 => {
//     // APPLICATION-SPECIFIC CODE TO PROCESS THE DATA
//     // FROM CONVERSATION SERVICE
//     console.log(JSON.stringify(response1, null, 2), '\n--------');

//     // invoke a second call to conversation
//     return message('second message', response1.context);
//   })
//   .then(response2 => {
//     console.log(JSON.stringify(response2, null, 2), '\n--------');
//     console.log('Note that the two reponses should have the same
//     context.conversation_id');
//   })
//   .catch(err => {
//     // APPLICATION-SPECIFIC CODE TO PROCESS THE ERROR
//     // FROM CONVERSATION SERVICE
//     console.error(JSON.stringify(err, null, 2));
//   });


module.exports = {
  getWatson: function(text) {

    return messageCB(text, undefined);
    // return "hi..." ;
  },

  message : messageCB
}

// module.exports = {
//   run: function () {
//     console.log('run from library');
//     Hello();
//   }
// };
