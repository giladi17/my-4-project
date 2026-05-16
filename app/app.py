from flask import Flask, request, jsonify

app = Flask(__name__)


# נתיב GET שמחזיר "Hello, DevOps!"
@app.route('/', methods=['GET'])
def hello():
    return "Hello, DevOps!"


# נתיב POST שמקבל JSON ומחזיר אותו חזרה
@app.route('/echo', methods=['POST'])
def echo():
    data = request.get_json()
    return jsonify(data)


if __name__ == '__main__':
    # הערה קצרה כדי לא לעבור 79 תווים
    app.run(host='0.0.0.0', port=5000)
    