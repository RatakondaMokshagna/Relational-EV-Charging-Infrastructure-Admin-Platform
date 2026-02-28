# ---------------- STATIC INR CONVERSION ----------------

CURRENCY_TO_INR = {
    "INR": 1,
    "USD": 83,
    "EUR": 90,
    "GBP": 105
}

from flask import Flask, render_template, request, redirect, url_for, send_file
import psycopg2
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
from reportlab.lib.units import inch

app = Flask(__name__)

# ---------------- DATABASE CONNECTION ----------------

conn = psycopg2.connect(
    dbname="voltgrid_system",
    user="postgres",
   password=os.getenv("PASSWORD"),
    host="localhost",
    port="5432"
)

# ---------------- ADMIN DASHBOARD ----------------

@app.route("/")
@app.route("/admin")
def admin_dashboard():
    cur = conn.cursor()

    # Active sessions
    cur.execute("""
        SELECT cs.session_id,
               v.registration_number,
               c.city_name,
               cs.start_time,
               cp.point_id
        FROM Charging_Session cs
        JOIN Vehicle v ON cs.vehicle_id = v.vehicle_id
        JOIN Charging_Point cp ON cs.point_id = cp.point_id
        JOIN Charging_Station st ON cp.station_id = st.station_id
        JOIN City c ON st.city_id = c.city_id
        WHERE cs.end_time IS NULL
        ORDER BY cs.start_time DESC;
    """)
    sessions = cur.fetchall()

    # Revenue in INR
    cur.execute("""
        SELECT cs.total_cost, c.currency
        FROM Charging_Session cs
        JOIN Charging_Point cp ON cs.point_id = cp.point_id
        JOIN Charging_Station st ON cp.station_id = st.station_id
        JOIN City c ON st.city_id = c.city_id
        WHERE cs.end_time IS NOT NULL;
    """)
    rows = cur.fetchall()

    revenue = 0
    for cost, currency in rows:
        rate = CURRENCY_TO_INR.get(currency, 1)
        revenue += float(cost) * rate

    # Cities
    cur.execute("SELECT city_id, city_name FROM City;")
    cities = cur.fetchall()

    # Models
    cur.execute("SELECT model_id, manufacturer || ' ' || model_name FROM EV_Model;")
    models = cur.fetchall()

    cur.close()

    return render_template("admin.html",
                           sessions=sessions,
                           revenue=round(revenue, 2),
                           cities=cities,
                           models=models)

# ---------------- START SESSION ----------------

@app.route("/start", methods=["POST"])
def start():
    city_id = request.form["city_id"]
    model_id = request.form["model_id"]
    car_name = request.form["car_name"]

    cur = conn.cursor()

    # Reuse or create vehicle
    cur.execute("SELECT vehicle_id FROM Vehicle WHERE registration_number=%s;", (car_name,))
    existing = cur.fetchone()

    if existing:
        vehicle_id = existing[0]
    else:
        cur.execute("""
            INSERT INTO Vehicle (model_id, registration_number, city_id)
            VALUES (%s,%s,%s)
            RETURNING vehicle_id;
        """, (model_id, car_name, city_id))
        vehicle_id = cur.fetchone()[0]

    # Find available charging point
    cur.execute("""
        SELECT cp.point_id
        FROM Charging_Point cp
        JOIN Charging_Station cs ON cp.station_id = cs.station_id
        WHERE cs.city_id = %s AND cp.status='Available'
        LIMIT 1;
    """, (city_id,))
    point = cur.fetchone()

    if not point:
        cur.close()
        return "No charging point available."

    point_id = point[0]

    cur.execute("SELECT start_charging_session(%s,%s);", (vehicle_id, point_id))
    conn.commit()
    cur.close()

    return redirect(url_for("admin_dashboard"))

# ---------------- STOP SESSION ----------------

@app.route("/stop/<int:session_id>")
def stop(session_id):
    cur = conn.cursor()

    cur.execute("SELECT stop_charging_session(%s);", (session_id,))
    conn.commit()
    cur.close()

    return redirect(url_for("generate_bill", session_id=session_id))

# ---------------- GENERATE BILL ----------------

@app.route("/bill/<int:session_id>")
def generate_bill(session_id):
    cur = conn.cursor()

    cur.execute("""
        SELECT v.registration_number,
               c.city_name,
               c.currency,
               cs.duration_minutes,
               cs.energy_consumed_kwh,
               cs.price_per_kwh_snapshot,
               cs.total_cost
        FROM Charging_Session cs
        JOIN Vehicle v ON cs.vehicle_id = v.vehicle_id
        JOIN Charging_Point cp ON cs.point_id = cp.point_id
        JOIN Charging_Station st ON cp.station_id = st.station_id
        JOIN City c ON st.city_id = c.city_id
        WHERE cs.session_id = %s;
    """, (session_id,))
    
    data = cur.fetchone()
    cur.close()

    vehicle = data[0]
    city = data[1]
    currency = data[2]
    duration = data[3]
    energy = data[4]
    price = data[5]
    local_total = data[6]

    rate = CURRENCY_TO_INR.get(currency, 1)
    inr_total = float(local_total) * rate

    file_path = f"bill_{session_id}.pdf"
    doc = SimpleDocTemplate(file_path)
    elements = []

    styles = getSampleStyleSheet()
    elements.append(Paragraph("VoltGrid EV Charging Bill", styles['Title']))
    elements.append(Spacer(1, 0.3 * inch))

    table_data = [
        ["Session ID", session_id],
        ["Vehicle", vehicle],
        ["City", city],
        ["Local Currency", currency],
        ["Duration (minutes)", duration],
        ["Energy (kWh)", energy],
        ["Price per kWh", price],
        ["Total (Local)", f"{local_total} {currency}"],
        ["Total (Converted)", f"{round(inr_total,2)} INR"]
    ]

    table = Table(table_data)
    table.setStyle(TableStyle([
        ('GRID', (0,0), (-1,-1), 1, colors.black),
        ('BACKGROUND', (0,0), (-1,0), colors.lightgrey),
    ]))

    elements.append(table)
    doc.build(elements)

    return send_file(file_path, as_attachment=True)

# ---------------- RUN ----------------

if __name__ == "__main__":

    app.run(debug=True)
