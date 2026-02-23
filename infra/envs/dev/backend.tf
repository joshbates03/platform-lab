terraform {
  backend "gcs" {
    bucket = "tfstate-platform-lab-488015"
    prefix = "dev"
  }
}
