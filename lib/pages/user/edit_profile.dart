import 'package:flutter/material.dart';
import 'package:jom_makan/database/db_connection.dart';
import 'package:jom_makan/server/user/user_profile.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  State<StatefulWidget> createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfile> {
  late UserProfile _userProfile;
  final MySqlConnectionPool connectionPool = MySqlConnectionPool();
  
  // Controller for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  // Error texts
  String? _emailError;
  String? _passwordError;
  String? _repeatPasswordError;

  late String existingUsername;
  bool _showPassword = false;

  // Fetch user profile data when the widget is initialized
  @override
  void initState() {
    super.initState();
    _userProfile = UserProfile(connectionPool); // Initialize _userProfile here
    _fetchUserProfile();
  }

  // Fetch user profile data
  void _fetchUserProfile() async {
    var userProfileData = await _userProfile.getUserProfile(widget.username);
    if (userProfileData['success']) {
      // Set the text controllers with the retrieved data
      setState(() {
        _nameController.text = userProfileData['username'];
        _emailController.text = userProfileData['email'];
      });

      // Get the username and temporarily stores in a variable for server-side purpose
      existingUsername = _nameController.text;
    } else {
      // Handle error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Oops! There is an error!'),
            content: const Text('Error while retrieving user profile. Please try again later.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ]
          );
        }
      );
    }
  }
  
  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            name(),
            const SizedBox(height: 16),
            email(),
            const SizedBox(height: 16),
            currentPassword(),
            const SizedBox(height: 16),
            newPassword(),
            const SizedBox(height: 16),
            repeatPassword(),
            const SizedBox(height: 16),
            saveButton(),
          ],
        ),
      ),
    );
  }

  // Text fields
  Widget name() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: 'Name'),
    );
  }

  Widget email() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email (someone@example.com)',
        errorText: _emailError,
      ),
      onChanged: (value) => _validateEmail(value),
    );
  }

  Widget currentPassword() {
    return TextField(
      controller: _currentPasswordController,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Current Password'),
    );
  }

  Widget newPassword() {
    return TextField(
      controller: _newPasswordController,
      decoration: InputDecoration(
        labelText: 'New Password (minimum 8 characters)',
        errorText: _passwordError,

        // "Show Password" icon
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      onChanged: (value) => _validatePassword(value),
      obscureText: !_showPassword,
    );
  }

  Widget repeatPassword() {
    return TextField(
      controller: _repeatPasswordController,
      decoration: InputDecoration(
        labelText: 'Repeat New Password',
        errorText: _repeatPasswordError,

        // "Show Password" icon
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      onChanged: (value) => _validateRepeatPassword(value),
      obscureText: !_showPassword, 
    );
  }

  Widget saveButton() {
    return ElevatedButton(
      onPressed: _saveChanges,
      child: const Text('Save Changes'),
    );
  }

  // Validations
  void _validateEmail(String value) {
    if (value.isEmpty) {
      _emailError = 'Email cannot be empty';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      _emailError = 'Please enter a valid email';
    } else {
      _emailError = null;
    }
    setState(() {});
  }

  void _validatePassword(String value) {
    if (value.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
    } else {
      _passwordError = null;
    }
    setState(() {});
  }

  void _validateRepeatPassword(String value) {
    if (value != _newPasswordController.text) {
      _repeatPasswordError = 'Passwords do not match';
    } else {
      _repeatPasswordError = null;
    }
    setState(() {});
  }

  // Function to handle save button press
  void _saveChanges() async {
    // Get the values from the text controllers
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String repeatPassword = _repeatPasswordController.text;

    // Validate the inputs
    _validateEmail(email);
    _validatePassword(newPassword);
    _validateRepeatPassword(repeatPassword);

    // required:
    // name and email; current password
    // passwords

    // Check for errors
    if (
      // If the new and repeat password fields are empty, but the name is empty or email has errors
      ((name.isEmpty || _emailError != null) && (newPassword.isEmpty && repeatPassword.isEmpty)) ||

      // If the name and email fields are empty, but the new and repeat password fields have errors
      ((name.isEmpty && email.isEmpty) && (_passwordError != null && _repeatPasswordError != null)) ||

      // If all the fields are not empty, but any validation parts have errors
      ((name.isNotEmpty && email.isNotEmpty && newPassword.isNotEmpty && repeatPassword.isNotEmpty) &&
        (_emailError != null && _passwordError != null && _repeatPasswordError != null))
    ) {
      // There are validation errors, show an error message or toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors')),
      );
      return;
    }

    // Check if the current password matches with the database
    bool isCurrentPasswordMatch = await _userProfile.checkCurrentPassword(name, currentPassword);

    if (!isCurrentPasswordMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid current password')),
      );
    } else {
      // If there are no errors, show confirmation message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Are you sure you want to save your changes?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: const Text('Register'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog

                  // Update the user profile
                  updateUserProfile(existingUsername, name, email, newPassword);
                },
              ),
            ],
          );
        }
      );
    }
  }

  // function to update user profile
  void updateUserProfile(String currentUsername, String username, String email, String password) async {
    bool isUpdateSuccessful;

    if (username.isNotEmpty && email.isNotEmpty && password.isEmpty) {
      isUpdateSuccessful = await _userProfile.updateNameEmail(currentUsername, username, email);
    }
    else if (username.isEmpty && email.isEmpty && password.isNotEmpty) {
      isUpdateSuccessful = await _userProfile.updatePassword(currentUsername, password);
    } else {
      isUpdateSuccessful = await _userProfile.updateUserProfile(currentUsername, username, email, password);
    }
    
    if (isUpdateSuccessful) {
      // Show a success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      // Show an error message or handle the update failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }
}