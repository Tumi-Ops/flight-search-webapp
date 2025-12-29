import os
from datetime import datetime
import requests
from flask import Flask, request, render_template, redirect, session, url_for, flash, get_flashed_messages
from data_manager import DataManager
from flight_search import FlightSearch
from flight_data import FlightData
from flight_form import FlightForm, TripAlertForm, SubscribeForm
from flask_bootstrap import Bootstrap5
from authlib.integrations.flask_client import OAuth
from dotenv import load_dotenv

load_dotenv()
id_token = None
api_headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {id_token}"
}

API_URL = os.getenv("AWS_API_GATEWAY")
if not API_URL:
    raise RuntimeError("AWS_API_GATEWAY is not set")

SUBSCRIPTION_URL = os.getenv("AWS_API_GATEWAY_SUBSCRIPTION")
if not SUBSCRIPTION_URL:
    raise RuntimeError("AWS_API_GATEWAY is not set")

app = Flask(__name__)
Bootstrap5(app)
app.config['PREFERRED_URL_SCHEME'] = 'http'
app.config['SERVER_NAME'] = 'localhost:5000'
app.config['SECRET_KEY'] = 'your-secret-key-here'
app.secret_key = os.urandom(24)

# For Signup and Login
oauth = OAuth(app)
oauth.register(
    name='oidc',
    authority='https://cognito-idp.eu-north-1.amazonaws.com/eu-north-1_f1zENbFUo',
    client_id='lb7butfnsmiti0aqpi5kgc0k9',
    server_metadata_url='https://cognito-idp.eu-north-1.amazonaws.com/eu-north-1_f1zENbFUo/.well-known/openid-configuration',
    client_kwargs={'scope': 'email openid'}
)


##########

@app.route("/login")
def login():
    return oauth.oidc.authorize_redirect('http://localhost:5000/authorize')


@app.route('/authorize')
def authorize():
    token = oauth.oidc.authorize_access_token()
    user = token['userinfo']
    session['user'] = user
    session['id_token'] = token['id_token']
    get_flashed_messages()
    session.pop('_flashes', None)
    session['search_count'] = 4
    return redirect(url_for('home'))


@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect(url_for('home'))


@app.route("/", methods=["GET", "POST"])
def home():
    form = FlightForm()
    if 'search_count' not in session:
        session['search_count'] = 0

    if session['search_count'] == 4:
        get_flashed_messages()
        session.pop('_flashes', None)
    elif session['search_count'] == 3:
        flash("You must be logged in after 3 free searches.", "danger")

    user = session.get('user')
    if user:
        if form.validate_on_submit():
            search_for_flight()
            return redirect(url_for('results'))

    if form.validate_on_submit() and not user and session['search_count'] < 3:
        search_for_flight()
        session['search_count'] += 1
        return redirect(url_for('results'))

    return render_template("index.html", form=form, user=user, active_page="home")


@app.route("/flight_results")
def results():
    # Retrieve data from session
    flight_messages = session.get('flight_messages', [])
    structured_flights = session.get('structured_flights', [])
    search_params = session.get('details', {})
    return render_template("results.html",
                           flight_messages=flight_messages,
                           structured_flights=structured_flights,
                           search_params=search_params, user=session.get('user'))


@app.route("/trip_alert", methods=["GET", "POST"])
def trip_alert():
    global id_token, api_headers
    form = TripAlertForm()
    user = session.get('user')
    alerts = []
    if user:
        id_token = session['id_token']
        api_headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {id_token}"
        }
        read_response = requests.get(url=API_URL, headers=api_headers, timeout=30)

        items = read_response.json()
        if items:
            alerts = {"alerts": items}
        else:
            alerts = []
        if form.validate_on_submit():
            try:
                payload = {
                    "created_at": str(datetime.now()),
                    "destination_city": form.destination_city.data,
                    "origin_location": form.origin_location.data,
                    "max_price": form.max_price.data,
                    "adults": form.adults.data,
                    "children": form.children.data,
                    "infants": form.infants.data,
                    "from_date": str(form.from_date.data),
                    "to_date": str(form.to_date.data)
                }

                api_gateway_response = requests.post(url=API_URL, headers=api_headers, json=payload, timeout=30)
                if api_gateway_response.status_code == 200:
                    print(f"\n✅ {api_gateway_response.text}")
                    flash(f"Trip set successfully! You will be notified by email when it is found!"
                          f"\nCheck the 'Live Trips' tab, to view your trip.", "success")
                else:
                    print(f"\n❌ {api_gateway_response.text} ")
                    flash(f"{api_gateway_response.raise_for_status()}", "danger")

                return redirect(url_for("trip_alert", active_page="trip_alert", form=form, user=session.get('user'),
                                        alerts=alerts))
            except Exception as e:
                flash(f"Error: {e}")

    if request.method == 'POST' and not user:
        flash("You must be logged in before creating alerts for flights.", "danger")

    return render_template("trip_alert.html", active_page="trip_alert", form=form, user=session.get('user'),
                           alerts=alerts)


@app.route("/delete_alert/<alert_id>", methods=["GET", "POST"])
def delete_alert(alert_id):
    global id_token, api_headers
    user = session.get('user')
    if user:
        id_token = session['id_token']
        payload = {
            "created_at": alert_id
        }
        api_gateway_response = requests.delete(url=API_URL, headers=api_headers, json=payload, timeout=30)
        if api_gateway_response.status_code == 200:
            print(f"\n✅ {api_gateway_response.text}")
            flash(f"Alert delete successfully!", "success")
        else:
            print(f"\n❌ {api_gateway_response.text} ")
            flash(f"{api_gateway_response.raise_for_status()}", "danger")
    return redirect(url_for("trip_alert"))


@app.route("/pricing")
def pricing():
    return render_template("pricing.html", active_page="pricing", user=session.get('user'))


@app.route("/faq")
def faq():
    return render_template("faq.html", active_page="faq", user=session.get('user'))


@app.route("/about")
def about():
    return render_template("about.html", active_page="about", user=session.get('user'))


@app.route("/contact", methods=["GET", "POST"])
def contact():
    form = SubscribeForm()
    if form.validate_on_submit():
        headers = {
            "Content-Type": "application/json",
        }
        payload = {
            "email": form.email.data
        }
        api_gateway_response = requests.post(url=SUBSCRIPTION_URL, headers=headers, json=payload, timeout=30)
        if api_gateway_response.status_code == 200:
            print(f"\n✅ {api_gateway_response.text}")
            flash(f"Subscription successful! \nPlease confirm your subscription in your emails to activate it!", "success")
        else:
            print(f"\n❌ {api_gateway_response.text} ")
            flash(f"{api_gateway_response.raise_for_status()}", "danger")

    return render_template("contact.html", active_page="contact", user=session.get('user'), subscribe_form=form)

def search_for_flight():
    form = FlightForm()
    data_manage = DataManager()
    data_manage.get_iata_codes(city=form.city.data, og_loc=form.origin_location.data)

    fly_search = FlightSearch(data_manage)
    fly_search.get_flights(dep_date=form.departure_date.data,
                           ret_date=form.return_date.data, ad=form.adults.data,
                           child=form.children.data, inf=form.infants.data, tc=form.travel_class.data)

    fly_data = FlightData(data_manage, fly_search)

    session['flight_messages'] = fly_data.offer_messages
    session['structured_flights'] = fly_data.structured_flights
    session['details'] = {
        'origin': form.origin_location.data,
        'destination': form.city.data,
        'adults': form.adults.data,
        'children': form.children.data,
        'infants': form.infants.data,
        'travel_class': form.travel_class.data,
        'departure_date': form.departure_date.data.strftime('%Y-%m-%d'),
        'return_date': form.return_date.data.strftime('%Y-%m-%d')
    }


if __name__ == '__main__':
    app.run(debug=True, port=5000)
