const { IncomingWebhook } = require('@slack/webhook');
const url = process.env.SLACK_WEBHOOK;

const webhook = new IncomingWebhook(url);

// Optionally filter what notification types to forward to Slack.
// If empty, all types will be allowed.
const allowedTypeURLs = [];

// slackNotifier is the main function called by Cloud Functions
module.exports.slackNotifier = (pubSubEvent, context) => {
  const data = decode(pubSubEvent.data);

  // Send message to Slack.
  if (isAllowedType(pubSubEvent.attributes)) {
    const message = createSlackMessage(data, pubSubEvent.attributes);
    webhook.send(message);
  }
};

// decode decodes a pubsub event message from base64.
const decode = (data) => {
  return Buffer.from(data, 'base64').toString();
}

// isAllowedType can be used to filter out messages that don't match the
// allowed type URLs. If allowedTypeURLs is empty, it allows all types.
const isAllowedType = (attributes) => {
  if (allowedTypeURLs.length == 0) {
    return true;
  }
  for (var x in allowedTypeURLs) {
    if (attributes['type_url'] == allowedTypeURLs[x]) {
      return true;
    }
  }
  return false;
}

// createSlackMessage creates a message from a data object.
const createSlackMessage = (data, attributes) => {
  // Write the message data and attributes.
  text = `${data}`
  for (var key in attributes) {
    if (attributes.hasOwnProperty(key)) {
      text = text + `\n\t\`${key}: ${attributes[key]}\``
    }
  }
  const message = {
    text: text,
    mrkdwn: true,
  };
  return message;
}