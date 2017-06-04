var ConversationV1 = require('watson-developer-cloud/conversation/v1');
// var ToneAnalyzerV3 = require('watson-developer-cloud/tone-analyzer/v3');

var btn = document.getElementById('analyze-btn');
var input = document.getElementById('input');
var output = document.getElementById('output');
var conversation = new ConversationV1({
  username: '7e5cdf3e-63f4-4de7-8be0-2a794c3c67fd', // replace with username from service key
  password: 'LFPqmWlRfOQd', // replace with password from service key
  path: { workspace_id: '2187bd3d-1528-4831-bc39-bd5899e50612' }, // replace with workspace ID
  version_date: '2017-03-06'
});
/**
 * @return {Promise<String>} returns a promise that resolves to a string token
 */
function getToken() {
  return fetch('/api/token/tone_analyzer').then(function(response) {
    return response.text();
  });
}

function analyze(token) {
  const toneAnalyzer = new ToneAnalyzerV3({
    token: token,
    version_date: '2016-05-19'
  });
  toneAnalyzer.tone(
    {
      text: input.value
    },
    function(err, result) {
      if (err) {
        output.innerHTML = err;
        return console.log(err);
      }
      output.innerHTML = JSON.stringify(result, null, 2);
    }
  );
}
function Hello(){
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
    console.log(getWatson("where am I?"));
    // conversation.message({}, processResponse);
}

function getWatson(str) {
  // try{
  // conversation.message({
  //     input: { text: str },
  //     // Send back the context to maintain state.
  //     context : response.context,
  //   }, processResponse)
  //   return response.output.text[0];
  // } catch(err) {
  //       console.log(err);
  //   }
  console.log("gfds")
  return conversation.message({}, processResponse);
}
function processResponse(err, response) {
  if (err) {
    console.error(err); // something went wrong
    return;
  }
  return response.output.text[0]
  // var endConversation = false;
  
  // Check for action flags.
  // if (response.output.action === 'display_time') {
  //   // User asked what time it is, so we output the local system time.
  //   console.log('The current time is ' + new Date().toLocaleTimeString());
  // } else if (response.output.action === 'end_conversation') {
  //   // User said goodbye, so we're done.
  //   console.log(response.output.text[0]);
  //   endConversation = true;
  // } else {
  //   // Display the output from dialog, if any.
  //   if (response.output.text.length != 0) {
  //       console.log(response.output.text[0]);
  //   }
  // }

  // If we're not done, prompt for the next round of input.
  // if (!endConversation) {
  //   var newMessageFromUser = prompt('>> ');
  //   conversation.message({
  //     input: { text: newMessageFromUser },
  //     // Send back the context to maintain state.
  //     context : response.context,
  //   }, processResponse)
  // }
}

module.exports = {
  run: function () {
    console.log('run from library');
    Hello();
  }
};
