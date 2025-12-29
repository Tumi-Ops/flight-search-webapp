# This class is responsible for talking to the Flight Search API.
import requests
import amadeus

class FlightSearch:
    def __init__(self, dm_data):
        self.layover_response = None
        self.ama_auth = None
        self.response = None
        self.flight_data = []
        self.dm_codes = dm_data.iata_codes

    def get_flights(self, ad, child, inf, tc, dep_date, ret_date):
        self.ama_auth = requests.post(url=amadeus.amadeus_token_endpoint, data=amadeus.amadeus_token_params, timeout=60)
        amadeus_header = {
            "accept": "application/vnd.amadeus+json",
            "Authorization": f"{self.ama_auth.json()['token_type']} {self.ama_auth.json()['access_token']}"
        }
        amadeus_params = {
            "originLocationCode": self.dm_codes[0]['from'],
            "destinationLocationCode": self.dm_codes[1]['to'],
            "departureDate": dep_date,
            "returnDate": ret_date,
            "adults": ad,
            "children": child,
            "infants": inf,
            "travelClass": tc,
            "max": 3,
            "currencyCode": "ZAR",
            "nonStop": "true"
        }
        self.response = requests.get(url=amadeus.amadeus_endpoint, params=amadeus_params, headers=amadeus_header, timeout=60)
        try:
            if self.response.status_code == 400:
                amadeus_params["nonStop"] = "false"
                self.layover_response = requests.get(url=amadeus.amadeus_endpoint, params=amadeus_params,
                                                     headers=amadeus_header, timeout=60)
                if self.layover_response.status_code == 400:
                    self.flight_data.append("Error: This resource does not exist. Skipping this request.")
                else:
                    self.flight_data.append(self.response.json())
            else:
                self.flight_data.append(self.response.json())
        except Exception as e:
            self.flight_data.append("Error Found, try again later. ")
            print(f"An unexpected error occurred: {e}")
        print(self.flight_data)
        # print(self.flight_data)
        # print(self.response.json())
        # self.flight_data = [{'meta': {'count': 1, 'links': {
        #     'self': 'https://test.api.amadeus.com/v2/shopping/flight-offers?originLocationCode=NYC&destinationLocationCode=PAR&departureDate=2025-10-02&returnDate=2025-10-04&adults=1&max=1&currencyCode=ZAR&nonStop=true'}},
        #                      'data': [
        #                          {'type': 'flight-offer', 'id': '1', 'source': 'GDS', 'instantTicketingRequired': False,
        #                           'nonHomogeneous': False, 'oneWay': False, 'isUpsellOffer': False,
        #                           'lastTicketingDate': '2025-10-02', 'lastTicketingDateTime': '2025-10-02',
        #                           'numberOfBookableSeats': 9, 'itineraries': [{'duration': 'PT4H', 'segments': [
        #                              {'departure': {'iataCode': 'JFK', 'at': '2025-10-02T10:00:00'},
        #                               'arrival': {'iataCode': 'CDG', 'at': '2025-10-02T20:00:00'}, 'carrierCode': '6X',
        #                               'number': '1563', 'aircraft': {'code': '744'}, 'operating': {'carrierCode': '6X'},
        #                               'duration': 'PT4H', 'id': '1', 'numberOfStops': 0, 'blacklistedInEU': False}]},
        #                                                                       {'duration': 'PT11H30M', 'segments': [{
        #                                                                                                                 'departure': {
        #                                                                                                                     'iataCode': 'ORY',
        #                                                                                                                     'at': '2025-10-04T13:30:00'},
        #                                                                                                                 'arrival': {
        #                                                                                                                     'iataCode': 'JFK',
        #                                                                                                                     'at': '2025-10-04T19:00:00'},
        #                                                                                                                 'carrierCode': '6X',
        #                                                                                                                 'number': '1390',
        #                                                                                                                 'aircraft': {
        #                                                                                                                     'code': '744'},
        #                                                                                                                 'operating': {
        #                                                                                                                     'carrierCode': '6X'},
        #                                                                                                                 'duration': 'PT11H30M',
        #                                                                                                                 'id': '2',
        #                                                                                                                 'numberOfStops': 0,
        #                                                                                                                 'blacklistedInEU': False}]}],
        #                           'price': {'currency': 'ZAR', 'total': '4334.00', 'base': '1220.00',
        #                                     'fees': [{'amount': '0.00', 'type': 'SUPPLIER'},
        #                                              {'amount': '0.00', 'type': 'TICKETING'}], 'grandTotal': '4334.00'},
        #                           'pricingOptions': {'fareType': ['PUBLISHED'], 'includedCheckedBagsOnly': False},
        #                           'validatingAirlineCodes': ['6X'], 'travelerPricings': [
        #                              {'travelerId': '1', 'fareOption': 'STANDARD', 'travelerType': 'ADULT',
        #                               'price': {'currency': 'ZAR', 'total': '4334.00', 'base': '1220.00'},
        #                               'fareDetailsBySegment': [
        #                                   {'segmentId': '1', 'cabin': 'ECONOMY', 'fareBasis': 'GLINKERS', 'class': 'G'},
        #                                   {'segmentId': '2', 'cabin': 'ECONOMY', 'fareBasis': 'GLINKERS',
        #                                    'class': 'G'}]}]}], 'dictionaries': {
        #         'locations': {'CDG': {'cityCode': 'PAR', 'countryCode': 'FR'},
        #                       'ORY': {'cityCode': 'PAR', 'countryCode': 'FR'},
        #                       'JFK': {'cityCode': 'NYC', 'countryCode': 'US'}}, 'aircraft': {'744': 'BOEING 747-400'},
        #         'currencies': {'ZAR': 'S.AFRICAN RAND'}, 'carriers': {'6X': 'AMADEUS SIX'}}}]

        # print(f"Flight Data: {self.flight_data}")
