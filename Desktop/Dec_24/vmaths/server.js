const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/vmaths', { useNewUrlParser: true, useUnifiedTopology: true })
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
  // Handle saving the question and correct answer in the database
  // Example: Save it in a game history collection or log
  res.status(200).send('Question saved');
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




app.listen(5000, () => {
  console.log('Server running on port 5000');
});
