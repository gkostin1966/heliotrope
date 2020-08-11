// By default, ActionCable channels use the App.cable consumer created in
// the app/assets/javascripts/cable.js file.  To avoid polluting the global namespace
// you can use webpack’s module system to provide a consumer for your channels.
//
// To do so, create a file named app/javascript/channels/consumer.js with the following content:
import { createConsumer } from '@rails/actioncable';

export default createConsumer();
// Then update your channels to use this consumer instead of App.cable:
//
// import consumer from "./consumer"
//
// consumer.subscriptions.create("ChatChannel", {
//   // ...
// })
// You should now be able to remove the app/assets/javascripts/cable.js file.
