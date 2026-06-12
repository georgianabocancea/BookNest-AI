from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from app import db
from app.models import User
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
import secrets
import re
from datetime import datetime, timedelta

if os.getenv("RAILWAY_ENVIRONMENT") is None:
    load_dotenv()

FRONTEND_URL = os.getenv('FRONTEND_URL', 'http://localhost:3000')
GMAIL_USER = os.getenv('GMAIL_USER')
GMAIL_APP_PASSWORD = os.getenv('GMAIL_APP_PASSWORD')

auth_bp = Blueprint('auth', __name__)


def send_email(to_email, subject, html_content):
    try:
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = f"BookNest AI <{GMAIL_USER}>"
        msg['To'] = to_email

        part = MIMEText(html_content, 'html')
        msg.attach(part)

        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(GMAIL_USER, GMAIL_APP_PASSWORD)
            server.sendmail(GMAIL_USER, to_email, msg.as_string())
        return True
    except Exception as e:
        print(f"Email send error: {e}")
        return False


def send_verification_email(email, username, token):
    verify_url = f"{FRONTEND_URL}/verify-email?token={token}"
    html = f"""
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #7B3F00;">🪺 Welcome to BookNest, {username}!</h1>
        <p style="color: #555; font-size: 16px;">
            Thank you for joining BookNest. Please verify your email address to get started.
        </p>
        <a href="{verify_url}" 
           style="display: inline-block; background-color: #7B3F00; color: white; 
                  padding: 12px 24px; border-radius: 12px; text-decoration: none; 
                  font-weight: bold; margin: 20px 0;">
            Verify my email
        </a>
        <p style="color: #999; font-size: 14px;">
            This link expires in 24 hours. If you didn't create a BookNest account, ignore this email.
        </p>
    </div>
    """
    return send_email(email, "Welcome to BookNest — Verify your email", html)


def send_reset_email(email, token):
    reset_url = f"{FRONTEND_URL}/reset-password?token={token}"
    html = f"""
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #7B3F00;">🪺 Reset your password</h1>
        <p style="color: #555; font-size: 16px;">
            We received a request to reset your BookNest password.
        </p>
        <a href="{reset_url}"
           style="display: inline-block; background-color: #7B3F00; color: white;
                  padding: 12px 24px; border-radius: 12px; text-decoration: none;
                  font-weight: bold; margin: 20px 0;">
            Reset my password
        </a>
        <p style="color: #999; font-size: 14px;">
            This link expires in 1 hour. If you didn't request this, ignore this email.
        </p>
    </div>
    """
    return send_email(email, "BookNest AI - Reset your password", html)


def is_strong_password(password: str) -> tuple[bool, str]:
    """Validate password strength.

    Requirements:
    - At least 8 characters
    - At least one lowercase letter
    - At least one uppercase letter
    - At least one digit
    - At least one special character
    """
    if not password or len(password) < 8:
        return False, 'Password must be at least 8 characters long.'
    if re.search(r"[a-z]", password) is None:
        return False, 'Password must include at least one lowercase letter.'
    if re.search(r"[A-Z]", password) is None:
        return False, 'Password must include at least one uppercase letter.'
    if re.search(r"\d", password) is None:
        return False, 'Password must include at least one digit.'
    if re.search(r"[^A-Za-z0-9]", password) is None:
        return False, 'Password must include at least one special character (e.g. !@#$%).'
    return True, ''


@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()

    # Validate password strength
    ok, msg = is_strong_password(data.get('password', ''))
    if not ok:
        return jsonify({'error': msg}), 400

    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already in use'}), 409

    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Username already taken'}), 409

    token = secrets.token_urlsafe(32)
    expires_at = datetime.utcnow() + timedelta(hours=24)

    user = User(
        email=data['email'],
        username=data['username'],
        password_hash=generate_password_hash(data['password'], method='pbkdf2:sha256'),
        is_verified=False,
        verification_token=token,
        token_expires_at=expires_at
    )
    db.session.add(user)
    db.session.commit()

    email_sent = send_verification_email(data['email'], data['username'], token)

    return jsonify({
        'message': 'Account created! Please check your email to verify your account.',
        'email_sent': email_sent
    }), 201


@auth_bp.route('/verify-email', methods=['POST'])
def verify_email():
    data = request.get_json()
    token = data.get('token')

    user = User.query.filter_by(verification_token=token).first()

    if not user:
        return jsonify({'error': 'Invalid verification link'}), 400

    if user.token_expires_at < datetime.utcnow():
        return jsonify({'error': 'Verification link has expired. Please register again.'}), 400

    user.is_verified = True
    user.verification_token = None
    user.token_expires_at = None
    db.session.commit()

    access_token = create_access_token(identity=str(user.id))
    return jsonify({
        'message': 'Email verified successfully!',
        'token': access_token,
        'username': user.username
    }), 200


@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data['email']).first()

    if not user or not check_password_hash(user.password_hash, data['password']):
        return jsonify({'error': 'Incorrect email or password'}), 401

    if not user.is_verified:
        return jsonify({'error': 'Please verify your email before logging in', 'not_verified': True}), 403

    token = create_access_token(identity=str(user.id))
    return jsonify({'token': token, 'username': user.username}), 200


@auth_bp.route('/forgot-password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    print(f"Forgot password request for: {data.get('email')}")
    user = User.query.filter_by(email=data.get('email')).first()
    print(f"User found: {user}")
    data = request.get_json()
    user = User.query.filter_by(email=data.get('email')).first()

    if not user:
        return jsonify({'message': 'If this email exists, you will receive a reset link.'}), 200

    token = secrets.token_urlsafe(32)
    expires_at = datetime.utcnow() + timedelta(hours=1)
    user.reset_token = token
    user.reset_token_expires_at = expires_at
    db.session.commit()

    send_reset_email(user.email, token)

    return jsonify({'message': 'If this email exists, you will receive a reset link.'}), 200


@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    data = request.get_json()
    token = data.get('token')
    new_password = data.get('password')

    user = User.query.filter_by(reset_token=token).first()

    if not user:
        return jsonify({'error': 'Invalid reset link'}), 400

    if user.reset_token_expires_at < datetime.utcnow():
        return jsonify({'error': 'Reset link has expired'}), 400

    # Validate password strength on reset as well
    ok, msg = is_strong_password(new_password)
    if not ok:
        return jsonify({'error': msg}), 400

    user.password_hash = generate_password_hash(new_password, method='pbkdf2:sha256')
    user.reset_token = None
    user.reset_token_expires_at = None
    db.session.commit()

    return jsonify({'message': 'Password reset successfully!'}), 200