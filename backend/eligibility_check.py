from flask import Flask, render_template, request, jsonify
from pymongo import MongoClient

app = Flask(__name__)

# Connect to MongoDB
client = MongoClient('mongodb://localhost:27017')
db_mongo = client['farmers_db']
collection = db_mongo['newcollection']

@app.route('/eligibility_check_form')
def eligibility_check_form():
    return render_template('eligibility_check_form.html')

@app.route('/get_eligibility_criteria', methods=['POST'])
def get_eligibility_criteria():
    if request.method == 'POST':
        scheme_name = request.form.get('scheme_name')
        eligibility_criteria = collection.find_one({'scheme_name': scheme_name}, {'_id': 0, 'Eligibility_criteria': 1})

        if eligibility_criteria and 'Eligibility_criteria' in eligibility_criteria:
            return jsonify(eligibility_criteria['Eligibility_criteria'])
        else:
            return jsonify({})

@app.route('/check_eligibility', methods=['POST'])
def check_eligibility():
    if request.method == 'POST':
        scheme_name = request.form.get('scheme_name')
        eligibility_criteria = collection.find_one({'scheme_name': scheme_name})

        if eligibility_criteria:
            # Fields for eligibility criteria
            eligibility_fields = list(eligibility_criteria['Eligibility_criteria'].keys())

            # Extract form data
            farmer_data = {field: request.form.get(field) for field in eligibility_fields}

            # Check eligibility
            eligible = all(farmer_data[field] == str(eligibility_criteria['Eligibility_criteria'].get(field)) for field in eligibility_fields)

            # Print data for comparison (server-side)
            print("MongoDB Data:", eligibility_criteria['Eligibility_criteria'])
            print("Input Data:", farmer_data)

            return jsonify({'eligible': eligible, 'message': 'Scheme not found' if not eligibility_criteria else '', 'mongodb_data': eligibility_criteria['Eligibility_criteria']})
        else:
            return jsonify({'eligible': False, 'message': 'Scheme not found'})

if __name__ == '__main__':
    app.run(debug=True)
