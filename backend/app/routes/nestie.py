from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import UserBook, User
from dotenv import load_dotenv
from groq import Groq
import os

load_dotenv()
nestie_bp = Blueprint('nestie', __name__)
client = Groq(api_key=os.getenv('OPENAI_API_KEY'))

def get_user_context(user_id):
    user = User.query.get(user_id)
    user_books = UserBook.query.filter_by(user_id=user_id).all()
    
    read_books = [ub for ub in user_books if ub.status == 'read']
    reading_books = [ub for ub in user_books if ub.status == 'reading']
    to_read_books = [ub for ub in user_books if ub.status == 'to_read']
    
    context = f"The user's name is {user.username}.\n"
    
    if read_books:
        context += f"Books they have read: {', '.join([ub.book.title + ' by ' + ub.book.author for ub in read_books])}.\n"
        rated = [ub for ub in read_books if ub.rating]
        if rated:
            context += f"Their ratings: {', '.join([ub.book.title + ' (' + str(ub.rating) + '/5)' for ub in rated])}.\n"
    
    if reading_books:
        context += f"Currently reading: {', '.join([ub.book.title + ' by ' + ub.book.author for ub in reading_books])}.\n"
    
    if to_read_books:
        context += f"Want to read: {', '.join([ub.book.title for ub in to_read_books])}.\n"
    
    return context

@nestie_bp.route('/chat', methods=['POST'])
@jwt_required()
def chat():
    user_id = get_jwt_identity()
    data = request.get_json()
    messages = data.get('messages', [])
    
    user_context = get_user_context(int(user_id))
    
    system_prompt = f"""You are Nestie, a warm and knowledgeable AI reading assistant for BookNest, a personal library app. 
You help users with book recommendations, discuss authors, explain literary terms, assist with writing reviews, and motivate their reading journey.
You are friendly, enthusiastic about books, and always personalize your responses based on the user's reading history.

Here is what you know about this user:
{user_context}

Guidelines:
- Keep responses concise and conversational
- Use the user's reading history to personalize recommendations
- When recommending books, briefly explain why they might enjoy them
- You can discuss any book, author, or literary topic
- Help users write reviews by asking about their thoughts and feelings
- Always respond in the same language the user writes in"""

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {"role": "system", "content": system_prompt},
            *messages
        ],
        max_tokens=500,
        temperature=0.7,
    )
    
    return jsonify({
        "message": response.choices[0].message.content
    })