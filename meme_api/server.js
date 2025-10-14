import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

// sample meme data
const meme = {
  text: "You think say you sabi?",
  audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
  answer: "Zlatan"
};

// route to get meme
app.get("/api/meme", (req, res) => {
  res.json({
    text: meme.text,
    audioUrl: meme.audioUrl
  });
});

// route to check answer
app.post("/api/check", (req, res) => {
  const { guess } = req.body;
  const correct = guess && guess.trim().toLowerCase() === meme.answer.toLowerCase();
  res.json({ correct });
});

// start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(` Meme API running on port ${PORT}`));
