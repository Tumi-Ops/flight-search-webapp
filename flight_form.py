from flask_wtf import FlaskForm
from wtforms import SelectField, StringField, SubmitField
from wtforms.fields.datetime import DateField
from wtforms.fields.numeric import IntegerField
from wtforms.validators import DataRequired, NumberRange


class FlightForm(FlaskForm):
    destination_city = StringField(
        "Destination City, e.g. Paris", validators=[DataRequired()]
    )
    origin_location = StringField(
        "Origin City, e.g. Johannesburg", validators=[DataRequired()]
    )
    adults = IntegerField(
        "No. of Adults (Age 13 or older)", validators=[NumberRange(min=0, max=9)]
    )
    children = IntegerField(
        "No. of Children (Ages 2 - 12)", validators=[NumberRange(min=0, max=9)]
    )
    infants = IntegerField(
        "No. of Infants (Ages under 2)", validators=[NumberRange(min=0, max=9)]
    )
    travel_class = SelectField(
        "Travel Class",
        choices=["ECONOMY", "PREMIUM_ECONOMY", "BUSINESS", "FIRST"],
        validators=[DataRequired()],
    )
    from_date = DateField("Departure Date", validators=[DataRequired()])
    to_date = DateField("Return Date", validators=[DataRequired()])
    submit = SubmitField(label="Check Flights")


class TripAlertForm(FlaskForm):
    destination_city = StringField(
        "Destination City, e.g. Paris", validators=[DataRequired()]
    )
    origin_location = StringField(
        "Origin City, e.g. Johannesburg", validators=[DataRequired()]
    )
    max_price = IntegerField(
        "Max Price willing to Pay", validators=[NumberRange(min=1000, max=100000)]
    )
    adults = IntegerField(
        "No. of Adults (Age 13 or older)", validators=[NumberRange(min=0, max=9)]
    )
    children = IntegerField(
        "No. of Children (Ages 2 - 12)", validators=[NumberRange(min=0, max=9)]
    )
    infants = IntegerField(
        "No. of Infants (Ages under 2)", validators=[NumberRange(min=0, max=9)]
    )
    from_date = DateField("Departure Date", validators=[DataRequired()])
    to_date = DateField("Return Date", validators=[DataRequired()])
    submit = SubmitField(label="Set Trip")


class SubscribeForm(FlaskForm):
    email = StringField("Email", validators=[DataRequired()])
    submit = SubmitField(label="Subscribe")
