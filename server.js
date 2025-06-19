const express = require("express");
const axios = require("axios");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5000;

// Allow both Vercel frontend and local dev
const allowedOrigins = [
  "https://razorbill-website.vercel.app",
  "http://localhost:5173",
];

app.use(
  cors({
    origin: allowedOrigins,
    methods: ["GET", "POST"],
    credentials: true,
  }),
);

app.use(express.json());

app.post("/ask", async (req, res) => {
  const question = req.body.question;

  try {
    const response = await axios.post(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        model: "mistral/mistral-7b-instruct",
        messages: [
          {
            role: "system",
            content:
              "You are SportGPT, an expert in sports. Answer only sports-related questions clearly and concisely.",
          },
          {
            role: "user",
            content: question,
          },
        ],
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
        },
      },
    );

    const answer =
      response.data.choices?.[0]?.message?.content ||
      "Sorry, I couldn't answer that.";
    res.json({ reply: answer });
  } catch (error) {
    console.error(
      "🔥 OpenRouter error:",
      error.response?.data || error.message,
    );
    res.status(500).json({ error: "Failed to fetch answer from OpenRouter." });
  }
});

app.listen(PORT, () =>
  console.log(`✅ SportGPT backend running at http://localhost:${PORT}`),
);
