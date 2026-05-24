from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
import os
import random
import string
import re
from datetime import datetime
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.secret_key = 'doctor_secret_key'

UPLOAD_FOLDER = 'static/uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def get_db_connection():
    return mysql.connector.connect(
        host="localhost", user="root", password="", database="ehr_system"
    )

def generate_patient_id():
    year = datetime.now().year
    random_code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))
    return f"PAT-{year}-{random_code}"

def is_strong_password(password):
    if len(password) < 8: return False
    if not re.search(r"[A-Z]", password): return False
    if not re.search(r"[0-9]", password): return False
    if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password): return False
    return True

@app.route('/')
def index(): 
    return render_template('index.html')

@app.route('/about')
def about(): 
    return render_template('about.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        u, p, e = request.form.get('username'), request.form.get('password'), request.form.get('email')
        if not is_strong_password(p):
            return render_template('register.html', error="Requirement: 8+ chars, Upper, Num, Special.")
        db = get_db_connection(); cursor = db.cursor()
        try:
            cursor.execute("INSERT INTO doctors (username, password, email) VALUES (%s, %s, %s)", (u, p, e))
            db.commit(); cursor.close()
            flash("Registration Successful! Please check your email for confirmation.")
            return redirect(url_for('login'))
        except mysql.connector.Error as err: return f"Error: {err}"
        finally: db.close()
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        u, p = request.form.get('username'), request.form.get('password')
        db = get_db_connection(); cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM doctors WHERE username = %s AND password = %s", (u, p))
        doc = cursor.fetchone()
        cursor.close(); db.close()
        if doc:
            session['doctor_id'] = doc['id']
            return redirect(url_for('dashboard'))
        return render_template('login.html', error="Invalid Credentials.")
    return render_template('login.html')

@app.route('/forgot_password', methods=['GET', 'POST'])
def forgot_password():
    if request.method == 'POST':
        email = request.form.get('email')
        return render_template('forgot_password.html', success=True)
    return render_template('forgot_password.html')

@app.route('/dashboard')
def dashboard():
    if 'doctor_id' not in session: return redirect(url_for('login'))
    db = get_db_connection(); cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM patients WHERE doctor_id = %s", (session['doctor_id'],))
    patients = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('dashboard.html', patients=patients)

@app.route('/add_patient', methods=['POST'])
def add_patient():
    if 'doctor_id' not in session: return redirect(url_for('login'))
    db = get_db_connection(); cursor = db.cursor()
    new_uid = generate_patient_id() 
    sql = """INSERT INTO patients (doctor_id, patient_uid, full_name, weight, blood_type, gender, dob, is_smoker, notes) 
             VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    cursor.execute(sql, (session['doctor_id'], new_uid, request.form.get('full_name'), request.form.get('weight'), 
                         request.form.get('blood_type'), request.form.get('gender'), request.form.get('dob'), 
                         1 if request.form.get('immunization') else 0, request.form.get('notes')))
    pid = cursor.lastrowid
    
    images = request.files.getlist('radiology_scan')
    for img in images:
        if img and img.filename != '':
            fname = secure_filename(img.filename)
            uname = f"{pid}_{random.randint(1000,9999)}_{fname}"
            img.save(os.path.join(app.config['UPLOAD_FOLDER'], uname))
            cursor.execute("INSERT INTO patient_images (patient_id, image_path) VALUES (%s, %s)", (pid, uname))
    db.commit(); cursor.close(); db.close()
    return redirect(url_for('dashboard'))

@app.route('/view_patient/<int:id>', methods=['GET', 'POST'])
def view_patient(id):
    if 'doctor_id' not in session: return redirect(url_for('login'))
    db = get_db_connection(); cursor = db.cursor(dictionary=True)
    if request.method == 'POST':
        sql = """UPDATE patients SET full_name=%s, weight=%s, blood_type=%s, gender=%s, dob=%s, is_smoker=%s, notes=%s 
                 WHERE id=%s AND doctor_id=%s"""
        cursor.execute(sql, (request.form.get('full_name'), request.form.get('weight'), request.form.get('blood_type'), 
                             request.form.get('gender'), request.form.get('dob'), 1 if request.form.get('immunization') else 0, 
                             request.form.get('notes'), id, session['doctor_id']))
        db.commit()
    cursor.execute("SELECT * FROM patients WHERE id = %s AND doctor_id = %s", (id, session['doctor_id']))
    p = cursor.fetchone()
    cursor.execute("SELECT * FROM patient_images WHERE patient_id = %s", (id,))
    imgs = cursor.fetchall()
    cursor.close(); db.close()
    return render_template('view_patient.html', p=p, images=imgs)

@app.route('/delete_image/<int:image_id>')
def delete_image(image_id):
    if 'doctor_id' not in session: return redirect(url_for('login'))
    db = get_db_connection(); cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM patient_images WHERE id = %s", (image_id,))
    img = cursor.fetchone()
    if img:
        try: os.remove(os.path.join(app.config['UPLOAD_FOLDER'], img['image_path']))
        except: pass
        cursor.execute("DELETE FROM patient_images WHERE id = %s", (image_id,))
        db.commit()
        return redirect(url_for('view_patient', id=img['patient_id']))
    return redirect(url_for('dashboard'))

@app.route('/delete_patient/<int:id>')
def delete_patient(id):
    if 'doctor_id' not in session: return redirect(url_for('login'))
    db = get_db_connection(); cursor = db.cursor()
    cursor.execute("DELETE FROM patients WHERE id = %s AND doctor_id = %s", (id, session['doctor_id']))
    db.commit(); cursor.close(); db.close()
    return redirect(url_for('dashboard'))

@app.route('/logout')
def logout(): session.clear(); return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)