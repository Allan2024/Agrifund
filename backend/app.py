from flask import Flask, request, jsonify, render_template
from translate import Translator
from werkzeug.security import generate_password_hash, check_password_hash
from flask_pymongo import PyMongo
import firebase_admin
from firebase_admin import credentials, db
from pymongo import MongoClient
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel
import secrets
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.secret_key = secrets.token_hex(16)

# Initialize Firebase
cred = credentials.Certificate("C:/Users/allan/Downloads/schemez/major-farmer-firebase-adminsdk-odnhy-d09d4e46ea.json")
firebase_admin.initialize_app(cred, {'databaseURL': 'https://major-farmer-default-rtdb.firebaseio.com/'})

# Connect to MongoDB
client = MongoClient('mongodb://localhost:27017')
db_mongo = client['farmers_db']
collection = db_mongo['newcollection']

# Connect to FarmerLogin MongoDB
db_mongo_login = client['FarmerLogin']
collection_login = db_mongo_login['FarmerData']

# Preprocess the dataset
cursor = collection.find({})
df = pd.DataFrame(list(cursor))
df = df.fillna('')
# Fetch the eligibility criteria for all schemes from the farmers_db collection
eligibility_criteria_list = df['Eligibilty_criteria'].tolist()

# Make sure to replace 'Tags', 'Eligibilty_criteria', 'Scheme_Name' with actual field names
vectorizer = TfidfVectorizer(stop_words='english')
combined_text = df['Eligibilty_criteria'].astype(str) + ' ' + df['Tags'].astype(str)
tfidf_matrix = vectorizer.fit_transform(combined_text)

# Translator function
def translate_text(text, source_language, target_language):
    translator = Translator(from_lang=source_language, to_lang=target_language)
    translated_text = translator.translate(text)
    return translated_text


@app.route('/translate', methods=['POST'])
def translate():
    original_text = request.json.get('text')
    source_language = request.json.get('source_language', 'en')  # Default source language is English
    target_language = request.json.get('target_language', 'mr')  # Default target language is Marathi

    translated_text = translate_text(original_text, source_language, target_language)

    return jsonify({'translated_text': translated_text})

@app.route('/get_scheme_names', methods=['GET'])
def get_scheme_names():
    query = request.args.get('query', '')
    regex_query = {'Scheme_Name': {'$regex': f'.*{query}.*', '$options': 'i'}}
    schemes = collection.find(regex_query, {'Scheme_Name': 1})
    scheme_names = [scheme['Scheme_Name'] for scheme in schemes]
    return jsonify({'schemes': scheme_names})

@app.route('/register_profile', methods=['POST'])
def register_profile():
    if request.method == 'POST':
        name = request.form.get('name')
        state = request.form.get('state')
        occupation = request.form.get('occupation')
        password = request.form.get('password')
        gender = request.form.get('gender')  # Add gender field
        age = request.form.get('age')  # Add age field
        has_ownership = request.form.get('hasOwnership')  # Add hasOwnership field
        income = request.form.get('income')  # Add income field

        hashed_password = generate_password_hash(password)
        collection_login.insert_one({
            'name': name,
            'state': state,
            'occupation': occupation,
            'password': hashed_password,
            'gender': gender,
            'age': age,
            'hasOwnership': has_ownership,
            'income': income
        })

        return "Profile registered successfully"

    return "Invalid request method"


@app.route('/get_user_data', methods=['GET'])
def get_user_data():
    username = request.args.get('username', '')
    user_data = collection_login.find_one({'name': username}, {'_id': 0, 'password': 0})  # Exclude password field
    return jsonify(user_data)

# Route to get scheme recommendations based on user input
@app.route('/get_suggested_keywords', methods=['GET'])
def get_suggested_keywords():
    input_text = request.args.get('input', '').lower()
    matched_keywords = set()
    max_keywords = 5  # Maximum number of suggested keywords

    # Iterate through each scheme's tags and find matches
    for tags in df['Tags']:
        for tag in tags.split(','):
            if input_text in tag.lower():
                matched_keywords.add(tag.strip())
                if len(matched_keywords) >= max_keywords:
                    break  # Stop adding more keywords if the limit is reached
        if len(matched_keywords) >= max_keywords:
            break  # Stop iterating through schemes if the limit is reached

    return jsonify({'suggested_keywords': list(matched_keywords)})


@app.route('/get_recommendations')
def get_recommendations():
    user_input = request.args.get('user_input', '')

    # Vectorize the user input
    user_input_vectorized = vectorizer.transform([user_input])

    # Calculate cosine similarities
    cosine_similarities = linear_kernel(user_input_vectorized, tfidf_matrix).flatten()

    # Get indices of schemes sorted by similarity
    scheme_indices = cosine_similarities.argsort()[::-1]

    # Prepare recommended schemes
    recommended_schemes = []
    for idx in scheme_indices[:5]:
        name = df['Scheme_Name'].iloc[idx]
        description = df['Description'].iloc[idx]
        eligibility_criteria = df['Eligibilty_criteria'].iloc[idx]
        tags = df['Tags'].iloc[idx]
        link = df['Links'].iloc[idx]

        # Check if any of the scheme details are empty
        if name and description and eligibility_criteria and tags and link:
            recommended_schemes.append({
                'name': name,
                'description': description,
                'eligibility_criteria': eligibility_criteria,
                'tags': tags,
                'link': link,
                'similarity': cosine_similarities[idx]  # Include the similarity value
            })

    return jsonify({'recommended_schemes': recommended_schemes})


@app.route('/get_profile_recommendations')
def get_profile_recommendations():
    username = request.args.get('username', '')
    user_data = collection_login.find_one({'name': username}, {'_id': 0, 'password': 0})  # Exclude password field

    if not user_data:
        return jsonify({'error': 'User not found'}), 404

    age = user_data.get('age', '')
    if age:
        if age.isdigit():
            age = int(age)
            if age < 18:
                age = "below 18"
            elif age >= 18 and age < 35:
                age = "above 18"
            else:
                age = "above 35"

    user_keywords = ' '.join(str(value) for value in user_data.values())
    user_input_vectorized = vectorizer.transform([user_keywords])
    cosine_similarities = linear_kernel(user_input_vectorized, tfidf_matrix).flatten()
    scheme_indices = cosine_similarities.argsort()[::-1]
    recommended_schemes = []

    for idx in scheme_indices[:5]:
        recommended_schemes.append({
            'name': df['Scheme_Name'].iloc[idx],
            'description': df['Description'].iloc[idx],
            'eligibility_criteria': df['Eligibilty_criteria'].iloc[idx],
            'link': df['Links'].iloc[idx],
            'similarity': cosine_similarities[idx],  # Include the similarity value
            'age': age  # Include the converted age value
        })

    return jsonify({'recommended_schemes': recommended_schemes})
@app.route('/custom_login', methods=['POST'])
def custom_login():
    if request.method == 'POST':
        name = request.form.get('name')
        password = request.form.get('password')

        user = collection_login.find_one({'name': name})

        if user and check_password_hash(user['password'], password):
            return jsonify({'message': 'Login successful'}), 200
        else:
            return jsonify({'error': 'Invalid username or password. Please try again.'}), 401

    return jsonify({'error': 'Invalid request method'}), 400

@app.route('/update_profile', methods=['POST'])
def update_profile():
    data = request.form
    username = data.get('username')
    caste = data.get('caste')
    gender = data.get('gender')
    income = data.get('income')
    has_ownership = data.get('hasOwnership')
    age = data.get('age')

    try:
        collection_login.update_one(
            {'name': username},
            {'$set': {
                'caste': caste,
                'gender': gender,
                'income': income,
                'hasOwnership': has_ownership,
                'age': age
            }}
        )

        return jsonify({'message': 'Profile updated successfully'}), 200

    except Exception as e:
        print('Error:', str(e))
        return jsonify({'error': 'An error occurred while updating the profile'}), 500

@app.route('/check_eligibility', methods=['POST'])
def check_eligibility():
    data = request.form

    # Retrieve eligibility criteria from MongoDB based on the selected scheme
    scheme_name = data.get('scheme', '')
    eligibility_criteria = collection.find_one({'Scheme_Name': scheme_name}, {'_id': 0, 'Eligibilty_criteria': 1})

    if eligibility_criteria:
        # Extract keywords from the eligibility criteria
        keywords = set(eligibility_criteria['Eligibilty_criteria'].lower().split(','))

        # Initialize the eligibility checklist with empty values
        eligibility_checklist = {
            'State': '',  # Initialize with empty value
            'Personal Identity': '',  # Initialize with empty value
            'Ownership': '',  # Initialize with empty value
            'Gender': '',  # Initialize with empty value
            'Age': '',  # Initialize with empty value
            'Occupation': '',  # Initialize with empty value
            'Caste': ''  # Initialize with empty value
        }

        # Check if the user has filled in the state field
        if 'state' in data:
            # Check if "central" keyword is present in the eligibility criteria
            use_user_state = 'central' not in keywords
            user_state = data.get('state', '').lower()
            eligibility_checklist['State'] = user_state if use_user_state else 'central'

            # Check if user's state matches the eligibility criteria
            if user_state not in keywords:
                # Return not eligible response if state doesn't match
                return jsonify({'eligibility_checklist': eligibility_checklist, 'message': 'You are not eligible. State criteria not satisfied.'}), 200

        # Check if the user has filled in the ownership field
        if 'ownership' in data:
            eligibility_checklist['Ownership'] = 'yes' if 'yes' in keywords and data.get('ownership', '').lower() == 'yes' else 'no'

        # Check if the user has filled in the gender field
        if 'gender' in data:
            eligibility_checklist['Gender'] = data.get('gender', '').lower()

        # Check if the user has filled in the age field
        if 'age' in data:
            user_age_input = data.get('age', '').lower()
            if user_age_input.isdigit():
                user_age = int(user_age_input)
                age_criteria = any(keyword.isdigit() and int(keyword) == user_age for keyword in keywords)
                eligibility_checklist['Age'] = user_age_input if age_criteria else ''
            else:
                eligibility_checklist['Age'] = ''

        # Check if the user has filled in the caste field
        if 'caste' in data:
            user_caste_input = data.get('caste', '').lower()
            if user_caste_input:
                caste_criteria = user_caste_input in keywords or 'all' in keywords
                eligibility_checklist['Caste'] = user_caste_input if caste_criteria else ''
            else:
                eligibility_checklist['Caste'] = ''

        # Check if the user has filled in the personal identity field
        if 'personalIdentity' in data:
            eligibility_checklist['Personal Identity'] = data.get('personalIdentity', '').lower()

        # Check if the user has filled in the occupation field
        if'occupation' in data:
            eligibility_checklist['Occupation'] = data.get('occupation', '').lower()

        # Check if user-entered values are present in eligibility keywords, considering partial matches
        matched_keywords = {
            key: value.lower() in keywords or (value.lower() == 'male' and 'male/female' in keywords) or (value.lower() == 'female' and 'male/female' in keywords)
            for key, value in eligibility_checklist.items()
        }

        # If age criterion is 'above/below 18', consider all age options as true
        if 'above/below 18' in keywords and 'Age' in eligibility_checklist:
            matched_keywords['Age'] = True

        # If caste criterion is 'all', consider all caste options as true
        if 'all' in keywords and 'Caste' in eligibility_checklist:
            matched_keywords['Caste'] = True

        eligibility_checklist_result = {
            key: {
                'value': value,
                'matched': matched_keywords[key]
            }
            for key, value in eligibility_checklist.items()
        }

        # Print whether the fields are matching or not
        print("Matched Keywords:", matched_keywords)

        # Count the number of matched criteria
        matched_criteria_count = sum(matched_keywords.values())

        # Check if at least three criteria are met for eligibility
        if matched_criteria_count >= 3:
            return jsonify({'eligibility_checklist': eligibility_checklist_result, 'message': 'You are eligible!'})
        else:
            return jsonify({'eligibility_checklist': eligibility_checklist_result, 'message': 'You are not eligible.'}), 200
    else:
        return jsonify({'error': 'Scheme not found'}), 404

# The rest of your Flask code...
# Run the application
if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)