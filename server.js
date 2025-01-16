require('dotenv').config();  // Load environment variables from .env file
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// Fetch MongoDB URI from .env
const mongoURI = process.env.MONGO_URI;
const PORT = process.env.PORT || 3000;

// Set up CORS
const corsOptions = {
    origin: '*', // Add the IP for Android Emulator
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
};
app.use(cors(corsOptions));

console.log('Mongo URI:', process.env.MONGO_URI);
console.log('Port:', process.env.PORT);

// MongoDB connection using .env
mongoose.connect(mongoURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.log('Error connecting to MongoDB:', err));

// User Schema
const UserSchema = new mongoose.Schema({
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    dob: { type: String, default: null },
    mobile: { type: String, default: null },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: false },
    profileImage: { type: String , default: null },
    points: { type: Number, default: 100 }
});

const User = mongoose.model('User', UserSchema);

// Google Login Endpoint (Simplified)
app.post('/google-login', async (req, res) => {
    console.log('Request body:', req.body);
    const { email, firstName, lastName, profileImage } = req.body;

    if (!email || !firstName || !lastName) {
        return res.status(400).json({ error: 'Required fields missing' });
    }

    try {
        // Check if user already exists in the database
        let user = await User.findOne({ email });
        if (!user) {
            // If user doesn't exist, create a new user
            const newUser = new User({
                firstName,
                lastName,
                email,
                profileImage,
                points: 100,
            });

            user = await newUser.save();
            console.log('New user created:', user);
        } else {
            console.log('User found in database:', user);
        }

        res.status(200).json({
            message: 'Google login successful',
            user,
        });
    } catch (error) {
        console.error('Error logging in with google:', error);
        res.status(500).json({ error: 'Error logging in with Google' });
    }
});

// Signup Endpoint
app.post('/signup', async (req, res) => {
    const { firstName, lastName, dob, mobile, email, password, isGoogleLogin } = req.body;

    try {
        if (!isGoogleLogin) {
            const existingUser = await User.findOne({ email });
            if (existingUser) return res.status(400).send('Email already registered.');
        }

        const newUser = new User({ firstName, lastName, dob, mobile, email, password });
        await newUser.save();
        res.status(201).send('User registered successfully');
    } catch (error) {
        res.status(500).send('Error registering user');
    }
});

// Login Endpoint
app.post('/login', async (req, res) => {
    const { email, password, isGoogleLogin } = req.body;

    try {
        if (isGoogleLogin) {
            const user = await User.findOne({ email });
            if (!user) return res.status(404).send('User not found');
            return res.status(200).json({ message: 'Login successful', user });
        } else {
            const user = await User.findOne({ email });
            if (!user || user.password !== password)
                return res.status(400).send('Invalid email or password.');
            res.status(200).send('Login successful');
        }
    } catch (error) {
        res.status(500).send('Error logging in');
    }
});

app.get('/profile', async (req, res) => {
    const { email } = req.query;
    if (!email) {
        return res.status(400).send('Email is required');
    }
    try {
        const user = await User.findOne({ email });
        if (user) {
            res.json(user);
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        console.error(error); // Log the error for debugging
        res.status(500).send('Error fetching profile');
    }
});

// Start Server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
