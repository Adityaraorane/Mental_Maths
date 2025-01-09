require('dotenv').config();  // Load environment variables from .env file
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Fetch MongoDB URI from .env
const mongoURI = process.env.MONGO_URI;

// MongoDB connection using .env
mongoose.connect(mongoURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.log('Error connecting to MongoDB:', err));

const UserSchema = new mongoose.Schema({
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    dob: { type: String, required: true },
    mobile: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    profileImage: { type: String },
    points: { type: Number, default: 100 }
});

const User = mongoose.model('User', UserSchema);

const QuestionSchema = new mongoose.Schema({
    question: { type: String, required: true },
    correctAnswer: { type: String, required: true },
    createdAt: { type: Date, default: Date.now }
});

const Question = mongoose.model('Question', QuestionSchema);

// Signup Endpoint
app.post('/signup', async (req, res) => {
    const { firstName, lastName, dob, mobile, email, password } = req.body;

    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) return res.status(400).send('Email already registered.');

        const newUser = new User({ firstName, lastName, dob, mobile, email, password });
        await newUser.save();
        res.status(201).send('User registered successfully');
    } catch (error) {
        res.status(500).send('Error registering user');
    }
});

// Login Endpoint
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user || user.password !== password)
            return res.status(400).send('Invalid email or password.');

        res.status(200).send('Login successful');
    } catch (error) {
        res.status(500).send('Error logging in');
    }
});

// Profile Endpoint
app.get('/profile', async (req, res) => {
    const { email } = req.query;
    try {
        const user = await User.findOne({ email });
        if (user) {
            res.json(user);
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send('Error fetching profile');
    }
});

// Save question and answer route
app.post('/saveQuestion', async (req, res) => {
    const { level, question, correctAnswer, userAnswer, email } = req.body;
  
    console.log('Request body:', req.body); // Add this line to see the incoming data
  
    let pointsAwarded = 0;
    if (userAnswer === correctAnswer) {
      pointsAwarded = 5; // Add points for correct answer
    }
  
    // Save the question data
    const newQuestion = new Question({
      level,
      question,
      correctAnswer,
      userAnswer,
      pointsAwarded,
    });
  
    await newQuestion.save();
  
    console.log('Question saved to DB:', newQuestion); // Log the saved question
  
    // Update user's points based on the answer
    const user = await User.findOne({ email });
    user.points += pointsAwarded;
    await user.save();
  
    console.log('User points updated:', user); // Log the updated user
  
    res.status(200).send('Question saved successfully');
  });
  

  app.get('/leaderboard', async (req, res) => {
    try {
        const leaderboard = await User.find().sort({ points: -1 }).limit(10);
        res.json(leaderboard);
    } catch (error) {
        res.status(500).send('Error fetching leaderboard');
    }
});


// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
