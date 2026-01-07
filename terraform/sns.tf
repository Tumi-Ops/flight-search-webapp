resource "aws_sns_topic" "flightsyte_sns_topic" {
  name = "FlightSyte"
}

resource "aws_sns_topic" "new_dummy_sns_topic" {
  name = "Dummy2"
}