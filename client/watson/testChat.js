var prompt = require('prompt-sync')();
var ConversationV1 = require('watson-developer-cloud/conversation/v1');

// Set up Conversation service.
var conversation = new ConversationV1({
  username: '7e5cdf3e-63f4-4de7-8be0-2a794c3c67fd', // replace with username from service key
  password: 'LFPqmWlRfOQd', // replace with password from service key
  path: { workspace_id: '2187bd3d-1528-4831-bc39-bd5899e50612' }, // replace with workspace ID
  version_date: '2017-03-06'
})

// Start conversation with empty message.
console.log("hi")
  conversation.message({}, function(err, response) {
       if (err) {
         console.error(err);
         // return err;
       } else {
         // console.log(JSON.stringify(response, null, 2));
         return JSON.stringify(response, null, 2); //response.output.text[0];
       }
  });

// Process the conversation response.
function processResponse(err, response) {
  if (err) {
    console.error(err); // something went wrong
    return;
  }

  // var endConversation = false;
  
  // // Check for action flags.
 
  // console.log(response.output.text[0]);

  // // If we're not done, prompt for the next round of input.
  // if (!endConversation) {
  //   var newMessageFromUser = prompt('>> ');
  //   conversation.message({
  //     input: { text: newMessageFromUser },
  //     // Send back the context to maintain state.
  //     context : response.context,
  //   }, processResponse)
  // }
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
  // conversation.message({
  //     input: { text: newMessageFromUser } //,
  //     // Send back the context to maintain state.
  //     // context : response.context,
  //   }, processResponse)
  // return conversation.message({}, processResponse);
  conversation.message({
  input: { text: str }//,
  // workspace_id: '<workspace id>'
  }, function(err, response) {
       if (err) {
         console.error(err);
       } else {
         console.log(JSON.stringify(response.output.text[0], null, 2));
         var ret = JSON.stringify(response.output.text[0], null, 2); //response.output.text[0];
         // console.log(ret)
         return ret;
       }
  });
  // return "hi..." ;
}
var newMessageFromUser = ""
while(newMessageFromUser != "no") {
// conversation.message({}, processResponse);
// console.log(getWatson(""))
newMessageFromUser = prompt('>> ');
console.log(getWatson(newMessageFromUser))
}
