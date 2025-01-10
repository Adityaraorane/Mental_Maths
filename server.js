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
    level: { type: Number, required: true },               // Level added here
    question: { type: String, required: true },
    correctAnswer: { type: String, required: true },
    userAnswer: { type: String, required: true },
    pointsAwarded: { type: Number, default: 0 },            // Points added here
    createdAt: { type: Date, default: Date.now }            // Automatically captured
});

const Question = mongoose.model('Question', QuestionSchema);

const AssignmentSchema = new mongoose.Schema({
    email: { type: String, required: true },
    question: { type: String, required: true },
    correctAnswer: { type: String, required: true },
    userAnswer: { type: String, required: false }, // Allow userAnswer to be optional initially
    submittedAt: { type: Date, default: null },     // Tracks when the answer was submitted
    createdAt: { type: Date, default: Date.now }    // Automatically capture the date and time
});

const Assignment = mongoose.model('Assignment', AssignmentSchema);



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
  
    let pointsAwarded = 0;
    if (userAnswer == correctAnswer) {
        pointsAwarded = 10; // Award points for correct answer
    }
  
    try {
        const newQuestion = new Question({
            level, 
            question, 
            correctAnswer, 
            userAnswer, 
            pointsAwarded,
            createdAt: new Date()
        });
        
        await newQuestion.save();
        
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).send('User not found');
        }
        
        user.points += pointsAwarded;
        await user.save();
        
        res.status(200).json({
            message: 'Question saved successfully',
            questionDetails: newQuestion,
            updatedUserPoints: user.points
        });
    } catch (error) {
        console.error('Error saving question:', error);
        res.status(500).send('Error saving question');
    }
});


  

  app.get('/leaderboard', async (req, res) => {
    try {
        const leaderboard = await User.find().sort({ points: -1 }).limit(10);
        res.json(leaderboard);
    } catch (error) {
        res.status(500).send('Error fetching leaderboard');
    }
});

// Fetch all users from the database
app.get('/users', async (req, res) => {
    try {
        const users = await User.find(); // Fetch all users
        res.json(users); // Return users in JSON format
    } catch (error) {
        console.error("Error fetching users:", error);
        res.status(500).send("Error fetching users");
    }
});


// Assign Question Endpoint
app.post('/assignQuestion', async (req, res) => {
    const { email, question, correctAnswer } = req.body;

    try {
        // Find the user by email
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).send('User not found');
        }

        // Create the new question
        const newQuestion = new Question({
            question,
            correctAnswer,
            level: 1, // Default level or could be passed from the client
            pointsAwarded: 10, // Example points
            userAnswer: "", // Initially empty answer
        });

        await newQuestion.save();

        // Associate question with the user (optional, depends on your requirements)
        user.questions.push(newQuestion._id); // Add the question to user's list (if you want)
        await user.save();

        res.status(200).send('Question assigned successfully');
    } catch (error) {
        console.error('Error assigning question:', error);
        res.status(500).send('Error assigning question');
    }
});

// Endpoint to save an assignment


app.get('/assignments', async (req, res) => {
    const { email } = req.query;
    try {
      const assignments = await Assignment.find({ email });
      if (!assignments || assignments.length === 0) {
        return res.status(404).send('No assignments found');
      }
      res.json(assignments);
    } catch (error) {
      console.error('Error fetching assignments:', error);
      res.status(500).send('Error fetching assignments');
    }
  });
  

// Endpoint to save an assignment
app.post('/assignments', async (req, res) => {
    const { email, question, correctAnswer } = req.body;

    try {
        // Create a new assignment entry
        const newAssignment = new Assignment({
            email,
            question,
            correctAnswer,
            createdAt: new Date(), // Store the assignment creation time
        });

        // Save the assignment to the database
        await newAssignment.save();

        // Send a success response
        res.status(200).json({
            message: 'Assignment saved successfully',
            assignment: newAssignment,
        });
    } catch (error) {
        console.error("Error saving assignment:", error);
        res.status(500).send('Error saving assignment');
    }
});

// Endpoint to update an assignment with user's answer (updated endpoint name)
app.post('/updateAssignmentAnswer', async (req, res) => {
    const { email, question, userAnswer } = req.body;

    try {
        // Find the assignment by email and question
        const assignment = await Assignment.findOne({ email, question });

        if (!assignment) {
            return res.status(404).send('Assignment not found');
        }

        // Update the assignment with the user's answer and submission date
        assignment.userAnswer = userAnswer; // Save the user's answer
        assignment.submittedAt = new Date(); // Save the submission date

        // Save the updated assignment
        await assignment.save();

        // Send the response
        res.status(200).json({
            message: 'Answer submitted successfully',
            updatedAssignment: assignment,
        });
    } catch (error) {
        console.error("Error submitting answer:", error);
        res.status(500).send('Error submitting answer');
    }
});


// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
