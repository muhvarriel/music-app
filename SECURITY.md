# Security Policy

## 🔒 Security Overview

We take the security of the Music App project seriously. This document outlines our security policy, supported versions, and procedures for reporting security vulnerabilities.

## 📋 Supported Versions

We actively maintain and provide security updates for the following versions:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 1.0.x   | ✅ Yes            | Active |
| < 1.0   | ❌ No             | Deprecated |

## 🛡️ Security Features

### Current Security Implementations

- **API Key Protection**: Spotify API credentials are stored in configuration files (not in version control)
- **Token Management**: Automatic token refresh with secure storage using SharedPreferences
- **Input Validation**: Search queries are sanitized before API calls
- **Network Security**: HTTPS-only communication with Spotify APIs
- **Error Handling**: Sensitive information is not exposed in error messages

### Data Protection

- **Local Storage**: User preferences and favorites are stored locally using SharedPreferences
- **No Personal Data**: The app does not collect or store personal user information
- **Audio Previews**: Only 30-second previews are played, respecting Spotify's content policies
- **API Rate Limiting**: Debounced search prevents API abuse

## 🚨 Reporting Security Vulnerabilities

If you discover a security vulnerability in this project, please help us by reporting it responsibly.

### 📧 How to Report

**Please DO NOT report security vulnerabilities through public GitHub issues.**

Instead, please report vulnerabilities through one of the following methods:

#### 1. GitHub Security Advisories (Preferred)
- Go to the [Security tab](https://github.com/muhvarriel/music-app/security) of this repository
- Click "Report a vulnerability"
- Fill out the vulnerability report form

#### 2. Email Report
- Send an email to: **muhvarriel@gmail.com**
- Subject: `[SECURITY] Music App Vulnerability Report`
- Include detailed information about the vulnerability

### 📝 What to Include in Your Report

Please provide as much of the following information as possible:

- **Type of vulnerability** (e.g., API key exposure, injection, etc.)
- **Location of the affected code** (file path and line numbers if possible)
- **Step-by-step instructions** to reproduce the vulnerability
- **Potential impact** of the vulnerability
- **Suggested fix** or mitigation (if you have one)
- **Your contact information** for follow-up questions

### ⏱️ Response Timeline

We are committed to addressing security vulnerabilities promptly:

- **Initial Response**: Within 48 hours of receiving the report
- **Assessment**: Within 1 week of initial response
- **Fix Development**: Varies based on complexity (typically 1-4 weeks)
- **Patch Release**: Within 1 week of fix completion
- **Public Disclosure**: After patch is released and users have time to update

## 🔐 Security Best Practices for Contributors

### API Security

```dart
// ❌ DON'T: Hardcode API credentials
class BadExample {
  static const String clientId = "your_actual_client_id";
  static const String clientSecret = "your_actual_secret";
}

// ✅ DO: Use environment configuration
class AppEnvironment {
  static const String spotifyClientId = String.fromEnvironment('SPOTIFY_CLIENT_ID');
  static const String spotifyClientSecret = String.fromEnvironment('SPOTIFY_CLIENT_SECRET');
}
```

### Input Validation

```dart
// ✅ DO: Validate and sanitize user input
Future<dynamic> searchTrack(String content) async {
  // Sanitize input
  String query = content.trim().replaceAll(RegExp(r'[<>"']'), '');

  if (query.isEmpty || query.length > 100) {
    return [400, "Invalid search query"];
  }

  String encodedQuery = Uri.encodeComponent(query);
  // ... rest of the implementation
}
```

### Error Handling

```dart
// ❌ DON'T: Expose sensitive information in errors
catch (e) {
  print("Error with token: ${apiToken}"); // Exposes sensitive data
}

// ✅ DO: Log errors securely
catch (e) {
  log('API request failed: ${e.message}'); // Safe logging
  return [500, "Request failed"];
}
```

## 🔍 Security Checklist for Development

### Before Committing Code

- [ ] No hardcoded API keys or secrets
- [ ] Input validation for all user inputs
- [ ] Proper error handling without information disclosure
- [ ] HTTPS-only network requests
- [ ] Secure storage for sensitive data
- [ ] Rate limiting for API calls

### Before Releasing

- [ ] Security review of new features
- [ ] Dependency vulnerability scan
- [ ] API key rotation (if needed)
- [ ] Documentation updated with security considerations
- [ ] Test credentials removed from configuration

## 🛠️ Security Tools and Scanning

### Recommended Tools

- **Flutter Analyze**: Built-in static analysis
- **Dependency Check**: Scan for vulnerable dependencies
- **Git Secrets**: Prevent committing secrets
- **SAST Tools**: Static Application Security Testing

### Commands for Security Scanning

```bash
# Run Flutter static analysis
flutter analyze

# Check for outdated/vulnerable packages
flutter pub deps
flutter pub outdated

# Audit dependencies (if using npm for web)
npm audit
```

## 📚 Security Resources

### Flutter Security Guidelines
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/security)
- [Dart Security Guidelines](https://dart.dev/guides/language/security)

### API Security
- [Spotify API Security](https://developer.spotify.com/documentation/general/guides/authorization/)
- [OAuth 2.0 Security Best Practices](https://tools.ietf.org/html/draft-ietf-oauth-security-topics)

### Mobile App Security
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Android Security Guidelines](https://developer.android.com/training/articles/security-tips)
- [iOS Security Guidelines](https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/)

## 🏆 Security Hall of Fame

We recognize and appreciate security researchers who help make our project safer:

<!-- Security researchers who report vulnerabilities will be listed here -->
*No security reports received yet.*

## 📄 Legal

By reporting a vulnerability, you agree that:

- You will not publicly disclose the vulnerability until we have had a reasonable time to address it
- You will not access, modify, or delete data belonging to others
- You will not perform any attacks that could harm the availability of our services
- Your research and disclosure activities will comply with applicable laws

## 📞 Contact Information

**Security Team**: Varriel Muhammad  
**Email**: muhvarriel@gmail.com  
**GitHub**: [@muhvarriel](https://github.com/muhvarriel)  
**Response Time**: Within 48 hours

---

**Last Updated**: October 2025  
**Policy Version**: 1.0

Thank you for helping keep Music App and our users safe! 🙏
