#!/bin/bash

echo "⚙️ Setting up Razorbill SportGPT Backend (Node.js + Nodemon)..."

# Step 1: Initialize Node.js project
npm init -y

# Step 2: Install dependencies
npm install express axios cors dotenv
npm install --save-dev nodemon

# Step 3: Create basic files
touch server.js .env

# Step 4: Add start script to package.json
npx json -I -f package.json -e '
  this.scripts = {
    "start": "node server.js",
    "server": "nodemon server.js"
  }
'

# Step 5: Write backend code to server.js
cat << 'EOF' > server.js
const express = require("express");
const axios = require("axios");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

app.post("/ask", async (req, res) => {
  const question = req.body.question;

  try {
    const response = await axios.post(
      "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1",
      { inputs: question },
      {
        headers: {
          Authorization: \`Bearer \${process.env.HUGGINGFACE_API_KEY}\`,
        },
      }
    );

    const answer = response.data[0]?.generated_text || "Sorry, I don't have an answer.";
    res.json({ reply: answer });
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ error: "Failed to fetch answer from Hugging Face." });
  }
});

app.listen(3000, () => console.log("✅ SportGPT backend running at http://localhost:3000"));
EOF

# Step 6: Reminder for user
echo "✅ Setup complete!"
echo "🔐 Add your Hugging Face API key to the .env file:"
echo "HUGGINGFACE_API_KEY=your_token_here"
echo "🚀 Run the server with: npm run server"

