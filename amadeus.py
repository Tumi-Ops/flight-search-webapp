# This file harbors the amadeus API objects.
import os
from dotenv import load_dotenv

load_dotenv()
# trip-nav-link active
amadeus_apikey = os.environ["AMS_API_KEY"]
amadeus_api_secret = os.environ["AMS_API_SECRET"]
amadeus_token_endpoint = os.environ["AMADEUS_TOKEN_ENDPOINT"]
amadeus_token_params = {
    "grant_type": "client_credentials",
    "client_id": amadeus_apikey,
    "client_secret": amadeus_api_secret
}
amadeus_endpoint = os.environ["AMADEUS_FLIGHT_OFFERS"]
amadeus_cities_endpoint = os.environ["AMADEUS_CITIES_ENDPOINT"]
amadeus_locations_endpoint = os.environ["AMADEUS_LOCATIONS"]




