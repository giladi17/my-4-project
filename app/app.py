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
    # אנחנו מגדירים 0.0.0.0 כדי שהאפליקציה תהיה נגישה מבחוץ כשהיא תרוץ בתוך Docker
    app.run(host='0.0.0.0', port=5000)
