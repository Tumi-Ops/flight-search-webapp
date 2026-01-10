import os
from datetime import datetime

import requests
from authlib.integrations.flask_client import OAuth
from flask import (
    Flask,
    flash,
    get_flashed_messages,
    jsonify,
    redirect,
    render_template,
    request,
    session,
    url_for,
)
from flask_bootstrap import Bootstrap5
from werkzeug.middleware.proxy_fix import ProxyFix

from flight_form import FlightForm, SubscribeForm, TripAlertForm

SEARCH_URL = "https://harperygxa.execute-api.eu-north-1.amazonaws.com/search"
ALERT_URL = "https://harperygxa.execute-api.eu-north-1.amazonaws.com/alert"
SUBSCRIPTION_URL = "https://harperygxa.execute-api.eu-north-1.amazonaws.com/subscribe"
CHATBOT_URL = "https://harperygxa.execute-api.eu-north-1.amazonaws.com/chatbot"

app = Flask(__name__)
Bootstrap5(app)
app.config["PREFERRED_URL_SCHEME"] = "http"
# app.config["PREFERRED_URL_SCHEME"] = "https" <- For when production domain is set up
app.config["SECRET_KEY"] = os.environ.get("FLASK_SECRET_KEY")
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)

# For Signup and Login
oauth = OAuth(app)
oauth.register(
    name="oidc",
    authority="https://cognito-idp.eu-north-1.amazonaws.com/eu-north-1_RUNNAH0Lw",
    client_id="2l31ncbok6dl0ob72bscurc1qp",
    server_metadata_url="https://cognito-idp.eu-north-1.amazonaws.com/eu-north-1_RUNNAH0Lw/.well-known/openid-configuration",
    client_kwargs={"scope": "email openid"},
)
##########


@app.route("/login")
def login():
    # Alternate option to redirect to /authorize
    redirect_uri = url_for("authorize", _external=True)
    return oauth.oidc.authorize_redirect(redirect_uri)
    # return oauth.oidc.authorize_redirect('https://flightsyte-ui-alb-1830812917.eu-north-1.elb.amazonaws.com/authorize')
    # https://flightsyte.auth.eu-north-1.amazoncognito.com/error?error=redirect_mismatch&client_id=2l31ncbok6dl0ob72bscurc1qp


@app.route("/authorize")
def authorize():
    token = oauth.oidc.authorize_access_token()
    user = token["userinfo"]
    session["user"] = user
    session["id_token"] = token["id_token"]
    get_flashed_messages()
    session.pop("_flashes", None)
    return redirect(url_for("home"))


def build_api_headers():
    id_token = session["id_token"]
    if not id_token:
        return None

    return {"Content-Type": "application/json", "Authorization": f"Bearer {id_token}"}


@app.route("/logout")
def logout():
    session.pop("user", None)
    return redirect(url_for("home"))


@app.route("/health")
def health():
    return "ok", 200


@app.route("/", methods=["GET", "POST"])
def home():
    form = FlightForm()
    user = session.get("user")

    if form.validate_on_submit() and not user:
        flash("You must be logged in to search for flights!", "danger")

    if user:
        if form.validate_on_submit():
            search_for_flight()
            return redirect(url_for("results"))

    return render_template("index.html", form=form, user=user, active_page="home")


@app.route("/flight_results")
def results():
    # Retrieve data from session
    flight_messages = session.get("flight_messages", [])
    structured_flights = session.get("structured_flights", [])
    search_params = session.get("details", {})
    return render_template(
        "results.html",
        flight_messages=flight_messages,
        structured_flights=structured_flights,
        search_params=search_params,
        user=session.get("user"),
    )


@app.route("/trip_alert", methods=["GET", "POST"])
def trip_alert():
    form = TripAlertForm()
    user = session.get("user")
    alerts = []
    if user:
        api_headers = build_api_headers()
        read_response = requests.get(url=ALERT_URL, headers=api_headers, timeout=30)

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
                    "to_date": str(form.to_date.data),
                }

                api_gateway_response = requests.post(
                    url=ALERT_URL, headers=api_headers, json=payload, timeout=30
                )
                if api_gateway_response.status_code == 200:
                    print(f"\n✅ {api_gateway_response.text}")
                    flash(
                        "Trip set successfully! You will be notified by email when it is found!"
                        "\nCheck the 'Live Trips' tab, to view your trip!",
                        "success",
                    )
                else:
                    print(f"\n❌ {api_gateway_response.text} ")
                    flash(f"{api_gateway_response.raise_for_status()}", "danger")

                return redirect(
                    url_for(
                        "trip_alert",
                        active_page="trip_alert",
                        form=form,
                        user=session.get("user"),
                        alerts=alerts,
                    )
                )
            except Exception as e:
                flash(f"Error: {e}")

    if request.method == "POST" and not user:
        flash("You must be logged in before creating alerts for flights.", "danger")

    return render_template(
        "trip_alert.html",
        active_page="trip_alert",
        form=form,
        user=session.get("user"),
        alerts=alerts,
    )


@app.route("/delete_alert/<alert_id>", methods=["GET", "POST"])
def delete_alert(alert_id):
    user = session.get("user")
    if user:
        api_headers = build_api_headers()
        payload = {"created_at": alert_id}
        api_gateway_response = requests.delete(
            url=ALERT_URL, headers=api_headers, json=payload, timeout=30
        )
        if api_gateway_response.status_code == 200:
            print(f"\n✅ {api_gateway_response.text}")
            flash("Alert delete successfully! ", "success")
        else:
            print(f"\n❌ {api_gateway_response.text} ")
            flash(f"{api_gateway_response.raise_for_status()}", "danger")
    return redirect(url_for("trip_alert"))


@app.route("/pricing")
def pricing():
    return render_template(
        "pricing.html", active_page="pricing", user=session.get("user")
    )


@app.route("/faq")
def faq():
    return render_template("faq.html", active_page="faq", user=session.get("user"))


@app.route("/statistics")
def statistics():
    return render_template(
        "statistics.html", active_page="statistics", user=session.get("user")
    )


@app.route("/contact", methods=["GET", "POST"])
def contact():
    form = SubscribeForm()
    if form.validate_on_submit():
        payload = {"email": form.email.data}
        api_gateway_response = requests.post(
            url=SUBSCRIPTION_URL,
            headers={
                "Content-Type": "application/json",
            },
            json=payload,
            timeout=30,
        )
        if api_gateway_response.status_code == 200:
            print(f"\n✅ {api_gateway_response.text}")
            flash(
                "Subscription successful!\n Please confirm your subscription in your emails to activate it!",
                "success",
            )
        else:
            print(f"\n❌ {api_gateway_response.text} ")
            flash(f"{api_gateway_response.raise_for_status()}", "danger")

    return render_template(
        "contact.html",
        active_page="contact",
        user=session.get("user"),
        subscribe_form=form,
    )


@app.route("/chat", methods=["POST"])
def chat():
    query = request.json["message"]

    response = requests.post(
        CHATBOT_URL,
        headers={
            "Content-Type": "application/json",
        },
        json={"message": query},
        timeout=60,
    )
    print(response.json())
    body = response.json()

    return jsonify(body)


def search_for_flight():
    form = FlightForm()
    offer_messages = None
    structured_flights = None
    try:
        api_headers = build_api_headers()
        payload = {
            "destination_city": form.destination_city.data,
            "origin_location": form.origin_location.data,
            "travel_class": form.travel_class.data,
            "adults": form.adults.data,
            "children": form.children.data,
            "infants": form.infants.data,
            "from_date": str(form.from_date.data),
            "to_date": str(form.to_date.data),
        }

        api_gateway_response = requests.post(
            url=SEARCH_URL, headers=api_headers, json=payload, timeout=30
        )

        if api_gateway_response.status_code == 200:
            try:
                response_json = api_gateway_response.json()
            except ValueError:
                print("❌ Invalid JSON from Lambda")
                response_json = {}

            offer_messages = response_json.get("messages", [])
            structured_flights = response_json.get("structured_flights", [])
            print("✅ Flights received from Lambda")
            print(structured_flights)

        else:
            print(f"❌ API error: {api_gateway_response.text}")
            offer_messages = []
            structured_flights = []

    except Exception as e:
        print(f"Error: {e}")

    session["flight_messages"] = offer_messages
    session["structured_flights"] = structured_flights
    session["details"] = {
        "origin": form.origin_location.data,
        "destination": form.destination_city.data,
        "adults": form.adults.data,
        "children": form.children.data,
        "infants": form.infants.data,
        "travel_class": form.travel_class.data,
        "departure_date": form.from_date.data.strftime("%Y-%m-%d"),
        "return_date": form.to_date.data.strftime("%Y-%m-%d"),
    }


if __name__ == "__main__":
    app.run(debug=True, port=5000, host="0.0.0.0")
