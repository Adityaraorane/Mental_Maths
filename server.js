const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// MongoDB connection
mongoose.connect('mongodb+srv://devgaonkar:devgaonkar@mentalmaths.7zqt9.mongodb.net/', { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.log(err));

  const UserSchema = new mongoose.Schema({
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    dob: { type: String, required: true },
    mobile: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    profileImage: { type: String }, // Store the base64-encoded image
    points: { type: Number, default: 100 }, // Default points set to 100
  });
  

  const User = mongoose.model('User', UserSchema);

  const QuestionSchema = new mongoose.Schema({
    question: { type: String, required: true },
    correctAnswer: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
  });
  
  const Question = mongoose.model('Question', QuestionSchema);
  

  // Signup
  app.post('/signup', async (req, res) => {
    const { firstName, lastName, dob, mobile, email, password } = req.body;
  
    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).send('Email already registered.');
  
    const newUser = new User({ firstName, lastName, dob, mobile, email, password });
    await newUser.save();
  
    res.status(201).send('User registered successfully');
  });
  
  // Login
  app.post('/login', async (req, res) => {
    const { email, password } = req.body;
  
    const user = await User.findOne({ email });
    if (!user || user.password !== password)
      return res.status(400).send('Invalid email or password.');
  
    res.status(200).send('Login successful');
  });

  app.get('/profile', async (req, res) => {
    const { email } = req.query;
    const user = await User.findOne({ email });
    if (user) {
        res.json({
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            mobile: user.mobile,
            dob: user.dob,
            profileImage: user.profileImage || null,
            points: user.points || 100,
        });
    } else {
        res.status(404).send('User not found');
    }
});

app.post('/updateProfile', async (req, res) => {
  const { email, profileImage, points } = req.body;
  await User.updateOne(
      { email },
      { $set: { profileImage, points } },
      { upsert: true }
  );
  res.send('Profile updated successfully');
});

// Save question and correct answer
app.post('/saveQuestion', async (req, res) => {
  const { question, correctAnswer } = req.body;
  
  // Validate that both question and correctAnswer are provided
  if (!question || !correctAnswer) {
    return res.status(400).send('Question and correct answer are required.');
  }

  try {
    const newQuestion = new Question({ question, correctAnswer });
    await newQuestion.save();
    res.status(200).send('Question saved successfully');
  } catch (error) {
    console.error(error);
    res.status(500).send('Error saving question');
  }
});

app.get('/getQuestions', async (req, res) => {
  try {
    const questions = await Question.find();
    res.status(200).json(questions);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching questions');
  }
});


// Update user score
app.post('/updateScore', async (req, res) => {
  const { scoreIncrement } = req.body;
  const email = req.user.email; // Assuming user is authenticated
  const user = await User.findOne({ email });

  if (user) {
    user.points += scoreIncrement;
    await user.save();
    res.status(200).send('Score updated');
  } else {
    res.status(404).send('User not found');
  }
});

const LeaderboardSchema = new mongoose.Schema({
  username: String,
  score: Number,
  date: { type: Date, default: Date.now },
});

const Leaderboard = mongoose.model('Leaderboard', LeaderboardSchema);

app.post('/submitScore', async (req, res) => {
  const { username, score } = req.body;
  const newScore = new Leaderboard({ username, score });
  await newScore.save();
  res.status(200).send('Score submitted');
});

app.get('/leaderboard', async (req, res) => {
  const topScores = await Leaderboard.find().sort({ score: -1 }).limit(10);
  res.json(topScores);
});

let users = {};

app.post('/updateUserScore', (req, res) => {
  const { userId, score } = req.body;
  if (!users[userId]) users[userId] = 0;
  users[userId] += score;
  console.log(`User ${userId} score updated to ${users[userId]}`);
  res.status(200).send('Score updated');
});


app.listen(5000, () => {
  console.log('Server running on port 5000');
});
