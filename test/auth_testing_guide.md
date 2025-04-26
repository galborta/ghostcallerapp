# Authentication Testing Guide

## Manual Test Cases

### 1. Login Flow
- [ ] **Valid Credentials**
  - Enter valid email and password
  - Verify successful login
  - Verify navigation to home screen
  - Verify user data is displayed correctly

- [ ] **Invalid Credentials**
  - Enter incorrect password
  - Verify error message appears
  - Enter invalid email format
  - Verify validation message appears
  - Verify form remains accessible

- [ ] **Empty Fields**
  - Submit with empty email
  - Submit with empty password
  - Verify validation messages
  - Verify submit button state

### 2. Signup Flow
- [ ] **New Account**
  - Enter new email and valid password
  - Add optional referral code
  - Verify successful account creation
  - Verify navigation to home screen

- [ ] **Existing Email**
  - Attempt signup with existing email
  - Verify error message
  - Verify form remains accessible
  - Verify data persistence

- [ ] **Password Requirements**
  - Test minimum length (8 characters)
  - Test uppercase requirement
  - Test number requirement
  - Verify helper text visibility
  - Verify validation messages

### 3. Password Reset Flow
- [ ] **Request Reset**
  - Navigate to forgot password
  - Enter valid email
  - Verify confirmation message
  - Check email delivery

- [ ] **Reset Process**
  - Click reset link in email
  - Enter new password
  - Verify password requirements
  - Verify successful reset
  - Verify able to login with new password

### 4. Auth Persistence
- [ ] **Session Maintenance**
  - Login successfully
  - Close app completely
  - Reopen app
  - Verify still logged in
  - Verify user data persists

- [ ] **Session Expiry**
  - Force session expiry
  - Verify redirect to login
  - Verify proper error message
  - Verify re-authentication works

### 5. UI/UX Verification
- [ ] **Layout & Typography**
  - Compare against design specs
  - Verify font sizes and weights
  - Verify spacing and alignment
  - Verify color scheme
  - Verify responsive behavior

- [ ] **Interactive Elements**
  - Verify button states (normal/hover/pressed)
  - Verify input field states
  - Verify loading indicators
  - Verify error state styling
  - Verify animations and transitions

## Automated Integration Tests

### Running Tests
```bash
# Run all integration tests
flutter test integration_test/auth_flow_test.dart

# Run with coverage
flutter test --coverage integration_test/auth_flow_test.dart
```

### Test Coverage

1. **Login Flow Tests**
- [x] Successful login
- [x] Invalid credentials
- [x] Form validation
- [x] Navigation flow
- [x] Loading states

2. **Signup Flow Tests**
- [x] Successful signup
- [x] Existing email handling
- [x] Password validation
- [x] Referral code processing
- [x] Navigation flow

3. **Auth State Tests**
- [x] Session persistence
- [x] Session expiry
- [x] State management
- [x] Auth stream handling

4. **Error Handling Tests**
- [x] Network errors
- [x] Server errors
- [x] Validation errors
- [x] UI error states

## UI Design Verification Checklist

### Login Screen
- [ ] **Header Section**
  - [ ] "Welcome Back" text uses Headline1 style
  - [ ] Subtitle uses Body1 style
  - [ ] Proper vertical spacing (xxLarge)

- [ ] **Form Fields**
  - [ ] Email field styling matches design
  - [ ] Password field includes show/hide toggle
  - [ ] Proper spacing between fields (medium)
  - [ ] Helper text styling matches design

- [ ] **Buttons**
  - [ ] Primary button matches design system
  - [ ] Loading spinner centered in button
  - [ ] Text button styling for "Forgot Password"
  - [ ] Proper button spacing (large)

### Signup Screen
- [ ] **Header Section**
  - [ ] "Create Account" text uses Headline1 style
  - [ ] Subtitle uses Body1 style
  - [ ] Proper vertical spacing (xxLarge)

- [ ] **Form Fields**
  - [ ] All fields match design system
  - [ ] Password requirements helper text
  - [ ] Referral code field styling
  - [ ] Proper field spacing (medium)

- [ ] **Error States**
  - [ ] Error text color matches design
  - [ ] Error icon alignment
  - [ ] Error message spacing (small)
  - [ ] Field border color in error state

### Responsive Design
- [ ] **Mobile Layout**
  - [ ] Proper padding (Spacing.large)
  - [ ] Scrollable content
  - [ ] Keyboard handling
  - [ ] Touch target sizes

- [ ] **Tablet/Desktop**
  - [ ] Centered content
  - [ ] Maximum width constraints
  - [ ] Proper scaling
  - [ ] Maintained spacing ratios

## Notes
- Always test on both iOS and Android devices
- Verify keyboard behavior and form field focus
- Check accessibility features (screen readers, etc.)
- Test different network conditions
- Document any deviations from design specs 