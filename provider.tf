provider "google" {
  credentials=file("gcp_auth_key.json")
  project="red-league-378004"
  region  = "us-west4"
  zone = "us-west4-b"
}
